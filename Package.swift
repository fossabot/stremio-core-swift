// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StremioCore",
    platforms: [
        .macCatalyst(.v13),
        .iOS(.v12),
    ],
    products: [
        .library(
            name: "StremioCore",
            targets: ["StremioCore", "XCFramework"]),
    ], dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.0.0"),
    ],
    targets: [
        .target(name: "Wrapper", dependencies: []),
        .target(name: "StremioCore",
                        dependencies: [
                            "Wrapper",
                            .product(name: "SwiftProtobuf", package: "swift-protobuf")
                ]),
        //.binaryTarget(name: "XCFramework", path: ".build/StremioCore.xcframework")
        .binaryTarget(name: "XCFramework", url: "https://github.com/Stremio/stremio-core-swift/releases/download/1.2.4/StremioCore.zip", checksum: "6a51b06b8734ddb9d7121813cddb8b5c8f1ee7929cfc8aa16f9ecef4f785a795")
    ]
)
