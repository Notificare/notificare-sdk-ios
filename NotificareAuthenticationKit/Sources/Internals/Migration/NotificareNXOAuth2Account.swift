//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

class NotificareNXOAuth2Account: NSObject, NSCoding {
    let accountType: String
    let identifier: String
    let accessToken: NotificareNXOAuth2AccessToken

    required init?(coder: NSCoder) {
        accountType = coder.decodeObject(forKey: "accountType") as! String
        identifier = coder.decodeObject(forKey: "identifier") as! String
        accessToken = coder.decodeObject(forKey: "accessToken") as! NotificareNXOAuth2AccessToken
    }

    func encode(with coder: NSCoder) {
        coder.encode(accountType, forKey: "accountType")
        coder.encode(identifier, forKey: "identifier")
    }
}
