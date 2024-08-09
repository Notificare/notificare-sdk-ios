//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareGeoKit
import Testing

internal struct NotificareRegionTest {
    @Test
    internal func testNotificareRegionSerialization() {
        let region = NotificareRegion(
            id: "testId",
            name: "testName",
            description: "testDescription",
            referenceKey: "testReferenceKey",
            geometry: NotificareRegion.Geometry(
                type: "testType",
                coordinate: NotificareRegion.Coordinate(
                    latitude: 1.5,
                    longitude: 2.5
                )
            ),
            advancedGeometry: NotificareRegion.AdvancedGeometry(
                type: "testType",
                coordinates: [
                    NotificareRegion.Coordinate(
                        latitude: 3.5,
                        longitude: 4.5
                    ),
                ]
            ),
            major: 1,
            distance: 5.5,
            timeZone: "testTimeZone",
            timeZoneOffset: 0
        )

        do {
            let convertedRegion = try NotificareRegion.fromJson(json: region.toJson())

            #expect(region == convertedRegion)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testNotificareRegionSerializationWithNilProps() {
        let region = NotificareRegion(
            id: "testId",
            name: "testName",
            description: nil,
            referenceKey: nil,
            geometry: NotificareRegion.Geometry(
                type: "testType",
                coordinate: NotificareRegion.Coordinate(
                    latitude: 1.5,
                    longitude: 2.5
                )
            ),
            advancedGeometry: nil,
            major: nil,
            distance: 3.5,
            timeZone: "testTimeZone",
            timeZoneOffset: 0
        )

        do {
            let convertedRegion = try NotificareRegion.fromJson(json: region.toJson())

            #expect(region == convertedRegion)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testGeometrySerialization() {
        let geometry = NotificareRegion.Geometry(
            type: "testType",
            coordinate: NotificareRegion.Coordinate(
                latitude: 1.5,
                longitude: 2.5
            )
        )

        do {
            let convertedGeometry = try NotificareRegion.Geometry.fromJson(json: geometry.toJson())

            #expect(geometry == convertedGeometry)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testAdvancedGeometrySerialization() {
        let advancedGeometry = NotificareRegion.AdvancedGeometry(
            type: "testType",
            coordinates: [
                NotificareRegion.Coordinate(
                    latitude: 1.5,
                    longitude: 2.5
                ),
            ]
        )

        do {
            let convertedAdvancedGeometry = try NotificareRegion.AdvancedGeometry.fromJson(json: advancedGeometry.toJson())

            #expect(advancedGeometry == convertedAdvancedGeometry)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testAdvancedGeometryWithEmptyPropsSerialization() {
        let advancedGeometry = NotificareRegion.AdvancedGeometry(
            type: "testType",
            coordinates: []
        )

        do {
            let convertedAdvancedGeometry = try NotificareRegion.AdvancedGeometry.fromJson(json: advancedGeometry.toJson())

            #expect(advancedGeometry == convertedAdvancedGeometry)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testCoordinateSerialization() {
        let coordinate = NotificareRegion.Coordinate(
            latitude: 1.5,
            longitude: 2.5
        )

        do {
            let convertedCoordinate = try NotificareRegion.Coordinate.fromJson(json: coordinate.toJson())

            #expect(coordinate == convertedCoordinate)
        } catch {
            Issue.record()
        }
    }
}
