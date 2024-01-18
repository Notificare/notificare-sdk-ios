// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Notificare",
    platforms: [
        .iOS(.v13),
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
            name: "NotificareGeoKit",
            targets: ["NotificareGeoKit"]
        ),
        .library(
            name: "NotificareInAppMessagingKit",
            targets: ["NotificareInAppMessagingKit"]
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
            name: "NotificareMonetizeKit",
            targets: ["NotificareMonetizeKit"]
        ),
        .library(
            name: "NotificareNotificationServiceExtensionKit",
            targets: ["NotificareNotificationServiceExtensionKit"]
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
        .library(
            name: "NotificareUserInboxKit",
            targets: ["NotificareUserInboxKit"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "NotificareKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.7.0/spm-notificare.zip",
            checksum: "e69377f2aa127a9092fe600174ad6c0e25f208c349404eb32eaf5d0d2c0521e0"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.7.0/spm-notificare-assets.zip",
            checksum: "e770a0fdf190758b3eff32d4a95f1216acb55ec7eb1bc65ad0857311213e01c1"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.7.0/spm-notificare-geo.zip",
            checksum: "0d39575c55ad0a1e848ecede89f58b2e87c713f26c10ce4efd35676f6348130d"
        ),
        .binaryTarget(
            name: "NotificareInAppMessagingKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.7.0/spm-notificare-in-app-messaging.zip",
            checksum: "5e11c958c94ce7a46ed5d71b7020c67da6e0dac5265750ea710c392830a120ed"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.7.0/spm-notificare-inbox.zip",
            checksum: "69afe07101c120c42ff401286c18e03ff5b0c42b0c9f0942fb1d2b6bdcda61ab"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.7.0/spm-notificare-loyalty.zip",
            checksum: "edfddf0fdea93b0fcd3c4350d522805c877c28dc7e2f6e547534bbabb58bf9c7"
        ),
        .binaryTarget(
            name: "NotificareMonetizeKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.7.0/spm-notificare-monetize.zip",
            checksum: "0d33f6cde19b44c4091e6214d189b374b7f1e9e4af5ed9db0ce3cde7fbb78de4"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.7.0/spm-notificare-push.zip",
            checksum: "a4564eadd90d9e0841d13d8fd98bac2e9dad3837132917e5fc9ef38fefd10ac9"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.7.0/spm-notificare-notification-service-extension.zip",
            checksum: "055d6f1b476876181af64c134a942edd1fa25f236dd33d8560ddff7bd2d03fc2"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.7.0/spm-notificare-push-ui.zip",
            checksum: "2191a7ddd3fba006b7c5327e79f6909fd0b1ec993c7c604401066b1969a78db5"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.7.0/spm-notificare-scannables.zip",
            checksum: "598ced9010945fa733ac7f0952da9e700ef30df7d07c997f1a8e74dd7c175fdc"
        ),
        .binaryTarget(
            name: "NotificareUserInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.7.0/spm-notificare-user-inbox.zip",
            checksum: "cb8f0d2d8d66aa8d22fc688f2666ce85531e427afecbf9470520bf1138f0402d"
        ),
    ]
)
