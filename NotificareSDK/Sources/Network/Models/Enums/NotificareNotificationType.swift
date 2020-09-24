//
// Created by Helder Pinhal on 15/07/2020.
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

public enum NotificareNotificationType: String, Codable {
    case alert = "re.notifica.notification.Alert"
    case image = "re.notifica.notification.Image"
    case map = "re.notifica.notification.Map"
    case none = "re.notifica.notification.None"
    case passbook = "re.notifica.notification.Passbook"
    case rate = "re.notifica.notification.Rate"
    case store = "re.notifica.notification.Store"
    case url = "re.notifica.notification.URL"
    case urlScheme = "re.notifica.notification.URLScheme"
    case video = "re.notifica.notification.Video"
    case webview = "re.notifica.notification.WebView"
}
