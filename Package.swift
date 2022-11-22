// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Notificare",
    platforms: [
        .iOS(.v11),
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
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.2/spm-notificare.zip",
            checksum: "408d8742b4f705a14321f970ea5d3579581437ce9ea924c5030d155f0601df50"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.2/spm-notificare-assets.zip",
            checksum: "0853ecbb08ac3427cf3d7935f23f963ae3e6ceae9f0db16bfdcf50a6a9895d46"
        ),
        .binaryTarget(
            name: "NotificareAuthenticationKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.2/spm-notificare-authentication.zip",
            checksum: "812c23787a1cbd6763f42c2c6074b7ade1ad2b9cc97421acb7497f77b5a47151"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.2/spm-notificare-geo.zip",
            checksum: "f6a51c4c78038273501b59b2b845c52e40dd71d1cd6a7e8aedcbe00e1396a88d"
        ),
        .binaryTarget(
            name: "NotificareInAppMessagingKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.2/spm-notificare-in-app-messaging.zip",
            checksum: "d5238047c39cdc698fdcc489d796b7d633969ae4f62e89dbd294882d8f428d1a"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.2/spm-notificare-inbox.zip",
            checksum: "22bed5ea4e519cd7a9f9631f9c0a6034672a6d02fffd9096b987772cc496ac94"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.2/spm-notificare-loyalty.zip",
            checksum: "c2d448652c2da58915f98fd1357dece8d78ce138c16ecb6354f11267c5699e78"
        ),
        .binaryTarget(
            name: "NotificareMonetizeKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.2/spm-notificare-monetize.zip",
            checksum: "50f70a189c1a368d1c95d6d47ab7d17ba82ef296d19b94e5ea8d3cd4c523ca71"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.2/spm-notificare-push.zip",
            checksum: "dde11278c2494d41fb5fc6d9745f286d80ba55c1470761a84911d9f8f3fc68f2"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.2/spm-notificare-notification-service-extension.zip",
            checksum: "85e1c423a676b78e0c755c51651b3f934f8eeb29a1a4b2dc310ebdacdf3bade4"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.2/spm-notificare-push-ui.zip",
            checksum: "657559952cb886b9093d55efc0f3fb85f70c4d5b100397a0ea17bd6c0deea732"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.2/spm-notificare-scannables.zip",
            checksum: "caf48e9b05d297c613a424a967a3d4311d0d81f246c4d04bef544cbe135d2305"
        ),
    ]
)
