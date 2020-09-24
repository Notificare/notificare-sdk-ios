//
//  NotificarePushManager.swift
//  Core
//
//  Created by Helder Pinhal on 13/07/2020.
//  Copyright © 2020 Notificare. All rights reserved.
//

import Foundation

public protocol NotificarePushManager {
    init(applicationKey: String, applicationSecret: String)

    func configure()
}
