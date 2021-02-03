//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import UIKit
import NotificareInboxKit
import NotificarePushUIKit

class InboxViewController: UITableViewController {
    
    // Properties
    private var data = [NotificareInboxItem]()
    
    override func viewDidLoad() {
        NotificareInbox.shared.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        data = NotificareInbox.shared.items
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "inbox-item", for: indexPath) as! InboxItemTableViewCell
        cell.item = data[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = data[indexPath.row]
        NotificareInbox.shared.open(item) { (result) in
            switch result {
            case .success(let notification):
                NotificarePushUI.shared.presentNotification(notification, in: self.navigationController!)
                
            case .failure:
                break
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    @IBAction func onMarkAllAsReadClicked(_ sender: Any) {
        NotificareInbox.shared.markAllAsRead { _ in }
    }
    
    @IBAction func onClearClicked(_ sender: Any) {
        NotificareInbox.shared.clear { _ in }
    }
}

extension InboxViewController: NotificareInboxDelegate {
    func notificare(_ notificareInbox: NotificareInbox, didUpdateBadge badge: Int) {
        //
    }
    
    func notificare(_ notificareInbox: NotificareInbox, didUpdateInbox items: [NotificareInboxItem]) {
        data = items
        tableView.reloadData()
    }
}
