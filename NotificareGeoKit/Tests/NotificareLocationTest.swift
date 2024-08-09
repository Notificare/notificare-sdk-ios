//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareGeoKit
import CoreLocation
import Testing

internal struct NotificareLocationTest {
    @Test
    @available(iOS 13.4, *)
    internal func testNotificareLocationCLLocationInitialization() {
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

        #expect(expectedLocation == location)
    }

    @Test
    internal func testNotificareLocationSerialization() {
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

            #expect(location == convertedLocation)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testNotificareLocationSerializationWithNilProps() {
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

            #expect(location == convertedLocation)
        } catch {
            Issue.record()
        }
    }
}
