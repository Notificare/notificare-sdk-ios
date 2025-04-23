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
            url: "https://cdn.notifica.re/libs/ios/4.2.0/spm-notificare.zip",
            checksum: "f5f0e8bd2ed80be9eecf6e6ed347be6c33e92fdaaea9893a7675a8dc3ce37dd0"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.0/spm-notificare-assets.zip",
            checksum: "d7a205392ddfc5105b54bd14eee5f1f1e5a4ef1aab25ab155cb57c1ba23469bb"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.0/spm-notificare-geo.zip",
            checksum: "6b6baedd79cfc42f528a6c15693ee36a6ea92b65ecfb9e7cef20e57c27a34508"
        ),
        .binaryTarget(
            name: "NotificareInAppMessagingKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.0/spm-notificare-in-app-messaging.zip",
            checksum: "4d830a65f2323973c5bd416d8705501b71d33bb91df4d8b45663ffd25dbfcff1"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.0/spm-notificare-inbox.zip",
            checksum: "37b8f021bb6b9329031e7a553c86a3f249a05cfe33b72f60755638e0df7420d9"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.0/spm-notificare-loyalty.zip",
            checksum: "db54b0ff2088f2f0ccf87b28bd002000db9a4e6f00aba4c8039eee547e6fd4d5"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.0/spm-notificare-push.zip",
            checksum: "47dd5bc07019e55bc2325ff6d00621eadf5c34578ddae706cf4f257b4f05210a"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.0/spm-notificare-notification-service-extension.zip",
            checksum: "3eecb20a31b91da20e82bd24d756059da37c10b9d03f2e91b90c7af4961fdaf4"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.0/spm-notificare-push-ui.zip",
            checksum: "36d37dac39c5b8e885976d5bcad902c13bc792db21580678f47aec2c1e9d7789"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.0/spm-notificare-scannables.zip",
            checksum: "b503e047c909f4827ce28ae674ee6c9f0c9484477065475379bf2031e87add04"
        ),
        .binaryTarget(
            name: "NotificareUserInboxKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.0/spm-notificare-user-inbox.zip",
            checksum: "f8960e1acf91fedbf63da2a55003c75ac1115bcb18984047f84f5a3296b90d9e"
        ),
        .binaryTarget(
            name: "NotificareUtilitiesKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.0/spm-notificare-utilities.zip",
            checksum: "6fe23dbb65ce020bbee6d930ec4fe4e825fbe1f6ed07033b027bd3d55162f80f"
        ),
    ]
)
