//
//  NotificareSwizzler.swift
//  Notificare
//
//  Created by Helder Pinhal on 14/07/2020.
//  Copyright © 2020 Notificare. All rights reserved.
//

import Foundation

public class NotificareSwizzler: NSObject {

    private override init() {
    }


    @objc
    public static func setup() {
        Notificare.shared.autoLaunch()

        let configuration = NotificareUtils.getConfiguration()
        guard configuration.swizzlingEnabled else {
            Notificare.shared.logger.warning("Swizzling is not enabled. You will have to forward your AppDelegate events manually. Please check the documentation for more information.")
            return
        }

        Notificare.shared.logger.debug("Performing AppDelegate swizzling.")
        NotificareSwizzler.swizzle()
    }

    private static func swizzle() {
        // TODO: add swizzling logic
    }
}
