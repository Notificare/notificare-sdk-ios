//
// Copyright (c) 2024 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

internal class NotificationUrlResolver {
    internal static func resolve(_ notification: NotificareNotification) -> UrlResolverResult {
        guard let content = notification.content.first(where: { $0.type == "re.notifica.content.URL"}) else {
            return .none
        }

        guard let urlStr = content.data as? String, !urlStr.isBlank else {
            return .none
        }

        guard let urlComponents = URLComponents(string: urlStr) else {
            return .none
        }

        let isHttpUrl = urlComponents.scheme == "http" || urlComponents.scheme == "https"
        let isDynamicLink = urlComponents.host?.hasSuffix("ntc.re") == true

        if !isHttpUrl || isDynamicLink {
            return .urlScheme
        }

        let webViewQueryParameter = urlComponents.queryItems?.first(where: { $0.name == "notificareWebView" })?.value
        let isWebViewMode = webViewQueryParameter == "1" || webViewQueryParameter?.lowercased() == "true"

        return isWebViewMode ? .webView : .inAppBrowser
    }

    internal enum UrlResolverResult {
        case none
        case urlScheme
        case inAppBrowser
        case webView
    }
}
