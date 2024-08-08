//
// Copyright (c) 2024 Notificare. All rights reserved.
//

import Foundation

@propertyWrapper
public struct NotificareExtraEquatable<T>: Equatable {
    public var wrappedValue: T

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }

    public static func == (lhs: NotificareExtraEquatable<T>, rhs: NotificareExtraEquatable<T>) -> Bool {
        if let lho = lhs.wrappedValue as? Any?, let rho = rhs.wrappedValue as? Any? {
            switch (lho, rho) {
            case (.none, .none):
                return true
            default:
                break
            }
        }

        switch (lhs.wrappedValue, rhs.wrappedValue) {
        case let (lhs as Bool, rhs as Bool):
            return lhs == rhs
        case let (lhs as Int, rhs as Int):
            return lhs == rhs
        case let (lhs as Int8, rhs as Int8):
            return lhs == rhs
        case let (lhs as Int16, rhs as Int16):
            return lhs == rhs
        case let (lhs as Int32, rhs as Int32):
            return lhs == rhs
        case let (lhs as Int64, rhs as Int64):
            return lhs == rhs
        case let (lhs as UInt, rhs as UInt):
            return lhs == rhs
        case let (lhs as UInt8, rhs as UInt8):
            return lhs == rhs
        case let (lhs as UInt16, rhs as UInt16):
            return lhs == rhs
        case let (lhs as UInt32, rhs as UInt32):
            return lhs == rhs
        case let (lhs as UInt64, rhs as UInt64):
            return lhs == rhs
        case let (lhs as Float, rhs as Float):
            return lhs == rhs
        case let (lhs as Double, rhs as Double):
            return lhs == rhs
        case let (lhs as String, rhs as String):
            return lhs == rhs
        case let (lhs as [Any], rhs as [Any]):
            if lhs.isEmpty, rhs.isEmpty {
                return true
            }

            if lhs.count != rhs.count {
                return false
            }

            for (lha, rha) in zip(lhs, rhs) {
                let lhv = NotificareExtraEquatable<Any>(wrappedValue: lha)
                let rhv = NotificareExtraEquatable<Any>(wrappedValue: rha)

                guard lhv == rhv  else {
                    return false
                }
            }

            return true
        case let (lhs as [String: Any], rhs as [String: Any]):
            if lhs.isEmpty, rhs.isEmpty {
                return true
            }

            if lhs.count != rhs.count {
                return false
            }

            for (lhk, lhv) in lhs {
                guard let rhv = rhs[lhk] else {
                    return false
                }

                let lhe = NotificareExtraEquatable<Any>(wrappedValue: lhv)
                let rhe = NotificareExtraEquatable<Any>(wrappedValue: rhv)

                guard lhe == rhe else {
                    return false
                }
            }
            return true
        default:
            NotificareLogger.warning("Unable to compare type provided.")
            return false
        }
    }
}
