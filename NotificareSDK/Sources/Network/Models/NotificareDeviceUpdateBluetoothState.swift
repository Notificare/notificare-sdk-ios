//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

struct NotificareDeviceUpdateBluetoothState: Encodable {
    let language: String
    let region: String
    let bluetoothEnabled: Bool
}
