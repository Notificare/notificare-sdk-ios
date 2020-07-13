//
//  Notificare.swift
//  Core
//
//  Created by Helder Pinhal on 13/07/2020.
//  Copyright © 2020 Notificare. All rights reserved.
//

import Foundation

public class Notificare {
    
    public static let shared = Notificare()
    
    
    public var logger = NotificareLogger()
    
    internal let applicationKey = ""
    internal let applicationSecret = ""
    
    
    public func launch() {
        Notificare.shared.logger.info("Launching Notificare.")
    }
    
    public func unlaunch() {
        Notificare.shared.logger.info("Un-launching Notificare.")
    }
}
