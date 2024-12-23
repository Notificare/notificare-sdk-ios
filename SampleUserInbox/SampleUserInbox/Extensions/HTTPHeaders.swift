//
// Copyright (c) 2024 Notificare. All rights reserved.
//

import Alamofire

extension HTTPHeaders {
    static func authorizationHeader(accessToken: String) -> HTTPHeaders {
        return [
            "Authorization": "Bearer \(accessToken)"
        ]
    }
}
