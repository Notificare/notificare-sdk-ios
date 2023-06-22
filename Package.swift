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
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.3/spm-notificare.zip",
            checksum: "ccc8008c9ea54859d35a341220b4ae374010666f7ec6861464c89d8a9ea82775"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.3/spm-notificare-assets.zip",
            checksum: "01a0d15669d8efc582f4de5691959b17d5575c809542f5d5d80ea3177caa99e7"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.3/spm-notificare-geo.zip",
            checksum: "75a94f33331f0f7aefcf7a3a801b79bd3b86b39230ba2beb233fe1a025e5081a"
        ),
        .binaryTarget(
            name: "NotificareInAppMessagingKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.3/spm-notificare-in-app-messaging.zip",
            checksum: "5f4e29c8b5dd526974e87f51ecbe07c2ba571324a01998279c223b265ca66fb0"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.3/spm-notificare-inbox.zip",
            checksum: "877a05d79f7c141266f096083061ad7e4748c2e9d6940075f8492cce1ccb509d"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.3/spm-notificare-loyalty.zip",
            checksum: "23f1a1f7a33132b5a4899c6fa9a4af11f04395fc50efbbc0894f074fe4495050"
        ),
        .binaryTarget(
            name: "NotificareMonetizeKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.3/spm-notificare-monetize.zip",
            checksum: "98c6eb9364a6caf9bdcf4884408188a0de4bd704c65d02b7714f113b0a8e217d"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.3/spm-notificare-push.zip",
            checksum: "c73d29138e2989104ac6b525425581a8d395ba988a698b892b9d9f91b4e90f43"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.3/spm-notificare-notification-service-extension.zip",
            checksum: "3fe70ba2276189941e134f238f657ff5a5747d47aa532c44ac66d68aaf1a4e23"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.3/spm-notificare-push-ui.zip",
            checksum: "77178d9b3f63301c50462125620278de9468cf350711ec5145ece8cfdd1ec6a6"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.3/spm-notificare-scannables.zip",
            checksum: "5f2919c2a5720daca4cd177c4bb680b05c08247420d432748eec7a62b6aeb642"
        ),
        .binaryTarget(
            name: "NotificareUserInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.3/spm-notificare-user-inbox.zip",
            checksum: "b68f7f50c3ed5b56df8d93afbba8edeeee4f49e9fc8c760f52059e60b7c52e51"
        ),
    ]
)
