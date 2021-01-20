//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareCore
import NotificareKit

public class NotificareInbox: NSObject, NotificareModule {
    public static let shared = NotificareInbox()

    public weak var delegate: NotificareInboxDelegate?

    public static func configure(applicationKey: String, applicationSecret: String) {
        _ = applicationKey
        _ = applicationSecret
    }

    public static func launch(_ completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }
}
