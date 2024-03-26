//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit
import UIKit

public class NotificareBaseNotificationViewController: UIViewController {
    internal var notification: NotificareNotification!

    public private(set) var theme: NotificareOptions.Theme?

    internal private(set) var actionsButton: UIBarButtonItem?

    internal var isActionsButtonEnabled: Bool = false {
        didSet {
            renderNavigationBarItems()
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        theme = Notificare.shared.options!.theme(for: self)

        // Update the view controller's title.
        title = notification.title ?? NotificareUtils.applicationName

        // Check if we should show any possible actions
        isActionsButtonEnabled = !notification.actions.isEmpty

        if let colorStr = theme?.backgroundColor {
            view.backgroundColor = UIColor(hexString: colorStr)
        } else {
            if #available(iOS 13.0, *) {
                view.backgroundColor = .systemBackground
            } else {
                view.backgroundColor = .white
            }
        }
    }

    @objc internal func dismissViewController() {
        dismiss(animated: true)
    }

    @objc internal func showActions() {
        let alert: UIAlertController

        if UIDevice.current.userInterfaceIdiom == .pad, let actionsButton {
            alert = UIAlertController(
                title: NotificareUtils.applicationName,
                message: notification.message,
                preferredStyle: .actionSheet
            )

            alert.modalPresentationStyle = .popover
            alert.popoverPresentationController?.barButtonItem = actionsButton
            alert.popoverPresentationController?.permittedArrowDirections = .up
        } else if UIDevice.current.userInterfaceIdiom == .phone {
            alert = UIAlertController(
                title: NotificareUtils.applicationName,
                message: notification.message,
                preferredStyle: .actionSheet
            )

            alert.modalPresentationStyle = .currentContext
        } else {
            alert = UIAlertController(
                title: NotificareUtils.applicationName,
                message: notification.message,
                preferredStyle: .alert
            )
        }

        for action in notification.actions {
            alert.addAction(
                UIAlertAction(title: NotificareLocalizable.string(resource: action.label, fallback: action.label),
                              style: .default,
                              handler: { _ in self.handleAction(action) })
            )
        }

        alert.addAction(
            UIAlertAction(title: NotificareLocalizable.string(resource: .cancelButton),
                          style: .cancel,
                          handler: nil)
        )

        present(alert, animated: true, completion: nil)
    }

    internal func handleAction(_ action: NotificareNotification.Action) {
        Notificare.shared.pushUI().presentAction(action, for: notification, in: self)
    }

    internal func hasNotificareQueryParameters(in url: URL) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return false
        }

        guard let queryItems = components.queryItems else {
            return false
        }

        return queryItems.contains { item -> Bool in
            if item.name == "notificareCloseWindow" || item.name == Notificare.shared.options!.closeWindowQueryParameter {
                return true
            } else if item.name == "notificareOpenActions", item.value == "1" || item.value == "true" {
                return true
            } else if item.name == "notificareOpenAction" {
                return true
            }

            return false
        }
    }

    internal func handleNotificareQueryParameters(for url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return
        }

        guard let queryItems = components.queryItems else {
            return
        }

        for item in queryItems {
            if item.name == "notificareCloseWindow" || item.name == Notificare.shared.options!.closeWindowQueryParameter {
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
                for action in notification.actions {
                    if action.label == item.value {
                        handleAction(action)
                    }
                }
            }
        }
    }

    private func renderNavigationBarItems() {
        if Notificare.shared.options?.legacyNotificationsUserInterfaceEnabled == true {
            renderLegacyNavigationBarItems()
            return
        }

        var leftBarButtonItem: UIBarButtonItem?
        var rightBarButtonItem: UIBarButtonItem?

        if isModal, isActionsButtonEnabled {
            leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .close,
                target: self,
                action: #selector(dismissViewController)
            )
        }

        if isModal, !isActionsButtonEnabled {
            rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .done,
                target: self,
                action: #selector(dismissViewController)
            )
        }

        if isActionsButtonEnabled {
            rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "ellipsis"),
                style: .plain,
                target: self,
                action: #selector(showActions)
            )

            if let colorStr = theme?.actionButtonTextColor {
                rightBarButtonItem?.tintColor = UIColor(hexString: colorStr)
            }

            actionsButton = rightBarButtonItem
        } else {
            actionsButton = nil
        }

        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }

    private func renderLegacyNavigationBarItems() {
        guard isActionsButtonEnabled else {
            navigationItem.rightBarButtonItem = nil
            actionsButton = nil
            return
        }

        if let image = NotificareLocalizable.image(resource: .actions) {
            actionsButton = UIBarButtonItem(image: image,
                                            style: .plain,
                                            target: self,
                                            action: #selector(showActions))
        } else {
            actionsButton = UIBarButtonItem(title: NotificareLocalizable.string(resource: .actionsButton),
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

private extension UIViewController {
    var isModal: Bool {
        if let index = navigationController?.viewControllers.firstIndex(of: self), index > 0 {
            return false
        } else if presentingViewController != nil {
            return true
        } else {
            return false
        }
    }
}
