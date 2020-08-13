//
//  NotificareDelegate.swift
//  Notificare
//
//  Created by Helder Pinhal on 03/08/2020.
//  Copyright © 2020 Notificare. All rights reserved.
//

import Foundation

public protocol NotificareDelegate {

    func notificare(_ notificare: Notificare, onReady application: NotificareApplicationInfo)

    func notificare(_ notificare: Notificare, didRegisterDevice device: NotificareDevice)
}

extension NotificareDelegate {
    
    func notificare(_ notificare: Notificare, didRegisterDevice device: NotificareDevice) {}
}
