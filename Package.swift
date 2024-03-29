// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CrystalCardKit",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "CrystalCardKit",
            targets: ["CrystalCardKit"]),
    ],
    dependencies: [
        .package(name: "CrystalButtonKit", url: "https://github.com/robhasacamera/CrystalButtonKit.git", from: "1.0.6"),
        .package(name: "CrystalViewUtilities", url: "https://github.com/robhasacamera/CrystalViewUtilities.git", from: "0.12.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CrystalCardKit",
            dependencies: ["CrystalButtonKit", "CrystalViewUtilities"]),
        .testTarget(
            name: "CrystalCardKitTests",
            dependencies: ["CrystalCardKit"]),
    ]
)
