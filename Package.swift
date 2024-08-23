// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
let sha256 = "c6212fd5e111080ffb4ea2e1501b0a09b2c5e780b3ff63de86ac8184a75674c5";
let url = "https://github.com/Stremio/stremio-core-swift/releases/download/1.2.61/StremioCore.xcframework.zip";

import PackageDescription

let package = Package(
    name: "StremioCore",
    platforms: [
        .macCatalyst(.v13),
        .iOS(.v12),
        .visionOS(.v1),
        .tvOS(.v12)
    ],
    products: [
        .library(
            name: "StremioCore",
            targets: ["StremioCore", "XCFramework"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.0.0"),
    ],
    targets: [
        .target(name: "StremioCore",
                dependencies: ["Wrapper", .product(name: "SwiftProtobuf", package: "swift-protobuf")], plugins: [
                    .plugin(name: "SwiftProtobufPlugin", package: "swift-protobuf")
                ]),
        .target(name: "Wrapper", dependencies: []),
        .binaryTarget(name: "XCFramework", path: ".build/StremioCore.xcframework")
        //.binaryTarget(name: "XCFramework", url: url, checksum: sha256)
    ]
)
