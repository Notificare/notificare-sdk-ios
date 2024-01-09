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
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.7.0-beta.1/spm-notificare.zip",
            checksum: "19889e02d1fed16f6dbbc424401fd5e1cbf6c82aa3f6932e2f458edb13f14263"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.7.0-beta.1/spm-notificare-assets.zip",
            checksum: "8bae5dd90b5c54fab697b842a7d530cde81624e6fb1071ec25ee11b85a10d014"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.7.0-beta.1/spm-notificare-geo.zip",
            checksum: "2f2a69f1995089e4ea17e2c19b213cffa009e0f8eef0b913883a8b8e410ae00b"
        ),
        .binaryTarget(
            name: "NotificareInAppMessagingKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.7.0-beta.1/spm-notificare-in-app-messaging.zip",
            checksum: "2f12691d047d925e9ec2437e3c61c061201ee50f624d89dea74c495397f06f56"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.7.0-beta.1/spm-notificare-inbox.zip",
            checksum: "e42d4f5c091430f5c4fdff408af618c6bf9aa9f066dd1cd08ded13ee43d3b739"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.7.0-beta.1/spm-notificare-loyalty.zip",
            checksum: "5cf5d42a1acb90d6436135988215692bbda9a7b46d460bd499b4b989d4982678"
        ),
        .binaryTarget(
            name: "NotificareMonetizeKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.7.0-beta.1/spm-notificare-monetize.zip",
            checksum: "be0b2b3fed7395eebd236e6af69679d51284f2fbdae037a1f8c6cd746625ef6f"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.7.0-beta.1/spm-notificare-push.zip",
            checksum: "6eb2343f53274d347b9d5448a12f147b5cf7e61943752722f7a4c285d1b70ed8"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.7.0-beta.1/spm-notificare-notification-service-extension.zip",
            checksum: "8abc229ce4674d203003bc344f53661ba3529c1d4408b056ec225e225ae4a6d5"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.7.0-beta.1/spm-notificare-push-ui.zip",
            checksum: "0bc019c2e5df7393b8f9a363b0d8dbe3ff553902f1c90d6ed6f31d7825707c42"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.7.0-beta.1/spm-notificare-scannables.zip",
            checksum: "121b8ea5e42f8ca139107bcfe53b9f9166e2c6556f86f9cfc0b80ba6440d95e8"
        ),
        .binaryTarget(
            name: "NotificareUserInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.7.0-beta.1/spm-notificare-user-inbox.zip",
            checksum: "f3572f7e3b5703c4b561e195a7916c0107347a0fac75ad5eeb5deb888ff8154a"
        ),
    ]
)
