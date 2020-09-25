//
//  NotificarePushManager.swift
//  Push
//
//  Created by Helder Pinhal on 13/07/2020.
//  Copyright © 2020 Notificare. All rights reserved.
//

import Foundation
import NotificareSDK
import UIKit

public class NotificarePushManagerImpl: NSObject, NotificarePushManager, NotificareAppDelegateInterceptor {
    private let applicationKey: String
    private let applicationSecret: String
    private var interceptorId: String?

    public required init(applicationKey: String, applicationSecret: String) {
        self.applicationKey = applicationKey
        self.applicationSecret = applicationSecret
    }

    public func configure() {
        interceptorId = NotificareSwizzler.addInterceptor(self)
    }

    // MARK: - NotificareInterceptor

    public func applicationDidBecomeActive(_: UIApplication) {
        Notificare.shared.logger.info("PushManager: applicationDidBecomeActive")
    }

    public func applicationWillResignActive(_: UIApplication) {
        Notificare.shared.logger.info("PushManager: applicationWillResignActive")
    }
}
