// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Notificare",
    platforms: [
        .iOS(.v11),
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
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.6.0/spm-notificare.zip",
            checksum: "693ab3ca6bd8e7c376dceea5d73fb0f5e76b75e1b6e513324a8922d96fc6af15"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.6.0/spm-notificare-assets.zip",
            checksum: "4eb4ebeee5470a1f0eebf30124fa141aceeced872d29f90ed222f3b3c800dfd2"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.6.0/spm-notificare-geo.zip",
            checksum: "09de914d51eaf551cfa3f288e78dc78820e57e827835fd7e2e1d1968fa2e00fc"
        ),
        .binaryTarget(
            name: "NotificareInAppMessagingKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.6.0/spm-notificare-in-app-messaging.zip",
            checksum: "57938cc446777a9ba94328c671c38e189cb75d27b589ed9099c1093d256919b3"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.6.0/spm-notificare-inbox.zip",
            checksum: "ccf99c6946d092149d663e7e45c7c875a00b286f05ed29702d1610278c89ca24"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.6.0/spm-notificare-loyalty.zip",
            checksum: "ae3d5ba2c3966270215a017876386f97c0244ea443fa401306c91db2aac58ffe"
        ),
        .binaryTarget(
            name: "NotificareMonetizeKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.6.0/spm-notificare-monetize.zip",
            checksum: "c701ab45ea4e19aa66ed5ea09ace204bf080245d48e3c2b3ffa1067797aa0bf5"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.6.0/spm-notificare-push.zip",
            checksum: "32555c67a426fcc9290ee86dff5edc088458096a231ca0cd323ba99ee99019de"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.6.0/spm-notificare-notification-service-extension.zip",
            checksum: "5212aa6408c66eff8f6533d67939fefc1a40795ccb5745e5b9a0317a00aec1cf"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.6.0/spm-notificare-push-ui.zip",
            checksum: "4abb6bffb3fd8b672e68c956811a9c9c6ef11109fd4c2ae76ec7b43a55c4538b"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.6.0/spm-notificare-scannables.zip",
            checksum: "9ab1e6a0211adc82e90c6015b9f873a9b0f0e04c98ae20205d169dc8ac256a17"
        ),
        .binaryTarget(
            name: "NotificareUserInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.6.0/spm-notificare-user-inbox.zip",
            checksum: "ccaa25e90ece2f0893d2b573e9469336de34457bddd57a54bbd3d463b0bb90d6"
        ),
    ]
)
