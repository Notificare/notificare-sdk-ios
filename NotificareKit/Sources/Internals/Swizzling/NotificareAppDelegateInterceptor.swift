//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import UIKit

@objc
public protocol NotificareAppDelegateInterceptor {
    @objc optional func applicationDidBecomeActive(_ application: UIApplication)

    @objc optional func applicationWillResignActive(_ application: UIApplication)

    @objc optional func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)

    @objc optional func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)

    @objc optional func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)

    @objc optional func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool

    @objc optional func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool
}
