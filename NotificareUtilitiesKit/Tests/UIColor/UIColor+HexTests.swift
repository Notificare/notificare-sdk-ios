//
// Copyright (c) 2024 Notificare. All rights reserved.
//

import UIKit
@testable import NotificareUtilitiesKit
import Testing

internal struct UIColorsHexTesting {
    @Test
    internal func testValidHexStringWithHash() {
        let color = UIColor(hexString: "#ff5733")
        #expect(color == UIColor(
            red: 255 / 255.0,
            green: 87 / 255.0,
            blue: 51 / 255.0,
            alpha: 1
        ))
    }

    @Test
    internal func testValidHexStringWithoutHash() {
        let color = UIColor(hexString: "ff5733")
        #expect(color == UIColor(
            red: 255 / 255.0,
            green: 87 / 255.0,
            blue: 51 / 255.0,
            alpha: 1
        ))
    }

    @Test
    internal func testValidHexStringWithAlpha() {
        let color = UIColor(hexString: "#ff5733", alpha: 0.5)
        #expect(color == UIColor(
            red: 255 / 255.0,
            green: 87 / 255.0,
            blue: 51 / 255.0,
            alpha: 0.5
        ))
    }

    @Test
    internal func testInvalidHexString() {
        let color = UIColor(hexString: "zzzzzz")
        #expect(color != UIColor(red: 255 / 255.0, green: 255 / 255.0, blue: 255 / 255.0, alpha: 1.0))
    }

    @Test
    internal func testEmptyHexString() {
        let color = UIColor(hexString: "")
        #expect(color == UIColor(red: 0, green: 0, blue: 0, alpha: 1))
    }

    @Test
    internal func testUIColorToHexString() {
        let color = UIColor(
            red: 255 / 255.0,
            green: 87 / 255.0,
            blue: 51 / 255.0,
            alpha: 1
        )

        let hexString = color.toHexString()
        #expect(hexString == "#ff5733")
    }

    @Test
    internal func testHexToUIColorAndBack() {
        let hexString = "#ff5733"
        let color = UIColor(hexString: hexString)
        let convertedHex = color.toHexString()
        #expect(convertedHex == hexString)
    }

    @Test
    internal func testToHexStringIgnoresAlpha() {
        let color = UIColor(
            red: 127 / 255.0,
            green: 127 / 255.0,
            blue: 127 / 255.0,
            alpha: 0.5
        )

        let hexString = color.toHexString()
        #expect(hexString == "#7f7f7f")
    }

}
