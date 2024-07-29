// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RadioBrowser",
    platforms: [
        .macOS(.v11),
        .iOS(.v15)
    ],
    products: [
        .library(name: "RadioBrowser", targets: ["RadioBrowser"])
    ],
    dependencies: [
        .package(url: "https://github.com/ShapovalovIlya/SwiftFP.git", branch: "main")
    ],
    targets: [
        
        .target(
            name: "RadioBrowser",
            dependencies: [
                .product(name: "SwiftFP", package: "SwiftFP")
            ]
        ),
        .testTarget(
            name: "RadioBrowserTests",
            dependencies: ["RadioBrowser"]
        ),
    ]
)
