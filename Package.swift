// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PhotoPicker_SwiftUI",
    defaultLocalization: "en",
    products: [
        .library(
            name: "PhotoPicker_SwiftUI",
            targets: ["PhotoPickerSwiftUI","PhotoPickerCore"]
        ),
        .library(
            name: "PhotoPickerKit",
            targets: ["PhotoPickerUIKit","PhotoPickerCore"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/zjinhu/Brick_SwiftUI.git", .upToNextMajor(from: "0.3.0")),
        .package(url: "https://github.com/zjinhu/PagerTabStripView.git", .upToNextMajor(from: "0.0.1")),
        .package(url: "https://github.com/pujiaxin33/JXSegmentedView.git", .upToNextMajor(from: "1.3.3")),
    ],
    targets: [
//        .target(name: "PhotoPicker_SwiftUI",
//                dependencies:
//                    [
//                        .product(name: "BrickKit", package: "Brick_SwiftUI"),
//                        .product(name: "PagerTabStripView", package: "PagerTabStripView"),
//                        .product(name: "JXSegmentedView", package: "JXSegmentedView"),
//                    ],
//                resources: [.process("Resources")]
//               ),
        .target(name: "PhotoPickerCore",
                dependencies:
                    [
                        .product(name: "BrickKit", package: "Brick_SwiftUI")
                    ],
                path: "Sources/PhotoPicker_SwiftUI/PhotoPickerCore",
                resources: [.process("Resources")]
               ),
        .target(name: "PhotoPickerSwiftUI",
                dependencies:
                    [
                        .target(name: "PhotoPickerCore"),
                        .product(name: "PagerTabStripView", package: "PagerTabStripView")
                    ],
                path: "Sources/PhotoPicker_SwiftUI/PhotoPickerSwiftUI"
               ),
        .target(name: "PhotoPickerUIKit",
                dependencies:
                    [
                        .target(name: "PhotoPickerCore"),
                        .product(name: "JXSegmentedView", package: "JXSegmentedView")
                    ],
                path: "Sources/PhotoPicker_SwiftUI/PhotoPickerUIKit"
               )
    ]
)
package.platforms = [
    .iOS(.v14),
]
package.swiftLanguageVersions = [.v5]

