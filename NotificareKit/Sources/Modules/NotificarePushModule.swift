//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

public protocol NotificarePushModule {
    init(applicationKey: String, applicationSecret: String)

    func configure()
}
