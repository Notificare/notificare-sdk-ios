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
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.0-beta.2/spm-notificare.zip",
            checksum: "aab5381496434fd8abf73deef1874072cde01901196383585c7eef16f6edc65b"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.0-beta.2/spm-notificare-assets.zip",
            checksum: "8cb55c9a33db7aa244afbf477134790072868ac687b7869550209cbf7ad7e8b6"
        ),
        .binaryTarget(
            name: "NotificareAuthenticationKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.0-beta.2/spm-notificare-authentication.zip",
            checksum: "1176c52f2e182bfad1a6a2a81d045f30a0f09822b5185c72e400459a1dd76c9f"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.0-beta.2/spm-notificare-geo.zip",
            checksum: "a6617cbe5d06725887372d30f69c25696c6251a0340f784afeb5fbe56021b7b5"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.0-beta.2/spm-notificare-inbox.zip",
            checksum: "053ff380af46c2e033c12d8097a4a5776f97ec152ce87df76070c1f452bff12d"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.0-beta.2/spm-notificare-loyalty.zip",
            checksum: "4aca17a078e749862a77962b7e76efca67cda17039814ebddb293b27b7d3104a"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.0-beta.2/spm-notificare-push.zip",
            checksum: "05f318903451f05a8f31f0ad268c1542ffd7768a0d5f1edf5be680f37de25d41"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.0-beta.2/spm-notificare-notification-service-extension.zip",
            checksum: "b10d4139f7eb7da9fc786dda862fef3680364924352aef5ae08a3ef0bda7d8be"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.0-beta.2/spm-notificare-push-ui.zip",
            checksum: "d3c4eb921627e2cacba285f6d2d45a823de8721ecd8a3853fd72606f150075cb"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.0-beta.2/spm-notificare-scannables.zip",
            checksum: "da05a4047bb4b06ddbc77ea7e0a1df17d7945ac998dc9f1ff5a5b219ef7261c7"
        ),
    ]
)
