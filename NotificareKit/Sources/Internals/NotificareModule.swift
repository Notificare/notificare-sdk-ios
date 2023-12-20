//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

public protocol NotificareModule {
    associatedtype Instance: NotificareModule

    static var instance: Instance { get }

    func migrate()

    func configure()

    func launch(_ completion: @escaping NotificareCallback<Void>)

    func postLaunch() async throws

    func unlaunch(_ completion: @escaping NotificareCallback<Void>)
}

public extension NotificareModule {
    func migrate() {}

    func configure() {}

    func launch(_ completion: @escaping NotificareCallback<Void>) {
        completion(.success(()))
    }

    func postLaunch() async throws {}

    func unlaunch(_ completion: @escaping NotificareCallback<Void>) {
        completion(.success(()))
    }
}
