//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareKit
@testable import NotificareInboxKit
import Testing

struct NotificareInboxItemTest {
    @Test
    func testNotificareInboxItemSerialization() {
        let item = NotificareInboxItem(
            id: "testId",
            notification: NotificareNotification(
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
            ),
            time: Date(timeIntervalSince1970: 1),
            opened: true,
            expires: Date(timeIntervalSince1970: 1)
        )

        do {
            let convertedItem = try NotificareInboxItem.fromJson(json: item.toJson())

            assertItem(item: item, convertedItem: convertedItem)
        } catch {
            Issue.record()
        }
    }

    @Test
    func testNotificareInboxItemSerializationWithNilProps() {
        let item = NotificareInboxItem(
            id: "testId",
            notification: NotificareNotification(
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
            ),
            time: Date(timeIntervalSince1970: 1),
            opened: true,
            expires: nil
        )

        do {
            let convertedItem = try NotificareInboxItem.fromJson(json: item.toJson())

            assertItem(item: item, convertedItem: convertedItem)
        } catch {
            Issue.record()
        }
    }

    func assertItem(item: NotificareInboxItem, convertedItem: NotificareInboxItem) {
        #expect(item.id == convertedItem.id)
        #expect(item.notification.partial == convertedItem.notification.partial)
        #expect(item.notification.id == convertedItem.notification.id)
        #expect(item.notification.type == convertedItem.notification.type)
        #expect(item.notification.time == convertedItem.notification.time)
        #expect(item.notification.title == convertedItem.notification.title)
        #expect(item.notification.subtitle == convertedItem.notification.subtitle)
        #expect(item.notification.message == convertedItem.notification.message)
        for index in item.notification.content.indices {
            #expect(item.notification.content[index].type == convertedItem.notification.content[index].type)
            #expect(TestUtils.isEqual(type: String.self, a: item.notification.content[index].data, b: convertedItem.notification.content[index].data))
        }
        for index in item.notification.actions.indices {
            #expect(item.notification.actions[index].type == convertedItem.notification.actions[index].type)
            #expect(item.notification.actions[index].label == convertedItem.notification.actions[index].label)
            #expect(item.notification.actions[index].target == convertedItem.notification.actions[index].target)
            #expect(item.notification.actions[index].keyboard == convertedItem.notification.actions[index].keyboard)
            #expect(item.notification.actions[index].camera == convertedItem.notification.actions[index].camera)
            #expect(item.notification.actions[index].destructive == convertedItem.notification.actions[index].destructive)
            #expect(item.notification.actions[index].icon?.android == convertedItem.notification.actions[index].icon?.android)
            #expect(item.notification.actions[index].icon?.ios == convertedItem.notification.actions[index].icon?.ios)
            #expect(item.notification.actions[index].icon?.web == convertedItem.notification.actions[index].icon?.web)
        }
        for index in item.notification.attachments.indices {
            #expect(item.notification.attachments[index].mimeType == convertedItem.notification.attachments[index].mimeType)
            #expect(item.notification.attachments[index].uri == convertedItem.notification.attachments[index].uri)
        }
        #expect(NSDictionary(dictionary: item.notification.extra) == NSDictionary(dictionary: convertedItem.notification.extra))
        #expect(item.notification.targetContentIdentifier == convertedItem.notification.targetContentIdentifier)
        #expect(item.time == convertedItem.time)
        #expect(item.opened == convertedItem.opened)
        #expect(item.expires == convertedItem.expires)
    }
}
