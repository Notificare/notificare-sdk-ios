//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareUserInboxKit
@testable import NotificareKit
import Testing

internal struct RawUserInboxResponseTest {
    @Test
    internal func testRawUserInboxResponseToModel() {
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

        #expect(expectedItem == item)
    }

    @Test
    internal func testRawUserInboxResponseWithNilPropsToModel() {
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

        #expect(expectedItem == item)
    }
}
