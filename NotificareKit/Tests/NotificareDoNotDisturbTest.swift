//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareKit
import Testing

internal struct NotificareDoNotDisturbTest {
    @Test
    internal func testNotificareDoNotDisturbSerialization() {
        do {
            let dnd = NotificareDoNotDisturb(
                start: try NotificareTime(hours: 21, minutes: 30),
                end: try NotificareTime(hours: 08, minutes: 00)
            )

            let convertedDnd = try NotificareDoNotDisturb.fromJson(json: dnd.toJson())

            #expect(dnd == convertedDnd)
        } catch {
            Issue.record()
        }
    }
}
