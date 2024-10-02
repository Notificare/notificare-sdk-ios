//
// Copyright (c) 2020 Notificare. All rights reserved.
//

@testable import NotificareUtilitiesKit
import Testing

internal struct NotificareExtraEquatableTest {
    internal struct TestStruct: Equatable {
        @NotificareExtraEquatable internal var extra: Any?
    }

    @Test
    internal func testNotificareExtraEquatableInvalidType() {
        let firstObject = TestStruct(extra: Date())
        let secondObject = TestStruct(extra: Date())

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableNils() {
        let firstObject = TestStruct(extra: nil)
        let secondObject = TestStruct(extra: nil)

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableBool() {
        let firstObject = TestStruct(extra: Bool(true))
        let secondObject = TestStruct(extra: Bool(true))

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongBool() {
        let firstObject = TestStruct(extra: true)
        let secondObject = TestStruct(extra: false)

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableInt() {
        let firstObject = TestStruct(extra: Int(5))
        let secondObject = TestStruct(extra: Int(5))

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongInt() {
        let firstObject = TestStruct(extra: Int(5))
        let secondObject = TestStruct(extra: Int(6))

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableInt8() {
        let firstObject = TestStruct(extra: Int8(125))
        let secondObject = TestStruct(extra: Int8(125))

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongInt8() {
        let firstObject = TestStruct(extra: Int8(125))
        let secondObject = TestStruct(extra: Int8(126))

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableInt16() {
        let firstObject = TestStruct(extra: Int16(32765))
        let secondObject = TestStruct(extra: Int16(32765))

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongInt16() {
        let firstObject = TestStruct(extra: Int16(32765))
        let secondObject = TestStruct(extra: Int16(32766))

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableInt32() {
        let firstObject = TestStruct(extra: Int32(2147483645))
        let secondObject = TestStruct(extra: Int32(2147483645))

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongInt32() {
        let firstObject = TestStruct(extra: Int32(2147483645))
        let secondObject = TestStruct(extra: Int32(2147483646))

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableInt64() {
        let firstObject = TestStruct(extra: Int64(9223372036854775805))
        let secondObject = TestStruct(extra: Int64(9223372036854775805))

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongInt64() {
        let firstObject = TestStruct(extra: Int64(9223372036854775805))
        let secondObject = TestStruct(extra: Int64(9223372036854775806))

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableUInt() {
        let firstObject = TestStruct(extra: UInt(5))
        let secondObject = TestStruct(extra: UInt(5))

        #expect(firstObject == secondObject)
    }
    @Test
    internal func testNotificareExtraEquatableWrongUInt() {
        let firstObject = TestStruct(extra: UInt(5))
        let secondObject = TestStruct(extra: UInt(6))

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableUInt8() {
        let firstObject = TestStruct(extra: UInt8(125))
        let secondObject = TestStruct(extra: UInt8(125))

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUInt8() {
        let firstObject = TestStruct(extra: UInt8(125))
        let secondObject = TestStruct(extra: UInt8(126))

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableUInt16() {
        let firstObject = TestStruct(extra: UInt16(32765))
        let secondObject = TestStruct(extra: UInt16(32765))

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUInt16() {
        let firstObject = TestStruct(extra: UInt16(32765))
        let secondObject = TestStruct(extra: UInt16(32766))

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableUInt32() {
        let firstObject = TestStruct(extra: UInt32(2147483645))
        let secondObject = TestStruct(extra: UInt32(2147483645))

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUInt32() {
        let firstObject = TestStruct(extra: UInt32(2147483645))
        let secondObject = TestStruct(extra: UInt32(2147483646))

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableUInt64() {
        let firstObject = TestStruct(extra: UInt64(9223372036854775805))
        let secondObject = TestStruct(extra: UInt64(9223372036854775805))

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUInt64() {
        let firstObject = TestStruct(extra: UInt64(9223372036854775805))
        let secondObject = TestStruct(extra: UInt64(9223372036854775806))

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableFloat() {
        let firstObject = TestStruct(extra: Float(3.14))
        let secondObject = TestStruct(extra: Float(3.14))

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongFloat() {
        let firstObject = TestStruct(extra: Float(3.14))
        let secondObject = TestStruct(extra: Float(2.71))

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableDouble() {
        let firstObject = TestStruct(extra: Double(3.14))
        let secondObject = TestStruct(extra: Double(3.14))

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongDouble() {
        let firstObject = TestStruct(extra: Double(3.14))
        let secondObject = TestStruct(extra: Double(2.71))

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableString() {
        let firstObject = TestStruct(extra: String("pi"))
        let secondObject = TestStruct(extra: String("pi"))

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongString() {
        let firstObject = TestStruct(extra: String("pi"))
        let secondObject = TestStruct(extra: String("euler"))

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableEmptyArray() {
        let firstObject = TestStruct(extra: [])
        let secondObject = TestStruct(extra: [])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableDiferentSizeArray() {
        let firstObject = TestStruct(extra: ["true", false])
        let secondObject = TestStruct(extra: ["true"])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongTypeArray() {
        let firstObject = TestStruct(extra: [Date(), Date()])
        let secondObject = TestStruct(extra: [Date(), Date()])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableNilsArray() {
        let firstObject = TestStruct(extra: [nil, nil])
        let secondObject = TestStruct(extra: [nil, nil])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableBoolArray() {
        let firstObject = TestStruct(extra: [Bool(true)])
        let secondObject = TestStruct(extra: [Bool(true)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongBoolArray() {
        let firstObject = TestStruct(extra: [Bool(true)])
        let secondObject = TestStruct(extra: [Bool(false)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableIntArray() {
        let firstObject = TestStruct(extra: [Int(5)])
        let secondObject = TestStruct(extra: [Int(5)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongIntArray() {
        let firstObject = TestStruct(extra: [Int(5)])
        let secondObject = TestStruct(extra: [Int(6)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableInt8Array() {
        let firstObject = TestStruct(extra: [Int8(125)])
        let secondObject = TestStruct(extra: [Int8(125)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongInt8Array() {
        let firstObject = TestStruct(extra: [Int8(125)])
        let secondObject = TestStruct(extra: [Int8(126)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableInt16Array() {
        let firstObject = TestStruct(extra: [Int16(32765)])
        let secondObject = TestStruct(extra: [Int16(32765)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongInt16Array() {
        let firstObject = TestStruct(extra: [Int16(32765)])
        let secondObject = TestStruct(extra: [Int16(32766)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableInt32Array() {
        let firstObject = TestStruct(extra: [Int32(2147483645)])
        let secondObject = TestStruct(extra: [Int32(2147483645)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongInt32Array() {
        let firstObject = TestStruct(extra: [Int32(2147483645)])
        let secondObject = TestStruct(extra: [Int32(2147483646)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableInt64Array() {
        let firstObject = TestStruct(extra: [Int64(9223372036854775805)])
        let secondObject = TestStruct(extra: [Int64(9223372036854775805)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongInt64Array() {
        let firstObject = TestStruct(extra: [Int64(9223372036854775805)])
        let secondObject = TestStruct(extra: [Int64(9223372036854775806)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableUIntArray() {
        let firstObject = TestStruct(extra: [UInt(5)])
        let secondObject = TestStruct(extra: [UInt(5)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUIntArray() {
        let firstObject = TestStruct(extra: [UInt(5)])
        let secondObject = TestStruct(extra: [UInt(6)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableUInt8Array() {
        let firstObject = TestStruct(extra: [UInt8(125)])
        let secondObject = TestStruct(extra: [UInt8(125)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUInt8Array() {
        let firstObject = TestStruct(extra: [UInt8(125)])
        let secondObject = TestStruct(extra: [UInt8(126)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableUInt16Array() {
        let firstObject = TestStruct(extra: [UInt16(32765)])
        let secondObject = TestStruct(extra: [UInt16(32765)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUInt16Array() {
        let firstObject = TestStruct(extra: [UInt16(32765)])
        let secondObject = TestStruct(extra: [UInt16(32766)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableUInt32Array() {
        let firstObject = TestStruct(extra: [UInt32(2147483645)])
        let secondObject = TestStruct(extra: [UInt32(2147483645)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUInt32Array() {
        let firstObject = TestStruct(extra: [UInt32(2147483645)])
        let secondObject = TestStruct(extra: [UInt32(2147483646)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableUInt64Array() {
        let firstObject = TestStruct(extra: [UInt64(9223372036854775805)])
        let secondObject = TestStruct(extra: [UInt64(9223372036854775805)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUInt64Array() {
        let firstObject = TestStruct(extra: [UInt64(9223372036854775805)])
        let secondObject = TestStruct(extra: [UInt64(9223372036854775806)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableFloatArray() {
        let firstObject = TestStruct(extra: [Float(3.14)])
        let secondObject = TestStruct(extra: [Float(3.14)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongFloatArray() {
        let firstObject = TestStruct(extra: [Float(3.14)])
        let secondObject = TestStruct(extra: [Float(2.71)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableDoubleArray() {
        let firstObject = TestStruct(extra: [Double(3.14)])
        let secondObject = TestStruct(extra: [Double(3.14)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongDoubleArray() {
        let firstObject = TestStruct(extra: [Double(3.14)])
        let secondObject = TestStruct(extra: [Double(2.71)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableStringArray() {
        let firstObject = TestStruct(extra: [String("pi")])
        let secondObject = TestStruct(extra: [String("pi")])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongStringArray() {
        let firstObject = TestStruct(extra: [String("pi")])
        let secondObject = TestStruct(extra: [String("euler")])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableMixedArray() {
        let firstObject = TestStruct(extra: [String("pi"), nil, Int(5)])
        let secondObject = TestStruct(extra: [String("pi"), nil, Int(5)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableEmptyDictionary() {
        let firstObject = TestStruct(extra: [:])
        let secondObject = TestStruct(extra: [:])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableDifferentKeysDictionary() {
        let firstObject = TestStruct(extra: ["key": true])
        let secondObject = TestStruct(extra: ["anotherKey": true])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableDiferentSizeDictionary() {
        let firstObject = TestStruct(extra: ["key": false, "anotherKey": true])
        let secondObject = TestStruct(extra: ["key": false])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongTypeDictionary() {
        let firstObject = TestStruct(extra: ["key": Date()])
        let secondObject = TestStruct(extra: ["key": Date()])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableNilsDictionary() {
        let firstObject = TestStruct(extra: ["key": nil])
        let secondObject = TestStruct(extra: ["key": nil])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableStringBoolDictionary() {
        let firstObject = TestStruct(extra: ["key": Bool(true)])
        let secondObject = TestStruct(extra: ["key": Bool(true)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongBoolDictionary() {
        let firstObject = TestStruct(extra: ["key": Bool(true)])
        let secondObject = TestStruct(extra: ["key": Bool(false)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableIntDictionary() {
        let firstObject = TestStruct(extra: ["key": Int(5)])
        let secondObject = TestStruct(extra: ["key": Int(5)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongIntDictionary() {
        let firstObject = TestStruct(extra: ["key": Int(5)])
        let secondObject = TestStruct(extra: ["key": Int(6)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableInt8Dictionary() {
        let firstObject = TestStruct(extra: ["key": Int8(125)])
        let secondObject = TestStruct(extra: ["key": Int8(125)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongInt8Dictionary() {
        let firstObject = TestStruct(extra: ["key": Int8(125)])
        let secondObject = TestStruct(extra: ["key": Int8(126)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableInt16Dictionary() {
        let firstObject = TestStruct(extra: ["key": Int16(32765)])
        let secondObject = TestStruct(extra: ["key": Int16(32765)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongInt16Dictionary() {
        let firstObject = TestStruct(extra: ["key": Int16(32765)])
        let secondObject = TestStruct(extra: ["key": Int16(32766)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableInt32Dictionary() {
        let firstObject = TestStruct(extra: ["key": Int32(2147483645)])
        let secondObject = TestStruct(extra: ["key": Int32(2147483645)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongInt32Dictionary() {
        let firstObject = TestStruct(extra: ["key": Int32(2147483645)])
        let secondObject = TestStruct(extra: ["key": Int32(2147483646)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableInt64Dictionary() {
        let firstObject = TestStruct(extra: ["key": Int64(9223372036854775805)])
        let secondObject = TestStruct(extra: ["key": Int64(9223372036854775805)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongInt64Dictionary() {
        let firstObject = TestStruct(extra: ["key": Int64(9223372036854775805)])
        let secondObject = TestStruct(extra: ["key": Int64(9223372036854775806)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableUIntDictionary() {
        let firstObject = TestStruct(extra: ["key": UInt(5)])
        let secondObject = TestStruct(extra: ["key": UInt(5)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUIntDictionary() {
        let firstObject = TestStruct(extra: ["key": UInt(5)])
        let secondObject = TestStruct(extra: ["key": UInt(6)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableUInt8Dictionary() {
        let firstObject = TestStruct(extra: ["key": UInt8(125)])
        let secondObject = TestStruct(extra: ["key": UInt8(125)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUInt8Dictionary() {
        let firstObject = TestStruct(extra: ["key": UInt8(125)])
        let secondObject = TestStruct(extra: ["key": UInt8(126)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableUInt16Dictionary() {
        let firstObject = TestStruct(extra: ["key": UInt16(32765)])
        let secondObject = TestStruct(extra: ["key": UInt16(32765)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUInt16Dictionary() {
        let firstObject = TestStruct(extra: ["key": UInt16(32765)])
        let secondObject = TestStruct(extra: ["key": UInt16(32766)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableUInt32Dictionary() {
        let firstObject = TestStruct(extra: ["key": UInt32(2147483645)])
        let secondObject = TestStruct(extra: ["key": UInt32(2147483645)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUInt32Dictionary() {
        let firstObject = TestStruct(extra: ["key": UInt32(2147483645)])
        let secondObject = TestStruct(extra: ["key": UInt32(2147483646)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableUInt64Dictionary() {
        let firstObject = TestStruct(extra: ["key": UInt64(9223372036854775805)])
        let secondObject = TestStruct(extra: ["key": UInt64(9223372036854775805)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUInt64Dictionary() {
        let firstObject = TestStruct(extra: ["key": UInt64(9223372036854775805)])
        let secondObject = TestStruct(extra: ["key": UInt64(9223372036854775806)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableFloatDictionary() {
        let firstObject = TestStruct(extra: ["key": Float(3.14)])
        let secondObject = TestStruct(extra: ["key": Float(3.14)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongFloatDictionary() {
        let firstObject = TestStruct(extra: ["key": Float(3.14)])
        let secondObject = TestStruct(extra: ["key": Float(2.71)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableDoubleDictionary() {
        let firstObject = TestStruct(extra: ["key": Double(3.14)])
        let secondObject = TestStruct(extra: ["key": Double(3.14)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongDoubleDictionary() {
        let firstObject = TestStruct(extra: ["key": Double(3.14)])
        let secondObject = TestStruct(extra: ["key": Double(2.71)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableStringDictionary() {
        let firstObject = TestStruct(extra: ["key": String("pi")])
        let secondObject = TestStruct(extra: ["key": String("pi")])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableWrongStringDictionary() {
        let firstObject = TestStruct(extra: ["key": String("pi")])
        let secondObject = TestStruct(extra: ["key": String("euler")])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testNotificareExtraEquatableMixedDictionary() {
        let firstObject = TestStruct(extra: ["key": String("pi"), "anotherKey": nil, "yetAnotherKey": Int(5)])
        let secondObject = TestStruct(extra: ["key": String("pi"), "anotherKey": nil, "yetAnotherKey": Int(5)])

        #expect(firstObject == secondObject)
    }
}
