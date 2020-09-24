//
//  NotificarePushManager.swift
//  Push
//
//  Created by Helder Pinhal on 13/07/2020.
//  Copyright © 2020 Notificare. All rights reserved.
//

import Foundation
import UIKit
import NotificareSDK

public class NotificarePushManagerImpl: NSObject, NotificarePushManager, NotificareAppDelegateInterceptor {

    private let applicationKey: String
    private let applicationSecret: String
    private var interceptorId: String?

    required public init(applicationKey: String, applicationSecret: String) {
        self.applicationKey = applicationKey
        self.applicationSecret = applicationSecret
    }

    public func configure() {
        self.interceptorId = NotificareSwizzler.addInterceptor(self)
    }
    
    
    // MARK: - NotificareInterceptor
    public func applicationDidBecomeActive(_ application: UIApplication) {
        Notificare.shared.logger.info("PushManager: applicationDidBecomeActive")
    }

    public func applicationWillResignActive(_ application: UIApplication) {
        Notificare.shared.logger.info("PushManager: applicationWillResignActive")
    }
}
