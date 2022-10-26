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
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0/spm-notificare.zip",
            checksum: "01b65ea7d6d13813c7d15fb21706ff0ae820bf1e90eee7187697193b7f3c29e5"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0/spm-notificare-assets.zip",
            checksum: "4edae91b2624456b2807df00527ddb4142610a949bfc3ba0876e45154b0443ee"
        ),
        .binaryTarget(
            name: "NotificareAuthenticationKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0/spm-notificare-authentication.zip",
            checksum: "c4edde9bb6e218dd83456f8e47912135d1e96b309aaea4c1a98af609a3305f99"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0/spm-notificare-geo.zip",
            checksum: "e316d1cd99680f4b4e5b2d61fa8a9c8f80309642a540c708f496e1202fb73c91"
        ),
        .binaryTarget(
            name: "NotificareInAppMessagingKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0/spm-notificare-in-app-messaging.zip",
            checksum: "8cb9b8f80dfde6596fc56b79eb9b8ca82a6d963a17b13d4664ccace6981ed06b"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0/spm-notificare-inbox.zip",
            checksum: "d395b1ec871afb1b06a77f35d0636ab20719e52f578b3e91115e828c48d01d1c"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0/spm-notificare-loyalty.zip",
            checksum: "95451484756f6bc8fed54d262bfeefa1f9dd11c52561d0d5e4e99ec19d2eaaea"
        ),
        .binaryTarget(
            name: "NotificareMonetizeKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0/spm-notificare-monetize.zip",
            checksum: "578e9ed498d8a73e53b97e770ee9ddafdb42b332eacb52051db39a9c6245472d"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0/spm-notificare-push.zip",
            checksum: "323ec60d1680e9bd6d4753f4e774b18b8317a7aeda691b8facec23bbc585de46"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0/spm-notificare-notification-service-extension.zip",
            checksum: "07a7f9c230cc86338f570295e58426b8ce7e13dd73f589d40bbd31c2c2f53d7e"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0/spm-notificare-push-ui.zip",
            checksum: "d475b4dca352bcc1c9f3e606284b9a1eee79fd11c103dc3ebeeab04e840bf0c0"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.4.0/spm-notificare-scannables.zip",
            checksum: "6b05274c8bcc78f2b7fb40f5cf49115ca7c68ae95fde0b42399c78a6571c18c0"
        ),
    ]
)
