//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit
import NotificareUtilitiesKit
import UIKit

internal class NotificareAlertController: NotificareNotificationPresenter {
    private let notification: NotificareNotification

    internal init(notification: NotificareNotification) {
        self.notification = notification
    }

    internal func present(in controller: UIViewController) {
        let alert = UIAlertController(title: notification.title ?? Bundle.main.applicationName,
                                      message: notification.message,
                                      preferredStyle: .alert)

        notification.actions.forEach { action in
            alert.addAction(
                UIAlertAction(title: NotificareLocalizable.string(resource: action.label, fallback: action.label),
                              style: .default,
                              handler: { _ in
                                  Notificare.shared.pushUI().presentAction(action, for: self.notification, in: controller)

                                  DispatchQueue.main.async {
                                      Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFinishPresentingNotification: self.notification)
                                  }
                              })
            )
        }

        let useCancelButton = !notification.actions.isEmpty
        alert.addAction(UIAlertAction(title: NotificareLocalizable.string(resource: useCancelButton ? .cancelButton : .okButton),
                                      style: useCancelButton ? .cancel : .default,
                                      handler: { _ in
                                          DispatchQueue.main.async {
                                              Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFinishPresentingNotification: self.notification)
                                          }
                                      }))

        controller.presentOrPush(alert) {
            DispatchQueue.main.async {
                Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didPresentNotification: self.notification)
            }
        }
    }
}
