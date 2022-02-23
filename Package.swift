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
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.0/spm-notificare.zip",
            checksum: "993b463424a624d55d123c814337d6f040b8bab76bdd145092924a82c1e59b6f"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.0/spm-notificare-assets.zip",
            checksum: "584dbbd1cce3a3325548a5afed982373b827a4779d6b1d37857554b6da234160"
        ),
        .binaryTarget(
            name: "NotificareAuthenticationKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.0/spm-notificare-authentication.zip",
            checksum: "2d7b6f3f7e180ad54c21c5a8e4ab2e1787e87e771100511121d9e622e200c66c"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.0/spm-notificare-geo.zip",
            checksum: "ca1e133360c1d3f24ed2cf4800962782f08416d13944df16f8551f268a75b2a7"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.0/spm-notificare-inbox.zip",
            checksum: "14f2b02531dd3327e1b3e0e1f949a115fa29e54ded82ca84c39ad369ba3252eb"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.0/spm-notificare-loyalty.zip",
            checksum: "2b3db7fb15c0f987a44a09395342e528e660957f452add20bfc50220c6b9d2a7"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.0/spm-notificare-push.zip",
            checksum: "8e6d8397e387296eb93890c96fd8edd003bafabbe678f86e43d63d984c54053e"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.0/spm-notificare-notification-service-extension.zip",
            checksum: "d1c746498105b1e055522c44fbbe0a2bf9bee4829bd49bdf09d3fbf27739e7dd"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.0/spm-notificare-push-ui.zip",
            checksum: "e948ae83f40d759ee618a537457116f0412021b5ad5d61973db09184babdc3b4"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.0/spm-notificare-scannables.zip",
            checksum: "d311c876f86e8b364ff819992b6736c38e00fb3a09917a37f8fdc0c680523543"
        ),
    ]
)
