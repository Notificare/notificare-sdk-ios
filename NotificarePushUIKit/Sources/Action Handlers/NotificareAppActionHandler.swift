//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit
import NotificareUtilitiesKit
import UIKit

public class NotificareAppActionHandler: NotificareBaseActionHandler {
    private let sourceViewController: UIViewController

    internal init(notification: NotificareNotification, action: NotificareNotification.Action, sourceViewController: UIViewController) {
        self.sourceViewController = sourceViewController

        super.init(notification: notification, action: action)
    }

    internal override func execute() {
        if let target = action.target, let url = URL(string: target), let urlScheme = url.scheme, Bundle.main.getSupportedUrlSchemes().contains(urlScheme) || UIApplication.shared.canOpenURL(url)
        {
            DispatchQueue.main.async {
                UIApplication.shared.open(url, options: [:]) { _ in
                    DispatchQueue.main.async {
                        Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didExecuteAction: self.action, for: self.notification)
                    }

                    Task {
                        try? await Notificare.shared.createNotificationReply(notification: self.notification, action: self.action)
                    }

                    self.dismiss()
                }
            }
        } else {
            DispatchQueue.main.async {
                Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToExecuteAction: self.action, for: self.notification, error: ActionError.unsupportedUrlScheme)
            }
        }
    }

    private func dismiss() {
        if let rootViewController = UIApplication.shared.rootViewController, rootViewController.presentedViewController != nil {
            rootViewController.dismiss(animated: true, completion: nil)
        } else {
            if sourceViewController is UIAlertController {
                UIApplication.shared.rootViewController?.dismiss(animated: true, completion: nil)
            } else {
                sourceViewController.dismiss(animated: true) {
                    self.sourceViewController.becomeFirstResponder()
                }
            }
        }
    }
}

extension NotificareAppActionHandler {
    public enum ActionError: LocalizedError {
        case unsupportedUrlScheme

        public var errorDescription: String? {
            switch self {
            case .unsupportedUrlScheme:
                return "The app cannot open this URL Scheme."
            }
        }
    }
}
