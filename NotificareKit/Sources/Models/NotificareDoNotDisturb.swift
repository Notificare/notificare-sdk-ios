//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

public struct NotificareDoNotDisturb: Codable {
    public let start: NotificareTime
    public let end: NotificareTime

    public init(start: NotificareTime, end: NotificareTime) {
        self.start = start
        self.end = end
    }
}
