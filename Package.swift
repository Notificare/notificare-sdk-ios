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
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.0-beta.1/spm-notificare.zip",
            checksum: "c1dbd94a88c4c617e8c6ef7ca23ef30f69f48803e6f198522153e461265f8cbf"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.0-beta.1/spm-notificare-assets.zip",
            checksum: "d8f475999f664c445dbcbd26af19afa56e4d33d1dc734718f28b140b255b29ff"
        ),
        .binaryTarget(
            name: "NotificareAuthenticationKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.0-beta.1/spm-notificare-authentication.zip",
            checksum: "852f2d5ef712d0bbba89cb91ed86a6a2c3f6e3509534ea4537b6f825229019bc"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.0-beta.1/spm-notificare-geo.zip",
            checksum: "140346f0d5f0637796ebdcc2785a840eccecdb11c023b89815dd13ef3f300bc7"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.0-beta.1/spm-notificare-inbox.zip",
            checksum: "fb3bd3134c323599d0e585f24e22835ff6b58839debe70d373d9e4cb67e77fcf"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.0-beta.1/spm-notificare-loyalty.zip",
            checksum: "c8193f6e1642c06f7822c6a44e75b5eac8b53dfff52663bc971ba054719cc45a"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.0-beta.1/spm-notificare-push.zip",
            checksum: "1c561294631952a92ef0fe715046ade3a15394e7d2864673299138d411112836"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.0-beta.1/spm-notificare-push-ui.zip",
            checksum: "d06c34d2402d7184936a0ddeb3cc83e90ae7a7986ca4696ecdc4cb9a1a5ec914"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.0-beta.1/spm-notificare-scannables.zip",
            checksum: "c6efd5be201cb9798a0f9987fddeebb9c7eb1a2ad50cafaf947f6838b18fda90"
        ),
    ]
)
