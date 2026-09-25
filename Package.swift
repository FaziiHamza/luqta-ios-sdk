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
            url: "https://github.com/FaziiHamza/luqta-ios-sdk/releases/download/1.5.0/LuqtaSDK.xcframework.zip",
            checksum: "205163522df2eee3ac64bfe7d6c2bc1207e588eaa128f8c071a8de9eca508932"
        ),
    ]
)
