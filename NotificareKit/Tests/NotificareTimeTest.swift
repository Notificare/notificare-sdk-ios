//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareKit
import Testing

struct NotificareTimeTest {
    @Test
    func testInvalidNotificareTimeInitialization() {
        #expect(throws: (any Error).self) {
            try NotificareTime(hours: -1, minutes: 60)
        }
    }

    @Test
    func testInvalidStringNotificareTimeInitialization() {
        #expect(throws: (any Error).self) {
            try NotificareTime(string: "21h30")
        }
        #expect(throws: (any Error).self) {
            try NotificareTime(string: ":")
        }
        #expect(throws: (any Error).self) {
            try NotificareTime(string: "21:30:45")
        }
    }

    @Test
    func testNotificareTimeInitialization() {
        do {
            let time = try NotificareTime(hours: 21, minutes: 30)

            #expect(21 == time.hours)
            #expect(30 == time.minutes)
        } catch {
            Issue.record()
        }
    }

    @Test
    func testStringNotificareTimeInitialization() {
        do {
            let time = try NotificareTime(string: "21:30")

            #expect(21 == time.hours)
            #expect(30 == time.minutes)
        } catch {
            Issue.record()
        }
    }

    @Test
    func testNotificareTimeFormat() {
        do {
            let time = try NotificareTime(string: "21:30").format()

            #expect("21:30" == time)
        } catch {
            Issue.record()
        }
    }
}
