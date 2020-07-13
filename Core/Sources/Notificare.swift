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
    public private(set) var pushManager: NotificarePushManager? = nil
    public private(set) var locationManager: NotificareLocationManager? = nil
    
    internal let applicationKey = ""
    internal let applicationSecret = ""
    
    
    public func launch() {
        Notificare.shared.logger.info("Launching Notificare.")
        
        self.loadAvailableModules()
    }
    
    public func unlaunch() {
        Notificare.shared.logger.info("Un-launching Notificare.")
    }
    
    private func loadAvailableModules() {
        let factory = NotificareModuleFactory()
        self.pushManager = factory.createPushManager()
        self.locationManager = factory.createLocationManager()
        
        self.verifyLoadedModules()
    }
    
    private func verifyLoadedModules() {
        var modules: [String] = []
        if self.pushManager != nil { modules.append("push") }
        if self.locationManager != nil { modules.append("location") }
        
        if modules.isEmpty {
            Notificare.shared.logger.warning("No modules have been loaded.")
        } else {
            Notificare.shared.logger.info("Loaded modules: [\(modules.joined(separator: ", "))]")
        }
    }
}
