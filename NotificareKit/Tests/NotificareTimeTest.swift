//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareKit
import Testing

internal struct NotificareTimeTest {
    @Test
    internal func testInvalidNotificareTimeInitialization() {
        #expect(throws: (any Error).self) {
            try NotificareTime(hours: -1, minutes: 00)
        }

        #expect(throws: (any Error).self) {
            try NotificareTime(hours: 24, minutes: 00)
        }

        #expect(throws: (any Error).self) {
            try NotificareTime(hours: 21, minutes: -1)
        }

        #expect(throws: (any Error).self) {
            try NotificareTime(hours: 21, minutes: 60)
        }
    }

    @Test
    internal func testInvalidNotificareTimeStringInitialization() {
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
    internal func testNotificareTimeInitialization() {
        do {
            let time = try NotificareTime(hours: 21, minutes: 30)

            #expect(21 == time.hours)
            #expect(30 == time.minutes)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testNotificareTimeStringInitialization() {
        do {
            let time = try NotificareTime(string: "21:30")

            #expect(21 == time.hours)
            #expect(30 == time.minutes)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testNotificareTimeFormat() {
        do {
            let time = try NotificareTime(string: "21:30").format()

            #expect("21:30" == time)
        } catch {
            Issue.record()
        }
    }
}
