// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CrystalWindowKit",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "CrystalWindowKit",
            targets: ["CrystalWindowKit"]),
    ],
    dependencies: [
        .package(name: "CrystalButtonKit", url: "https://github.com/robhasacamera/CrystalButtonKit.git", from: "1.0.5"),
        .package(name: "CrystalViewUtilities", url: "https://github.com/robhasacamera/CrystalViewUtilities.git", from: "0.2.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CrystalWindowKit",
            dependencies: ["CrystalButtonKit", "CrystalViewUtilities"]),
        .testTarget(
            name: "CrystalWindowKitTests",
            dependencies: ["CrystalWindowKit"]),
    ]
)
