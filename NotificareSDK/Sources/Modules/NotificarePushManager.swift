//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

public protocol NotificarePushManager {
    init(applicationKey: String, applicationSecret: String)

    func configure()
}
