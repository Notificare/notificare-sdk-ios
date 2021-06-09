// swift-tools-version:5.3

import PackageDescription

let version = "3.0.0-alpha.1"

let package = Package(
    name: "Notificare",
    platforms: [
        .iOS(.v10),
    ],
    products: [
        .library(
            name: "NotificareKit",
            targets: ["NotificareKit"]
        ),
        .library(
            name: "NotificareInboxKit",
            targets: ["NotificareInboxKit"]
        ),
        .library(
            name: "NotificarePushKit",
            targets: ["NotificarePushKit"]
        ),
        .library(
            name: "NotificarePushUIKit",
            targets: ["NotificarePushUIKit"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "NotificareKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/\(version)/NotificareKit.zip",
            checksum: "f733c5a98609c98ddaec9938c4ee096b070162aacd02b5a5d9b64102fa1a942f"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/\(version)/NotificareInboxKit.zip",
            checksum: "172444e3118290e8c8f0e8c52a0aeaf116a0d554ba1e69e4d01c6dc77d38d700"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/\(version)/NotificarePushKit.zip",
            checksum: "d503151c8bd23abd892246dcdddbd02cb8b1ff7ad9a562697c9c2f20e3fcc37a"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/\(version)/NotificarePushUIKit.zip",
            checksum: "691bd7d68e1a5eefcf698d580c847ba3b94cc2c6177d293868f9c54180fbbd37"
        ),
    ]
)
