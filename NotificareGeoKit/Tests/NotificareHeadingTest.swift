//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareGeoKit
import Testing

internal struct NotificareHeadingTest {
    @Test
    internal func testNotificareHeadingSerialization() {
        let heading = NotificareHeading(
            magneticHeading: 0.5,
            trueHeading: 1.5,
            headingAccuracy: 2.5,
            x: 3.5,
            y: 4.5,
            z: 5.5,
            timestamp: Date(timeIntervalSince1970: 1)
        )

        do {
            let convertedHeading = try NotificareHeading.fromJson(json: heading.toJson())

            #expect(heading == convertedHeading)
        } catch {
            Issue.record()
        }
    }
}
