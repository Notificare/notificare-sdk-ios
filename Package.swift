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
            url: "https://cdn.notifica.re/libs/ios/4.0.0-beta.1/spm-notificare.zip",
            checksum: "94bf93da15998e1491ed36c52faedf2a577861c721b1c7255d37b3eedc943784"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.0-beta.1/spm-notificare-assets.zip",
            checksum: "2b10b6198df80bc66cd1d122bfca500af7a5a00065118812b20d9c6bc2007001"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.0-beta.1/spm-notificare-geo.zip",
            checksum: "f59c6c4cc41ae48adf6161c72c64df5a3a84a68a3ba670e7931205575f2bb8a0"
        ),
        .binaryTarget(
            name: "NotificareInAppMessagingKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.0-beta.1/spm-notificare-in-app-messaging.zip",
            checksum: "12607e1e61b9ed4e27f4cd57dcab0e856bd844619b8683fddb35893a3dd2c759"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.0-beta.1/spm-notificare-inbox.zip",
            checksum: "1d0674fa0567104ce4701769a27b16e09127a8ca8f686967934513e7aecf12d1"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.0-beta.1/spm-notificare-loyalty.zip",
            checksum: "b094a487ed3a51e3265658fd1af49ca1cc1427181139f13736a4f554b4b12657"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.0-beta.1/spm-notificare-push.zip",
            checksum: "4b62a34712a44256ae82839e690b65aa9ea86d62ba594ef52d95a7a333a07be6"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.0-beta.1/spm-notificare-notification-service-extension.zip",
            checksum: "52eb30ba7d6a01b6e176ce2ada28eeb783e695a0b0a8a6b79fb4c72664fea1b1"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.0-beta.1/spm-notificare-push-ui.zip",
            checksum: "9de28527dbe21d5c8831423cb45a51c7d0b5ffb8a3e9e68b4e885a35af9f646c"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.0-beta.1/spm-notificare-scannables.zip",
            checksum: "2343242a1a26feb0b7a688c09bf138b53f4b155b5e8a398b9a8e641bbef3e9b3"
        ),
        .binaryTarget(
            name: "NotificareUserInboxKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.0-beta.1/spm-notificare-user-inbox.zip",
            checksum: "5645ffb42b109a897acb1a6414f223a35304aa1a94dd91d67e7e0923fe4d4c61"
        ),
    ]
)
