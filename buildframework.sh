#!/bin/bash

PROJECT_NAME="AmazonLocationiOSAuthFramework"
PRODUCT_NAME="AmazonLocationiOSAuthSDK"
PROJECT_DIR="./Packages/${PROJECT_NAME}" # Relative path to the directory containing the `Package.swift` file
BUILD_FOLDER="./build"
OUTPUT_DIR="${PROJECT_DIR}/Output"
SIMULATOR_ARCHIVE="${OUTPUT_DIR}/${PROJECT_NAME}-iphonesimulator.xcarchive"
DEVICE_ARCHIVE="${OUTPUT_DIR}/${PROJECT_NAME}-iphoneos.xcarchive"

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Function to copy .swiftmodule directories
copy_swiftmodule() {
  SRC_ARCHIVE_PATH=$1
  DST_FRAMEWORK_PATH=$2
  #ARCHIVE_MODULE_PATH= $SRC_ARCHIVE_PATH #"$SRC_ARCHIVE_PATH/Products/Library/Frameworks/${PROJECT_NAME}.framework/Modules"
echo "SRC_ARCHIVE_PATH"
echo $SRC_ARCHIVE_PATH

echo "DST_FRAMEWORK_PATH"
echo $DST_FRAMEWORK_PATH

  # Find all .swiftmodule directories in the source archive path
  find $SRC_ARCHIVE_PATH -type d -name "*.swiftmodule" | while read -r SWIFTMODULE_DIR; do
  RELATIVE_PATH=$(basename "$SWIFTMODULE_DIR")
    # RELATIVE_PATH=$(realpath --relative-to=$SRC_ARCHIVE_PATH "$SWIFTMODULE_DIR")
    echo "DST_FRAMEWORK_PATH"
    echo $DST_FRAMEWORK_PATH

    DST_DIR="$DST_FRAMEWORK_PATH/$RELATIVE_PATH"

    echo " copying... SWIFTMODULE_DIR:"
    echo $SWIFTMODULE_DIR

    echo "to DST_DIR:"
    echo $DST_DIR



    mkdir -p "$DST_DIR"
    cp -R "$SWIFTMODULE_DIR"/* "$DST_DIR/"
  done
}

echo "# 2 iterations: 1 for device arch and another for simulator arch"
for PLATFORM in "iOS Simulator"; do
    case $PLATFORM in
      "iOS")
        ARCHIVE=$DEVICE_ARCHIVE
        SDK=iphoneos
        RELEASE_FOLDER="Release-iphoneos"
      ;;
      "iOS Simulator")
        ARCHIVE=$SIMULATOR_ARCHIVE
        SDK=iphonesimulator
        RELEASE_FOLDER="Release-iphonesimulator"
      ;;
    esac

    echo "# Step 2"
    xcodebuild archive \
      -workspace AmazonLocationiOSAuthWorkspace.xcworkspace \
      -scheme AmazonLocationiOSAuthFramework \
      -configuration Release \
      -destination="generic/platform=${PLATFORM}" \
      -archivePath $ARCHIVE \
      -sdk $SDK \
      -derivedDataPath $BUILD_FOLDER \
      SKIP_INSTALL=NO \
      BUILD_LIBRARY_FOR_DISTRIBUTION=NO

    FRAMEWORK_PATH="${ARCHIVE}/Products/Library/Frameworks/${PROJECT_NAME}.framework"
    MODULES_PATH="$FRAMEWORK_PATH/Modules"
    mkdir -p $MODULES_PATH

    BUILD_PRODUCTS_PATH="${BUILD_FOLDER}/Build/Intermediates.noindex/ArchiveIntermediates/${PROJECT_NAME}/BuildProductsPath"
    RELEASE_PATH="${BUILD_PRODUCTS_PATH}/${RELEASE_FOLDER}"
    SWIFT_MODULE_PATH="${RELEASE_PATH}/${PRODUCT_NAME}.swiftmodule"
    RESOURCES_BUNDLE_PATH="${RELEASE_PATH}/${PRODUCT_NAME}.bundle"

    echo "# Step 3"

    echo "ARCHIVE"
    echo $ARCHIVE

    echo "FRAMEWORK_PATH"
    echo $FRAMEWORK_PATH

    # Copy swiftmodule directories
    copy_swiftmodule $RELEASE_PATH $MODULES_PATH

    # if [ -d $SWIFT_MODULE_PATH ]; then
    #   echo "copying..."
    #   cp -r $SWIFT_MODULE_PATH $MODULES_PATH
    # else
    #   echo "Swift module directory does not exist. Skipping header copy."
    # fi

    echo "# Step 4"
    echo "RESOURCES_BUNDLE_PATH"
    echo $RESOURCES_BUNDLE_PATH 
    echo "FRAMEWORK_PATH"
    echo $FRAMEWORK_PATH 

    echo "# Step 4.1"
    if [ -e $RESOURCES_BUNDLE_PATH ]; then
      echo "# Step 4.2"
      cp -r $RESOURCES_BUNDLE_PATH $FRAMEWORK_PATH
    fi



done

echo "# Step 5"

xcodebuild -create-xcframework \
 -framework "${SIMULATOR_ARCHIVE}/Products/Library/Frameworks/${PROJECT_NAME}.framework" \
 -output "${OUTPUT_DIR}/${PROJECT_NAME}.xcframework"

 #-framework "${DEVICE_ARCHIVE}/Products/Library/Frameworks/${PROJECT_NAME}.framework" \