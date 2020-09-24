// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Notificare",
    platforms: [
        .iOS(.v10),
    ],
    products: [
        .library(
            name: "NotificareSDK",
            targets: ["NotificareSDK"]
        ),
        .library(
            name: "NotificareAssets",
            targets: ["NotificareAssets"]
        ),
        .library(
            name: "NotificareLocation",
            targets: ["NotificareLocation"]
        ),
        .library(
            name: "NotificareLoyalty",
            targets: ["NotificareLoyalty"]
        ),
        .library(
            name: "NotificareMonetize",
            targets: ["NotificareMonetize"]
        ),
        .library(
            name: "NotificarePush",
            targets: ["NotificarePush"]
        ),
        .library(
            name: "NotificareScannable",
            targets: ["NotificareScannable"]
        ),
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "NotificareSDK",
            path: ".artefacts/NotificareSDK.xcframework"
        ),
        .binaryTarget(
            name: "NotificareAssets",
            path: ".artefacts/NotificareAssets.xcframework"
        ),
        .binaryTarget(
            name: "NotificareLocation",
            path: ".artefacts/NotificareLocation.xcframework"
        ),
        .binaryTarget(
            name: "NotificareLoyalty",
            path: ".artefacts/NotificareLoyalty.xcframework"
        ),
        .binaryTarget(
            name: "NotificareMonetize",
            path: ".artefacts/NotificareMonetize.xcframework"
        ),
        .binaryTarget(
            name: "NotificarePush",
            path: ".artefacts/NotificarePush.xcframework"
        ),
        .binaryTarget(
            name: "NotificareScannable",
            path: ".artefacts/NotificareScannable.xcframework"
        ),
    ]
)
