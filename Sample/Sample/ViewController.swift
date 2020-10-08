//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import NotificareSDK
import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction private func onEnableRemoteNotificationsClick(_: Any) {
        // Notificare.shared.pushManager!.enableRemoteNotifications()
    }

    @IBAction private func onSendCustomEventClick(_: Any) {
        let data: NotificareEventData = [
            "color": "blue",
        ]

        Notificare.shared.eventsManager.logCustom("test", data: data)
    }
}
