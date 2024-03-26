//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit
import UIKit

public class NotificareAppActionHandler: NotificareBaseActionHandler {
    internal override func execute() {
        if
            let target = action.target,
            let url = URL(string: target),
            let urlScheme = url.scheme,
            NotificareUtils.getSupportedUrlSchemes().contains(urlScheme) || UIApplication.shared.canOpenURL(url)
        {
            DispatchQueue.main.async {
                UIApplication.shared.open(url, options: [:]) { _ in
                    DispatchQueue.main.async {
                        Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didExecuteAction: self.action, for: self.notification)
                    }

                    Task {
                        try? await Notificare.shared.createNotificationReply(notification: self.notification, action: self.action)
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToExecuteAction: self.action, for: self.notification, error: ActionError.unsupportedUrlScheme)
            }
        }
    }
}

public extension NotificareAppActionHandler {
    enum ActionError: LocalizedError {
        case unsupportedUrlScheme

        public var errorDescription: String? {
            switch self {
            case .unsupportedUrlScheme:
                return "The app cannot open this URL Scheme."
            }
        }
    }
}
