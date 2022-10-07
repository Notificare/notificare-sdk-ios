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
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0-beta.3/spm-notificare.zip",
            checksum: "c04465c16bbc299bdc67dc64910a5c47f689b3102661ed1b0eb89c6382ee323b"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0-beta.3/spm-notificare-assets.zip",
            checksum: "e730fc9df923154e61de3a614f1be1babb2030373e79c4e7ea117612b27ecb5c"
        ),
        .binaryTarget(
            name: "NotificareAuthenticationKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0-beta.3/spm-notificare-authentication.zip",
            checksum: "7c97d8c27453b38e87b7a4e7d4cf162dbde961ade778709b55ac08c9dda360ef"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0-beta.3/spm-notificare-geo.zip",
            checksum: "d4cfc29b86aa32abdd8590cfccd0a7cd77e3e3b0c8f2248f62107e3a8e6d7f82"
        ),
        .binaryTarget(
            name: "NotificareInAppMessagingKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0-beta.3/spm-notificare-in-app-messaging.zip",
            checksum: "b549d3abd62c0f89f5fc21927b980a7b19187336a0082d34faa52c69d5afe8b9"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0-beta.3/spm-notificare-inbox.zip",
            checksum: "bce55031102ee5601738358ebb7c29cbed47e11a390bf125841e5a1df2f90df9"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0-beta.3/spm-notificare-loyalty.zip",
            checksum: "c2faf3a3786822284a299dc7c119b2a0306e19e52589b6c4478f776586bab73e"
        ),
        .binaryTarget(
            name: "NotificareMonetizeKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0-beta.3/spm-notificare-monetize.zip",
            checksum: "1488d3d6b283eaccacf5447de15366f81aaca6a5792646a60139a6c01aab450e"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0-beta.3/spm-notificare-push.zip",
            checksum: "5d92ef65c0b6e1d518dbf218e95929ad6b83c7f4ec903d8d58e954da7787901b"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0-beta.3/spm-notificare-notification-service-extension.zip",
            checksum: "e63d6e33f4931a1d459f012b2efcc595948ca80c7c713e5b9576adfafeb32598"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0-beta.3/spm-notificare-push-ui.zip",
            checksum: "2a16915f93a40e40dd2a72a7ff54282945dd9f1e0b8052c232a7acb66326d7a1"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0-beta.3/spm-notificare-scannables.zip",
            checksum: "d3fb054f0edbc6ac653adbeac565afff1efb57e3b7fbf582329fb4def9955a52"
        ),
    ]
)
