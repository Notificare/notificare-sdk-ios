//
// Created by Helder Pinhal on 15/07/2020.
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

public enum NotificationAction: String, Codable {
    case app = "re.notifica.action.App"
    case browser = "re.notifica.action.Browser"
    case callback = "re.notifica.action.Callback"
    case custom = "re.notifica.action.Custom"
    case mail = "re.notifica.action.Mail"
    case sms = "re.notifica.action.SMS"
    case telephone = "re.notifica.action.Telephone"
}
