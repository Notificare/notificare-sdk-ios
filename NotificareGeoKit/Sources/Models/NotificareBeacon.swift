//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import CoreLocation
import Foundation
import NotificareKit

public struct NotificareBeacon: Codable, Hashable {
    public let id: String
    public let name: String
    public let major: Int
    public let minor: Int?
    public let triggers: Bool
    public internal(set) var proximity: Proximity?

    public enum Proximity: String, Codable {
        case immediate
        case near
        case far
    }
}
