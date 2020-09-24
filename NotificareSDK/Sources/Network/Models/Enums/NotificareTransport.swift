//
// Created by Helder Pinhal on 11/08/2020.
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

public enum NotificareTransport: String, Codable {
    case notificare = "Notificare"
    case apns = "APNS"
}
