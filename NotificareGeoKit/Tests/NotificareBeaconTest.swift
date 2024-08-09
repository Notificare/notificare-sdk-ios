//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareGeoKit
import Testing

internal struct NotificareBeaconTest {
    @Test
    internal func testNotificareBeaconSerialization() {
        let beacon = NotificareBeacon(
            id: "testId",
            name: "testName",
            major: 1,
            minor: 1,
            triggers: true,
            proximity: .unknown
        )

        do {
            let convertedBeacon = try NotificareBeacon.fromJson(json: beacon.toJson())

            #expect(beacon == convertedBeacon)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testNotificareBeaconWithNilPropsSerialization() {
        let beacon = NotificareBeacon(
            id: "testId",
            name: "testName",
            major: 1,
            minor: nil,
            triggers: true,
            proximity: .unknown
        )

        do {
            let convertedBeacon = try NotificareBeacon.fromJson(json: beacon.toJson())

            #expect(beacon == convertedBeacon)
        } catch {
            Issue.record()
        }
    }
}
