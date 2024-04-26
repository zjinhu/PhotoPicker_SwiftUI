// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PhotoPicker_SwiftUI",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PhotoPicker_SwiftUI",
            targets: ["PhotoPicker_SwiftUI"]),
    ],
    dependencies: [
        .package(url: "https://gitee.com/zjinhu/brick.git", .upToNextMajor(from: "0.3.0")),
        .package(url: "https://gitee.com/zjinhu/pagertabstripview.git", .upToNextMajor(from: "0.0.1")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PhotoPicker_SwiftUI",
            dependencies: [
                .product(name: "BrickKit", package: "brick"), // 👈  Reference to a Local Package
                .product(name: "PagerTabStripView", package: "pagertabstripview"),
             ]),
    ]
)
package.platforms = [
    .iOS(.v14),
]
package.swiftLanguageVersions = [.v5]
