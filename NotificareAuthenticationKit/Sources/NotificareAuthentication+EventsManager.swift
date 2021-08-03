//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

extension NotificareEventsModule {
    func logUserLogin(_ completion: NotificareCallback<Void>? = nil) {
        log("re.notifica.event.oauth2.Signin", completion)
    }

    func logUserLogout(_ completion: NotificareCallback<Void>? = nil) {
        log("re.notifica.event.oauth2.Signout", completion)
    }

    func logCreateUserAccount(_ completion: NotificareCallback<Void>? = nil) {
        log("re.notifica.event.oauth2.Signup", completion)
    }

    func logSendPasswordReset(_ completion: NotificareCallback<Void>? = nil) {
        log("re.notifica.event.oauth2.SendPassword", completion)
    }

    func logResetPassword(_ completion: NotificareCallback<Void>? = nil) {
        log("re.notifica.event.oauth2.ResetPassword", completion)
    }

    func logChangePassword(_ completion: NotificareCallback<Void>? = nil) {
        log("re.notifica.event.oauth2.NewPassword", completion)
    }

    func logValidateUser(_ completion: NotificareCallback<Void>? = nil) {
        log("re.notifica.event.oauth2.Validate", completion)
    }

    func logFetchUserDetails(_ completion: NotificareCallback<Void>? = nil) {
        log("re.notifica.event.oauth2.Account", completion)
    }

    func logGeneratePushEmailAddress(_ completion: NotificareCallback<Void>? = nil) {
        log("re.notifica.event.oauth2.AccessToken", completion)
    }
}
