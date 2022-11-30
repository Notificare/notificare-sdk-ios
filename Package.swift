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
        .library(
            name: "NotificareUserInboxKit",
            targets: ["NotificareUserInboxKit"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "NotificareKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.0-beta.1/spm-notificare.zip",
            checksum: "c60d5607fcf6d3fd32843d5ccc0fe839659be3de006f7b7299c40ab69ad7e36f"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.0-beta.1/spm-notificare-assets.zip",
            checksum: "e6a9353c99d7b91217eebeaf0a7059dbc2a556c7bcc6754b1ab01dc026b499de"
        ),
        .binaryTarget(
            name: "NotificareAuthenticationKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.0-beta.1/spm-notificare-authentication.zip",
            checksum: "8b82dcdc5630f6dcca7383772f8ffe46674caf3b51ee2e0e8edb93649f7a7281"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.0-beta.1/spm-notificare-geo.zip",
            checksum: "767b6bd2ba5bedc9021895bc59c99e049f6ea68b1c14efb4fcd6bd8fc1b902d0"
        ),
        .binaryTarget(
            name: "NotificareInAppMessagingKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.0-beta.1/spm-notificare-in-app-messaging.zip",
            checksum: "c5670cbbc33076bf5c414392a2dd92570dbea2673b706129b507b233effcfcf4"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.0-beta.1/spm-notificare-inbox.zip",
            checksum: "5eec1daea0a1994a2d4147b6553f77a21f0738135d6b142b867e39c5f23355c3"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.0-beta.1/spm-notificare-loyalty.zip",
            checksum: "45ac8feaca703131b3fa628fd7e7f9228af694766d719d4e10163243109ac31e"
        ),
        .binaryTarget(
            name: "NotificareMonetizeKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.0-beta.1/spm-notificare-monetize.zip",
            checksum: "89c81526eb892360bc590ac5894474b10c46410e4ff1dd4d2fbe26ecade9ce2e"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.0-beta.1/spm-notificare-push.zip",
            checksum: "51c5a9771c7b79dbb00663f86bd9a534c2295d53cb860dec449992d72e6132dd"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.0-beta.1/spm-notificare-notification-service-extension.zip",
            checksum: "99ba1deb4f9294f296092957e0cea549ea6deba31015ed8fc739c18dc6ca7141"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.0-beta.1/spm-notificare-push-ui.zip",
            checksum: "71f2c1a768a7313ca1ae4200126f4522d2ad66c51f6d928e768739c97b8ec520"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.0-beta.1/spm-notificare-scannables.zip",
            checksum: "50e634852e9c0f9a1713aaf4274fdb991c90a9c2ecf560b624a6de083136c9ad"
        ),
        .binaryTarget(
            name: "NotificareUserInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.0-beta.1/spm-notificare-user-inbox.zip",
            checksum: "a94402aa6a625e93abbe7d9fc413de3a0004abb32fc95d99e781bc72eafbc83a"
        ),
    ]
)
