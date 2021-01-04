//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

public protocol NotificareModule {
    static func configure(applicationKey: String, applicationSecret: String)

    static func launch(_ completion: @escaping (Result<Void, Error>) -> Void)
}
