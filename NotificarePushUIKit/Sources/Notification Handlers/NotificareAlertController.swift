//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareCore
import NotificarePushKit
import UIKit

class NotificareAlertController: NotificareNotificationPresenter {
    private let notification: NotificareNotification

    init(notification: NotificareNotification) {
        self.notification = notification
    }

    func present(in controller: UIViewController) {
        let alert = UIAlertController(title: notification.title ?? NotificareUtils.applicationName,
                                      message: notification.message,
                                      preferredStyle: .alert)

        notification.actions.forEach { action in
            alert.addAction(
                UIAlertAction(title: NotificareLocalizable.string(resource: action.label, fallback: action.label),
                              style: .default,
                              handler: { _ in
                                  NotificareBaseNotificationViewController.handleAction(action, for: self.notification)
                              })
            )
        }

        let useCancelButton = !notification.actions.isEmpty
        alert.addAction(UIAlertAction(title: NotificareLocalizable.string(resource: useCancelButton ? .cancel : .ok),
                                      style: useCancelButton ? .cancel : .default,
                                      handler: { _ in
                                          // TODO: [[self delegate] notificationType:self didCloseNotification:[self notification]];
                                      }))

        NotificarePushUI.shared.presentController(alert, in: controller)
    }
}
