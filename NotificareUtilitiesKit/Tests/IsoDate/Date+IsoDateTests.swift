//
// Copyright (c) 2024 Notificare. All rights reserved.
//

import Foundation
import Testing

internal struct DateIsoDateTests {

    @Test
    internal func testInitWithValidIsoDateString() {
        let isoDateString = "2024-09-29T15:30:00.000Z"

        let date = Date(isoDateString: isoDateString)

        #expect(date != nil)

        let timezone = TimeZone(identifier: "GMT")
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: timezone!, from: date!)

        #expect(components.year == 2024)
        #expect(components.month == 9)
        #expect(components.day == 29)
        #expect(components.hour == 15)
        #expect(components.minute == 30)
        #expect(components.second == 0)
    }

    @Test
    internal func testInitWithInvalidIsoDateString() {
        let invalidIsoDateString = "invalid-date-string"

        let date = Date(isoDateString: invalidIsoDateString)

        #expect(date == nil)
    }

    @Test
    internal func testToIsoString() {
        let components = DateComponents(calendar: Calendar(identifier: .gregorian),
                                        timeZone: TimeZone(identifier: "UTC"),
                                        year: 2024, month: 9, day: 29,
                                        hour: 15, minute: 30, second: 0)
        let date = components.date!

        let isoString = date.toIsoString()

        #expect(isoString == "2024-09-29T15:30:00.000Z")
    }
}
