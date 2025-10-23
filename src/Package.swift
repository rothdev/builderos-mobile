// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "BuilderSystemMobile",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .executable(
            name: "BuilderSystemMobile",
            targets: ["BuilderSystemMobile"]),
    ],
    dependencies: [
        .package(url: "https://github.com/NMSSH/NMSSH", from: "2.3.0")
    ],
    targets: [
        .executableTarget(
            name: "BuilderSystemMobile",
            dependencies: ["NMSSH"],
            path: "BuilderSystemMobile"),
        .testTarget(
            name: "BuilderSystemMobileTests",
            dependencies: ["BuilderSystemMobile"],
            path: "BuilderSystemMobileTests"),
    ]
)