//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

public struct NotificareVisit: Codable {
    public let departureDate: Date
    public let arrivalDate: Date
    public let latitude: Double
    public let longitude: Double
}
