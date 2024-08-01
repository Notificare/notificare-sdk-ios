//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareGeoKit
import CoreLocation
import Testing

struct NotificareLocationTest {
    @Test
    @available(iOS 13.4, *)
    func testNotificareLocationCLLocationInitialization() {
        let expectedLocation = NotificareLocation(
            latitude: 0.5,
            longitude: 1.5,
            altitude: 2.5,
            course: 3.5,
            speed: 4.5,
            floor: nil,
            horizontalAccuracy: 5.5,
            verticalAccuracy: 6.5,
            timestamp: Date(timeIntervalSince1970: 1)
        )

        let clLocation = CLLocation(
            coordinate: CLLocationCoordinate2D(
                latitude: 0.5,
                longitude: 1.5
            ),
            altitude: 2.5,
            horizontalAccuracy: 5.5,
            verticalAccuracy: 6.5,
            course: 3.5,
            speed: 4.5,
            timestamp: Date(timeIntervalSince1970: 1)
        )

        let location = NotificareLocation(cl: clLocation)

        assertLocation(expectedLocation: expectedLocation, actualLocation: location)
    }

    @Test
    func testNotificareLocationSerialization() {
        let location = NotificareLocation(
            latitude: 0.5,
            longitude: 1.5,
            altitude: 2.5,
            course: 3.5,
            speed: 4.5,
            floor: 0,
            horizontalAccuracy: 5.5,
            verticalAccuracy: 6.5,
            timestamp: Date(timeIntervalSince1970: 1)
        )

        do {
            let convertedLocation = try NotificareLocation.fromJson(json: location.toJson())

            assertLocation(expectedLocation: location, actualLocation: convertedLocation)
        } catch {
            Issue.record()
        }
    }

    @Test
    func testNotificareLocationSerializationWithNilProps() {
        let location = NotificareLocation(
            latitude: 0.5,
            longitude: 1.5,
            altitude: 2.5,
            course: 3.5,
            speed: 4.5,
            floor: nil,
            horizontalAccuracy: 5.5,
            verticalAccuracy: 6.5,
            timestamp: Date(timeIntervalSince1970: 1)
        )

        do {
            let convertedLocation = try NotificareLocation.fromJson(json: location.toJson())

            assertLocation(expectedLocation: location, actualLocation: convertedLocation)
        } catch {
            Issue.record()
        }
    }

    func assertLocation(expectedLocation: NotificareLocation, actualLocation: NotificareLocation) {
        #expect(expectedLocation.latitude == actualLocation.latitude)
        #expect(expectedLocation.longitude == actualLocation.longitude)
        #expect(expectedLocation.altitude == actualLocation.altitude)
        #expect(expectedLocation.course == actualLocation.course)
        #expect(expectedLocation.speed == actualLocation.speed)
        #expect(expectedLocation.floor == actualLocation.floor)
        #expect(expectedLocation.horizontalAccuracy == actualLocation.horizontalAccuracy)
        #expect(expectedLocation.verticalAccuracy == actualLocation.verticalAccuracy)
        #expect(expectedLocation.timestamp == actualLocation.timestamp)
    }
}
