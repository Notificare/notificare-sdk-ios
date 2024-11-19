//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

public protocol NotificareAssets: AnyObject {
    /// Fetches a list of ``NotificareAsset`` for a specified group, with a callback.
    ///
    /// - Parameters:
    ///   - group: The name of the group whose assets are to be fetched.
    ///   - completion: A callback that will be invoked with the result of the fetch operation.
    func fetch(group: String, _ completion: @escaping NotificareCallback<[NotificareAsset]>)

    /// Fetches a list of ``NotificareAsset`` for a specified group.
    ///
    /// - Parameters:
    ///   - group: The name of the group whose assets are to be fetched.
    /// - Returns: A list of `NotificareAssets` belonging to a specified group.
    func fetch(group: String) async throws -> [NotificareAsset]
}
