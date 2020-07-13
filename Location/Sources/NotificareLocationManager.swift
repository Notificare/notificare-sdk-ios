//
//  NotificareLocationManager.swift
//  Location
//
//  Created by Helder Pinhal on 13/07/2020.
//  Copyright © 2020 Notificare. All rights reserved.
//

import Foundation
import Core

public class NotificareLocationManagerImpl: NSObject, NotificareLocationManager {
    
    private let applicationKey: String
    private let applicationSecret: String
    
    required public init(applicationKey: String, applicationSecret: String) {
        self.applicationKey = applicationKey
        self.applicationSecret = applicationSecret
    }
}
