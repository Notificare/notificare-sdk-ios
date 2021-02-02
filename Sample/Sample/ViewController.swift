//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import NotificareKit
import NotificarePushKit
import NotificareInboxKit
import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction private func onEnableRemoteNotificationsClick(_: Any) {
        NotificarePush.shared.enableRemoteNotifications { result in
            switch result {
            case .success(let granted):
                print("-----> User allowed notifications: \(granted)")
            case .failure(let error):
                print("-----> Something went wrong: \(error)")
            }
        }
    }

    @IBAction func onSendCustomEventClick(_: Any) {
        let data: NotificareEventData = [
            "color": "blue",
        ]

        Notificare.shared.eventsManager.logCustom("test", data: data)
    }

    @IBAction func onRegisterWithUserClick(_ sender: Any) {
        Notificare.shared.deviceManager.register(userId: "d09f8b8e-2c10-4ae9-82e5-44f1bf627d89", userName: "John Doe") { result in
            switch (result) {
            case .success:
                print("Device registered with user.")
            case let .failure(error):
                print("Failed to register device with user: \(error)")
            }
        }
    }

    @IBAction func onRegisterAnonymousClick(_ sender: Any) {
        Notificare.shared.deviceManager.register(userId: nil, userName: nil) { result in
            switch (result) {
            case .success:
                print("Device registered anonymously.")
            case let .failure(error):
                print("Failed to register device anonymously: \(error)")
            }
        }
    }
    
    @IBAction func onListInboxItemsClick(_ sender: Any) {
        print("-----> Inbox items")
        print(NotificareInbox.shared.items)
    }

    @IBAction func onRefreshBadgeClick(_ sender: Any) {
        NotificareInbox.shared.refreshBadge { (result) in
            switch result {
            case .success(let badge):
                print("-----> Badge: \(badge)")
            case .failure(let error):
                print("-----> Failed to refresh the badge: \(error)")
            }
        }
    }
}
