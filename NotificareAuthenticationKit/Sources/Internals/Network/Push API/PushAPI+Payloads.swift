//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

internal extension NotificareInternals.PushAPI.Payloads {
    struct CreateAccount: Encodable {
        let email: String
        let password: String
        let name: String?
    }

    struct ChangePassword: Encodable {
        let password: String
    }

    struct SendPasswordReset: Encodable {
        let email: String
    }

    struct ResetPassword: Encodable {
        let password: String
    }
}
