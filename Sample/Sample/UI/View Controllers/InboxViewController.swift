//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareInboxKit
import NotificareKit
import NotificarePushUIKit
import UIKit

class InboxViewController: UITableViewController {
    // Properties
    private var data = [NotificareInboxItem]()

    override func viewDidLoad() {
        // Listen to inbox updates.
        Notificare.shared.inbox().delegate = self

        // Handle long press to show item options.
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onTableViewLongPress(_:)))
        longPressGestureRecognizer.minimumPressDuration = 0.5
        tableView.addGestureRecognizer(longPressGestureRecognizer)

        // Update the navigation title / badge.
        updateBadge()
    }

    override func viewWillAppear(_: Bool) {
        data = Notificare.shared.inbox().items
        tableView.reloadData()
    }

    override func numberOfSections(in _: UITableView) -> Int {
        1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "inbox-item", for: indexPath) as! InboxItemTableViewCell
        cell.item = data[indexPath.row]

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = data[indexPath.row]
        Notificare.shared.inbox().open(item) { result in
            switch result {
            case let .success(notification):
                if let splitViewController = self.splitViewController {
                    if let detailViewController = splitViewController.viewControllers.last as? UINavigationController {
                        NotificarePushUI.shared.presentNotification(notification, in: detailViewController)
                    }
                } else if let navigationController = self.navigationController {
                    NotificarePushUI.shared.presentNotification(notification, in: navigationController)
                }

            case .failure:
                break
            }

            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    @IBAction func onMarkAllAsReadClicked(_: Any) {
        Notificare.shared.inbox().markAllAsRead { _ in }
    }

    @IBAction func onClearClicked(_: Any) {
        Notificare.shared.inbox().clear { _ in }
    }

    @objc private func onTableViewLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began else {
            return
        }

        let touchPoint = gestureRecognizer.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: touchPoint) {
            let item = data[indexPath.row]

            let alert = UIAlertController(title: nil,
                                          message: nil,
                                          preferredStyle: .actionSheet)

            alert.addAction(UIAlertAction(title: "Open",
                                          style: .default,
                                          handler: { _ in
                                              Notificare.shared.inbox().open(item) { result in
                                                  switch result {
                                                  case let .success(notification):
                                                      if let splitViewController = self.splitViewController {
                                                          if let detailViewController = splitViewController.viewControllers.last as? UINavigationController {
                                                              NotificarePushUI.shared.presentNotification(notification, in: detailViewController)
                                                          }
                                                      } else if let navigationController = self.navigationController {
                                                          NotificarePushUI.shared.presentNotification(notification, in: navigationController)
                                                      }

                                                  case .failure:
                                                      break
                                                  }
                                              }
                                          }))

            alert.addAction(UIAlertAction(title: "Mark as read",
                                          style: .default,
                                          handler: { _ in
                                              Notificare.shared.inbox().markAsRead(item) { _ in }
                                          }))

            alert.addAction(UIAlertAction(title: "Delete",
                                          style: .destructive,
                                          handler: { _ in
                                              Notificare.shared.inbox().remove(item) { _ in }
                                          }))

            alert.addAction(UIAlertAction(title: "Cancel",
                                          style: .cancel,
                                          handler: nil))

            if UIDevice.current.userInterfaceIdiom == .pad {
                alert.modalPresentationStyle = .popover
                alert.popoverPresentationController?.permittedArrowDirections = .up
                alert.popoverPresentationController?.sourceView = tableView
                alert.popoverPresentationController?.sourceRect = tableView.rectForRow(at: indexPath)
            } else {
                alert.modalPresentationStyle = .currentContext
            }

            present(alert, animated: true, completion: nil)
        }
    }

    private func updateBadge(_ badge: Int = Notificare.shared.inbox().badge) {
        navigationItem.setTitle("Inbox", subtitle: "\(badge) unread")
    }
}

extension InboxViewController: NotificareInboxDelegate {
    func notificare(_: NotificareInbox, didUpdateBadge badge: Int) {
        updateBadge(badge)
    }

    func notificare(_: NotificareInbox, didUpdateInbox items: [NotificareInboxItem]) {
        data = items
        tableView.reloadData()
    }
}
