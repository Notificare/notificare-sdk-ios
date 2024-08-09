//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificarePushKit
import Testing

internal struct NotificareSystemNotificationTest {
    @Test
    internal func testNotificareSystemNotificationSerialization() {
        let notification = NotificareSystemNotification(
            id: "testId",
            type: "testType",
            extra: ["testKey": "testValue"]
        )

        do {
            let convertedNotification = try NotificareSystemNotification.fromJson(json: notification.toJson())

            #expect(notification == convertedNotification)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testNotificareSystemNotificationSerializationWithNilProps() {
        let notification = NotificareSystemNotification(
            id: "testId",
            type: "testType",
            extra: [:]
        )

        do {
            let convertedNotification = try NotificareSystemNotification.fromJson(json: notification.toJson())

            #expect(notification == convertedNotification)
        } catch {
            Issue.record()
        }
    }
}
