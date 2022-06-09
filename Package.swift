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
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.2.0/spm-notificare.zip",
            checksum: "49d948e4bd01024393276f9b1e752c97924fb2b4d3476fc8c179ecba2df02cc7"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.2.0/spm-notificare-assets.zip",
            checksum: "da1570873a7b254f687a24b3fee7921c83ab7de4ca0a10b7f67e7d0a43cf14f8"
        ),
        .binaryTarget(
            name: "NotificareAuthenticationKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.2.0/spm-notificare-authentication.zip",
            checksum: "bb75fa282d9dcbf5500815b0ef44c4bc261f096cbb5a090a32036c6937aac6e8"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.2.0/spm-notificare-geo.zip",
            checksum: "63ec4bf585659401ca3cd1b2ad35028b711f2c0ba9d376bdf185d19e506bfaaa"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.2.0/spm-notificare-inbox.zip",
            checksum: "2511e799427d4f58cc4f9de480b71c53fd45a42f14cc7b8d785d809323aedaed"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.2.0/spm-notificare-loyalty.zip",
            checksum: "ee427c11c6e05e85ca3cacbffc5bb1082f3a0a9a3ee9cb9226bb32cb98928b17"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.2.0/spm-notificare-push.zip",
            checksum: "84fb5d37d0f319628b0f34e993b4e85b487baa499b6a58fc5d40e9048bc04df0"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.2.0/spm-notificare-notification-service-extension.zip",
            checksum: "8a3bce5d071d48d8114a55ad9ed14c3acb62f2ef12c7c533b82439dfc9008f15"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.2.0/spm-notificare-push-ui.zip",
            checksum: "e8ee85e0e1fdf397e90bab4616b33392bc6d067c1757d233dbafd6c20f3af5c6"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.2.0/spm-notificare-scannables.zip",
            checksum: "1ae430d0f85fa1fc89f3ecc4b9452e8a5d0f192901a959d0bd8da215343d3295"
        ),
    ]
)
