//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit
import UIKit

public class NotificareBaseNotificationViewController: UIViewController {
    var notification: NotificareNotification!

    public private(set) var theme: NotificareOptions.Theme?

    private(set) var actionsButton: UIBarButtonItem?

    var isActionsButtonEnabled: Bool = false {
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

    @objc func dismissViewController() {
        dismiss(animated: true)
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
            UIAlertAction(title: NotificareLocalizable.string(resource: .cancelButton),
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
        Notificare.shared.pushUI().presentAction(action, for: notification, in: self)
    }

    func hasNotificareQueryParameters(in url: URL) -> Bool {
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

    func handleNotificareQueryParameters(for url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return
        }

        guard let queryItems = components.queryItems else {
            return
        }

        queryItems.forEach { item in
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
                notification.actions.forEach { action in
                    if action.label == item.value {
                        handleAction(action)
                    }
                }
            }
        }
    }

    private func renderNavigationBarItems() {
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
        }

        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.rightBarButtonItem = rightBarButtonItem

        actionsButton = rightBarButtonItem
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
