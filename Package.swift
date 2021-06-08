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
            checksum: "176402bf2cfceac38884bef0572e0c7b08e2c17da60ceb5963bc9b83f27684bf"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/\(version)/NotificareInboxKit.zip",
            checksum: "db7363b136ffa548b867b17eeffc093680a4c42739c06158369dba0847850687"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/\(version)/NotificarePushKit.zip",
            checksum: "f822371eb5918a9b8441ed0ad1ce0f936de3b7e38da2b920c47fccaf76cf1876"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/\(version)/NotificarePushUIKit.zip",
            checksum: "8a98499104a6d75381cd054fd7251394874149b5ddd2636fcc077fcfd1f7cb44"
        ),
    ]
)
