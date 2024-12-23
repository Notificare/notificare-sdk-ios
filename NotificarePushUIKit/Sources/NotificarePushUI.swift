//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit
import UIKit

public protocol NotificarePushUI: AnyObject {
    // MARK: Properties

    /// Specifies the delegate that handles notification lifecycle events
    ///
    /// This property allows setting a delegate conforming to ``NotificarePushUIDelegate`` to respond to various notification lifecycle events,
    /// such as when a notification is presented, actions are executed, or errors occur.
    var delegate: NotificarePushUIDelegate? { get set }

    // MARK: Methods

    /// Presents a notification to the user.
    ///
    /// This method launches the UI for displaying the provided ``NotificareNotification`` on the provided ``UIViewController``.
    ///
    /// - Parameters:
    ///   - notification: The ``NotificareNotification`` to present.
    ///   - controller: The ``UIViewController`` in which to present the notification.
    func presentNotification(_ notification: NotificareNotification, in controller: UIViewController)

    /// Presents an action associated with a notification.
    ///
    /// This method presents the UI for executing a specific ``NotificareNotification.Action`` associated with the provided ``NotificareNotification``.
    ///
    /// - Parameters:
    ///   - action: The ``NotificareNotification.Action`` to execute.
    ///   - notification: The ``NotificareNotification`` to present.
    ///   - controller: The ``UIViewController`` in which to present the action.
    func presentAction(_ action: NotificareNotification.Action, for notification: NotificareNotification, in controller: UIViewController)
}
