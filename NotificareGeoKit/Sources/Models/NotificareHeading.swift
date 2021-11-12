//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

public struct NotificareHeading: Codable {
    public let magneticHeading: Double
    public let trueHeading: Double
    public let headingAccuracy: Double
    public let x: Double
    public let y: Double
    public let z: Double
    public let timestamp: Date
}
