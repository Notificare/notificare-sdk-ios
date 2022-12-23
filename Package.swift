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
            name: "NotificareAuthenticationKit",
            targets: ["NotificareAuthenticationKit"]
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
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.0/spm-notificare.zip",
            checksum: "025a002b630dcc96e3f39000352fec95074ed3e9ca6ed68fb9a40d9baa541400"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.0/spm-notificare-assets.zip",
            checksum: "9dbed90729023a6869a76456420987e946868f24d62ac6a9b311d0dc6bb0e73b"
        ),
        .binaryTarget(
            name: "NotificareAuthenticationKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.0/spm-notificare-authentication.zip",
            checksum: "abf76be247349960b1590e011cfb2b296a8784645444fb3237d4051cf5fbfb90"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.0/spm-notificare-geo.zip",
            checksum: "e51210f0a2c82e3652e3e3ac56aaf60bfa23f1ff20d1ea62db3161e036dd5b07"
        ),
        .binaryTarget(
            name: "NotificareInAppMessagingKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.0/spm-notificare-in-app-messaging.zip",
            checksum: "ea0f9e02c59172ee350bcfc92b013e3301bc9c77a98949a65c6fe107dec3382d"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.0/spm-notificare-inbox.zip",
            checksum: "04255f264cd4e724d0f839bee67c3445864374fd17b93ea5ca07d43988317e3b"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.0/spm-notificare-loyalty.zip",
            checksum: "292ba0492f7acfb6a374084db3e180f05efbee605682f2d1bd3c54e5bbcc8a4b"
        ),
        .binaryTarget(
            name: "NotificareMonetizeKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.0/spm-notificare-monetize.zip",
            checksum: "80e82e80ed94f61c0b066f71d8380105b67c4d37dbafc60181a66c651a3f4946"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.0/spm-notificare-push.zip",
            checksum: "c826f84b2262ee1f220e5c8a88b13efa4393d4bcccc6fd3cb05e3851a9ab73db"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.0/spm-notificare-notification-service-extension.zip",
            checksum: "e596b8354a3058d7f2075a3120f5a06f9329b65882afd2f7b365b2f32c08d598"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.0/spm-notificare-push-ui.zip",
            checksum: "54aeb2a6a62ec9d70277ea6218a40f53d7f5f5e2f1225eea96ad763b046326f9"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.0/spm-notificare-scannables.zip",
            checksum: "fcd780ede6a96e2f9aa36081d25a9648aa4dae70a3ac77ceb0e9d97e34001d68"
        ),
        .binaryTarget(
            name: "NotificareUserInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.0/spm-notificare-user-inbox.zip",
            checksum: "15f4c0835c76bc9f1378fc60876ecb0e3666564c14f3491299e66182123de8f8"
        ),
    ]
)
