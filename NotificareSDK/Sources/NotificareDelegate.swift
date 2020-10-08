//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

public protocol NotificareDelegate: AnyObject {
    func notificare(_ notificare: Notificare, onReady application: NotificareApplication)

    func notificare(_ notificare: Notificare, didRegisterDevice device: NotificareDevice)
}

extension NotificareDelegate {
    func notificare(_: Notificare, didRegisterDevice _: NotificareDevice) {}
}
