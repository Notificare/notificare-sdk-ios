//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareInboxKit
import NotificarePushUIKit
import UIKit

class InboxViewController: UITableViewController {
    // Properties
    private var data = [NotificareInboxItem]()

    override func viewDidLoad() {
        // Listen to inbox updates.
        NotificareInbox.shared.delegate = self

        // Handle long press to show item options.
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onTableViewLongPress(_:)))
        longPressGestureRecognizer.minimumPressDuration = 0.5
        tableView.addGestureRecognizer(longPressGestureRecognizer)

        // Update the navigation title / badge.
        updateBadge()
    }

    override func viewWillAppear(_: Bool) {
        data = NotificareInbox.shared.items
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
        NotificareInbox.shared.open(item) { result in
            switch result {
            case let .success(notification):
                NotificarePushUI.shared.presentNotification(notification, in: self.navigationController!)

            case .failure:
                break
            }

            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    @IBAction func onMarkAllAsReadClicked(_: Any) {
        NotificareInbox.shared.markAllAsRead { _ in }
    }

    @IBAction func onClearClicked(_: Any) {
        NotificareInbox.shared.clear { _ in }
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
                                              NotificareInbox.shared.open(item) { result in
                                                  switch result {
                                                  case let .success(notification):
                                                      NotificarePushUI.shared.presentNotification(notification, in: self.navigationController!)

                                                  case .failure:
                                                      break
                                                  }
                                              }
                                          }))

            alert.addAction(UIAlertAction(title: "Mark as read",
                                          style: .default,
                                          handler: { _ in
                                              NotificareInbox.shared.markAsRead(item)
                                          }))

            alert.addAction(UIAlertAction(title: "Delete",
                                          style: .destructive,
                                          handler: { _ in
                                              NotificareInbox.shared.remove(item) { _ in }
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

    private func updateBadge(_ badge: Int = NotificareInbox.shared.badge) {
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
