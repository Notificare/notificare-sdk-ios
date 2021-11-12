//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

internal extension NotificareEventsModule {
    func logUserLogin(_ completion: @escaping NotificareCallback<Void>) {
        let this = self as! NotificareInternalEventsModule
        this.log("re.notifica.event.oauth2.Signin", completion)
    }

    func logUserLogout(_ completion: @escaping NotificareCallback<Void>) {
        let this = self as! NotificareInternalEventsModule
        this.log("re.notifica.event.oauth2.Signout", completion)
    }

    func logCreateUserAccount(_ completion: @escaping NotificareCallback<Void>) {
        let this = self as! NotificareInternalEventsModule
        this.log("re.notifica.event.oauth2.Signup", completion)
    }

    func logSendPasswordReset(_ completion: @escaping NotificareCallback<Void>) {
        let this = self as! NotificareInternalEventsModule
        this.log("re.notifica.event.oauth2.SendPassword", completion)
    }

    func logResetPassword(_ completion: @escaping NotificareCallback<Void>) {
        let this = self as! NotificareInternalEventsModule
        this.log("re.notifica.event.oauth2.ResetPassword", completion)
    }

    func logChangePassword(_ completion: @escaping NotificareCallback<Void>) {
        let this = self as! NotificareInternalEventsModule
        this.log("re.notifica.event.oauth2.NewPassword", completion)
    }

    func logValidateUser(_ completion: @escaping NotificareCallback<Void>) {
        let this = self as! NotificareInternalEventsModule
        this.log("re.notifica.event.oauth2.Validate", completion)
    }

    func logFetchUserDetails(_ completion: @escaping NotificareCallback<Void>) {
        let this = self as! NotificareInternalEventsModule
        this.log("re.notifica.event.oauth2.Account", completion)
    }

    func logGeneratePushEmailAddress(_ completion: @escaping NotificareCallback<Void>) {
        let this = self as! NotificareInternalEventsModule
        this.log("re.notifica.event.oauth2.AccessToken", completion)
    }
}
