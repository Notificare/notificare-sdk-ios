//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareGeoKit
@testable import NotificareKit
import Testing

struct GeoPushAPIModelsTest {
    @Test
    func testNotificareRegionToModel() {
        let expectedRegion = NotificareRegion(
            id: "testId",
            name: "testName",
            description: "testDescription",
            referenceKey: "testReferenceKey",
            geometry: NotificareRegion.Geometry(
                type: "testType",
                coordinate: NotificareRegion.Coordinate(
                    latitude: 0.5,
                    longitude: 1.5
                )
            ),
            advancedGeometry: NotificareRegion.AdvancedGeometry(
                type: "testType",
                coordinates: [
                    NotificareRegion.Coordinate(
                        latitude: 2.5,
                        longitude: 3.5
                    ),
                ]
            ),
            major: 1,
            distance: 4.5,
            timeZone: "testTimeZone",
            timeZoneOffset: 0
        )

        let region = NotificareInternals.PushAPI.Models.Region(
            _id: "testId",
            name: "testName",
            description: "testDescription",
            referenceKey: "testReferenceKey",
            geometry: NotificareInternals.PushAPI.Models.Region.Geometry(
                type: "testType",
                coordinates: [1.5, 0.5]
            ),
            advancedGeometry: NotificareInternals.PushAPI.Models.Region.AdvancedGeometry(
                type: "testType",
                coordinates: [[[3.5, 2.5]]]
            ),
            major: 1,
            distance: 4.5,
            timezone: "testTimeZone",
            timeZoneOffset: 0
        ).toModel()

        assertRegion(region: expectedRegion, convertedRegion: region)
    }

    @Test
    func testNotificareRegionWithNilPropsToModel() {
        let expectedRegion = NotificareRegion(
            id: "testId",
            name: "testName",
            description: nil,
            referenceKey: nil,
            geometry: NotificareRegion.Geometry(
                type: "testType",
                coordinate: NotificareRegion.Coordinate(
                    latitude: 0.5,
                    longitude: 1.5
                )
            ),
            advancedGeometry: nil,
            major: nil,
            distance: 2.5,
            timeZone: "testTimeZone",
            timeZoneOffset: 0
        )

        let region = NotificareInternals.PushAPI.Models.Region(
            _id: "testId",
            name: "testName",
            description: nil,
            referenceKey: nil,
            geometry: NotificareInternals.PushAPI.Models.Region.Geometry(
                type: "testType",
                coordinates: [1.5, 0.5]
            ),
            advancedGeometry: nil,
            major: nil,
            distance: 2.5,
            timezone: "testTimeZone",
            timeZoneOffset: 0
        ).toModel()

        assertRegion(region: expectedRegion, convertedRegion: region)
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
