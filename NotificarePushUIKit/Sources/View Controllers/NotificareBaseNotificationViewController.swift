//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareCore
import NotificarePushKit
import UIKit

public class NotificareBaseNotificationViewController: UIViewController {
    var notification: NotificareNotification!

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

            navigationItem.rightBarButtonItem = actionsButton
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Update the view controller's title.
        title = notification.title

        // Set the theme options.
        // TODO:

        // Check if we should show any possible actions
        isActionsButtonEnabled = !notification.actions.isEmpty
    }

    @objc func showActions() {
        let alert = UIAlertController(title: nil, message: notification.message, preferredStyle: .actionSheet)

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

    func handleAction(_: NotificareNotification.Action) {
        // TODO: Handle action clicked / wants to execute. Should present the according UI.

        // Label found, handle single action.
//                        [[self notificareActions] setRootViewController:self];
//                        [[self notificareActions] setNotification:[self notification]];
//                        [[self notificareActions] handleAction:action];
    }
}
