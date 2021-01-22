//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

public enum NotificareDefinitions {
    public enum Modules: String, CaseIterable {
        case push = "NotificarePushKit.NotificarePush"
        case pushUI = "NotificarePushUIKit.NotificarePushUI"
        case inbox = "NotificareInboxKit.NotificareInbox"
    }

    public enum InternalNotification {
        public static let addInboxItem = NSNotification.Name(rawValue: "NotificareInboxKit.AddInboxItem")
        public static let refreshBadge = NSNotification.Name(rawValue: "NotificareInboxKit.RefreshBadge")
    }
}
