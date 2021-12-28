// swift-tools-version:5.3

import PackageDescription

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
        ),
        .library(
            name: "NotificareAuthenticationKit",
            targets: ["NotificareAuthenticationKit"]
        ),
        .library(
            name: "NotificareGeoKit",
            targets: ["NotificareGeoKit"]
        ),
        .library(
            name: "NotificareInboxKit",
            targets: ["NotificareInboxKit"]
        ),
        .library(
            name: "NotificareLoyaltyKit",
            targets: ["NotificareLoyaltyKit"]
        ),
        .library(
            name: "NotificarePushKit",
            targets: ["NotificarePushKit"]
        ),
        .library(
            name: "NotificarePushUIKit",
            targets: ["NotificarePushUIKit"]
        ),
        .library(
            name: "NotificareScannablesKit",
            targets: ["NotificareScannablesKit"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "NotificareKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.0-beta.1/NotificareKit.zip",
            checksum: "7674dd9cc33a7775d760206526ab0f43816d976e97790b3e17ee951e81d81d91"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.0-beta.1/NotificareAssetsKit.zip",
            checksum: "c7fcc64c3e521afcb2a3ffba4696798266dac39ca40992995eadaf28a2564052"
        ),
        .binaryTarget(
            name: "NotificareAuthenticationKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.0-beta.1/NotificareAuthenticationKit.zip",
            checksum: "cd47132dc0668ab1b5ae1cc207dbee1002475b25e1e7f82925c2d6e0cf3c9026"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.0-beta.1/NotificareGeoKit.zip",
            checksum: "a5722e1f1904a3c0aecafbf6f790f046debfa8b6b95e01215138d3617edf6c56"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.0-beta.1/NotificareInboxKit.zip",
            checksum: "d576a281816dea00a43aa5256ac718edc8c438f0d74f6c2efe7eb6b26cc1fea7"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.0-beta.1/NotificareLoyaltyKit.zip",
            checksum: "7d2b78070ea48de78c721918cbcfea764fac1d0ec7662b64a17999e180ced6bf"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.0-beta.1/NotificarePushKit.zip",
            checksum: "4e8060ab48e5076da52f895ddbaf4b1560f91ee210b79101fa1c3dc42405b885"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.0-beta.1/NotificarePushUIKit.zip",
            checksum: "0909324a0f1e7ab7588976560c44a6f03178a064d51b352c0142aeed286116ec"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.0-beta.1/NotificareScannablesKit.zip",
            checksum: "906031fa1bd69baa1dd88cd93c4f689c63749e4893c8e99ff98f7df5d7aff6c2"
        ),
    ]
)
