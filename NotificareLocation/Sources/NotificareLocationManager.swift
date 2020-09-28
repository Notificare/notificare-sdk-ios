//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import NotificareSDK

public class NotificareLocationManagerImpl: NSObject, NotificareLocationManager {
    private let applicationKey: String
    private let applicationSecret: String

    public required init(applicationKey: String, applicationSecret: String) {
        self.applicationKey = applicationKey
        self.applicationSecret = applicationSecret
    }
}
