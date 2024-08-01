//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificarePushKit
import Testing

struct NotificareSystemNotificationTest {
    @Test
    func testNotificareSystemNotificationSerialization() {
        let notification = NotificareSystemNotification(
            id: "testId",
            type: "testType",
            extra: ["testKey": "testValue"]
        )

        do {
            let convertedNotification = try NotificareSystemNotification.fromJson(json: notification.toJson())

            #expect(notification.id == convertedNotification.id)
            #expect(notification.type == convertedNotification.type)
            #expect(NSDictionary( dictionary: notification.extra) == NSDictionary(dictionary: convertedNotification.extra))
        } catch {
            Issue.record()
        }
    }

    @Test
    func testNotificareSystemNotificationSerializationWithNilProps() {
        let notification = NotificareSystemNotification(
            id: "testId",
            type: "testType",
            extra: [:]
        )

        do {
            let convertedNotification = try NotificareSystemNotification.fromJson(json: notification.toJson())

            #expect(notification.id == convertedNotification.id)
            #expect(notification.type == convertedNotification.type)
            #expect(NSDictionary( dictionary: notification.extra) == NSDictionary(dictionary: convertedNotification.extra))
        } catch {
            Issue.record()
        }
    }
}
