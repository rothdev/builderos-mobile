// swift-tools-version: 5.9
// Package.swift - BuilderOS iOS App Dependencies

import PackageDescription

let package = Package(
    name: "BuilderOS",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "BuilderOS",
            targets: ["BuilderOS"]
        )
    ],
    dependencies: [
        // Tailscale iOS SDK
        // Note: Tailscale iOS SDK is currently distributed via CocoaPods
        // For now, this is a placeholder for future SPM support
        // To integrate Tailscale, use CocoaPods or add the framework manually
        //
        // Installation via CocoaPods:
        // pod 'Tailscale', '~> 1.88.0'
        //
        // Alternative: Download Tailscale.xcframework from:
        // https://github.com/tailscale/tailscale-ios/releases
    ],
    targets: [
        .target(
            name: "BuilderOS",
            dependencies: [],
            path: "src"
        )
    ]
)
