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
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.9.0/spm-notificare.zip",
            checksum: "218814f8985d378b724275d7b0ed2f5929685f05547c6cb9ddf41cce823d8195"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.9.0/spm-notificare-assets.zip",
            checksum: "9669c34697b8c8d601825cb02f8f595671259d698fa446cf299ba3dd619b301f"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.9.0/spm-notificare-geo.zip",
            checksum: "9a90b70d417ce35fb35a6a9e023d1be055c7224e253bc9f678eb03ed09f598c1"
        ),
        .binaryTarget(
            name: "NotificareInAppMessagingKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.9.0/spm-notificare-in-app-messaging.zip",
            checksum: "2ed44ad34fc54c03ba4d20a754b4bf9066802105139e8e7806e2189b7351ab0f"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.9.0/spm-notificare-inbox.zip",
            checksum: "7b347d930a3ca899cec97c59bbdd99d59adca51e0c79094a8a5f1a1ba14647a4"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.9.0/spm-notificare-loyalty.zip",
            checksum: "a69bc423fb897127f8d3aefc2bc0398a3013b9c1504e39118a5fd2497c1b6abe"
        ),
        .binaryTarget(
            name: "NotificareMonetizeKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.9.0/spm-notificare-monetize.zip",
            checksum: "8f7721f7825bcea0c6c173acb84636188261ed8f486feaa95d9205c002334df9"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.9.0/spm-notificare-push.zip",
            checksum: "3d36c026bcff5f5bb70826290302f60ba2a02b60b5aaf0c1018d51f6a4d1a2c6"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.9.0/spm-notificare-notification-service-extension.zip",
            checksum: "9fc32c243f9c2f7f05a5ef22ff097d03ffedcd524edb100bb843454bb0c25b5b"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.9.0/spm-notificare-push-ui.zip",
            checksum: "b3bc03069b88304503e4d8d29a947e6edd769e3d68e38d32c498c43fe2638c01"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.9.0/spm-notificare-scannables.zip",
            checksum: "9fe0315fe1d6c8ccf787b6dbae454d938150d99bafffdf434c8c98b09e5bae9a"
        ),
        .binaryTarget(
            name: "NotificareUserInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.9.0/spm-notificare-user-inbox.zip",
            checksum: "5c0af0fb7f8dea618f51a136a58c606fc51f6b975486f68268c85014f6e6454e"
        ),
    ]
)
