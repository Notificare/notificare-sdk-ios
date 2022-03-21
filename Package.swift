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
            checksum: "963cab5721bad7e95d3f91dbc5bee53bd19e88eb69aa991c003b8504de6e9e62"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.1/spm-notificare-assets.zip",
            checksum: "19bc8dbb015e061834c3617a5c990b46ef5efc758186bdd57bae43a01c663a54"
        ),
        .binaryTarget(
            name: "NotificareAuthenticationKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.1/spm-notificare-authentication.zip",
            checksum: "f2020e81d57aa601b101e3a80228fc2ed2ee03f5882651f8bb11cb25683e6130"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.1/spm-notificare-geo.zip",
            checksum: "447a25d3d4362d6f64d8b5ecccadd180bb610a4ec3a8ac5aa5f414e3916a66ec"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.1/spm-notificare-inbox.zip",
            checksum: "2a2e16cdb154fadf8fa226eb81a8b87acd09df9ca0907ee2a17e17ee365161a9"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.1/spm-notificare-loyalty.zip",
            checksum: "3906029eb13c9b1066593931e14818cb93cf5b864c019a267a25113d4f3aec2c"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.1/spm-notificare-push.zip",
            checksum: "d20b2c0e32ed4d0fa02d5ccd121253a0938b62f9b990497bb171eee5cd39342c"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.1/spm-notificare-notification-service-extension.zip",
            checksum: "498a6e52fcfbf07582b64d1fc510026341b4d04d11be4a56acba365b4bc89bf8"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.1/spm-notificare-push-ui.zip",
            checksum: "e3843c8d2503009d1151821090fa052b999b91deeb8bc2d88fb875f13c3c4f43"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.0.1/spm-notificare-scannables.zip",
            checksum: "eb03e2102c406837fdfb037264ce5fb41cd479a5271402753a03055f93f23346"
        ),
    ]
)
