//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareCore
import NotificarePushKit
import UIKit

public class NotificareBaseNotificationViewController: UIViewController {
    var notification: NotificareNotification!

    private var theme: NotificareConfiguration.Theme?

    private(set) var actionsButton: UIBarButtonItem?

    var isActionsButtonEnabled: Bool = false {
        didSet {
            guard isActionsButtonEnabled else {
                navigationItem.rightBarButtonItem = nil
                return
            }

            if let image = NotificareLocalizable.image(resource: .actions) {
                actionsButton = UIBarButtonItem(image: image,
                                                style: .plain,
                                                target: self,
                                                action: #selector(showActions))
            } else {
                actionsButton = UIBarButtonItem(title: NotificareLocalizable.string(resource: .actions),
                                                style: .plain,
                                                target: self,
                                                action: #selector(showActions))
            }

            if let colorStr = theme?.actionButtonTextColor {
                actionsButton?.tintColor = UIColor(hexString: colorStr)
            }

            navigationItem.rightBarButtonItem = actionsButton
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        theme = NotificareUtils.getConfiguration()?.theme(for: self)

        // Update the view controller's title.
        title = notification.title ?? NotificareUtils.applicationName

        // Check if we should show any possible actions
        isActionsButtonEnabled = !notification.actions.isEmpty
    }

    @objc func showActions() {
        let alert = UIAlertController(title: NotificareUtils.applicationName,
                                      message: notification.message,
                                      preferredStyle: .actionSheet)

        notification.actions.forEach { action in
            alert.addAction(
                UIAlertAction(title: NotificareLocalizable.string(resource: action.label, fallback: action.label),
                              style: .default,
                              handler: { _ in self.handleAction(action) })
            )
        }

        alert.addAction(
            UIAlertAction(title: NotificareLocalizable.string(resource: .cancel),
                          style: .cancel,
                          handler: nil)
        )

        if UIDevice.current.userInterfaceIdiom == .pad {
            alert.modalPresentationStyle = .popover
            alert.popoverPresentationController?.barButtonItem = actionsButton
        } else {
            alert.modalPresentationStyle = .currentContext
        }

        present(alert, animated: true, completion: nil)
    }

    func handleAction(_ action: NotificareNotification.Action) {
        NotificareBaseNotificationViewController.handleAction(action, for: notification)
    }

    func hasNotificareQueryParameters(in url: URL) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return false
        }

        guard let queryItems = components.queryItems else {
            return false
        }

        return queryItems.contains { (item) -> Bool in
            if item.name == "notificareCloseWindow" || item.name == NotificareUtils.getConfiguration()?.options?.closeWindowQueryParameter {
                return true
            } else if item.name == "notificareOpenActions", item.value == "1" || item.value == "true" {
                return true
            } else if item.name == "notificareOpenAction" {
                return true
            }

            return false
        }
    }

    func handleNotificareQueryParameters(for url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return
        }

        guard let queryItems = components.queryItems else {
            return
        }

        queryItems.forEach { item in
            if item.name == "notificareCloseWindow" || item.name == NotificareUtils.getConfiguration()?.options?.closeWindowQueryParameter {
                if item.value == "1" || item.value == "true" {
                    if let rootViewController = UIApplication.shared.keyWindow?.rootViewController, rootViewController.presentedViewController != nil {
                        rootViewController.dismiss(animated: true, completion: nil)
                    } else {
                        navigationController?.popViewController(animated: true)
                    }
                }
            } else if item.name == "notificareOpenActions", item.value == "1" || item.value == "true" {
                showActions()
            } else if item.name == "notificareOpenAction" {
                // A query param to open a single action is present, let's loop over the actins and match the label.
                notification.actions.forEach { action in
                    if action.label == item.value {
                        handleAction(action)
                    }
                }
            }
        }
    }

    static func handleAction(_ action: NotificareNotification.Action, for notification: NotificareNotification) {
        NotificarePush.shared.delegate?.notificare(NotificarePush.shared, didOpenAction: action, for: notification, with: nil)
    }
}
