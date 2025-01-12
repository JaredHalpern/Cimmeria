// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Cimmeria",
    products: [
        // Products define the executables and libraries a package produces, 
        // making them visible to other packages.
        .library(name: "CimmeriaNet", targets: ["CimmeriaNet"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Cimmeria"),
        .testTarget(
            name: "CimmeriaTests",
            dependencies: ["Cimmeria"]),
        .target(
            name: "CimmeriaNet"),
        .testTarget(
            name: "CimmeriaNetTests",
            dependencies: ["Cimmeria"]),
    ]
)
