#if canImport(Foundation)
    import Foundation
#endif

/**
 A type-erased `Decodable` value.
 The `NotificareAnyDecodable` type forwards decoding responsibilities
 to an underlying value, hiding its specific underlying type.
 You can decode mixed-type values in dictionaries
 and other collections that require `Decodable` conformance
 by declaring their contained type to be `NotificareAnyDecodable`:
     let json = """
     {
         "boolean": true,
         "integer": 42,
         "double": 3.141592653589793,
         "string": "string",
         "array": [1, 2, 3],
         "nested": {
             "a": "alpha",
             "b": "bravo",
             "c": "charlie"
         }
     }
     """.data(using: .utf8)!
     let decoder = JSONDecoder()
     let dictionary = try! decoder.decode([String: NotificareAnyDecodable].self, from: json)
 */
#if swift(>=5.1)
    @frozen public struct NotificareAnyDecodable: Decodable {
        public let value: Any

        public init<T>(_ value: T?) {
            self.value = value ?? ()
        }
    }
#else
    public struct NotificareAnyDecodable: Decodable {
        public let value: Any

        public init<T>(_ value: T?) {
            self.value = value ?? ()
        }
    }
#endif

#if swift(>=4.2)
    @usableFromInline
    internal protocol _NotificareAnyDecodable {
        var value: Any { get }
        init<T>(_ value: T?)
    }
#else
    internal protocol _NotificareAnyDecodable {
        var value: Any { get }
        init<T>(_ value: T?)
    }
#endif

extension NotificareAnyDecodable: _NotificareAnyDecodable {}

// swiftformat:disable extensionAccessControl
extension _NotificareAnyDecodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            #if canImport(Foundation)
                self.init(NSNull())
            #else
                self.init(Self?.none)
            #endif
        } else if let bool = try? container.decode(Bool.self) {
            self.init(bool)
        } else if let int = try? container.decode(Int.self) {
            self.init(int)
        } else if let uint = try? container.decode(UInt.self) {
            self.init(uint)
        } else if let double = try? container.decode(Double.self) {
            self.init(double)
        } else if let string = try? container.decode(String.self) {
            self.init(string)
        } else if let array = try? container.decode([NotificareAnyDecodable].self) {
            self.init(array.map(\.value))
        } else if let dictionary = try? container.decode([String: NotificareAnyDecodable].self) {
            self.init(dictionary.mapValues { $0.value })
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "NotificareAnyDecodable value cannot be decoded")
        }
    }
}

extension NotificareAnyDecodable: Equatable {
    public static func == (lhs: NotificareAnyDecodable, rhs: NotificareAnyDecodable) -> Bool {
        switch (lhs.value, rhs.value) {
        #if canImport(Foundation)
            case is (NSNull, NSNull), is (Void, Void):
                return true
        #endif
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
        case let (lhs as [String: NotificareAnyDecodable], rhs as [String: NotificareAnyDecodable]):
            return lhs == rhs
        case let (lhs as [NotificareAnyDecodable], rhs as [NotificareAnyDecodable]):
            return lhs == rhs
        default:
            return false
        }
    }
}

extension NotificareAnyDecodable: CustomStringConvertible {
    public var description: String {
        switch value {
        case is Void:
            return String(describing: nil as Any?)
        case let value as CustomStringConvertible:
            return value.description
        default:
            return String(describing: value)
        }
    }
}

extension NotificareAnyDecodable: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch value {
        case let value as CustomDebugStringConvertible:
            return "NotificareAnyDecodable(\(value.debugDescription))"
        default:
            return "NotificareAnyDecodable(\(description))"
        }
    }
}
