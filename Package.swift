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
            url: "https://cdn.notifica.re/libs/ios/4.2.3/spm-notificare.zip",
            checksum: "fe63b13916eac4c214ace0d0d2ad6318501ee1246a9b42e2c2824aa14442273b"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.3/spm-notificare-assets.zip",
            checksum: "f72a1056631800740aef915aee6139fbda591c7b2ae840fc01cbdd40cd3d17f4"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.3/spm-notificare-geo.zip",
            checksum: "7c1d639c69b5fd38591670b19f5ccfe48ae0502394a8d47cb875dbbbaa236be2"
        ),
        .binaryTarget(
            name: "NotificareInAppMessagingKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.3/spm-notificare-in-app-messaging.zip",
            checksum: "a07d0f7b43bd03981220571d9e8e78fe7a70f802e4376073c2ce08bc1ad72255"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.3/spm-notificare-inbox.zip",
            checksum: "895080d30003dc19049515882179c5ef1bbfee7c893d830210b96635119a1ad3"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.3/spm-notificare-loyalty.zip",
            checksum: "06850b8615c1ebc521e90bd990ed9d7a1987eee9ab3010baf07cf7da114ccc38"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.3/spm-notificare-push.zip",
            checksum: "83f092bcdaa82270fd746f8096199e323047a24713acd45cead11cab9ba4fb70"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.3/spm-notificare-notification-service-extension.zip",
            checksum: "8640523a2dfb3b421806ce9853f4d4948527d767e383d5283d75b7e1a6c10c8d"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.3/spm-notificare-push-ui.zip",
            checksum: "b07bc3a350b79a4c1b59cd437cb2078c1f4e63a9033e8ea270e14181304cc95f"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.3/spm-notificare-scannables.zip",
            checksum: "bd433d93fa13730a8b994e8fdd3b4c79546b99c4fdbdb5899cda7fedf0543a4b"
        ),
        .binaryTarget(
            name: "NotificareUserInboxKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.3/spm-notificare-user-inbox.zip",
            checksum: "3f487ea7bd36debb70d903f037755f45a9cb989274ef2e2c3215e2091d82ca38"
        ),
        .binaryTarget(
            name: "NotificareUtilitiesKit",
            url: "https://cdn.notifica.re/libs/ios/4.2.3/spm-notificare-utilities.zip",
            checksum: "a3dfcab3794da0b5f2e6fbb71ac8b111e603a5199055f5f312e24b14dfb3f968"
        ),
    ]
)
