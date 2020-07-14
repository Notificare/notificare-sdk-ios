//
//  NotificareConfig.swift
//  Notificare
//
//  Created by Helder Pinhal on 13/07/2020.
//  Copyright © 2020 Notificare. All rights reserved.
//

import Foundation

struct NotificareConfig: Codable {
    let autoLaunch: Bool
    let production: Bool
    let developmentApplicationKey: String
    let developmentApplicationSecret: String
    let productionApplicationKey: String
    let productionApplicationSecret: String
}
