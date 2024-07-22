#!/bin/bash

# Function to check if a command is available
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for tee
if ! command_exists tee; then
    echo "Error: tee is not installed. Please install it and try again."
    exit 1
fi

# Check for xcpretty
if ! command_exists xcpretty; then
    echo "xcpretty not found, installing..."
    gem install xcpretty
    if [ $? -ne 0 ]; then
        echo "Error: Failed to install xcpretty. Please install it manually and try again."
        exit 1
    fi
fi

PACKAGE_DIRECTORY=""
SCHEME="AmazonLocationiOSAuthSDK"
FRAMEWORK_RELATIVE_DIRECTORY=".packages"
CONFIGURATION=Release
BUILD_FOLDER=".build"
FRAMEWORK_OUTPUT_DIRECTORY="frameworks"

# Value is ignored, only the definition of the variable is considered
export SPM_GENERATE_FRAMEWORK=1
buildframework() {

echo "FRAMEWORK_DIRECTORY: $FRAMEWORK_DIRECTORY"
echo "Step #1"
    BUILD_PATH="$FRAMEWORK_DIRECTORY/${CONFIGURATION}-${3}"

    xcodebuild -scheme "$1" \
    -destination "$2" \
    -sdk "$3" \
    -configuration "$CONFIGURATION" \
    -derivedDataPath "${FRAMEWORK_DIRECTORY}/.build" \
    SYMROOT="$FRAMEWORK_DIRECTORY" \
        SKIP_INSTALL=NO \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
        OTHER_SWIFT_FLAGS="-no-verify-emitted-module-interface" \
        | tee "${FRAMEWORK_DIRECTORY}/.build/xcodebuild.log" | xcpretty

echo "Step #2"

    BUILD_FRAMEWORK_PATH="$BUILD_PATH/PackageFrameworks/${SCHEME}.framework"
    BUILD_FRAMEWORK_HEADERS="$BUILD_FRAMEWORK_PATH/Headers"
echo "BUILD_FRAMEWORK_HEADERS: $BUILD_FRAMEWORK_HEADERS"
    mkdir -p "$BUILD_FRAMEWORK_HEADERS"
    SWIFT_HEADER="${FRAMEWORK_DIRECTORY}/.build/Build/Intermediates.noindex/$1.build/${CONFIGURATION}-${3}/$1.build/Objects-normal/arm64/${1}-Swift.h"

    if [ -f "$SWIFT_HEADER" ]; then
        cp -p "$SWIFT_HEADER" "$BUILD_FRAMEWORK_HEADERS" || exit -2
    fi

echo "Step #3"
echo "# Copy package headers (if any) to generated framework"
    PACKAGE_INCLUDE_DIRS=$(find "$PACKAGE_DIRECTORY" -path "*/Sources/*/include" -type d)

    if [ -n "$PACKAGE_INCLUDE_DIRS" ]; then
        cp -prv "$PACKAGE_DIRECTORY"/Sources/*/include/* "$BUILD_FRAMEWORK_HEADERS" || exit -2
    fi

echo "Step #4"    
echo "# Handle swiftmodule or modulemap file"
    mkdir -p "$BUILD_FRAMEWORK_PATH/Modules"
    
    SWIFT_MODULE_DIRECTORY="$BUILD_PATH/${1}.swiftmodule"
    
    if [ -d "$SWIFT_MODULE_DIRECTORY" ]; then
        cp -prv "$SWIFT_MODULE_DIRECTORY" "$BUILD_FRAMEWORK_PATH/Modules"
    else
    echo "Step #4.1" 
    echo "# Create module.modulemap file"
        echo "framework module $SCHEME {
umbrella \"Headers\"
export *

module * { export * }
}" > "$BUILD_FRAMEWORK_PATH/Modules/module.modulemap"
    fi

    # Copy bundle
    BUNDLE_DIRECTORY="$BUILD_PATH/${1}_${1}.bundle"
    if [ -d "$BUNDLE_DIRECTORY" ]; then
        cp -prv "$BUNDLE_DIRECTORY" "$BUILD_FRAMEWORK_PATH"
    fi
}

echo $FRAMEWORK_RELATIVE_DIRECTORY

rm -rf "$FRAMEWORK_RELATIVE_DIRECTORY/$BUILD_FOLDER/Build"
mkdir -p "$FRAMEWORK_RELATIVE_DIRECTORY"
FRAMEWORK_DIRECTORY=$(readlink -f "$FRAMEWORK_RELATIVE_DIRECTORY")
echo "FRAMEWORK_DIRECTORY: ${FRAMEWORK_DIRECTORY}"

echo "1# Building iphonesimulator"
buildframework "$SCHEME" "generic/platform=iOS Simulator" "iphonesimulator"

echo "2# Building iphoneos"
buildframework "$SCHEME" "generic/platform=iOS" "iphoneos"

echo "Step #5"    
echo "# Creating XCFramework"
rm -rf "$FRAMEWORK_OUTPUT_DIRECTORY"

xcodebuild -create-xcframework \
    -framework "${FRAMEWORK_DIRECTORY}/${CONFIGURATION}-iphoneos/PackageFrameworks/${SCHEME}.framework" \
    -framework "${FRAMEWORK_DIRECTORY}/${CONFIGURATION}-iphonesimulator/PackageFrameworks/${SCHEME}.framework" \
    -output "${FRAMEWORK_OUTPUT_DIRECTORY}/${SCHEME}.xcframework"
