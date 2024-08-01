//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareUserInboxKit
@testable import NotificareKit
import Testing

struct NotificareUserInboxResponseTest {
    @Test
    func testNotificareUserInboxResponseSerialization() {
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

            assertResponse(response: response, convertedResponse: convertedResponse)
        } catch {
            Issue.record()
        }
    }

    @Test
    func testNotificareUserInboxResponseSerializationWithNilProbs() {
        let response = NotificareUserInboxResponse(
            count: 1,
            unread: 1,
            items: []
        )

        do {
            let convertedResponse = try NotificareUserInboxResponse.fromJson(json: response.toJson())

            assertResponse(response: response, convertedResponse: convertedResponse)
        } catch {
            Issue.record()
        }
    }

    func assertResponse(response: NotificareUserInboxResponse, convertedResponse: NotificareUserInboxResponse) {
        #expect(response.count == convertedResponse.count)
        #expect(response.unread == convertedResponse.unread)
        for index in response.items.indices{
            #expect(response.items[index].id == convertedResponse.items[index].id)
            #expect(response.items[index].notification.partial == convertedResponse.items[index].notification.partial)
            #expect(response.items[index].notification.id == convertedResponse.items[index].notification.id)
            #expect(response.items[index].notification.type == convertedResponse.items[index].notification.type)
            #expect(response.items[index].notification.time == convertedResponse.items[index].notification.time)
            #expect(response.items[index].notification.title == convertedResponse.items[index].notification.title)
            #expect(response.items[index].notification.subtitle == convertedResponse.items[index].notification.subtitle)
            #expect(response.items[index].notification.message == convertedResponse.items[index].notification.message)
            for contentIndex in response.items[index].notification.content.indices {
                #expect(response.items[contentIndex].notification.content[contentIndex].type == convertedResponse.items[contentIndex].notification.content[contentIndex].type)
                #expect(TestUtils.isEqual(type: String.self, a: response.items[contentIndex].notification.content[contentIndex].data, b: convertedResponse.items[contentIndex].notification.content[contentIndex].data))
            }
            for actionsIndex in response.items[index].notification.actions.indices {
                #expect(response.items[actionsIndex].notification.actions[actionsIndex].type == convertedResponse.items[actionsIndex].notification.actions[actionsIndex].type)
                #expect(response.items[actionsIndex].notification.actions[actionsIndex].label == convertedResponse.items[actionsIndex].notification.actions[actionsIndex].label)
                #expect(response.items[actionsIndex].notification.actions[actionsIndex].target == convertedResponse.items[actionsIndex].notification.actions[actionsIndex].target)
                #expect(response.items[actionsIndex].notification.actions[actionsIndex].keyboard == convertedResponse.items[actionsIndex].notification.actions[actionsIndex].keyboard)
                #expect(response.items[actionsIndex].notification.actions[actionsIndex].camera == convertedResponse.items[actionsIndex].notification.actions[actionsIndex].camera)
                #expect(response.items[actionsIndex].notification.actions[actionsIndex].destructive == convertedResponse.items[actionsIndex].notification.actions[actionsIndex].destructive)
                #expect(response.items[actionsIndex].notification.actions[actionsIndex].icon?.android == convertedResponse.items[actionsIndex].notification.actions[actionsIndex].icon?.android)
                #expect(response.items[actionsIndex].notification.actions[actionsIndex].icon?.ios == convertedResponse.items[actionsIndex].notification.actions[actionsIndex].icon?.ios)
                #expect(response.items[actionsIndex].notification.actions[actionsIndex].icon?.web == convertedResponse.items[actionsIndex].notification.actions[actionsIndex].icon?.web)
            }
            for attachementIndex in response.items[index].notification.attachments.indices {
                #expect(response.items[attachementIndex].notification.attachments[attachementIndex].mimeType == convertedResponse.items[attachementIndex].notification.attachments[attachementIndex].mimeType)
                #expect(response.items[attachementIndex].notification.attachments[attachementIndex].uri == convertedResponse.items[attachementIndex].notification.attachments[attachementIndex].uri)
            }
            #expect(NSDictionary(dictionary: response.items[index].notification.extra) == NSDictionary(dictionary: convertedResponse.items[index].notification.extra))
            #expect(response.items[index].notification.targetContentIdentifier == convertedResponse.items[index].notification.targetContentIdentifier)
            #expect(response.items[index].time == convertedResponse.items[index].time)
            #expect(response.items[index].opened == convertedResponse.items[index].opened)
            #expect(response.items[index].expires == convertedResponse.items[index].expires)
        }

    }
}
