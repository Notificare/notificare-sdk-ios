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
            name: "NotificareAssetsKit",
            targets: ["NotificareAssetsKit"]
        )
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
            checksum: "aaf82e40d99f0e5fef7ffbe3bc079447a6f1459e1b75165d8073e68fe6747969"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/\(version)/NotificareAssetsKit.zip",
            checksum: "---"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/\(version)/NotificareInboxKit.zip",
            checksum: "4b7aeaf46d59bc5a2c22dddfd8220ce9393d2a41764119b79513335fea4408d8"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/\(version)/NotificarePushKit.zip",
            checksum: "2a572af2a2ccd035d1deca9c1b8f904a9ea3f5cf2b9c27fb74209912171f7b1e"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/\(version)/NotificarePushUIKit.zip",
            checksum: "7ca0840aaf1c48b9b3658314a97056a946609cab9ccf61be942ce9172a255b77"
        ),
    ]
)
