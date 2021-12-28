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
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/{{VERSION}}/NotificareKit.zip",
            checksum: "{{NOTIFICARE_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/{{VERSION}}/NotificareAssetsKit.zip",
            checksum: "{{NOTIFICARE_ASSETS_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "NotificareAuthenticationKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/{{VERSION}}/NotificareAuthenticationKit.zip",
            checksum: "{{NOTIFICARE_AUTHENTICATION_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/{{VERSION}}/NotificareGeoKit.zip",
            checksum: "{{NOTIFICARE_GEO_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/{{VERSION}}/NotificareInboxKit.zip",
            checksum: "{{NOTIFICARE_INBOX_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/{{VERSION}}/NotificareLoyaltyKit.zip",
            checksum: "{{NOTIFICARE_LOYALTY_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/{{VERSION}}/NotificarePushKit.zip",
            checksum: "{{NOTIFICARE_PUSH_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/{{VERSION}}/NotificarePushUIKit.zip",
            checksum: "{{NOTIFICARE_PUSH_UI_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/{{VERSION}}/NotificareScannablesKit.zip",
            checksum: "{{NOTIFICARE_SCANNABLES_CHECKSUM}}"
        ),
    ]
)
