// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AOC2020",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .executable(
            name: "AOC2020",
            targets: ["AOC2020"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/dexman/AdventOfCodeUtils/", from: "0.0.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "AOC2020",
            dependencies: [
                "AdventOfCodeUtils",
            ],
            resources: [
                .copy("day01.txt"),
                .copy("day02.txt"),
                .copy("day03.txt"),
            ]
        ),
    ]
)
