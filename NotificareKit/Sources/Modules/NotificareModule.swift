//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

public protocol NotificareModule {
    associatedtype LaunchResult

    func configure(applicationKey: String, applicationSecret: String)

    func launch(_ completion: @escaping (Result<LaunchResult, Error>) -> Void)
}
