//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareGeoKit
import Testing

struct NotificareRegionTest {
    @Test
    func testNotificareRegionSerialization() {
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

            assertRegion(region: region, convertedRegion: convertedRegion)
        } catch {
            Issue.record()
        }
    }

    @Test
    func testNotificareRegionSerializationWithNilProps() {
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

            assertRegion(region: region, convertedRegion: convertedRegion)
        } catch {
            Issue.record()
        }
    }

    @Test
    func testGeometrySerialization() {
        let geometry = NotificareRegion.Geometry(
            type: "testType",
            coordinate: NotificareRegion.Coordinate(
                latitude: 1.5,
                longitude: 2.5
            )
        )

        do {
            let convertedGeometry = try NotificareRegion.Geometry.fromJson(json: geometry.toJson())

            #expect(geometry.type == convertedGeometry.type)
            #expect(geometry.coordinate.latitude == convertedGeometry.coordinate.latitude)
            #expect(geometry.coordinate.longitude == convertedGeometry.coordinate.longitude)
        } catch {
            Issue.record()
        }
    }

    @Test
    func testAdvancedGeometrySerialization() {
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

            #expect(advancedGeometry.type == convertedAdvancedGeometry.type)
            for index in advancedGeometry.coordinates.indices {
                #expect(advancedGeometry.coordinates[index].latitude == convertedAdvancedGeometry.coordinates[index].latitude)
                #expect(advancedGeometry.coordinates[index].longitude == convertedAdvancedGeometry.coordinates[index].longitude)
            }
        } catch {
            Issue.record()
        }
    }

    @Test
    func testAdvancedGeometryWithEmptyPropsSerialization() {
        let advancedGeometry = NotificareRegion.AdvancedGeometry(
            type: "testType",
            coordinates: []
        )

        do {
            let convertedAdvancedGeometry = try NotificareRegion.AdvancedGeometry.fromJson(json: advancedGeometry.toJson())

            #expect(advancedGeometry.type == convertedAdvancedGeometry.type)
            for index in advancedGeometry.coordinates.indices {
                #expect(advancedGeometry.coordinates[index].latitude == convertedAdvancedGeometry.coordinates[index].latitude)
                #expect(advancedGeometry.coordinates[index].longitude == convertedAdvancedGeometry.coordinates[index].longitude)
            }
        } catch {
            Issue.record()
        }
    }

    @Test
    func testCoordinateSerialization() {
        let coordinate = NotificareRegion.Coordinate(
            latitude: 1.5,
            longitude: 2.5
        )

        do {
            let convertedCoordinate = try NotificareRegion.Coordinate.fromJson(json: coordinate.toJson())

            #expect(coordinate.latitude == convertedCoordinate.latitude)
            #expect(coordinate.longitude == convertedCoordinate.longitude)
        } catch {
            Issue.record()
        }
    }

    func assertRegion(region: NotificareRegion, convertedRegion: NotificareRegion) {
        #expect(region.id == convertedRegion.id)
        #expect(region.name == convertedRegion.name)
        #expect(region.description == convertedRegion.description)
        #expect(region.referenceKey == convertedRegion.referenceKey)
        #expect(region.geometry.type == convertedRegion.geometry.type)
        #expect(region.geometry.coordinate.latitude == convertedRegion.geometry.coordinate.latitude)
        #expect(region.geometry.coordinate.longitude == convertedRegion.geometry.coordinate.longitude)
        if let advancedGeometry = region.advancedGeometry,
           let convertedAdvancedGeometry = convertedRegion.advancedGeometry
        {
            #expect(advancedGeometry.type == convertedAdvancedGeometry.type)
            for index in advancedGeometry.coordinates.indices {
                #expect(advancedGeometry.coordinates[index].latitude == convertedAdvancedGeometry.coordinates[index].latitude)
                #expect(advancedGeometry.coordinates[index].longitude == convertedAdvancedGeometry.coordinates[index].longitude)
            }
        } else {
            #expect(region.advancedGeometry == nil)
            #expect(convertedRegion.advancedGeometry == nil)
        }
        #expect(region.major == convertedRegion.major)
        #expect(region.distance == convertedRegion.distance)
        #expect(region.timeZone == convertedRegion.timeZone)
        #expect(region.timeZoneOffset == convertedRegion.timeZoneOffset)
    }
}
