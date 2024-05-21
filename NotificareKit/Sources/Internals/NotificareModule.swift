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

extension NotificareModule {
    public func migrate() {}

    public func configure() {}

    public func launch() async throws {}

    public func postLaunch() async throws {}

    public func unlaunch() async throws {}
}
