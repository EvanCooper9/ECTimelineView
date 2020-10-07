// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ECTimelineView",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "ECTimelineView",
            targets: ["ECTimelineView"]),
    ],
    targets: [
        .target(
            name: "ECTimelineView",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "ECTimelineViewTests",
            dependencies: ["ECTimelineView"],
            path: "Tests"
        ),
    ]
)
