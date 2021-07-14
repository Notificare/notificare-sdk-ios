//
// Copyright (c) 2020 Notificare. All rights reserved.
//

public enum NotificareDefinitions {
    static let sdkVersion = "3.0.0"
    static let databaseVersion = "3.0.0"

    enum Tasks {
        static let processEvents = "re.notifica.tasks.process.events"
        static let applicationClose = "re.notifica.tasks.applicationClose"
    }

    enum Events {
        static let applicationInstall = "re.notifica.event.application.Install"
        static let applicationRegistration = "re.notifica.event.application.Registration"
        static let applicationUpgrade = "re.notifica.event.application.Upgrade"
        static let applicationOpen = "re.notifica.event.application.Open"
        static let applicationClose = "re.notifica.event.application.Close"
        static let applicationException = "re.notifica.event.application.Exception"

        static let notificationOpen = "re.notifica.event.notification.Open"
    }

    public enum Modules: String, CaseIterable {
        case push = "NotificarePushKit.NotificarePush"
        case pushUI = "NotificarePushUIKit.NotificarePushUI"
        case inbox = "NotificareInboxKit.NotificareInbox"
        case assets = "NotificareAssetsKit.NotificareAssets"
        case scannables = "NotificareScannablesKit.NotificareScannables"
    }
}
