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
            url: "https://cdn.notifica.re/libs/ios/4.2.4/spm-notificare.zip",
            checksum: "741c28c65016a5c3ee8ec53aa3ad73b90996c5634b8e4f61c1c64603e967602f"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.4/spm-notificare-assets.zip",
            checksum: "c8faba0194f566cc22ac4c5af687cb812f4a18ebdbfb6851799d321545505105"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.4/spm-notificare-geo.zip",
            checksum: "753230edc5814bfce15b351fd109a223655c3ef86bd235bbda7f628716d1afb7"
        ),
        .binaryTarget(
            name: "NotificareInAppMessagingKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.4/spm-notificare-in-app-messaging.zip",
            checksum: "76910f67b6d60becee8a9f1b822042442816f2e23ac4695c869611551a68b787"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.4/spm-notificare-inbox.zip",
            checksum: "99a19a6e731d46c0968c7ac6f66841a0e382b6d28e92b4907f7c64c700eea023"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.4/spm-notificare-loyalty.zip",
            checksum: "eb879b9937838585357852c986943b60add950e175faf6a86dfdfc6a44a2b993"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.4/spm-notificare-push.zip",
            checksum: "36811b515c2da606e631a8cdfb76269b696c36b3e7d2e0e48efbfff469023e03"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.4/spm-notificare-notification-service-extension.zip",
            checksum: "3cf0cc4dcbe2df4fd6695b4e2b24045265db98b5bd4f7c086a42055257c02e66"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.4/spm-notificare-push-ui.zip",
            checksum: "418b72b594a2c868732056918604d8a6a4374b0a2f19c1b7de463e94c8d8ae01"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.4/spm-notificare-scannables.zip",
            checksum: "4bd321649e51d1e47a40cb94584da4a559d4d3cf3bc482db309be5fd938aad36"
        ),
        .binaryTarget(
            name: "NotificareUserInboxKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.4/spm-notificare-user-inbox.zip",
            checksum: "c7c4511fa8a0f228a0448a124adf0b6866c68e5e5651bea07bf3edaa0b9165e0"
        ),
        .binaryTarget(
            name: "NotificareUtilitiesKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.4/spm-notificare-utilities.zip",
            checksum: "0d15050d8060e952c453bce7299eac8fd3055b42552e6fb2f3f4413e8ab128d9"
        ),
    ]
)
