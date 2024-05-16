//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import NotificareKit
import UIKit

extension NotificarePushImpl: NotificarePushUIApplicationDelegate {
    internal func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken token: Data) {
        applicationDelegateInterceptor.application(application, didRegisterForRemoteNotificationsWithDeviceToken: token)
    }

    internal func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        applicationDelegateInterceptor.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }

    internal func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        applicationDelegateInterceptor.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
    }

    internal func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult {
        await withCheckedContinuation { continuation in
            applicationDelegateInterceptor.application(application, didReceiveRemoteNotification: userInfo) { result in
                continuation.resume(returning: result)
            }
        }
    }
}
