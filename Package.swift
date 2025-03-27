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
        .package(url: "https://github.com/zjinhu/Brick_SwiftUI.git", .upToNextMajor(from: "0.7.3")),
    ],
    targets: [
        .target(name: "PhotoPicker_SwiftUI",
                dependencies:
                    [
                        .product(name: "BrickKit", package: "Brick_SwiftUI"),
                    ],
                resources: [.process("Resources")]
               ),
    ]
)
package.platforms = [
    .iOS(.v15),
]
package.swiftLanguageVersions = [.v5]

