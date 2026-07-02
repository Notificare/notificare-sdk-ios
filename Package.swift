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
            url: "https://cdn.notifica.re/libs/ios/4.2.5/spm-notificare.zip",
            checksum: "9b2b57093ed90d3371bedecaced1c3b8c0aa6579af953580be73b5ba144a0bb9"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.5/spm-notificare-assets.zip",
            checksum: "ad1d35283b07f29e2af4ec5ae67efa3fba76a35c7be46c50e854a77ea1675eb6"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.5/spm-notificare-geo.zip",
            checksum: "08bfeda4697c0a98f1a7b5b03ab8bd6dc2657e2c4617811b0038b4baa6a3b4c3"
        ),
        .binaryTarget(
            name: "NotificareInAppMessagingKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.5/spm-notificare-in-app-messaging.zip",
            checksum: "635b34d13c9b7df88be38863d0572eef18616c7696df52fcc50c0230ced4110c"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.5/spm-notificare-inbox.zip",
            checksum: "466a7c5f7e695ec471fef148d42ba5777072fabdd516ffd04c13606c17325eeb"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.5/spm-notificare-loyalty.zip",
            checksum: "baad275f98b0952321cc9fc17057aa308495e72fb5b5e212c9fdcc1d075918ea"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.5/spm-notificare-push.zip",
            checksum: "aa85eb12e13f8bed514db6bd4e1c039ab5d5fb759671697e810d20b1b366f83c"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.5/spm-notificare-notification-service-extension.zip",
            checksum: "4c74fa0a967564ecafd6b5cfd24f9f307b9f9e427de69c505b1d6d14da779c75"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.5/spm-notificare-push-ui.zip",
            checksum: "f1b7ee8b6c2897ea41e691d76524b02a2e78f9fb2ae20b68dc218fee9ad39e35"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.5/spm-notificare-scannables.zip",
            checksum: "eb5e9cf5d9a7a893b5f53de9be8d0943673d1fd780b322433dd2448dfb2e0d29"
        ),
        .binaryTarget(
            name: "NotificareUserInboxKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.5/spm-notificare-user-inbox.zip",
            checksum: "bef89910f6f4a027db5d1e906c9cd0ab703b857073af95ab9973a5ec120922b0"
        ),
        .binaryTarget(
            name: "NotificareUtilitiesKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.5/spm-notificare-utilities.zip",
            checksum: "5b0d68352876b2fe48fc32d3bd8cfa91d9f2205f70f00269b0a529d854723436"
        ),
    ]
)
