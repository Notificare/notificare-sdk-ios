//
// Copyright (c) 2020 Notificare. All rights reserved.
//

@testable import NotificareKit
import Testing

internal struct NotificareExtraEquatableTest {
    internal struct testStruct: Equatable {
        @NotificareExtraEquatable internal var extra: Any?
    }

    @Test
    internal func testNotificareExtraEquatableWrongType() {
        let firstObject = testStruct(extra: Date())
        let secondObject = testStruct(extra: Date())

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableNils() {
        let firstObject = testStruct(extra: nil)
        let secondObject = testStruct(extra: nil)

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableBool() {
        let firstObject = testStruct(extra: Bool(true))
        let secondObject = testStruct(extra: Bool(true))

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongBool() {
        let firstObject = testStruct(extra: true)
        let secondObject = testStruct(extra: false)

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableInt() {
        let firstObject = testStruct(extra: Int(5))
        let secondObject = testStruct(extra: Int(5))

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongInt() {
        let firstObject = testStruct(extra: Int(5))
        let secondObject = testStruct(extra: Int(6))

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableInt8() {
        let firstObject = testStruct(extra: Int8(125))
        let secondObject = testStruct(extra: Int8(125))

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongInt8() {
        let firstObject = testStruct(extra: Int8(125))
        let secondObject = testStruct(extra: Int8(126))

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableInt16() {
        let firstObject = testStruct(extra: Int16(32765))
        let secondObject = testStruct(extra: Int16(32765))

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongInt16() {
        let firstObject = testStruct(extra: Int16(32765))
        let secondObject = testStruct(extra: Int16(32766))

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableInt32() {
        let firstObject = testStruct(extra: Int32(2147483645))
        let secondObject = testStruct(extra: Int32(2147483645))

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongInt32() {
        let firstObject = testStruct(extra: Int32(2147483645))
        let secondObject = testStruct(extra: Int32(2147483646))

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableInt64() {
        let firstObject = testStruct(extra: Int64(9223372036854775805))
        let secondObject = testStruct(extra: Int64(9223372036854775805))

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongInt64() {
        let firstObject = testStruct(extra: Int64(9223372036854775805))
        let secondObject = testStruct(extra: Int64(9223372036854775806))

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableUInt() {
        let firstObject = testStruct(extra: UInt(5))
        let secondObject = testStruct(extra: UInt(5))

        #expect(firstObject == secondObject)
    }
    @Test
    internal func testNotificareExtraEquatableWrongUInt() {
        let firstObject = testStruct(extra: UInt(5))
        let secondObject = testStruct(extra: UInt(6))

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableUInt8() {
        let firstObject = testStruct(extra: UInt8(125))
        let secondObject = testStruct(extra: UInt8(125))

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUInt8() {
        let firstObject = testStruct(extra: UInt8(125))
        let secondObject = testStruct(extra: UInt8(126))

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableUInt16() {
        let firstObject = testStruct(extra: UInt16(32765))
        let secondObject = testStruct(extra: UInt16(32765))

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUInt16() {
        let firstObject = testStruct(extra: UInt16(32765))
        let secondObject = testStruct(extra: UInt16(32766))

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableUInt32() {
        let firstObject = testStruct(extra: UInt32(2147483645))
        let secondObject = testStruct(extra: UInt32(2147483645))

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUInt32() {
        let firstObject = testStruct(extra: UInt32(2147483645))
        let secondObject = testStruct(extra: UInt32(2147483646))

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableUInt64() {
        let firstObject = testStruct(extra: UInt64(9223372036854775805))
        let secondObject = testStruct(extra: UInt64(9223372036854775805))

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUInt64() {
        let firstObject = testStruct(extra: UInt64(9223372036854775805))
        let secondObject = testStruct(extra: UInt64(9223372036854775806))

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableFloat() {
        let firstObject = testStruct(extra: Float(3.14))
        let secondObject = testStruct(extra: Float(3.14))

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongFloat() {
        let firstObject = testStruct(extra: Float(3.14))
        let secondObject = testStruct(extra: Float(2.71))

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableDouble() {
        let firstObject = testStruct(extra: Double(3.14))
        let secondObject = testStruct(extra: Double(3.14))

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongDouble() {
        let firstObject = testStruct(extra: Double(3.14))
        let secondObject = testStruct(extra: Double(2.71))

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableString() {
        let firstObject = testStruct(extra: String("pi"))
        let secondObject = testStruct(extra: String("pi"))

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongString() {
        let firstObject = testStruct(extra: String("pi"))
        let secondObject = testStruct(extra: String("euler"))

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableEmptyArray() {
        let firstObject = testStruct(extra: [])
        let secondObject = testStruct(extra: [])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableDiferentSizeArray() {
        let firstObject = testStruct(extra: ["true", false])
        let secondObject = testStruct(extra: ["true"])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongTypeArray() {
        let firstObject = testStruct(extra: [Date(), Date()])
        let secondObject = testStruct(extra: [Date(), Date()])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableNilsArray() {
        let firstObject = testStruct(extra: [nil, nil])
        let secondObject = testStruct(extra: [nil, nil])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableBoolArray() {
        let firstObject = testStruct(extra: [Bool(true)])
        let secondObject = testStruct(extra: [Bool(true)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongBoolArray() {
        let firstObject = testStruct(extra: [Bool(true)])
        let secondObject = testStruct(extra: [Bool(false)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableIntArray() {
        let firstObject = testStruct(extra: [Int(5)])
        let secondObject = testStruct(extra: [Int(5)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongIntArray() {
        let firstObject = testStruct(extra: [Int(5)])
        let secondObject = testStruct(extra: [Int(6)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableInt8Array() {
        let firstObject = testStruct(extra: [Int8(125)])
        let secondObject = testStruct(extra: [Int8(125)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongInt8Array() {
        let firstObject = testStruct(extra: [Int8(125)])
        let secondObject = testStruct(extra: [Int8(126)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableInt16Array() {
        let firstObject = testStruct(extra: [Int16(32765)])
        let secondObject = testStruct(extra: [Int16(32765)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongInt16Array() {
        let firstObject = testStruct(extra: [Int16(32765)])
        let secondObject = testStruct(extra: [Int16(32766)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableInt32Array() {
        let firstObject = testStruct(extra: [Int32(2147483645)])
        let secondObject = testStruct(extra: [Int32(2147483645)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongInt32Array() {
        let firstObject = testStruct(extra: [Int32(2147483645)])
        let secondObject = testStruct(extra: [Int32(2147483646)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableInt64Array() {
        let firstObject = testStruct(extra: [Int64(9223372036854775805)])
        let secondObject = testStruct(extra: [Int64(9223372036854775805)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongInt64Array() {
        let firstObject = testStruct(extra: [Int64(9223372036854775805)])
        let secondObject = testStruct(extra: [Int64(9223372036854775806)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableUIntArray() {
        let firstObject = testStruct(extra: [UInt(5)])
        let secondObject = testStruct(extra: [UInt(5)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUIntArray() {
        let firstObject = testStruct(extra: [UInt(5)])
        let secondObject = testStruct(extra: [UInt(6)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableUInt8Array() {
        let firstObject = testStruct(extra: [UInt8(125)])
        let secondObject = testStruct(extra: [UInt8(125)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUInt8Array() {
        let firstObject = testStruct(extra: [UInt8(125)])
        let secondObject = testStruct(extra: [UInt8(126)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableUInt16Array() {
        let firstObject = testStruct(extra: [UInt16(32765)])
        let secondObject = testStruct(extra: [UInt16(32765)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUInt16Array() {
        let firstObject = testStruct(extra: [UInt16(32765)])
        let secondObject = testStruct(extra: [UInt16(32766)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableUInt32Array() {
        let firstObject = testStruct(extra: [UInt32(2147483645)])
        let secondObject = testStruct(extra: [UInt32(2147483645)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUInt32Array() {
        let firstObject = testStruct(extra: [UInt32(2147483645)])
        let secondObject = testStruct(extra: [UInt32(2147483646)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableUInt64Array() {
        let firstObject = testStruct(extra: [UInt64(9223372036854775805)])
        let secondObject = testStruct(extra: [UInt64(9223372036854775805)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUInt64Array() {
        let firstObject = testStruct(extra: [UInt64(9223372036854775805)])
        let secondObject = testStruct(extra: [UInt64(9223372036854775806)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableFloatArray() {
        let firstObject = testStruct(extra: [Float(3.14)])
        let secondObject = testStruct(extra: [Float(3.14)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongFloatArray() {
        let firstObject = testStruct(extra: [Float(3.14)])
        let secondObject = testStruct(extra: [Float(2.71)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableDoubleArray() {
        let firstObject = testStruct(extra: [Double(3.14)])
        let secondObject = testStruct(extra: [Double(3.14)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongDoubleArray() {
        let firstObject = testStruct(extra: [Double(3.14)])
        let secondObject = testStruct(extra: [Double(2.71)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableStringArray() {
        let firstObject = testStruct(extra: [String("pi")])
        let secondObject = testStruct(extra: [String("pi")])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongStringArray() {
        let firstObject = testStruct(extra: [String("pi")])
        let secondObject = testStruct(extra: [String("euler")])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableMixedArray() {
        let firstObject = testStruct(extra: [String("pi"), nil, Int(5)])
        let secondObject = testStruct(extra: [String("pi"), nil, Int(5)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableEmptyDictionary() {
        let firstObject = testStruct(extra: [:])
        let secondObject = testStruct(extra: [:])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableDifferentKeysDictionary() {
        let firstObject = testStruct(extra: ["key": true])
        let secondObject = testStruct(extra: ["anotherKey": true])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableDiferentSizeDictionary() {
        let firstObject = testStruct(extra: ["key": false, "anotherKey": true])
        let secondObject = testStruct(extra: ["key": false])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongTypeDictionary() {
        let firstObject = testStruct(extra: ["key": Date()])
        let secondObject = testStruct(extra: ["key": Date()])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableNilsDictionary() {
        let firstObject = testStruct(extra: ["key": nil])
        let secondObject = testStruct(extra: ["key": nil])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableStringBoolDictionary() {
        let firstObject = testStruct(extra: ["key": Bool(true)])
        let secondObject = testStruct(extra: ["key": Bool(true)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongBoolDictionary() {
        let firstObject = testStruct(extra: ["key": Bool(true)])
        let secondObject = testStruct(extra: ["key": Bool(false)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableIntDictionary() {
        let firstObject = testStruct(extra: ["key": Int(5)])
        let secondObject = testStruct(extra: ["key": Int(5)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongIntDictionary() {
        let firstObject = testStruct(extra: ["key": Int(5)])
        let secondObject = testStruct(extra: ["key": Int(6)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableInt8Dictionary() {
        let firstObject = testStruct(extra: ["key": Int8(125)])
        let secondObject = testStruct(extra: ["key": Int8(125)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongInt8Dictionary() {
        let firstObject = testStruct(extra: ["key": Int8(125)])
        let secondObject = testStruct(extra: ["key": Int8(126)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableInt16Dictionary() {
        let firstObject = testStruct(extra: ["key": Int16(32765)])
        let secondObject = testStruct(extra: ["key": Int16(32765)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongInt16Dictionary() {
        let firstObject = testStruct(extra: ["key": Int16(32765)])
        let secondObject = testStruct(extra: ["key": Int16(32766)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableInt32Dictionary() {
        let firstObject = testStruct(extra: ["key": Int32(2147483645)])
        let secondObject = testStruct(extra: ["key": Int32(2147483645)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongInt32Dictionary() {
        let firstObject = testStruct(extra: ["key": Int32(2147483645)])
        let secondObject = testStruct(extra: ["key": Int32(2147483646)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableInt64Dictionary() {
        let firstObject = testStruct(extra: ["key": Int64(9223372036854775805)])
        let secondObject = testStruct(extra: ["key": Int64(9223372036854775805)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongInt64Dictionary() {
        let firstObject = testStruct(extra: ["key": Int64(9223372036854775805)])
        let secondObject = testStruct(extra: ["key": Int64(9223372036854775806)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableUIntDictionary() {
        let firstObject = testStruct(extra: ["key": UInt(5)])
        let secondObject = testStruct(extra: ["key": UInt(5)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUIntDictionary() {
        let firstObject = testStruct(extra: ["key": UInt(5)])
        let secondObject = testStruct(extra: ["key": UInt(6)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableUInt8Dictionary() {
        let firstObject = testStruct(extra: ["key": UInt8(125)])
        let secondObject = testStruct(extra: ["key": UInt8(125)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUInt8Dictionary() {
        let firstObject = testStruct(extra: ["key": UInt8(125)])
        let secondObject = testStruct(extra: ["key": UInt8(126)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableUInt16Dictionary() {
        let firstObject = testStruct(extra: ["key": UInt16(32765)])
        let secondObject = testStruct(extra: ["key": UInt16(32765)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUInt16Dictionary() {
        let firstObject = testStruct(extra: ["key": UInt16(32765)])
        let secondObject = testStruct(extra: ["key": UInt16(32766)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableUInt32Dictionary() {
        let firstObject = testStruct(extra: ["key": UInt32(2147483645)])
        let secondObject = testStruct(extra: ["key": UInt32(2147483645)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUInt32Dictionary() {
        let firstObject = testStruct(extra: ["key": UInt32(2147483645)])
        let secondObject = testStruct(extra: ["key": UInt32(2147483646)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableUInt64Dictionary() {
        let firstObject = testStruct(extra: ["key": UInt64(9223372036854775805)])
        let secondObject = testStruct(extra: ["key": UInt64(9223372036854775805)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUInt64Dictionary() {
        let firstObject = testStruct(extra: ["key": UInt64(9223372036854775805)])
        let secondObject = testStruct(extra: ["key": UInt64(9223372036854775806)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableFloatDictionary() {
        let firstObject = testStruct(extra: ["key": Float(3.14)])
        let secondObject = testStruct(extra: ["key": Float(3.14)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongFloatDictionary() {
        let firstObject = testStruct(extra: ["key": Float(3.14)])
        let secondObject = testStruct(extra: ["key": Float(2.71)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableDoubleDictionary() {
        let firstObject = testStruct(extra: ["key": Double(3.14)])
        let secondObject = testStruct(extra: ["key": Double(3.14)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongDoubleDictionary() {
        let firstObject = testStruct(extra: ["key": Double(3.14)])
        let secondObject = testStruct(extra: ["key": Double(2.71)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableStringDictionary() {
        let firstObject = testStruct(extra: ["key": String("pi")])
        let secondObject = testStruct(extra: ["key": String("pi")])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongStringDictionary() {
        let firstObject = testStruct(extra: ["key": String("pi")])
        let secondObject = testStruct(extra: ["key": String("euler")])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableMixedDictionary() {
        let firstObject = testStruct(extra: ["key": String("pi"), "anotherKey": nil, "yetAnotherKey": Int(5)])
        let secondObject = testStruct(extra: ["key": String("pi"), "anotherKey": nil, "yetAnotherKey": Int(5)])

        #expect(firstObject == secondObject)
    }
}
