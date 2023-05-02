//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import Foundation
import NotificareKit
import NotificarePushUIKit
import UIKit

extension UIApplication {
    var currentKeyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            // .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .filter(\.isKeyWindow)
            .first
    }

    var rootViewController: UIViewController? {
        currentKeyWindow?.rootViewController
    }

    func present(_ notification: NotificareNotification) {
        guard let rootViewController = rootViewController else {
            return
        }

        if !notification.requiresViewController {
            Notificare.shared.pushUI().presentNotification(notification, in: rootViewController)
            return
        }

        let navigationController = UINavigationController()
        navigationController.view.backgroundColor = .systemBackground

        rootViewController.present(navigationController, animated: true) {
            Notificare.shared.pushUI().presentNotification(notification, in: navigationController)
        }
    }

    func present(_ action: NotificareNotification.Action, for notification: NotificareNotification) {
        guard let rootViewController = rootViewController else {
            return
        }

        Notificare.shared.pushUI().presentAction(action, for: notification, in: rootViewController)
    }
}
