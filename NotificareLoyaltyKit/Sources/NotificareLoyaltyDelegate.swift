//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

public protocol NotificareLoyaltyDelegate: AnyObject {
    func notificare(_ notificareLoyalty: NotificareLoyalty, didReceivePass url: URL, in notification: NotificareNotification)
}
