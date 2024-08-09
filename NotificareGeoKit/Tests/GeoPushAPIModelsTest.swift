//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareGeoKit
@testable import NotificareKit
import Testing

internal struct GeoPushAPIModelsTest {
    @Test
    internal func testNotificareRegionToModel() {
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

        #expect(expectedRegion == region)
    }

    @Test
    internal func testNotificareRegionWithNilPropsToModel() {
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

        #expect(expectedRegion == region)
    }
}
