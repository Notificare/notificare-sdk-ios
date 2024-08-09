//
// Copyright (c) 2024 Notificare. All rights reserved.
//
@testable import NotificareInAppMessagingKit
import Testing

internal struct NotificareInAppMessageTest {
    @Test
    internal func testNotificareInAppMessageSerialization() {
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

            #expect(message == convertedMessage)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testNotificareInAppMessageSerializationWithNilProps() {
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

            #expect(message == convertedMessage)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testActionSerialization() {
        let action = NotificareInAppMessage.Action(
            label: "testLabel",
            destructive: true,
            url: "testUrl"
        )

        do {
            let convertedAction = try NotificareInAppMessage.Action.fromJson(json: action.toJson())

            #expect(action == convertedAction)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testActionSerializationWithNilProps() {
        let action = NotificareInAppMessage.Action(
            label: nil,
            destructive: true,
            url: nil
        )

        do {
            let convertedAction = try NotificareInAppMessage.Action.fromJson(json: action.toJson())

            #expect(action == convertedAction)
        } catch {
            Issue.record()
        }
    }
}
