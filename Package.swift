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
            url: "https://cdn.notifica.re/libs/ios/4.0.1/spm-notificare.zip",
            checksum: "fd898e5ce6064877e5c4e229b3db72b44fe1a4a7e4ac69ce3069fb40ff90b004"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.1/spm-notificare-assets.zip",
            checksum: "f8a2cf8dad1f579500ed2b499512d89d050091433b763228f70caaa4fc88906d"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.1/spm-notificare-geo.zip",
            checksum: "ae8ebb5ebbe9a0b413e58fd41c3726b89e95ac8ab306babec9dd9d2013f3d336"
        ),
        .binaryTarget(
            name: "NotificareInAppMessagingKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.1/spm-notificare-in-app-messaging.zip",
            checksum: "a1419d6c7fe601029cb0831511a0a4d6cdfff05a42800d75a4822deff644d7c2"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.1/spm-notificare-inbox.zip",
            checksum: "39f24b07410e3c850c48ca947bf0410b03cda6ad087de31d04e6af813d65ca1b"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.1/spm-notificare-loyalty.zip",
            checksum: "d5c6addfc8cbe29ecb4a8341c11b5f69c2dfd926c51ffb7bab60cc2309d3817b"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.1/spm-notificare-push.zip",
            checksum: "8f7208bf916171dced82fdcbf94c1b3c2b3e6b57b868535f96c0a9df56077d1d"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.1/spm-notificare-notification-service-extension.zip",
            checksum: "5341801055c34e8f42016cc71392ffea1b1cddfecf7da9af2140aa2af9881656"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.1/spm-notificare-push-ui.zip",
            checksum: "335ca00fe57947eaefe6b44c2ee827da0dbccd2107f9d8d17db7348c5e1bdca8"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.1/spm-notificare-scannables.zip",
            checksum: "0aa416ad807add080c7a6188444f9cfc6003eec32926845c60740dc8de6b4e5d"
        ),
        .binaryTarget(
            name: "NotificareUserInboxKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.1/spm-notificare-user-inbox.zip",
            checksum: "1d9f9c3ff8aa7764481e7d16702a64179cb9dafa4adbac470d63515b78b2b2d5"
        ),
        .binaryTarget(
            name: "NotificareUtilitiesKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.1/spm-notificare-utilities.zip",
            checksum: "ebdd37d3a2b57c546f8c8f16597557130be73f223367388d07783c26bb2adb4e"
        ),
    ]
)
