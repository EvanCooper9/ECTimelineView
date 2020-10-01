// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TimelineCollectionView",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "TimelineCollectionView",
            targets: ["TimelineCollectionView"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "TimelineCollectionView",
            dependencies: []
        ),
    ]
)
