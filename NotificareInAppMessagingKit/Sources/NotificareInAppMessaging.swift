//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation

public protocol NotificareInAppMessaging: AnyObject {
    // MARK: Properties

    var delegate: NotificareInAppMessagingDelegate? { get set }

    var hasMessagesSuppressed: Bool { get set }

    func setMessagesSuppressed(_ suppressed: Bool, evaluateContext: Bool)
}
