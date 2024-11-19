//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation

public protocol NotificareInAppMessaging: AnyObject {
    // MARK: Properties

    /// Specifies the delegate that handles in-app messages lifecycle events
    ///
    /// This property allows setting a delegate conforming to ``NotificareInAppMessagingDelegate`` to respond to various in-app
    /// messages lifecycle events, such as presentation, completion, failures, and actions performed on the message.
    var delegate: NotificareInAppMessagingDelegate? { get set }

    /// Indicates wheter in-app messages are currently suppressed.
    /// 
    /// If *true*, message dispatching and the presentation of in-app messages are temporarily suspended.
    /// When *false*, in-app messages are allowed to be presented.
    var hasMessagesSuppressed: Bool { get set }

    /// Sets the message suppression state
    ///  
    /// When messages are suppressed, in-app messages will not be presented to the user.
    /// By default, stopping the in-app message suppression does not re-evaluate the foreground context.
    ///  
    /// To trigger a new context evaluation after stopping in-app message suppression, set the `evaluateContext`
    /// parameter to `true`.
    /// - Parameters:
    ///   - suppressed: Set to *true* to supress in-app messages, or *false* to stop supressing them.
    ///   - evaluateContext: Set to *true* to re-evaluate the foreground context when stopping in-app messaging supression.
    func setMessagesSuppressed(_ suppressed: Bool, evaluateContext: Bool)
}
