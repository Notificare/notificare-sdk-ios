//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

public protocol NotificareModule {
    static func configure()

    static func launch(_ completion: @escaping (Result<Void, Error>) -> Void)

    static func unlaunch(_ completion: @escaping (Result<Void, Error>) -> Void)
}
