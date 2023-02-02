// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WebViewSwiftUI",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "WebViewSwiftUI",
            targets: ["WebViewSwiftUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/hassanvfx/ios-vendor-Lux", exact: "1.2.7")
    ],
    targets: [
        .target(
            name: "WebViewSwiftUI",
            dependencies: [
                .product(name: "Lux", package: "ios-vendor-Lux")
            ]),
        .testTarget(
            name: "WebViewSwiftUITests",
            dependencies: ["WebViewSwiftUI"]),
    ]
)
