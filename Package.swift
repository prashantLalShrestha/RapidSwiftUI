// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RapidSwiftUI",
    platforms: [.iOS(.v13), .macOS(.v10_15), .tvOS(.v13), .watchOS(.v6)],
    products: [
        .library(
            name: "RapidSwiftUI",
            targets: ["RapidSwiftUI"]
        ),
    ],
    dependencies: [
        .package(name: "Introspect", url: "https://github.com/siteline/SwiftUI-Introspect.git", from: "0.1.3")
    ],
    targets: [
        .target(
            name: "RapidSwiftUI",
            dependencies: ["Introspect"],
            path: "Sources"
        ),
        .testTarget(
            name: "RapidSwiftUITests",
            dependencies: ["RapidSwiftUI"]
        ),
    ]
)
