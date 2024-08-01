//
// Copyright (c) 2024 Notificare. All rights reserved.
//
@testable import NotificareInAppMessagingKit
import Testing

struct NotificareInAppMessageTest {
    @Test
    func testNotificareInAppMessageSerialization() {
        let message = NotificareInAppMessage(
            id: "testId",
            name: "testName",
            type: "testType",
            context: ["testContext"],
            title: "testTitle",
            message: "testMessage",
            image: "testMessage",
            landscapeImage: "testLandscapeImage",
            delaySeconds: 0,
            primaryAction: NotificareInAppMessage.Action(
                label: "testLabel",
                destructive: true,
                url: "testUrl"
            ),
            secondaryAction: NotificareInAppMessage.Action(
                label: "testLabel",
                destructive: true,
                url: "testUrl"
            )
        )

        do {
            let convertedMessage = try NotificareInAppMessage.fromJson(json: message.toJson())

            assertMessage(message: message, convertedMessage: convertedMessage)
        } catch {
            Issue.record()
        }
    }

    @Test
    func testNotificareInAppMessageSerializationWithilProps() {
        let message = NotificareInAppMessage(
            id: "testId",
            name: "testName",
            type: "testType",
            context: [],
            title: nil,
            message: nil,
            image: nil,
            landscapeImage: nil,
            delaySeconds: 0,
            primaryAction: nil,
            secondaryAction: nil
        )

        do {
            let convertedMessage = try NotificareInAppMessage.fromJson(json: message.toJson())

            assertMessage(message: message, convertedMessage: convertedMessage)
        } catch {
            Issue.record()
        }
    }

    @Test
    func testActionSerialization() {
        let action = NotificareInAppMessage.Action(
            label: "testLabel",
            destructive: true,
            url: "testUrl"
        )

        do {
            let convertedAction = try NotificareInAppMessage.Action.fromJson(json: action.toJson())

            #expect(action.label == convertedAction.label)
            #expect(action.destructive == convertedAction.destructive)
            #expect(action.url == convertedAction.url)
        } catch {
            Issue.record()
        }
    }

    @Test
    func testActionSerializationWithNilProps() {
        let action = NotificareInAppMessage.Action(
            label: nil,
            destructive: true,
            url: nil
        )

        do {
            let convertedAction = try NotificareInAppMessage.Action.fromJson(json: action.toJson())

            #expect(action.label == convertedAction.label)
            #expect(action.destructive == convertedAction.destructive)
            #expect(action.url == convertedAction.url)
        } catch {
            Issue.record()
        }
    }

    func assertMessage(message: NotificareInAppMessage, convertedMessage: NotificareInAppMessage) {
        #expect(message.id == convertedMessage.id)
        #expect(message.name == convertedMessage.name)
        #expect(message.type == convertedMessage.type)
        #expect(message.context == convertedMessage.context)
        #expect(message.title == convertedMessage.title)
        #expect(message.message == convertedMessage.message)
        #expect(message.image == convertedMessage.image)
        #expect(message.landscapeImage == convertedMessage.landscapeImage)
        #expect(message.delaySeconds == convertedMessage.delaySeconds)
        #expect(message.primaryAction?.label == convertedMessage.primaryAction?.label)
        #expect(message.primaryAction?.destructive == convertedMessage.primaryAction?.destructive)
        #expect(message.primaryAction?.url == convertedMessage.primaryAction?.url)
        #expect(message.secondaryAction?.label == convertedMessage.secondaryAction?.label)
        #expect(message.secondaryAction?.destructive == convertedMessage.secondaryAction?.destructive)
        #expect(message.secondaryAction?.url == convertedMessage.secondaryAction?.url)
    }
}
