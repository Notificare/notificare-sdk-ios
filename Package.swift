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
            url: "https://cdn.notifica.re/libs/ios/4.0.0/spm-notificare.zip",
            checksum: "b1458731d6ccd81916d592b7e770bef793c1f0b5c77dad517d52c79a5cba3587"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.0/spm-notificare-assets.zip",
            checksum: "daa26edd88b3add03457a37c7365e9502e4daa37d4f7884653b4c3ef219930cd"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.0/spm-notificare-geo.zip",
            checksum: "aaa21caad4ecf98b46942daba3477077b36d6dbb8c88987a469596409202193a"
        ),
        .binaryTarget(
            name: "NotificareInAppMessagingKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.0/spm-notificare-in-app-messaging.zip",
            checksum: "296d3712fb94710fb78dfae6284f976e76803b2a70291b5424ff90e98c910698"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.0/spm-notificare-inbox.zip",
            checksum: "d357f68f4930d02f4b86890d73998032fda53447edf65948b50239897edb4937"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.0/spm-notificare-loyalty.zip",
            checksum: "8f9ce3ea2624060dbac742171e3c9020b13ce3cf3c002b701d2f4b209c17f85c"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.0/spm-notificare-push.zip",
            checksum: "83a6b1678f51a3a10e088a1e96b9bc2abda8cd6cf9616cd7737d3d655c77d88b"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.0/spm-notificare-notification-service-extension.zip",
            checksum: "37b49aecac8449427a27dde7434ee345bbf7ede28ec7c377b3b8edb494add486"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.0/spm-notificare-push-ui.zip",
            checksum: "eebeea55cdf56df4a1cfbe0d7354e5cbd620e264269f04dd2b68f086ed300f28"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.0/spm-notificare-scannables.zip",
            checksum: "20c5dc2915b610159fefa6effb1525233bddcf323675439b27b70b5fabec0c4c"
        ),
        .binaryTarget(
            name: "NotificareUserInboxKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.0/spm-notificare-user-inbox.zip",
            checksum: "4a3a9956bd615e94849474f0848112424fef4108b7438516550ae1b65ebc842d"
        ),
        .binaryTarget(
            name: "NotificareUtilitiesKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.0/spm-notificare-utilities.zip",
            checksum: "2d11b3372463567acff159663354ca6de75739711b6fbfedf77f21b6e266959c"
        ),
    ]
)
