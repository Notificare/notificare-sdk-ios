//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareUserInboxKit
@testable import NotificareKit
import Testing

struct RawUserInboxResponseTest {
    @Test
    func testRawUserInboxResponseToModel() {
        let expectedItem = NotificareUserInboxItem(
            id: "testId",
            notification: NotificareNotification(
                partial: true,
                id: "testNotification",
                type: "testType",
                time: Date(timeIntervalSince1970: 1),
                title: "testTitle",
                subtitle: "testSubtitle",
                message: "testMessage",
                content: [],
                actions: [],
                attachments: [NotificareNotification.Attachment(
                    mimeType: "testMimeType",
                    uri: "testUri"
                ), ],
                extra: ["testKey": "testValue"],
                targetContentIdentifier: nil
            ),
            time: Date(timeIntervalSince1970: 1),
            opened: true,
            expires: Date(timeIntervalSince1970: 1)
        )

        let item = RawUserInboxResponse.RawUserInboxItem(
            _id: "testId",
            notification: "testNotification",
            type: "testType",
            time: Date(timeIntervalSince1970: 1),
            title: "testTitle",
            subtitle: "testSubtitle",
            message: "testMessage",
            attachment: NotificareNotification.Attachment(
                mimeType: "testMimeType",
                uri: "testUri"
            ),
            extra: ["testKey": "testValue"],
            opened: true,
            expires: Date(timeIntervalSince1970: 1)
        ).toModel()

        assertItem(expectedItem: expectedItem, item: item)
    }

    @Test
    func testRawUserInboxResponseWithNilPropsToModel() {
        let expectedItem = NotificareUserInboxItem(
            id: "testId",
            notification: NotificareNotification(
                partial: true,
                id: "testNotification",
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

        let item = RawUserInboxResponse.RawUserInboxItem(
            _id: "testId",
            notification: "testNotification",
            type: "testType",
            time: Date(timeIntervalSince1970: 1),
            title: nil,
            subtitle: nil,
            message: "testMessage",
            attachment: nil,
            extra: [:],
            opened: true,
            expires: nil
        ).toModel()

        assertItem(expectedItem: expectedItem, item: item)
    }

    func assertItem(expectedItem: NotificareUserInboxItem, item: NotificareUserInboxItem) {
        #expect(expectedItem.id == item.id)
        #expect(expectedItem.notification.partial == item.notification.partial)
        #expect(expectedItem.notification.id == item.notification.id)
        #expect(expectedItem.notification.type == item.notification.type)
        #expect(expectedItem.notification.time == item.notification.time)
        #expect(expectedItem.notification.title == item.notification.title)
        #expect(expectedItem.notification.subtitle == item.notification.subtitle)
        #expect(expectedItem.notification.message == item.notification.message)
        for index in expectedItem.notification.content.indices {
            #expect(expectedItem.notification.content[index].type == item.notification.content[index].type)
            #expect(TestUtils.isEqual(type: String.self, a: expectedItem.notification.content[index].data, b: item.notification.content[index].data))
        }
        for index in expectedItem.notification.actions.indices {
            #expect(expectedItem.notification.actions[index].type == item.notification.actions[index].type)
            #expect(expectedItem.notification.actions[index].label == item.notification.actions[index].label)
            #expect(expectedItem.notification.actions[index].target == item.notification.actions[index].target)
            #expect(expectedItem.notification.actions[index].keyboard == item.notification.actions[index].keyboard)
            #expect(expectedItem.notification.actions[index].camera == item.notification.actions[index].camera)
            #expect(expectedItem.notification.actions[index].destructive == item.notification.actions[index].destructive)
            #expect(expectedItem.notification.actions[index].icon?.android == item.notification.actions[index].icon?.android)
            #expect(expectedItem.notification.actions[index].icon?.ios == item.notification.actions[index].icon?.ios)
            #expect(expectedItem.notification.actions[index].icon?.web == item.notification.actions[index].icon?.web)
        }
        for index in expectedItem.notification.attachments.indices {
            #expect(expectedItem.notification.attachments[index].mimeType == item.notification.attachments[index].mimeType)
            #expect(expectedItem.notification.attachments[index].uri == item.notification.attachments[index].uri)
        }
        #expect(NSDictionary(dictionary: expectedItem.notification.extra) == NSDictionary(dictionary: item.notification.extra))
        #expect(expectedItem.notification.targetContentIdentifier == item.notification.targetContentIdentifier)
        #expect(expectedItem.time == item.time)
        #expect(expectedItem.opened == item.opened)
        #expect(expectedItem.expires == item.expires)
    }
}
