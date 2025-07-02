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
            targets: ["NotificareKit", "NotificareUtilitiesKit"]
        ),
        .library(
            name: "NotificareAssetsKit",
            targets: ["NotificareAssetsKit", "NotificareUtilitiesKit"]
        ),
        .library(
            name: "NotificareGeoKit",
            targets: ["NotificareGeoKit", "NotificareUtilitiesKit"]
        ),
        .library(
            name: "NotificareInAppMessagingKit",
            targets: ["NotificareInAppMessagingKit", "NotificareUtilitiesKit"]
        ),
        .library(
            name: "NotificareInboxKit",
            targets: ["NotificareInboxKit", "NotificareUtilitiesKit"]
        ),
        .library(
            name: "NotificareLoyaltyKit",
            targets: ["NotificareLoyaltyKit", "NotificareUtilitiesKit"]
        ),
        .library(
            name: "NotificareNotificationServiceExtensionKit",
            targets: ["NotificareNotificationServiceExtensionKit"]
        ),
        .library(
            name: "NotificarePushKit",
            targets: ["NotificarePushKit", "NotificareUtilitiesKit"]
        ),
        .library(
            name: "NotificarePushUIKit",
            targets: ["NotificarePushUIKit", "NotificareUtilitiesKit"]
        ),
        .library(
            name: "NotificareScannablesKit",
            targets: ["NotificareScannablesKit", "NotificareUtilitiesKit"]
        ),
        .library(
            name: "NotificareUserInboxKit",
            targets: ["NotificareUserInboxKit", "NotificareUtilitiesKit"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "NotificareKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.2/spm-notificare.zip",
            checksum: "0cf7db8a7f9b100e90d7a30cffdf71fb2c0ab254bdc158b60f14e7ac644c6b31"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.2/spm-notificare-assets.zip",
            checksum: "d7d30cd607af40e385f8fdb630d3a8c17333670dbc7039f847229f84c4016a5c"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.2/spm-notificare-geo.zip",
            checksum: "25b49e6a881130ee0793ced6a0a4c475f37eaff4a95651d698e8c08d6c6eabc6"
        ),
        .binaryTarget(
            name: "NotificareInAppMessagingKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.2/spm-notificare-in-app-messaging.zip",
            checksum: "f0520d59f9807d3b79c2d8510a6b981a895fe0db6821424c60970d39ff271cbf"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.2/spm-notificare-inbox.zip",
            checksum: "d4b42321f60cba59e43b2b370fab784937a07c48856fb4ed1e8894af970cca76"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.2/spm-notificare-loyalty.zip",
            checksum: "23c5886d4c2b3f500f6ae459009a2d6b434a6950d37e2e637e74722c2e2db3dc"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.2/spm-notificare-push.zip",
            checksum: "39b3504da6d2cfd0f5472e745941da408084aa880cea2b4b2288fea6adc45243"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.2/spm-notificare-notification-service-extension.zip",
            checksum: "0f4a862c543b3906cc20bbc7ce86a542760d633d571ffa4063feeb03908018bc"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.2/spm-notificare-push-ui.zip",
            checksum: "8e089798ad7ad8e67a59933789093386bc9fe4b099d78151903be66596471885"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.2/spm-notificare-scannables.zip",
            checksum: "8075828a3e7d7a95f303b4e74fdfbf6e7054145c52b769c9b2d5222020fca68a"
        ),
        .binaryTarget(
            name: "NotificareUserInboxKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.2/spm-notificare-user-inbox.zip",
            checksum: "f5a1e9684f2865d7fbfa396fe76759c6bfad4a1dbeaeec6dbdfc218d608a1aea"
        ),
        .binaryTarget(
            name: "NotificareUtilitiesKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.2/spm-notificare-utilities.zip",
            checksum: "ab765783391e2bdc3b8253fe372add3995d597cde4c3e7c703738d87c484d827"
        ),
    ]
)
