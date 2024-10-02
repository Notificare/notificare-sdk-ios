//
// Copyright (c) 2024 . All rights reserved.
//

import Foundation
import Testing

internal struct TimeZoneExtensionsTests {

    @Test
    internal func testTimeZoneOffsetForUTC() {
        let timezone = TimeZone(identifier: "UTC")!

        let offset = timezone.timeZoneOffset

        #expect(offset == 0.0)
    }

    @Test
    internal func testTimeZoneOffsetForEST() {
        let timezone = TimeZone(identifier: "America/New_York")!

        let offset = timezone.timeZoneOffset

        #expect(offset == -4.0)
    }

    @Test
    internal func testTimeZoneOffsetForHalfHour() {
        let timezone = TimeZone(identifier: "America/St_Johns")!

        let offset = timezone.timeZoneOffset

        #expect(offset == -2.5)
    }
}
