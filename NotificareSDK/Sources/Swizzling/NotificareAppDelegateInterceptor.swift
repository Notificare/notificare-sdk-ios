//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import UIKit

@objc
public protocol NotificareAppDelegateInterceptor {
    @objc optional func applicationDidBecomeActive(_ application: UIApplication)

    @objc optional func applicationWillResignActive(_ application: UIApplication)

    @objc optional func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)

    @objc optional func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)

    @objc optional func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any])
}
