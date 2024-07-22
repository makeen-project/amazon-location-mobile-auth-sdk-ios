// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AmazonLocationiOSAuthSDK",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "AmazonLocationiOSAuthSDK",
            type: .dynamic,
            targets: ["AmazonLocationiOSAuthSDK"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/evgenyneu/keychain-swift.git", from: "20.0.0"),
        .package(url: "https://github.com/awslabs/aws-sdk-swift", branch: "0.46.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
                    name: "AmazonLocationiOSAuthSDK",
                    dependencies: [
                        .product(name: "KeychainSwift", package: "keychain-swift"),
                        .product(name: "AWSLocation", package: "aws-sdk-swift"),
                        .product(name: "AWSCognitoIdentity", package: "aws-sdk-swift"),
                        .product(name: "AWSClientRuntime", package: "aws-sdk-swift")
                        // Add other AWS services as needed
                    ],
                    path: "Sources"),
        .testTarget(
            name: "AmazonLocationiOSAuthSDKTests",
            dependencies: ["AmazonLocationiOSAuthSDK"],
            resources: [
                .process("TestConfig.plist")
            ]),
    ]
)
