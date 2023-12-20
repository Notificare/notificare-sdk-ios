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
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/{{VERSION}}/spm-notificare.zip",
            checksum: "{{NOTIFICARE_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "NotificareAssetsKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/{{VERSION}}/spm-notificare-assets.zip",
            checksum: "{{NOTIFICARE_ASSETS_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "NotificareGeoKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/{{VERSION}}/spm-notificare-geo.zip",
            checksum: "{{NOTIFICARE_GEO_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "NotificareInAppMessagingKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/{{VERSION}}/spm-notificare-in-app-messaging.zip",
            checksum: "{{NOTIFICARE_IN_APP_MESSAGING_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "NotificareInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/{{VERSION}}/spm-notificare-inbox.zip",
            checksum: "{{NOTIFICARE_INBOX_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "NotificareLoyaltyKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/{{VERSION}}/spm-notificare-loyalty.zip",
            checksum: "{{NOTIFICARE_LOYALTY_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "NotificareMonetizeKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/{{VERSION}}/spm-notificare-monetize.zip",
            checksum: "{{NOTIFICARE_MONETIZE_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "NotificarePushKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/{{VERSION}}/spm-notificare-push.zip",
            checksum: "{{NOTIFICARE_PUSH_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "NotificareNotificationServiceExtensionKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/{{VERSION}}/spm-notificare-notification-service-extension.zip",
            checksum: "{{NOTIFICARE_NOTIFICATION_SERVICE_EXTENSION_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "NotificarePushUIKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/{{VERSION}}/spm-notificare-push-ui.zip",
            checksum: "{{NOTIFICARE_PUSH_UI_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "NotificareScannablesKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/{{VERSION}}/spm-notificare-scannables.zip",
            checksum: "{{NOTIFICARE_SCANNABLES_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "NotificareUserInboxKit",
            url: "https://github.com/notificare/notificare-sdk-ios/releases/download/{{VERSION}}/spm-notificare-user-inbox.zip",
            checksum: "{{NOTIFICARE_USER_INBOX_CHECKSUM}}"
        ),
    ]
)
