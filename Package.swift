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
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0-beta.1/spm-notificare.zip",
            checksum: "d19d047567e632a26ff10a0397fa36f3fd00d1df114bcc2409ba780f3ce4aa52"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0-beta.1/spm-notificare-assets.zip",
            checksum: "11a30d5c4f8b309ce9671ac80f4f123ace80afd5b3fda025bc406c10b767c86a"
        ),
        .binaryTarget(
            name: "NotificareAuthenticationKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0-beta.1/spm-notificare-authentication.zip",
            checksum: "256390e170f4c6fcb02fe8d9917f3d9d0d48b44b371c1446a44865285505f657"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0-beta.1/spm-notificare-geo.zip",
            checksum: "e013ee1558b3d2bf698e1b94c88743ac69624f4c45138d84b1e77b034d3d4440"
        ),
        .binaryTarget(
            name: "NotificareInAppMessagingKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0-beta.1/spm-notificare-in-app-messaging.zip",
            checksum: "94e1948c4bcbf7418a887bb3697f7a1496426a046b547debd5eb58c97c182bca"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0-beta.1/spm-notificare-inbox.zip",
            checksum: "e4bfcd17abbaed3a2e48368a82c5aeeded8dfc0a6a80a4797879e697dfaf3070"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0-beta.1/spm-notificare-loyalty.zip",
            checksum: "d018f51637ae239e5e3b264b1bc7babe5c4fab2f34a6ebfb7e8248f888889f60"
        ),
        .binaryTarget(
            name: "NotificareMonetizeKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0-beta.1/spm-notificare-monetize.zip",
            checksum: "3c40ccc10621ac2c82cd7639f23544acb5883d0b23744d74f63c896c9533017e"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0-beta.1/spm-notificare-push.zip",
            checksum: "3d66fc36acc2a610450dce7164728b10ef7b2ecad198c185dcc909fbf63a7e51"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0-beta.1/spm-notificare-notification-service-extension.zip",
            checksum: "41ae13dccf0dea7ec9c9b5339e6bcbf248f86027e1c6072439e65acca8799026"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0-beta.1/spm-notificare-push-ui.zip",
            checksum: "619917dc7504d8635ddde68cc51465e4b3fc104b2904843d3fda83ef18e74b20"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0-beta.1/spm-notificare-scannables.zip",
            checksum: "ac6e7e73757be2c1fba031ae6cab389988d419bbb1f9b49c6b215cbd18de2f77"
        ),
    ]
)
