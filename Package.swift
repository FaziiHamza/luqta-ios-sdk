// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "LuqtaSDK",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "LuqtaSDK", targets: ["LuqtaSDK"]),
    ],
    targets: [
        .binaryTarget(
            name: "LuqtaSDK",
            url: "https://github.com/FaziiHamza/luqta-ios-sdk/releases/download/1.4.1/LuqtaSDK.xcframework.zip",
            checksum: "ec3b1b17a883531dffee1d12ec92c453ad0fba2eb16d7f22fd5bc1d0a243699a"
        ),
    ]
)
