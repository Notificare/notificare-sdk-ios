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
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.1/spm-notificare.zip",
            checksum: "9d5978f1ddc9f52ce43b70fcd5f3a8d02f43a79930ee0bdcea3cc34343022761"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.1/spm-notificare-assets.zip",
            checksum: "ec879a96729c9c00180f799e9e0af2b61f16a5223a43c37f52fdc2a39cbbe134"
        ),
        .binaryTarget(
            name: "NotificareAuthenticationKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.1/spm-notificare-authentication.zip",
            checksum: "90ad1a1ec83b5a9e306dbcf5237fd4800a7d3f86ffe965a5f9ee9b8999724d52"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.1/spm-notificare-geo.zip",
            checksum: "61de4ba411f4dad098c6f6f926e2a1630414631746bf5c69b65748baf4b96444"
        ),
        .binaryTarget(
            name: "NotificareInAppMessagingKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.1/spm-notificare-in-app-messaging.zip",
            checksum: "8e7bfb78c8e284f77381b8ff9ad815477c2dfd81724c8b17da72ce669bcfce33"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.1/spm-notificare-inbox.zip",
            checksum: "0d926e5b52d76d8ca84a018dd7c09623eba0380b67fd4f44454060ef12c72c91"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.1/spm-notificare-loyalty.zip",
            checksum: "d7d6820a10e815c08a199455e8ff1541a40c0c98390e4042de00dc1631522634"
        ),
        .binaryTarget(
            name: "NotificareMonetizeKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.1/spm-notificare-monetize.zip",
            checksum: "6a01a27f42f93e93d035c28470a3e31ca7dec184157f9dcc329224640fe79a58"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.1/spm-notificare-push.zip",
            checksum: "b02ff85e06a81488082446e67e695e4681e7e6b7b1922e2aa9b237b03ac1f054"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.1/spm-notificare-notification-service-extension.zip",
            checksum: "56fe3a945ee24357184b84ae085dcec859738bf8258e85f962405cabf52cb176"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.1/spm-notificare-push-ui.zip",
            checksum: "044e1f49699724adb4bb50bb9f1a3c0459bbe6c212a28d5e27a1b5739f190b46"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.1/spm-notificare-scannables.zip",
            checksum: "caeaaf6463c6f1adc90d0120b0513573a364ab41696c1cc71a026b33d846738b"
        ),
    ]
)
