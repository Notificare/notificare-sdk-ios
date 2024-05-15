//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

public protocol NotificareModule {
    associatedtype Instance: NotificareModule

    static var instance: Instance { get }

    func migrate()

    func configure()

    func launch() async throws

    func postLaunch() async throws

    func unlaunch() async throws
}

public extension NotificareModule {
    func migrate() {}

    func configure() {}

    func launch() async throws {}

    func postLaunch() async throws {}

    func unlaunch() async throws {}
}
