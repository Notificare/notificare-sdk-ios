//
// Copyright (c) 2024 Notificare. All rights reserved.
//

import Foundation

@propertyWrapper
public struct EncodeNull<T>: Encodable where T: Encodable {
    public let wrappedValue: T?

    public init(wrappedValue: T?) {
        self.wrappedValue = wrappedValue
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch wrappedValue {
        case .some(let value): try container.encode(value)
        case .none: try container.encodeNil()
        }
    }
}
