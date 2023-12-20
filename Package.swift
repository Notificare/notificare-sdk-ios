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
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.6.1/spm-notificare.zip",
            checksum: "40adb0b71e7f6458de8811b3741ea0ffda74d1a00144788116a14a5625d4bfd8"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.6.1/spm-notificare-assets.zip",
            checksum: "b996026871ce8156a82c802b008c7984e9c615501974b39f2ca0e85a9cabbc0d"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.6.1/spm-notificare-geo.zip",
            checksum: "b011ad8a97e7a072bb3b8b3998a06334cbe1bcb7e537460b5ad4632287b252af"
        ),
        .binaryTarget(
            name: "NotificareInAppMessagingKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.6.1/spm-notificare-in-app-messaging.zip",
            checksum: "b356f65589be33464a2923090cc1c2fdd5edaae0c6e4c71f225d62accbb2a1d9"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.6.1/spm-notificare-inbox.zip",
            checksum: "c9b01eca2e309a252235c584e4e7f3d3d9d7f81622d6441a14176e4f3044aa3b"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.6.1/spm-notificare-loyalty.zip",
            checksum: "85999f1ae7511629a4cfd8af02588a039686da8e8d8dac8eed0b01015dc8a8e7"
        ),
        .binaryTarget(
            name: "NotificareMonetizeKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.6.1/spm-notificare-monetize.zip",
            checksum: "87300f06a334eba78ffa57ba377e009723245a359c6b6b4de8b7f3c9a5ed12aa"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.6.1/spm-notificare-push.zip",
            checksum: "bc847cb8b1337450394837b20213fb9dcf50a6dd071bd4f898c2861695bc2110"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.6.1/spm-notificare-notification-service-extension.zip",
            checksum: "7b396f22b46b608bb8efdb9e8674d4b7964668b2b35f74c49298f460bc444860"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.6.1/spm-notificare-push-ui.zip",
            checksum: "00aa35a70bdaade448d650e6f37e6d9d654dd1cdd60b7c503cc749d2bf21e28d"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.6.1/spm-notificare-scannables.zip",
            checksum: "e145e4967ce26f44f3a748e67b1eea4fccc437655edc595fab2839e76461e956"
        ),
        .binaryTarget(
            name: "NotificareUserInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.6.1/spm-notificare-user-inbox.zip",
            checksum: "43090afa093790d1beb6455a6c4eb8f6b3fba8febac7ba78bb1890304daf84cc"
        ),
    ]
)
