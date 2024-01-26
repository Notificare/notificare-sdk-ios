//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit
import UIKit

public class NotificareTelephoneActionHandler: NotificareBaseActionHandler {
    override func execute() {
        if let target = action.target,
           let url = URL(string: target),
           UIApplication.shared.canOpenURL(url)
        {
            DispatchQueue.main.async {
                UIApplication.shared.open(url, options: [:]) { _ in
                    DispatchQueue.main.async {
                        Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didExecuteAction: self.action, for: self.notification)
                    }

                    Task {
                        do {
                            try await Notificare.shared.createNotificationReply(notification: self.notification, action: self.action)
                        } catch {
                            
                        }
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToExecuteAction: self.action, for: self.notification, error: ActionError.notSupported)
            }
        }
    }
}

public extension NotificareTelephoneActionHandler {
    enum ActionError: LocalizedError {
        case notSupported

        public var errorDescription: String? {
            switch self {
            case .notSupported:
                return "The device does not support this action."
            }
        }
    }
}
