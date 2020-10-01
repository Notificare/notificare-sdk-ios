//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

enum NotificareLaunchState: Int {
    case none
    case configured
    case launching
    case ready
}

extension NotificareLaunchState: Comparable {
    public static func < (lhs: NotificareLaunchState, rhs: NotificareLaunchState) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    public static func <= (lhs: NotificareLaunchState, rhs: NotificareLaunchState) -> Bool {
        lhs.rawValue <= rhs.rawValue
    }

    public static func >= (lhs: NotificareLaunchState, rhs: NotificareLaunchState) -> Bool {
        lhs.rawValue >= rhs.rawValue
    }

    public static func > (lhs: NotificareLaunchState, rhs: NotificareLaunchState) -> Bool {
        lhs.rawValue > rhs.rawValue
    }
}
