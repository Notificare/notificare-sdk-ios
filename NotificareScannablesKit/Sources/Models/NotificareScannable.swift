//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

public struct NotificareScannable: Codable {
    public let id: String
    public let name: String
    public let tag: String
    public let type: String
    public let notification: NotificareNotification?
}
