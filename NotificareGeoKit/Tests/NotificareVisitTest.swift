//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareGeoKit
import Testing

internal struct NotificareVisitTest {
    @Test
    internal func testNotificareVisitSerialization() {
        let visit = NotificareVisit(
            departureDate: Date(timeIntervalSince1970: 1),
            arrivalDate: Date(timeIntervalSince1970: 2),
            latitude: 1.5,
            longitude: 1.5
        )

        do {
            let convertedVisit = try NotificareVisit.fromJson(json: visit.toJson())

            #expect(visit == convertedVisit)
        } catch {
            Issue.record()
        }
    }
}
