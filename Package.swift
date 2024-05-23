// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PhotoPicker_SwiftUI",
    defaultLocalization: "en",
    products: [
        .library(
            name: "PhotoPicker_SwiftUI",
            targets: ["PhotoPicker_SwiftUI"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/zjinhu/Brick_SwiftUI.git", .upToNextMajor(from: "0.3.0")),
        .package(url: "https://github.com/zjinhu/PagerTabStripView.git", .upToNextMajor(from: "0.0.1"))
    ],
    targets: [
        .target(name: "PhotoPicker_SwiftUI",
                dependencies:
                    [
                        .product(name: "BrickKit", package: "Brick_SwiftUI"),
                        .product(name: "PagerTabStripView", package: "PagerTabStripView")
                    ],
                resources: [.process("Resources")]
               ),
    ]
)
package.platforms = [
    .iOS(.v14),
]
package.swiftLanguageVersions = [.v5]

