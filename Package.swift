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
    ],
    targets: [
        .binaryTarget(
            name: "NotificareKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.3.0/spm-notificare.zip",
            checksum: "4ca9e41ad57c84d57d5458c6a0b3067887fc8dff615179a3f5f4eb4c4c554aa2"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.3.0/spm-notificare-assets.zip",
            checksum: "6a05e9d761e0c5ac4d67273ad99415889327a09d17603b53d7de2dd3b7845429"
        ),
        .binaryTarget(
            name: "NotificareAuthenticationKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.3.0/spm-notificare-authentication.zip",
            checksum: "bf6ed593b8824c95f6bb7b013480943908a6aff196ca96d6e6ad06f6ee496cb6"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.3.0/spm-notificare-geo.zip",
            checksum: "64a4bbdf4869ebf71a6d5b056af089a5494a46fdf7d47b6e245b371d60b3fa84"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.3.0/spm-notificare-inbox.zip",
            checksum: "a05d5f57a8ef4fef5238a47008be4faa846200bac289128e1d8fdaa071e2a7ca"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.3.0/spm-notificare-loyalty.zip",
            checksum: "6ab71532c800a28c9e95205e705108958871b06b8f3518aa69205a4cdeb12b02"
        ),
        .binaryTarget(
            name: "NotificareMonetizeKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.3.0/spm-notificare-monetize.zip",
            checksum: "2352d124ef41196fb7244cf6fd93fde39e1d2a1df638ad55c278e3addca2e09f"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.3.0/spm-notificare-push.zip",
            checksum: "0b82124fde8c38d3df351a836edcfe4514028832b793d94f22080bcd86f8a33e"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.3.0/spm-notificare-notification-service-extension.zip",
            checksum: "bf8a825567d48f5ec6285f258f1033be298d770016d48813f69595840d596240"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.3.0/spm-notificare-push-ui.zip",
            checksum: "8bd1e164e233e78d2a59ee34a5df5fc0dc8353ba10ba9621a771927417f123d0"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.3.0/spm-notificare-scannables.zip",
            checksum: "32843a87bc3cce3b7722301e95ed38254b51224673799f06645c09aed83248fe"
        ),
    ]
)
