//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareKit
import Testing

internal struct NotificareNotificationTest {
    @Test
    internal func testNotificareNotificationSerialization() {
        let notification = NotificareNotification(
            partial: true,
            id: "testId",
            type: "testType",
            time: Date(timeIntervalSince1970: 1),
            title: "testTitle",
            subtitle: "testSubtitle",
            message: "testMessage",
            content: [
                NotificareNotification.Content(
                    type: "testType",
                    data: "testData"
                ),
            ],
            actions: [
                NotificareNotification.Action(
                    type: "testType",
                    label: "testLabel",
                    target: "testTarget",
                    keyboard: true,
                    camera: true,
                    destructive: true,
                    icon: NotificareNotification.Action.Icon(
                        android: "testAndroid",
                        ios: "testIos",
                        web: "testWeb")
                ),
            ],
            attachments: [
                NotificareNotification.Attachment(
                    mimeType: "testMimeType",
                    uri: "testUri"
                ),
            ],
            extra: ["testExtraKey": "testExtraValue"],
            targetContentIdentifier: "testTargetIdentifier"
        )

        do {
            let convertedNotification = try NotificareNotification.fromJson(json: notification.toJson())

            #expect(notification == convertedNotification)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testNotificareNotificationSerializationWithNilProps() {
        let notification = NotificareNotification(
            partial: true,
            id: "testId",
            type: "testType",
            time: Date(timeIntervalSince1970: 1),
            title: nil,
            subtitle: nil,
            message: "testMessage",
            content: [],
            actions: [],
            attachments: [],
            extra: [:],
            targetContentIdentifier: nil
        )

        do {
            let convertedNotification = try NotificareNotification.fromJson(json: notification.toJson())

            #expect(notification == convertedNotification)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testContentSerialization() {
        let content = NotificareNotification.Content(
            type: "testType",
            data: "testData"
        )

        do {
            let convertedContent = try NotificareNotification.Content.fromJson(json: content.toJson())

            #expect(content == convertedContent)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testActionSerialization() {
        let action = NotificareNotification.Action(
            type: "testType",
            label: "testLabel",
            target: "testTarget",
            keyboard: true,
            camera: true,
            destructive: true,
            icon: NotificareNotification.Action.Icon(
                android: "testAndroid",
                ios: "testIos",
                web: "testWeb"
            )
        )

        do {
            let convertedAction = try NotificareNotification.Action.fromJson(json: action.toJson())

            #expect(action == convertedAction)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testActionSerializationWithNilProps() {
        let action = NotificareNotification.Action(
            type: "testType",
            label: "testLabel",
            target: nil,
            keyboard: true,
            camera: true,
            destructive: nil,
            icon: nil
        )

        do {
            let convertedAction = try NotificareNotification.Action.fromJson(json: action.toJson())

            #expect(action == convertedAction)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testIconSerialization() {
        let icon = NotificareNotification.Action.Icon(
            android: "testAndroid",
            ios: "testIos",
            web: "testWeb"
        )

        do {
            let convertedIcon = try NotificareNotification.Action.Icon.fromJson(json: icon.toJson())

            #expect(icon == convertedIcon)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testIconSerializationWithNilProps() {
        let icon = NotificareNotification.Action.Icon(
            android: nil,
            ios: nil,
            web: nil
        )

        do {
            let convertedIcon = try NotificareNotification.Action.Icon.fromJson(json: icon.toJson())

            #expect(icon == convertedIcon)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testAttachmentSerialization() {
        let attachment = NotificareNotification.Attachment(
            mimeType: "testMimeType",
            uri: "testUri"
        )

        do {
            let convertedAttachment = try NotificareNotification.Attachment.fromJson(json: attachment.toJson())

            #expect(attachment == convertedAttachment)
        } catch {
            Issue.record()
        }
    }
}
