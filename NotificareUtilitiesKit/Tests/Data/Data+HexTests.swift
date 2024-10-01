//
// Copyright (c) 2024 Notificare. All rights reserved.
//

import Foundation
@testable import NotificareUtilitiesKit
import Testing

internal struct DataHexTests {
    @Test
    internal func testDataToHexStringWithSingleByte() {
        let data = Data([0x0F])
        let hexString = data.toHexString()
        #expect(hexString == "0f")
    }

    @Test
    internal func testDataToHexStringWithMultipleBytes() {
        let data = Data([0xFF, 0xA5, 0x10])
        let hexString = data.toHexString()
        #expect(hexString == "ffa510")
    }

    @Test
    internal func testDataToHexStringWithEmptyData() {
        let data = Data()
        let hexString = data.toHexString()
        #expect(hexString == "")
    }
}
