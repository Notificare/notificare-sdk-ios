//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareGeoKit
import Testing

struct NotificareHeadingTest {
    @Test
    func testNotificareHeadingSerialization() {
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

            #expect(heading.magneticHeading == convertedHeading.magneticHeading)
            #expect(heading.trueHeading == convertedHeading.trueHeading)
            #expect(heading.headingAccuracy == convertedHeading.headingAccuracy)
            #expect(heading.x == convertedHeading.x)
            #expect(heading.y == convertedHeading.y)
            #expect(heading.z == convertedHeading.z)
            #expect(heading.timestamp == convertedHeading.timestamp)
        } catch {
            Issue.record()
        }
    }
}
