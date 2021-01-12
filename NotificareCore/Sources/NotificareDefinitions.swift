//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

public enum NotificareDefinitions {
    public enum Modules: String, CaseIterable {
        case push = "NotificarePushKit.NotificarePush"
        case pushUI = "NotificarePushUIKit.NotificarePushUI"
    }
}
