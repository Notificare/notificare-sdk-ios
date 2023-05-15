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
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.2/spm-notificare.zip",
            checksum: "3d240a0cc1a6d4d59040194194b7850d89378c390162ce5962205e629dd4d173"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.2/spm-notificare-assets.zip",
            checksum: "461acc1f8a9f6cf02d41ac9a519142f3ab20bdbf86d117ea76c351478ae45533"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.2/spm-notificare-geo.zip",
            checksum: "02688a98de2d89750ce7d5f886c82be32374d3cb1ac6509d3217453b4ba925cd"
        ),
        .binaryTarget(
            name: "NotificareInAppMessagingKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.2/spm-notificare-in-app-messaging.zip",
            checksum: "b623eb617e97432b6799f17f90da30f60a3f23bd67ee8df86ed1bf59e5961961"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.2/spm-notificare-inbox.zip",
            checksum: "4b051e068e0ab6110a3ead4eaf669b66ade7e551e48ba2f90c52293268da09b3"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.2/spm-notificare-loyalty.zip",
            checksum: "ad5bb30b7c833450c974837618bd27f4b810bf3576c3209f03f21df9d3eb9c28"
        ),
        .binaryTarget(
            name: "NotificareMonetizeKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.2/spm-notificare-monetize.zip",
            checksum: "e71644485481db2f6de8d54e7ef348adda021822a547e5b0421f160998df42e2"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.2/spm-notificare-push.zip",
            checksum: "074b9b3cdc24d3ef93d2b229d174572b5470447cfff23baa21640ae1ad9ab76e"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.2/spm-notificare-notification-service-extension.zip",
            checksum: "bd17820e6ca49c8cda88b23b19d89255ff533e2aab6f84eff9381aaeb8df078a"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.2/spm-notificare-push-ui.zip",
            checksum: "0831f51ae6ccb8ea569d96d6e19b56e2b1d607a7770f4e7ca422b39ad243da87"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.2/spm-notificare-scannables.zip",
            checksum: "e8b8c521d28c6e8bdd6e6a7846ba69e8a9186660648016005d97631a3a7451ba"
        ),
        .binaryTarget(
            name: "NotificareUserInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.2/spm-notificare-user-inbox.zip",
            checksum: "4df6f4fc80c39cef5adca0ea60022587b3ed408ce51ddf0f37965aa112465a82"
        ),
    ]
)
