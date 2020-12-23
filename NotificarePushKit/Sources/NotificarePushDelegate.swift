//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

public protocol NotificarePushDelegate: AnyObject {
    func notificare(_ notificarePush: NotificarePush, didChangeNotificationSettings granted: Bool)
}

extension NotificarePushDelegate {
    func notificare(_: NotificarePush, didChangeNotificationSettings _: Bool) {}
}
