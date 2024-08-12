//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareUserInboxKit
@testable import NotificareKit
import Testing

internal struct NotificareUserInboxResponseTest {
    @Test
    internal func testNotificareUserInboxResponseSerialization() {
        let response = NotificareUserInboxResponse(
            count: 1,
            unread: 1,
            items: [NotificareUserInboxItem(
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
            ),
            ]
        )

        do {
            let convertedResponse = try NotificareUserInboxResponse.fromJson(json: response.toJson())

            #expect(response == convertedResponse)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testNotificareUserInboxResponseSerializationWithNilProps() {
        let response = NotificareUserInboxResponse(
            count: 1,
            unread: 1,
            items: []
        )

        do {
            let convertedResponse = try NotificareUserInboxResponse.fromJson(json: response.toJson())

            #expect(response == convertedResponse)
        } catch {
            Issue.record()
        }
    }
}
