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
        .library(
            name: "NotificareUtilitiesKit",
            targets: ["NotificareUtilitiesKit"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "NotificareKit",
            url: "https://cdn.notifica.re/libs/ios/{{VERSION}}/spm-notificare.zip",
            checksum: "{{NOTIFICARE_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://cdn.notifica.re/libs/ios/{{VERSION}}/spm-notificare-assets.zip",
            checksum: "{{NOTIFICARE_ASSETS_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://cdn.notifica.re/libs/ios/{{VERSION}}/spm-notificare-geo.zip",
            checksum: "{{NOTIFICARE_GEO_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "NotificareInAppMessagingKit",
            url: "https://cdn.notifica.re/libs/ios/{{VERSION}}/spm-notificare-in-app-messaging.zip",
            checksum: "{{NOTIFICARE_IN_APP_MESSAGING_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://cdn.notifica.re/libs/ios/{{VERSION}}/spm-notificare-inbox.zip",
            checksum: "{{NOTIFICARE_INBOX_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://cdn.notifica.re/libs/ios/{{VERSION}}/spm-notificare-loyalty.zip",
            checksum: "{{NOTIFICARE_LOYALTY_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://cdn.notifica.re/libs/ios/{{VERSION}}/spm-notificare-push.zip",
            checksum: "{{NOTIFICARE_PUSH_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://cdn.notifica.re/libs/ios/{{VERSION}}/spm-notificare-notification-service-extension.zip",
            checksum: "{{NOTIFICARE_NOTIFICATION_SERVICE_EXTENSION_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://cdn.notifica.re/libs/ios/{{VERSION}}/spm-notificare-push-ui.zip",
            checksum: "{{NOTIFICARE_PUSH_UI_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://cdn.notifica.re/libs/ios/{{VERSION}}/spm-notificare-scannables.zip",
            checksum: "{{NOTIFICARE_SCANNABLES_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "NotificareUserInboxKit",
            url: "https://cdn.notifica.re/libs/ios/{{VERSION}}/spm-notificare-user-inbox.zip",
            checksum: "{{NOTIFICARE_USER_INBOX_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "NotificareUtilitiesKit",
            url: "https://cdn.notifica.re/libs/ios/{{VERSION}}/spm-notificare-utilities.zip",
            checksum: "{{NOTIFICARE_UTILITIES_CHECKSUM}}"
        ),
    ]
)
