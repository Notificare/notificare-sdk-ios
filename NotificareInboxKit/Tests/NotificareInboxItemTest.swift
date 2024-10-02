//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareKit
@testable import NotificareInboxKit
import Testing

internal struct NotificareInboxItemTest {
    @Test
    internal func testNotificareInboxItemSerialization() {
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

            #expect(item == convertedItem)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testNotificareInboxItemSerializationWithNilProps() {
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

            #expect(item == convertedItem)
        } catch {
            Issue.record()
        }
    }
}
