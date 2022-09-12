// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Notificare",
    platforms: [
        .iOS(.v10),
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
    ],
    targets: [
        .binaryTarget(
            name: "NotificareKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0-beta.2/spm-notificare.zip",
            checksum: "bf6e418cb4c8a3c4a3c3839ffbc2cab356aa70ee8474c7ff38b059634af17481"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0-beta.2/spm-notificare-assets.zip",
            checksum: "825f361b5d2a62221936698ac968106901db3198bf8bc9420755c2b05bdfec8b"
        ),
        .binaryTarget(
            name: "NotificareAuthenticationKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0-beta.2/spm-notificare-authentication.zip",
            checksum: "4bf035bc9c7611ddbbbf9b7905ad0193a9d3b90c67d23fc353a51e4f894dbc23"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0-beta.2/spm-notificare-geo.zip",
            checksum: "87e35b2379699fc91e39f94f731511ac1f1d5b727df95d391ccec7336653b376"
        ),
        .binaryTarget(
            name: "NotificareInAppMessagingKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0-beta.2/spm-notificare-in-app-messaging.zip",
            checksum: "9b3be03817fed697f2e51e0100fee73128c32c16b12561bbab4762c6e15316a0"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0-beta.2/spm-notificare-inbox.zip",
            checksum: "4614151d2ee9d824f0db2550e4de70e2a4dbf1829202c103c309258e4f29b7bc"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0-beta.2/spm-notificare-loyalty.zip",
            checksum: "3855228590e06993f5ad0cedd0fe0cd3dca591abd0b1ca0fc344f650e54a65a4"
        ),
        .binaryTarget(
            name: "NotificareMonetizeKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0-beta.2/spm-notificare-monetize.zip",
            checksum: "5f918b965a8cadd90f8d7f0ca9d9d1504381934196537bf83cc4035527dfcaf6"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0-beta.2/spm-notificare-push.zip",
            checksum: "c9aa3a6559aa6174f78ca2860e1c0c8620376c3c5ce303624cac8c096610ecf6"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0-beta.2/spm-notificare-notification-service-extension.zip",
            checksum: "44dd2964ebc54fd7a52bba0ce95093ae6caf68e6ce50a2e1171b55269a6630e6"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0-beta.2/spm-notificare-push-ui.zip",
            checksum: "af25788a1008f731bedf1c3abec2f84508d686e80a44fadab45021d7347d5166"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0-beta.2/spm-notificare-scannables.zip",
            checksum: "7d0ae84cf036e7e0243f871abce2f8a604bbc8a5e4a21b641296fb51c07557b6"
        ),
    ]
)
