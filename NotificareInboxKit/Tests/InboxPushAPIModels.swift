//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareKit
@testable import NotificareInboxKit
import Testing

internal struct InboxPushAPIModels {
    @Test
    internal func testRemoteInboxItemToModel() {
        let expectedItem = NotificareInboxItem(
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
                attachments: [
                    NotificareNotification.Attachment(
                        mimeType: "testMimeType",
                        uri: "testUri"
                    ),
                ],
                extra: ["testKey": "testValue"],
                targetContentIdentifier: nil
            ),
            time: Date(timeIntervalSince1970: 1),
            opened: true,
            expires: Date(timeIntervalSince1970: 1)
        )

        let item = NotificareInternals.PushAPI.Models.RemoteInboxItem(
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
            visible: true,
            expires: Date(timeIntervalSince1970: 1)
        ).toModel()

        #expect(expectedItem == item)
    }

    @Test
    internal func testRemoteInboxItemWithNullPropsToModel() {
        let expectedItem = NotificareInboxItem(
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

        let item = NotificareInternals.PushAPI.Models.RemoteInboxItem(
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
            visible: true,
            expires: nil
        ).toModel()

        #expect(expectedItem == item)
    }
}
