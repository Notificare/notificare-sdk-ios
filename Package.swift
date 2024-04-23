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
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.9.0/spm-notificare.zip",
            checksum: "ef99265d58eb3e7922dbf7f3885d22b571bc45dc5138f097b74ac88fe75d93e8"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.9.0/spm-notificare-assets.zip",
            checksum: "b92e534822c0a4d93571fc2b300e317c267c00a4725c2f73d5ac77be963ff174"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.9.0/spm-notificare-geo.zip",
            checksum: "c5339a027fac52f42f9a9302d5cd6c1da10270273dac8b3c3b718654c31e3008"
        ),
        .binaryTarget(
            name: "NotificareInAppMessagingKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.9.0/spm-notificare-in-app-messaging.zip",
            checksum: "ad2b427ca0d00841a1f4926679c43f3444b37ec807bda8e9f2fd3188937ec679"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.9.0/spm-notificare-inbox.zip",
            checksum: "3688a085a0e4f554be3efb23fd459a6b7c49c419b1138d59c40c76c16a0d1fba"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.9.0/spm-notificare-loyalty.zip",
            checksum: "14684e1f9a56681c12b6aaa8c389fd82305e56502ddad1a70a97acfbd39fd578"
        ),
        .binaryTarget(
            name: "NotificareMonetizeKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.9.0/spm-notificare-monetize.zip",
            checksum: "524b5429dc5c24ca8a27ab3e4c40430ba21c78b72add340bcb546ce53d3fa1c4"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.9.0/spm-notificare-push.zip",
            checksum: "c97eac1b952fca816315ee45e88a528cd00969a3a7aecf0b2afc1ffec44ef290"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.9.0/spm-notificare-notification-service-extension.zip",
            checksum: "35d06cde2e967a779c964a31386dec01013a8fa206fcfbf320ed7ef09d56ab8b"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.9.0/spm-notificare-push-ui.zip",
            checksum: "ba2f6bcc5d5e7d9df77288faff9f99f9c1774115db3c46723022bf982145f0bb"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.9.0/spm-notificare-scannables.zip",
            checksum: "be8d24c271322d15359bd0fbf72d75c897292c92bcda66daa75587c29752135f"
        ),
        .binaryTarget(
            name: "NotificareUserInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.9.0/spm-notificare-user-inbox.zip",
            checksum: "80af3543ce9af99d2a319d56679359c311800b1430e5df4876fa770dff88bcf5"
        ),
    ]
)
