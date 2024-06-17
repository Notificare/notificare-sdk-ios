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
            url: "https://cdn.notifica.re/libs/ios/3.9.1/spm-notificare.zip",
            checksum: "2111dad0ec63c05bada7f16f23accdbdcbeb9428b1e75cb4c9f150415a6d3bee"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://cdn.notifica.re/libs/ios/3.9.1/spm-notificare-assets.zip",
            checksum: "23c1865c36b9890e71377d0f68bac73884e820df759782993482f50082a37b16"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://cdn.notifica.re/libs/ios/3.9.1/spm-notificare-geo.zip",
            checksum: "5197d1124fddd8cb9af9473d4d5b40e2e2a3776a841f97d41996751aead966c5"
        ),
        .binaryTarget(
            name: "NotificareInAppMessagingKit",
            url: "https://cdn.notifica.re/libs/ios/3.9.1/spm-notificare-in-app-messaging.zip",
            checksum: "1d15227523578f8184ff9329222b5f4301218f32227cc0f0ab2c08437dc2da5d"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://cdn.notifica.re/libs/ios/3.9.1/spm-notificare-inbox.zip",
            checksum: "23af81487c57cea23a90b49927c4c7502d863a2ed1f122e4aa72bf0db9ca9e04"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://cdn.notifica.re/libs/ios/3.9.1/spm-notificare-loyalty.zip",
            checksum: "9139c83dee13c48a0dfa9c17a707e9a1d8411c1d9349854dffc44cebd2b4c77e"
        ),
        .binaryTarget(
            name: "NotificareMonetizeKit",
            url: "https://cdn.notifica.re/libs/ios/3.9.1/spm-notificare-monetize.zip",
            checksum: "6ab97988cbe242ae54822b1854367a4bb5167f9d3a8e21f26f062c08133863ca"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://cdn.notifica.re/libs/ios/3.9.1/spm-notificare-push.zip",
            checksum: "23c24d5cb0598b1e4f06a07e16174927ae9e9bff334d00135974b05121dfe71b"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://cdn.notifica.re/libs/ios/3.9.1/spm-notificare-notification-service-extension.zip",
            checksum: "ad79596ec7896972ceac1f13aa1dc6e3cf4ccdcd99105ab199b9ec2214996a7e"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://cdn.notifica.re/libs/ios/3.9.1/spm-notificare-push-ui.zip",
            checksum: "41b94c47d3ef6e36485a0d49346756f676bed2fadbf80b8a118d4c4958332c5a"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://cdn.notifica.re/libs/ios/3.9.1/spm-notificare-scannables.zip",
            checksum: "109b5ad0e32fe4a3164a8c42154923b63fdefa4b6cf37539666496c482fe599a"
        ),
        .binaryTarget(
            name: "NotificareUserInboxKit",
            url: "https://cdn.notifica.re/libs/ios/3.9.1/spm-notificare-user-inbox.zip",
            checksum: "4c5f9b4152a87dbed40acecfbe75a9ae6aab3a5bf5ef3a3802415df315bbbf58"
        ),
    ]
)
