//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

extension Notificare {
    enum NotificationType: String {
        case none = "re.notifica.notification.None"
        case alert = "re.notifica.notification.Alert"
        case webView = "re.notifica.notification.WebView"
        case url = "re.notifica.notification.URL"
        case urlScheme = "re.notifica.notification.URLScheme"
        case image = "re.notifica.notification.Image"
        case video = "re.notifica.notification.Video"
        case map = "re.notifica.notification.Map"
        case rate = "re.notifica.notification.Rate"
        case passbook = "re.notifica.notification.Passbook"
        case store = "re.notifica.notification.Store"
    }
}
