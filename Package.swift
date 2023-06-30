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
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.4/spm-notificare.zip",
            checksum: "038eb236fa5dc54bb4072d91770adff8498a729ceac573432b9044f3881207af"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.4/spm-notificare-assets.zip",
            checksum: "3fced3670e5aa77d96b242039e11d0a0cc732133295ab9c78f77c13e8972be86"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.4/spm-notificare-geo.zip",
            checksum: "ab2b2c21b2014834f55d4bff3282ec4024b247be918cc603e056981810896313"
        ),
        .binaryTarget(
            name: "NotificareInAppMessagingKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.4/spm-notificare-in-app-messaging.zip",
            checksum: "73b4edecc30e2d156d80be723bc5d5c7947429518789375837c784d22466a8cb"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.4/spm-notificare-inbox.zip",
            checksum: "e18ea33ac99eb7850125941bb5145a6231704c6eca4e02a3067f712ddb0a7fe3"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.4/spm-notificare-loyalty.zip",
            checksum: "8d117db8bf038fe8a9c23d720ea673ab5b9b29d08141532e02d2266f97809cda"
        ),
        .binaryTarget(
            name: "NotificareMonetizeKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.4/spm-notificare-monetize.zip",
            checksum: "0d6383c5dd022cd317e1f8baac4e5c5c40c69dec721b87fa6d6015086f1ebfa0"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.4/spm-notificare-push.zip",
            checksum: "5fe63aa3b553d3306776aa4e1976a777a3ceb4cc53f2d17ec7d8434fa5c76640"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.4/spm-notificare-notification-service-extension.zip",
            checksum: "2978c1595e650eff70ec738c9d6e1434c731eb582a93d1f6b867871bd83a72da"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.4/spm-notificare-push-ui.zip",
            checksum: "07a000bdfa1579421c9617b82aec2872b45f5eee8743cf7faf29cf5d68d6c310"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.4/spm-notificare-scannables.zip",
            checksum: "7bf274eb480735c2f762eaede74d78226560d340242a3b58ead0d59666ffaca6"
        ),
        .binaryTarget(
            name: "NotificareUserInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/3.5.4/spm-notificare-user-inbox.zip",
            checksum: "866269c6107279ffdaae7fa584544e1a058d1caafd14000cb05fd84b08e37b16"
        ),
    ]
)
