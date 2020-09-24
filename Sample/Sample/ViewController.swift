//
//  ViewController.swift
//  Sample
//
//  Created by Helder Pinhal on 13/07/2020.
//  Copyright © 2020 Notificare. All rights reserved.
//

import UIKit
import NotificareSDK

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func onEnableRemoteNotificationsClick(_ sender: Any) {
        // Notificare.shared.pushManager!.enableRemoteNotifications()
    }

    @IBAction func onSendCustomEventClick(_ sender: Any) {
        let data: NotificareEventData = [
            "color": "blue"
        ]

        Notificare.shared.eventLogger.logCustom("test", data: data)
    }
}
