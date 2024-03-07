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
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.8.0/spm-notificare.zip",
            checksum: "3475cfe29168b3025646306bd134020fc6aac04f0da7544adf8cbad1394bccc1"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.8.0/spm-notificare-assets.zip",
            checksum: "fd16494fcba90c55dddbcf9dd097492627103af62ea07b80124497d1be91ff0a"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.8.0/spm-notificare-geo.zip",
            checksum: "ed2dcffe6df9169855434f00d695345582ff525c70ef37b177d6ee0cecc9269c"
        ),
        .binaryTarget(
            name: "NotificareInAppMessagingKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.8.0/spm-notificare-in-app-messaging.zip",
            checksum: "0ef5576d18e43895c49705519e876696174e68c85f25423d0ba5effdf78a60fa"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.8.0/spm-notificare-inbox.zip",
            checksum: "e8611726947f15ee1ecfd3c2e59aba0c008a97bded780ffd68aa8a962a623a24"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.8.0/spm-notificare-loyalty.zip",
            checksum: "36d41a8c7d8bed16fa00d52fbfebea0dc87fbeff35e180fc72686a2d6c98e66b"
        ),
        .binaryTarget(
            name: "NotificareMonetizeKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.8.0/spm-notificare-monetize.zip",
            checksum: "035ccbcfa87257249c846b6a386588d2e03c93db687f0cebf944f04a3e522f72"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.8.0/spm-notificare-push.zip",
            checksum: "0e309055a2e4eb0cd1565e61d4a87838946d2a9a124f3d881f0ec8640c0d9fd5"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.8.0/spm-notificare-notification-service-extension.zip",
            checksum: "f33b2790dda2cc0ff40437f736a797bd5e82fcceab2b15deca2cfe260b81e435"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.8.0/spm-notificare-push-ui.zip",
            checksum: "98e00e61a60271bfd9b44bfb69e577fc067017c72716e27301ed78de6ee1f2e5"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.8.0/spm-notificare-scannables.zip",
            checksum: "7ffabb4742e2ba9c7ac4f148e29785c8c202036ad56b99211fa497fed4158532"
        ),
        .binaryTarget(
            name: "NotificareUserInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.8.0/spm-notificare-user-inbox.zip",
            checksum: "6db115654c269009639575519fcab10856680917859ca0a713905118784f2522"
        ),
    ]
)
