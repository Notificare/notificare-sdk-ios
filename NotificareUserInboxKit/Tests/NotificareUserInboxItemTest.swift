//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareUserInboxKit
@testable import NotificareKit
import Testing

internal struct NotificareUserInboxItemTest {
    @Test
    internal func testNotificareUserInboxSerialization() {
        let item = NotificareUserInboxItem(
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
            let convertedItem = try NotificareUserInboxItem.fromJson(json: item.toJson())

            #expect(item == convertedItem)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testNotificareUserInboxSerializationWithNullProps() {
        let item = NotificareUserInboxItem(
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
            let convertedItem = try NotificareUserInboxItem.fromJson(json: item.toJson())

            #expect(item == convertedItem)
        } catch {
            Issue.record()
        }
    }
}
