//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import NotificareKit
import UIKit

public class NotificarePushManagerImpl: NSObject, NotificarePushModule, NotificareAppDelegateInterceptor {
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

    public func applicationDidBecomeActive(_: UIApplication) {}

    public func applicationWillResignActive(_: UIApplication) {}
}
