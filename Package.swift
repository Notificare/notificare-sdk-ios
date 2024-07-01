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
            url: "https://cdn.notifica.re/libs/ios/3.10.0/spm-notificare.zip",
            checksum: "dba2d0e34c9d02b5333723d251790a9bae6b2962deb61153a8b5fdde1a845fb2"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://cdn.notifica.re/libs/ios/3.10.0/spm-notificare-assets.zip",
            checksum: "b94aec519e9b5eaba75a5e3f88c21490a27a51743fb1b54173d5667df11ac087"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://cdn.notifica.re/libs/ios/3.10.0/spm-notificare-geo.zip",
            checksum: "0880b46ffa671e8002f6dd924e78416277f6766b2497ef0770b804f21f2c9299"
        ),
        .binaryTarget(
            name: "NotificareInAppMessagingKit",
            url: "https://cdn.notifica.re/libs/ios/3.10.0/spm-notificare-in-app-messaging.zip",
            checksum: "d5136003432724e06d51b9dac6c46bf77473d9facd18560fc2491a6ce700c9f5"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://cdn.notifica.re/libs/ios/3.10.0/spm-notificare-inbox.zip",
            checksum: "4a404afedb0e104e049bd4ffa42a54b91b3a57cc73ea1fcac213689c6f82ef24"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://cdn.notifica.re/libs/ios/3.10.0/spm-notificare-loyalty.zip",
            checksum: "a00733a1b1eb922b9e3e131f7c7fea1a18e1bbbb2529df1cc82a538108f9357f"
        ),
        .binaryTarget(
            name: "NotificareMonetizeKit",
            url: "https://cdn.notifica.re/libs/ios/3.10.0/spm-notificare-monetize.zip",
            checksum: "98ad03b9dfd2459a27443d61e5e8aa55f7365b08e916d2d63e5319d63f6ed71b"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://cdn.notifica.re/libs/ios/3.10.0/spm-notificare-push.zip",
            checksum: "3cf651a87c84f18ba366c5d6e81a9a26f34d5572e9d8f75186341eb6d31c10e1"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://cdn.notifica.re/libs/ios/3.10.0/spm-notificare-notification-service-extension.zip",
            checksum: "3134c0377121c5c4d53d54d70dead03c465b635e49e01428f80cd1cd90a365ea"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://cdn.notifica.re/libs/ios/3.10.0/spm-notificare-push-ui.zip",
            checksum: "eedc8a400ef80a9227a5a91c30b0dff71aad9334c545eaa423a2ff5b250a7459"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://cdn.notifica.re/libs/ios/3.10.0/spm-notificare-scannables.zip",
            checksum: "b0227b37a59015ddb06c12a93e16cc4f20a303b65db8562765d816167d66a0e5"
        ),
        .binaryTarget(
            name: "NotificareUserInboxKit",
            url: "https://cdn.notifica.re/libs/ios/3.10.0/spm-notificare-user-inbox.zip",
            checksum: "ad8d004a6f5b6a162f2813ab3b30896c34e657bd4a33a944191576dec53638f1"
        ),
    ]
)
