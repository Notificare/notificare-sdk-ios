//
// Copyright (c) 2020 Notificare. All rights reserved.
//

@testable import NotificareKit
import Testing

internal struct CoreTests {
    internal struct testStruct: Equatable {
        @NotificareExtraEquatable internal var extra: Any?
    }

    @Test
    internal func testNotificareExtraEquatableWrongType() {
        let foo = testStruct(extra: Date())
        let bar = testStruct(extra: Date())

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableNils() {
        let foo = testStruct(extra: nil)
        let bar = testStruct(extra: nil)

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableBool() {
        let foo = testStruct(extra: Bool(true))
        let bar = testStruct(extra: Bool(true))

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongBool() {
        let foo = testStruct(extra: true)
        let bar = testStruct(extra: false)

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableInt() {
        let foo = testStruct(extra: Int(5))
        let bar = testStruct(extra: Int(5))

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongInt() {
        let foo = testStruct(extra: Int(5))
        let bar = testStruct(extra: Int(6))

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableInt8() {
        let foo = testStruct(extra: Int8(125))
        let bar = testStruct(extra: Int8(125))

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongInt8() {
        let foo = testStruct(extra: Int8(125))
        let bar = testStruct(extra: Int8(126))

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableInt16() {
        let foo = testStruct(extra: Int16(32765))
        let bar = testStruct(extra: Int16(32765))

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongInt16() {
        let foo = testStruct(extra: Int16(32765))
        let bar = testStruct(extra: Int16(32766))

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableInt32() {
        let foo = testStruct(extra: Int32(2147483645))
        let bar = testStruct(extra: Int32(2147483645))

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongInt32() {
        let foo = testStruct(extra: Int32(2147483645))
        let bar = testStruct(extra: Int32(2147483646))

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableInt64() {
        let foo = testStruct(extra: Int64(9223372036854775805))
        let bar = testStruct(extra: Int64(9223372036854775805))

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongInt64() {
        let foo = testStruct(extra: Int64(9223372036854775805))
        let bar = testStruct(extra: Int64(9223372036854775806))

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableUInt() {
        let foo = testStruct(extra: UInt(5))
        let bar = testStruct(extra: UInt(5))

        #expect(foo == bar)
    }
    @Test
    internal func testNotificareExtraEquatableWrongUInt() {
        let foo = testStruct(extra: UInt(5))
        let bar = testStruct(extra: UInt(6))

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableUInt8() {
        let foo = testStruct(extra: UInt8(125))
        let bar = testStruct(extra: UInt8(125))

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUInt8() {
        let foo = testStruct(extra: UInt8(125))
        let bar = testStruct(extra: UInt8(126))

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableUInt16() {
        let foo = testStruct(extra: UInt16(32765))
        let bar = testStruct(extra: UInt16(32765))

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUInt16() {
        let foo = testStruct(extra: UInt16(32765))
        let bar = testStruct(extra: UInt16(32766))

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableUInt32() {
        let foo = testStruct(extra: UInt32(2147483645))
        let bar = testStruct(extra: UInt32(2147483645))

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUInt32() {
        let foo = testStruct(extra: UInt32(2147483645))
        let bar = testStruct(extra: UInt32(2147483646))

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableUInt64() {
        let foo = testStruct(extra: UInt64(9223372036854775805))
        let bar = testStruct(extra: UInt64(9223372036854775805))

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUInt64() {
        let foo = testStruct(extra: UInt64(9223372036854775805))
        let bar = testStruct(extra: UInt64(9223372036854775806))

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableFloat() {
        let foo = testStruct(extra: Float(3.14))
        let bar = testStruct(extra: Float(3.14))

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongFloat() {
        let foo = testStruct(extra: Float(3.14))
        let bar = testStruct(extra: Float(2.71))

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableDouble() {
        let foo = testStruct(extra: Double(3.14))
        let bar = testStruct(extra: Double(3.14))

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongDouble() {
        let foo = testStruct(extra: Double(3.14))
        let bar = testStruct(extra: Double(2.71))

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableString() {
        let foo = testStruct(extra: String("pi"))
        let bar = testStruct(extra: String("pi"))

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongString() {
        let foo = testStruct(extra: String("pi"))
        let bar = testStruct(extra: String("euler"))

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableEmptyArray() {
        let foo = testStruct(extra: [])
        let bar = testStruct(extra: [])

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableDiferentSizeArray() {
        let foo = testStruct(extra: ["true", false])
        let bar = testStruct(extra: ["true"])

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongTypeArray() {
        let foo = testStruct(extra: [Date(), Date()])
        let bar = testStruct(extra: [Date(), Date()])

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableNilsArray() {
        let foo = testStruct(extra: [nil, nil])
        let bar = testStruct(extra: [nil, nil])

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableBoolArray() {
        let foo = testStruct(extra: [Bool(true)])
        let bar = testStruct(extra: [Bool(true)])

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongBoolArray() {
        let foo = testStruct(extra: [Bool(true)])
        let bar = testStruct(extra: [Bool(false)])

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableIntArray() {
        let foo = testStruct(extra: [Int(5)])
        let bar = testStruct(extra: [Int(5)])

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongIntArray() {
        let foo = testStruct(extra: [Int(5)])
        let bar = testStruct(extra: [Int(6)])

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableInt8Array() {
        let foo = testStruct(extra: [Int8(125)])
        let bar = testStruct(extra: [Int8(125)])

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongInt8Array() {
        let foo = testStruct(extra: [Int8(125)])
        let bar = testStruct(extra: [Int8(126)])

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableInt16Array() {
        let foo = testStruct(extra: [Int16(32765)])
        let bar = testStruct(extra: [Int16(32765)])

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongInt16Array() {
        let foo = testStruct(extra: [Int16(32765)])
        let bar = testStruct(extra: [Int16(32766)])

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableInt32Array() {
        let foo = testStruct(extra: [Int32(2147483645)])
        let bar = testStruct(extra: [Int32(2147483645)])

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongInt32Array() {
        let foo = testStruct(extra: [Int32(2147483645)])
        let bar = testStruct(extra: [Int32(2147483646)])

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableInt64Array() {
        let foo = testStruct(extra: [Int64(9223372036854775805)])
        let bar = testStruct(extra: [Int64(9223372036854775805)])

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongInt64Array() {
        let foo = testStruct(extra: [Int64(9223372036854775805)])
        let bar = testStruct(extra: [Int64(9223372036854775806)])

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableUIntArray() {
        let foo = testStruct(extra: [UInt(5)])
        let bar = testStruct(extra: [UInt(5)])

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUIntArray() {
        let foo = testStruct(extra: [UInt(5)])
        let bar = testStruct(extra: [UInt(6)])

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableUInt8Array() {
        let foo = testStruct(extra: [UInt8(125)])
        let bar = testStruct(extra: [UInt8(125)])

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUInt8Array() {
        let foo = testStruct(extra: [UInt8(125)])
        let bar = testStruct(extra: [UInt8(126)])

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableUInt16Array() {
        let foo = testStruct(extra: [UInt16(32765)])
        let bar = testStruct(extra: [UInt16(32765)])

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUInt16Array() {
        let foo = testStruct(extra: [UInt16(32765)])
        let bar = testStruct(extra: [UInt16(32766)])

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableUInt32Array() {
        let foo = testStruct(extra: [UInt32(2147483645)])
        let bar = testStruct(extra: [UInt32(2147483645)])

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUInt32Array() {
        let foo = testStruct(extra: [UInt32(2147483645)])
        let bar = testStruct(extra: [UInt32(2147483646)])

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableUInt64Array() {
        let foo = testStruct(extra: [UInt64(9223372036854775805)])
        let bar = testStruct(extra: [UInt64(9223372036854775805)])

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUInt64Array() {
        let foo = testStruct(extra: [UInt64(9223372036854775805)])
        let bar = testStruct(extra: [UInt64(9223372036854775806)])

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableFloatArray() {
        let foo = testStruct(extra: [Float(3.14)])
        let bar = testStruct(extra: [Float(3.14)])

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongFloatArray() {
        let foo = testStruct(extra: [Float(3.14)])
        let bar = testStruct(extra: [Float(2.71)])

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableDoubleArray() {
        let foo = testStruct(extra: [Double(3.14)])
        let bar = testStruct(extra: [Double(3.14)])

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongDoubleArray() {
        let foo = testStruct(extra: [Double(3.14)])
        let bar = testStruct(extra: [Double(2.71)])

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableStringArray() {
        let foo = testStruct(extra: [String("pi")])
        let bar = testStruct(extra: [String("pi")])

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongStringArray() {
        let foo = testStruct(extra: [String("pi")])
        let bar = testStruct(extra: [String("euler")])

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableEmptyDictionary() {
        let foo = testStruct(extra: [:])
        let bar = testStruct(extra: [:])

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableDifferentKeysDictionary() {
        let foo = testStruct(extra: ["key": true])
        let bar = testStruct(extra: ["anotherKey": true])

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableDiferentSizeDictionary() {
        let foo = testStruct(extra: ["key": false, "anotherKey": true])
        let bar = testStruct(extra: ["key": false])

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongTypeDictionary() {
        let foo = testStruct(extra: ["key": Date()])
        let bar = testStruct(extra: ["key": Date()])

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableNilsDictionary() {
        let foo = testStruct(extra: ["key": nil])
        let bar = testStruct(extra: ["key": nil])

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableStringBoolDictionary() {
        let foo = testStruct(extra: ["key": Bool(true)])
        let bar = testStruct(extra: ["key": Bool(true)])

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongBoolDictionary() {
        let foo = testStruct(extra: ["key": Bool(true)])
        let bar = testStruct(extra: ["key": Bool(false)])

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableIntDictionary() {
        let foo = testStruct(extra: ["key": Int(5)])
        let bar = testStruct(extra: ["key": Int(5)])

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongIntDictionary() {
        let foo = testStruct(extra: ["key": Int(5)])
        let bar = testStruct(extra: ["key": Int(6)])

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableInt8Dictionary() {
        let foo = testStruct(extra: ["key": Int8(125)])
        let bar = testStruct(extra: ["key": Int8(125)])

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongInt8Dictionary() {
        let foo = testStruct(extra: ["key": Int8(125)])
        let bar = testStruct(extra: ["key": Int8(126)])

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableInt16Dictionary() {
        let foo = testStruct(extra: ["key": Int16(32765)])
        let bar = testStruct(extra: ["key": Int16(32765)])

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongInt16Dictionary() {
        let foo = testStruct(extra: ["key": Int16(32765)])
        let bar = testStruct(extra: ["key": Int16(32766)])

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableInt32Dictionary() {
        let foo = testStruct(extra: ["key": Int32(2147483645)])
        let bar = testStruct(extra: ["key": Int32(2147483645)])

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongInt32Dictionary() {
        let foo = testStruct(extra: ["key": Int32(2147483645)])
        let bar = testStruct(extra: ["key": Int32(2147483646)])

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableInt64Dictionary() {
        let foo = testStruct(extra: ["key": Int64(9223372036854775805)])
        let bar = testStruct(extra: ["key": Int64(9223372036854775805)])

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongInt64Dictionary() {
        let foo = testStruct(extra: ["key": Int64(9223372036854775805)])
        let bar = testStruct(extra: ["key": Int64(9223372036854775806)])

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableUIntDictionary() {
        let foo = testStruct(extra: ["key": UInt(5)])
        let bar = testStruct(extra: ["key": UInt(5)])

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUIntDictionary() {
        let foo = testStruct(extra: ["key": UInt(5)])
        let bar = testStruct(extra: ["key": UInt(6)])

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableUInt8Dictionary() {
        let foo = testStruct(extra: ["key": UInt8(125)])
        let bar = testStruct(extra: ["key": UInt8(125)])

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUInt8Dictionary() {
        let foo = testStruct(extra: ["key": UInt8(125)])
        let bar = testStruct(extra: ["key": UInt8(126)])

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableUInt16Dictionary() {
        let foo = testStruct(extra: ["key": UInt16(32765)])
        let bar = testStruct(extra: ["key": UInt16(32765)])

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUInt16Dictionary() {
        let foo = testStruct(extra: ["key": UInt16(32765)])
        let bar = testStruct(extra: ["key": UInt16(32766)])

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableUInt32Dictionary() {
        let foo = testStruct(extra: ["key": UInt32(2147483645)])
        let bar = testStruct(extra: ["key": UInt32(2147483645)])

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUInt32Dictionary() {
        let foo = testStruct(extra: ["key": UInt32(2147483645)])
        let bar = testStruct(extra: ["key": UInt32(2147483646)])

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableUInt64Dictionary() {
        let foo = testStruct(extra: ["key": UInt64(9223372036854775805)])
        let bar = testStruct(extra: ["key": UInt64(9223372036854775805)])

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongUInt64Dictionary() {
        let foo = testStruct(extra: ["key": UInt64(9223372036854775805)])
        let bar = testStruct(extra: ["key": UInt64(9223372036854775806)])

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableFloatDictionary() {
        let foo = testStruct(extra: ["key": Float(3.14)])
        let bar = testStruct(extra: ["key": Float(3.14)])

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongFloatDictionary() {
        let foo = testStruct(extra: ["key": Float(3.14)])
        let bar = testStruct(extra: ["key": Float(2.71)])

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableDoubleDictionary() {
        let foo = testStruct(extra: ["key": Double(3.14)])
        let bar = testStruct(extra: ["key": Double(3.14)])

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongDoubleDictionary() {
        let foo = testStruct(extra: ["key": Double(3.14)])
        let bar = testStruct(extra: ["key": Double(2.71)])

        #expect(foo != bar)
    }

    @Test
    internal func testNotificareExtraEquatableStringDictionary() {
        let foo = testStruct(extra: ["key": String("pi")])
        let bar = testStruct(extra: ["key": String("pi")])

        #expect(foo == bar)
    }

    @Test
    internal func testNotificareExtraEquatableWrongStringDictionary() {
        let foo = testStruct(extra: ["key": String("pi")])
        let bar = testStruct(extra: ["key": String("euler")])

        #expect(foo != bar)
    }
}
