//
// Created by Helder Pinhal on 15/07/2020.
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

extension URLRequest {
    mutating func setBasicAuthentication(username: String, password: String) {
        let base64encoded = "\(username):\(password)"
                .data(using: .utf8)!
                .base64EncodedString()

        self.addValue("Basic \(base64encoded)", forHTTPHeaderField: "Authorization")
    }

    mutating func setBearerAuthentication(token: String) {
        self.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
}
