//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

public protocol NotificareModule {
    static func migrate()

    static func configure()

    static func launch(_ completion: @escaping NotificareCallback<Void>)

    static func unlaunch(_ completion: @escaping NotificareCallback<Void>)
}

public extension NotificareModule {
    static func migrate() {}

    static func configure() {}

    static func launch(_ completion: @escaping NotificareCallback<Void>) {
        completion(.success(()))
    }

    static func unlaunch(_ completion: @escaping NotificareCallback<Void>) {
        completion(.success(()))
    }
}
