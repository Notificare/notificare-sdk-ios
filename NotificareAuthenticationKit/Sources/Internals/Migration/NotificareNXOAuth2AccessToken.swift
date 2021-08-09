//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

class NotificareNXOAuth2AccessToken: NSObject, NSCoding {
    let accessToken: String
    let refreshToken: String

    required init?(coder: NSCoder) {
        accessToken = coder.decodeObject(forKey: "accessToken") as! String
        refreshToken = coder.decodeObject(forKey: "refreshToken") as! String
    }

    func encode(with coder: NSCoder) {
        coder.encode(accessToken, forKey: "accessToken")
        coder.encode(refreshToken, forKey: "refreshToken")
    }
}
