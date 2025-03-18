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
            url: "https://cdn.notifica.re/libs/ios/4.1.0/spm-notificare.zip",
            checksum: "7e79ad94aff0f7944b512b97aeb3d86ab18e2749b4465ce8973e09d133cc0b41"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://cdn.notifica.re/libs/ios/4.1.0/spm-notificare-assets.zip",
            checksum: "d4f8589b661b8a0ac6f23b462956be190552666ca4b84a2848c803c37151f970"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://cdn.notifica.re/libs/ios/4.1.0/spm-notificare-geo.zip",
            checksum: "206941090b389a6aa51a538fafa22f1c0a9570c1eb69444bb2c0cd3735121312"
        ),
        .binaryTarget(
            name: "NotificareInAppMessagingKit",
            url: "https://cdn.notifica.re/libs/ios/4.1.0/spm-notificare-in-app-messaging.zip",
            checksum: "84df16604f448d104d3b5175425dc76a7267e4f29fc0a45a27913090e4d29528"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://cdn.notifica.re/libs/ios/4.1.0/spm-notificare-inbox.zip",
            checksum: "c02069a7bd95e313a600dde7af005e139d59edbad5a3939c0362d5520ce75d58"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://cdn.notifica.re/libs/ios/4.1.0/spm-notificare-loyalty.zip",
            checksum: "1585c7927863c952fc459e55b23c039b50a9ede5c447e460aa2ad5784598b4fe"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://cdn.notifica.re/libs/ios/4.1.0/spm-notificare-push.zip",
            checksum: "8385f410bb3b62d0fa34b4125a6fe86f8c0b4d829b6db3df2e875859b0870da9"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://cdn.notifica.re/libs/ios/4.1.0/spm-notificare-notification-service-extension.zip",
            checksum: "c1f2d139da8c01a1c0fbcd48b57b965af333d214d8a7f0b686631f9a582ef10e"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://cdn.notifica.re/libs/ios/4.1.0/spm-notificare-push-ui.zip",
            checksum: "2c29c665e646dac3efd97e42c692edaed1a6a82ceba62c129ab3cf8ca9c207d8"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://cdn.notifica.re/libs/ios/4.1.0/spm-notificare-scannables.zip",
            checksum: "fef559268c930ee1e40ae8eaa51ef3f4b8c5e74abda2b3b368986d6b03728604"
        ),
        .binaryTarget(
            name: "NotificareUserInboxKit",
            url: "https://cdn.notifica.re/libs/ios/4.1.0/spm-notificare-user-inbox.zip",
            checksum: "1875e420f06f890996c3088d11e2483bb1e362918a7d90492f7695b93287a5f0"
        ),
        .binaryTarget(
            name: "NotificareUtilitiesKit",
            url: "https://cdn.notifica.re/libs/ios/4.1.0/spm-notificare-utilities.zip",
            checksum: "52ccf49487514c7775c700f2cd23581d66bc6bd6ec834e358588a5dcf91d580f"
        ),
    ]
)
