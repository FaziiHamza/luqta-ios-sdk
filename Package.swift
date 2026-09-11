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
            url: "https://github.com/FaziiHamza/luqta-ios-sdk/releases/download/1.4.0/LuqtaSDK.xcframework.zip",
            checksum: "966df5d7cfd75db13949c5c736fa77823c2be7408ec4810c84be541a44300a7c"
        ),
    ]
)
