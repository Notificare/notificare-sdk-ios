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
        switch (lhs.wrappedValue, rhs.wrappedValue) {
        case is (Void, Void):
            return true
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
        case let (lhs as [String: NotificareExtraEquatable], rhs as [String: NotificareExtraEquatable]):
            return lhs == rhs
        case let (lhs as [NotificareExtraEquatable], rhs as [NotificareExtraEquatable]):
            return lhs == rhs
        default:
            return false
        }
    }
}
