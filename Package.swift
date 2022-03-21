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
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.1/spm-notificare.zip",
            checksum: "397ea00293b0be4ab38f6a80a28ef4b96b7647c2f497b34bfee387162ade40b2"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.1/spm-notificare-assets.zip",
            checksum: "c522456a3dd3efd28a35783fafd5b7b1968f349ac0dc837103195448a9988480"
        ),
        .binaryTarget(
            name: "NotificareAuthenticationKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.1/spm-notificare-authentication.zip",
            checksum: "6270bc97294e8f5b6f4a277b3ef71fb7d2a62e7bcee2ec539eecb9e2d5891473"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.1/spm-notificare-geo.zip",
            checksum: "b4966f5cb51d6c50f9998fb753a1fe69f0a8847ef79eab4a67303c890a9c70e5"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.1/spm-notificare-inbox.zip",
            checksum: "07a08451f4e135ffcbe87e22b525bcd8985315c283adca7073150db5f0822c4e"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.1/spm-notificare-loyalty.zip",
            checksum: "a4a76d0746e8cb647c5c5287d5d968f06f9eefa0d1cf9541cdb9025a20258b8e"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.1/spm-notificare-push.zip",
            checksum: "33153241aea9c71f1feeb803f34100d5f9fae9e0b1ff0f67ef0a47f0873961f3"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.1/spm-notificare-notification-service-extension.zip",
            checksum: "caa88cb75a9ae44898cbf8b50e95185c1a52f1547077ae5a28c0a9c285bcf706"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.1/spm-notificare-push-ui.zip",
            checksum: "bb144bbe4f1a9a513ed3a24647c8519cabf23af80f0a302df47d237ef0f917a5"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.1/spm-notificare-scannables.zip",
            checksum: "75fb6aa1b2851cfe0c2f81e434f36c49727c1d8328c838714d854f188a4d34a3"
        ),
    ]
)
