//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareGeoKit
import Testing

struct NotificareBeaconTest {
    @Test
    func testNotificareBeaconSerialization() {
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

            assertBeacon(beacon: beacon, convertedBeacon: convertedBeacon)
        } catch {
            Issue.record()
        }
    }

    @Test
    func testNotificareBeaconWithNilPropsSerialization() {
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

            assertBeacon(beacon: beacon, convertedBeacon: convertedBeacon)
        } catch {
            Issue.record()
        }
    }

    func assertBeacon(beacon: NotificareBeacon, convertedBeacon: NotificareBeacon) {
        #expect(beacon.id == convertedBeacon.id)
        #expect(beacon.name == convertedBeacon.name)
        #expect(beacon.major == convertedBeacon.major)
        #expect(beacon.minor == convertedBeacon.minor)
        #expect(beacon.triggers == convertedBeacon.triggers)
        #expect(beacon.proximity == convertedBeacon.proximity)
    }
}
