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
            url: "https://github.com/FaziiHamza/luqta-ios-sdk/releases/download/1.6.0/LuqtaSDK.xcframework.zip",
            checksum: "47e81f970704c8ffccbbd1cda2d01ebc0e64d9d1d059dc6c3123be957bbdf00a"
        ),
    ]
)
