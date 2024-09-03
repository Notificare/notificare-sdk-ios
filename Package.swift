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
            url: "https://cdn.notifica.re/libs/ios/4.0.0-beta.2/spm-notificare.zip",
            checksum: "6f3680de1dafe9d98f9b222902d8e51203160c1781777bf6a8f8c234f2cd0fc4"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.0-beta.2/spm-notificare-assets.zip",
            checksum: "0c5f4c51c05f4af3e5556bf18bc5c895b18f44ce241e8fa026aca1176d554d35"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.0-beta.2/spm-notificare-geo.zip",
            checksum: "35ded6f55b22c441d4bf1b59c11ff3f55cac93a714503ce057803485cf2d4cdf"
        ),
        .binaryTarget(
            name: "NotificareInAppMessagingKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.0-beta.2/spm-notificare-in-app-messaging.zip",
            checksum: "6502581af93e381567ee039f474ee9dd60aa9aede4de772683a95e19ab747bd1"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.0-beta.2/spm-notificare-inbox.zip",
            checksum: "41fb95517947dcb5cd83b388f7f71bd6f992b847fbc79b89caed95d4d04c7a6a"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.0-beta.2/spm-notificare-loyalty.zip",
            checksum: "b35331ddca79f7b39c1493cbdb6b4bf53124113db95fdc484350188391573ee1"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.0-beta.2/spm-notificare-push.zip",
            checksum: "12977d956fb51af617e622ddb36d95e3de5cfa7ef71dda33c2647061926489c6"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.0-beta.2/spm-notificare-notification-service-extension.zip",
            checksum: "bf3959c26e0232d4c27a9e48c2c0fbf5c88594218a59ee5d8e759b73656d7377"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.0-beta.2/spm-notificare-push-ui.zip",
            checksum: "56abd87bc7710e4e5528d6ea847ae65411bebd577417b91c0d7bdbb0cb310bdf"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.0-beta.2/spm-notificare-scannables.zip",
            checksum: "1da7889df9e2059157dea38b7c7cb758aa43d1f96765c48e1a8693d7903c175f"
        ),
        .binaryTarget(
            name: "NotificareUserInboxKit",
            url: "https://cdn.notifica.re/libs/ios/4.0.0-beta.2/spm-notificare-user-inbox.zip",
            checksum: "5c1b5e210ad1714cd761387bc15e96ee2d0239a1a851ba737128c8a45597a17a"
        ),
    ]
)
