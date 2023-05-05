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
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.1/spm-notificare.zip",
            checksum: "1122bafba60bfc9d68f6ec43b5a468b962d30fd6d23df2c7b03b19512870741a"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.1/spm-notificare-assets.zip",
            checksum: "6f9db9bc7cf0866bacec3567c367673399e655178937816564f7a60815e6d2ff"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.1/spm-notificare-geo.zip",
            checksum: "da3751f785fddc4e4d60f4e13ed5592417e5d1a8a47b35ba6b567ceca4cc23b1"
        ),
        .binaryTarget(
            name: "NotificareInAppMessagingKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.1/spm-notificare-in-app-messaging.zip",
            checksum: "272a69ec0925ac04b4052d0d80d912cf0edddf9929841d0c5fc197465aea67c5"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.1/spm-notificare-inbox.zip",
            checksum: "6cf57f6f93e19d50c3f5f83962f1d3956b065585340b6aa4f4bf4f434875d8ed"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.1/spm-notificare-loyalty.zip",
            checksum: "17f5b72d1e13f9bb01c2dec86928939cd07fe7cd9a6ef91c0529a94c3ea1b4a2"
        ),
        .binaryTarget(
            name: "NotificareMonetizeKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.1/spm-notificare-monetize.zip",
            checksum: "816d464bb3e3daf28bb7a2d4b969f5db1728a56a74a8bb97f15829e2cf195154"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.1/spm-notificare-push.zip",
            checksum: "d89f7a3eaf1f02e23a8f20b9343d22c5f5ad3571ae1bfa22b242de77895c420e"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.1/spm-notificare-notification-service-extension.zip",
            checksum: "a88d71b5cc3acf8503848af66a53862e35fb33b8efa6df696b967928381a0c3b"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.1/spm-notificare-push-ui.zip",
            checksum: "e6d8850c582ba857ea7b4925c1359f9779bfe4f2a9f0fd11ccc63336b6c246df"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.1/spm-notificare-scannables.zip",
            checksum: "25cfed9ed5aad97888ff04e11cc8540e464b1cb1bc7cf7dd132edd6e710611c0"
        ),
        .binaryTarget(
            name: "NotificareUserInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.1/spm-notificare-user-inbox.zip",
            checksum: "40d5e1ac43bf7adaef494a91bd2dedc1adfa82488254dd6b696c2421d4026992"
        ),
    ]
)
