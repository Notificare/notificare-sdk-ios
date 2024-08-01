//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareKit
import Testing

struct NotificareNotificationTest {
    @Test
    func testNotificareNotificationSerialization() {
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

            assertNotification(notification: notification, convertedNotification: convertedNotification)
        } catch {
            Issue.record()
        }
    }

    @Test
    func testNotificareNotificationSerializationWithNilProps() {
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

            assertNotification(notification: notification, convertedNotification: convertedNotification)
        } catch {
            Issue.record()
        }
    }

    @Test
    func testContentSerialization() {
        let content = NotificareNotification.Content(
            type: "testType",
            data: "testData"
        )

        do {
            let convertedContent = try NotificareNotification.Content.fromJson(json: content.toJson())

            #expect(content.type == convertedContent.type)
            #expect(TestUtils.isEqual(type: String.self, a: content.data, b: convertedContent.data))
        } catch {
            Issue.record()
        }
    }

    @Test
    func testActionSerialization() {
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

            #expect(action.type == convertedAction.type)
            #expect(action.label == convertedAction.label)
            #expect(action.target == convertedAction.target)
            #expect(action.keyboard == convertedAction.keyboard)
            #expect(action.camera == convertedAction.camera)
            #expect(action.destructive == convertedAction.destructive)
            #expect(action.icon?.android == convertedAction.icon?.android)
            #expect(action.icon?.ios == convertedAction.icon?.ios)
            #expect(action.icon?.web == convertedAction.icon?.web)
        } catch {
            Issue.record()
        }
    }

    @Test
    func testActionSerializationWithNilProps() {
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

            #expect(action.type == convertedAction.type)
            #expect(action.label == convertedAction.label)
            #expect(action.target == convertedAction.target)
            #expect(action.keyboard == convertedAction.keyboard)
            #expect(action.camera == convertedAction.camera)
            #expect(action.destructive == convertedAction.destructive)
            #expect(action.icon?.android == convertedAction.icon?.android)
            #expect(action.icon?.ios == convertedAction.icon?.ios)
            #expect(action.icon?.web == convertedAction.icon?.web)
        } catch {
            Issue.record()
        }
    }

    @Test
    func testIconSerialization() {
        let icon = NotificareNotification.Action.Icon(
            android: "testAndroid",
            ios: "testIos",
            web: "testWeb"
        )

        do {
            let convertedIcon = try NotificareNotification.Action.Icon.fromJson(json: icon.toJson())

            #expect(icon.android == convertedIcon.android)
            #expect(icon.ios == convertedIcon.ios)
            #expect(icon.web == convertedIcon.web)
        } catch {
            Issue.record()
        }
    }

    @Test
    func testIconSerializationWithNilProps() {
        let icon = NotificareNotification.Action.Icon(
            android: nil,
            ios: nil,
            web: nil
        )

        do {
            let convertedIcon = try NotificareNotification.Action.Icon.fromJson(json: icon.toJson())

            #expect(icon.android == convertedIcon.android)
            #expect(icon.ios == convertedIcon.ios)
            #expect(icon.web == convertedIcon.web)
        } catch {
            Issue.record()
        }
    }

    @Test
    func testAttachmentSerialization() {
        let attachment = NotificareNotification.Attachment(
            mimeType: "testMimeType",
            uri: "testUri"
        )

        do {
            let convertedAttachment = try NotificareNotification.Attachment.fromJson(json: attachment.toJson())

            #expect(attachment.mimeType == convertedAttachment.mimeType)
            #expect(attachment.uri == convertedAttachment.uri)
        } catch {
            Issue.record()
        }
    }

    func assertNotification(notification: NotificareNotification, convertedNotification: NotificareNotification) {
        #expect(notification.partial == convertedNotification.partial)
        #expect(notification.id == convertedNotification.id)
        #expect(notification.type == convertedNotification.type)
        #expect(notification.time == convertedNotification.time)
        #expect(notification.title == convertedNotification.title)
        #expect(notification.subtitle == convertedNotification.subtitle)
        #expect(notification.message == convertedNotification.message)
        for index in notification.content.indices {
            #expect(notification.content[index].type == convertedNotification.content[index].type)
            #expect(TestUtils.isEqual(type: String.self, a: notification.content[index].data, b: convertedNotification.content[index].data))
        }
        for index in notification.actions.indices {
            #expect(notification.actions[index].type == convertedNotification.actions[index].type)
            #expect(notification.actions[index].label == convertedNotification.actions[index].label)
            #expect(notification.actions[index].target == convertedNotification.actions[index].target)
            #expect(notification.actions[index].keyboard == convertedNotification.actions[index].keyboard)
            #expect(notification.actions[index].camera == convertedNotification.actions[index].camera)
            #expect(notification.actions[index].destructive == convertedNotification.actions[index].destructive)
            #expect(notification.actions[index].icon?.android == convertedNotification.actions[index].icon?.android)
            #expect(notification.actions[index].icon?.ios == convertedNotification.actions[index].icon?.ios)
            #expect(notification.actions[index].icon?.web == convertedNotification.actions[index].icon?.web)
        }
        for index in notification.attachments.indices {
            #expect(notification.attachments[index].mimeType == convertedNotification.attachments[index].mimeType)
            #expect(notification.attachments[index].uri == convertedNotification.attachments[index].uri)
        }
        #expect(NSDictionary(dictionary: notification.extra) == NSDictionary(dictionary: convertedNotification.extra))
        #expect(notification.targetContentIdentifier == convertedNotification.targetContentIdentifier)
    }
}
