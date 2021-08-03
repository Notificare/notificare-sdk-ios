//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

struct Credentials: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
}
