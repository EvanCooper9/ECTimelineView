// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ECTimelineView",
    products: [
        .library(
            name: "ECTimelineView",
            targets: ["ECTimelineView"]),
    ],
    dependencies: [
        .package(url: "https://github.com/EvanCooper9/ECUICollectionViewMultiDelegate", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "ECTimelineView",
            dependencies: [
                .init(stringLiteral: "ECUICollectionViewMultiDelegate")
            ],
            path: "Sources"
        )
    ]
)
