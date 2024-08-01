//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareKit
import Testing

struct NotificareDoNotDisturbTest {
    @Test
    func testNotificareDoNotDisturbSerialization() {
        do {
            let dnd = NotificareDoNotDisturb(
                start: try NotificareTime(hours: 21, minutes: 30),
                end: try NotificareTime(hours: 08, minutes: 00)
            )

            let convertedDnd = try NotificareDoNotDisturb.fromJson(json: dnd.toJson())

            #expect(dnd.start.hours == convertedDnd.start.hours)
            #expect(dnd.start.minutes == convertedDnd.start.minutes)
            #expect(dnd.end.hours == convertedDnd.end.hours)
            #expect(dnd.end.minutes == convertedDnd.end.minutes)
        } catch {
            Issue.record()
        }
    }
}
