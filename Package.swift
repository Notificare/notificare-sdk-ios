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
    ],
    targets: [
        .binaryTarget(
            name: "NotificareKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.1.0/spm-notificare.zip",
            checksum: "5d0d6f5172fba587984e89ffc78b0a9df4183dc4ccaa81d3154ef82e3b2da554"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.1.0/spm-notificare-assets.zip",
            checksum: "53565c2adc206620323340e4115ccb17bac409f4e3f69856b5dfe6a83415d7e1"
        ),
        .binaryTarget(
            name: "NotificareAuthenticationKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.1.0/spm-notificare-authentication.zip",
            checksum: "c36f3b5c5bbce929d6b68f5d40546a21f3b23a86d377277041d66015b512ac1a"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.1.0/spm-notificare-geo.zip",
            checksum: "c760181382726ffa92b35822f90d7c4f03b5b2b00ebb1f41f3630451eb42212b"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.1.0/spm-notificare-inbox.zip",
            checksum: "d0b305f3f49623d089a2bbc8b61b4a4461779b2e30cf24f4b2909d23ff1da92e"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.1.0/spm-notificare-loyalty.zip",
            checksum: "b8cb23387187e4ed82ce690e6b4778148a0e2e5b769efaeafdfc7635a578637b"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.1.0/spm-notificare-push.zip",
            checksum: "cfc7dace5f62ee03d63bdcf2f04f91bb19f635864416622c741b720a0b907fe8"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.1.0/spm-notificare-notification-service-extension.zip",
            checksum: "449d345da67d6e05813650fa5a875684cc0767ed400d6c590d287a98747a4b6f"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.1.0/spm-notificare-push-ui.zip",
            checksum: "f2f0f21cd81e54fc8be9a7a56e1519245ccb77e733174817577623357103313d"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.1.0/spm-notificare-scannables.zip",
            checksum: "8b959483217a58f277a2324d48a397b4c7d649253f0c4e2fe040ff54a405db4e"
        ),
    ]
)
