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
            targets: ["NotificareKit", "NotificareUtilitiesKit"]
        ),
        .library(
            name: "NotificareAssetsKit",
            targets: ["NotificareAssetsKit", "NotificareUtilitiesKit"]
        ),
        .library(
            name: "NotificareGeoKit",
            targets: ["NotificareGeoKit", "NotificareUtilitiesKit"]
        ),
        .library(
            name: "NotificareInAppMessagingKit",
            targets: ["NotificareInAppMessagingKit", "NotificareUtilitiesKit"]
        ),
        .library(
            name: "NotificareInboxKit",
            targets: ["NotificareInboxKit", "NotificareUtilitiesKit"]
        ),
        .library(
            name: "NotificareLoyaltyKit",
            targets: ["NotificareLoyaltyKit", "NotificareUtilitiesKit"]
        ),
        .library(
            name: "NotificareNotificationServiceExtensionKit",
            targets: ["NotificareNotificationServiceExtensionKit"]
        ),
        .library(
            name: "NotificarePushKit",
            targets: ["NotificarePushKit", "NotificareUtilitiesKit"]
        ),
        .library(
            name: "NotificarePushUIKit",
            targets: ["NotificarePushUIKit", "NotificareUtilitiesKit"]
        ),
        .library(
            name: "NotificareScannablesKit",
            targets: ["NotificareScannablesKit", "NotificareUtilitiesKit"]
        ),
        .library(
            name: "NotificareUserInboxKit",
            targets: ["NotificareUserInboxKit", "NotificareUtilitiesKit"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "NotificareKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.1/spm-notificare.zip",
            checksum: "c1702072bbc5db28cba239438eb30d73e7145c4d7be6d803b7996ab6e133dc80"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.1/spm-notificare-assets.zip",
            checksum: "9792313ae97d2e36da3994a41a343f70afcc6681fd35d05914dd0bfe4e362f27"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.1/spm-notificare-geo.zip",
            checksum: "68e02a79bcb1da2d55f994934ddeb73da26be577ba0af6173978ebb9b1a76687"
        ),
        .binaryTarget(
            name: "NotificareInAppMessagingKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.1/spm-notificare-in-app-messaging.zip",
            checksum: "3ecd22372ade6f47dfe484c596f396f4ede8710aa62e6471d1e4c46316588b06"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.1/spm-notificare-inbox.zip",
            checksum: "1b0239025c2bcd650216328413b77a672d9accd38e07bdc8423d5f10557d8456"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.1/spm-notificare-loyalty.zip",
            checksum: "457787e75c3a17975bf1d58103b92c817b0d9b1896df1f00d28b89fa26dbb1ef"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.1/spm-notificare-push.zip",
            checksum: "b12dc62d939956f5a6eb137ab978aebd1d8c37743aa945a6c3ab940c75468c30"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.1/spm-notificare-notification-service-extension.zip",
            checksum: "7a3e637370cdf91704b352adc7df3829be0048970a6f6f1328155cb0a888aa50"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.1/spm-notificare-push-ui.zip",
            checksum: "d719ee59f81b04181ebef7ab1dc6b702f6f3f2302b32be29bc8110a675bbf8fc"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.1/spm-notificare-scannables.zip",
            checksum: "6ee7c2efea40bd05f50e9937d1ebbf65e447bf1c91f45b98d04719e97cb3ea1d"
        ),
        .binaryTarget(
            name: "NotificareUserInboxKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.1/spm-notificare-user-inbox.zip",
            checksum: "8c61e9f98168cd1303e18c66cc3349ec3638106c760d9775ee50c66662ec6af1"
        ),
        .binaryTarget(
            name: "NotificareUtilitiesKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.1/spm-notificare-utilities.zip",
            checksum: "676c0fca732a09cdff7775764a9c4eb120d49d7bc23d9825bd13098299053a00"
        ),
    ]
)
