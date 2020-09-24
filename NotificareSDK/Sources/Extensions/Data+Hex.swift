//
// Created by Helder Pinhal on 05/08/2020.
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

extension Data {

    func toHexString() -> String {
        map { String(format: "%02hhx", $0) }.joined()
    }
}
