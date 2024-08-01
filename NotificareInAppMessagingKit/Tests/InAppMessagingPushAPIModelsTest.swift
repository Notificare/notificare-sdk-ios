//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareKit
@testable import NotificareInAppMessagingKit
import Testing

struct PushAPIModelsTest {
    @Test
    func testMessageToModel() {
        let expectedMessage = NotificareInAppMessage(
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

        let message = NotificareInternals.PushAPI.Models.Message(
            _id: "testId",
            name: "testName",
            type: "testType",
            context: ["testContext"],
            title: "testTitle",
            message: "testMessage",
            image: "testMessage",
            landscapeImage: "testLandscapeImage",
            delaySeconds: 0,
            primaryAction: NotificareInternals.PushAPI.Models.Message.Action(
                label: "testLabel",
                destructive: true,
                url: "testUrl"
            ),
            secondaryAction: NotificareInternals.PushAPI.Models.Message.Action(
                label: "testLabel",
                destructive: true,
                url: "testUrl"
            )
        ).toModel()

        assertMessage(expectedMessage: expectedMessage, message: message)
    }

    @Test
    func testMessageWithNlPropsToModel() {
        let expectedMessage = NotificareInAppMessage(
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

        let message = NotificareInternals.PushAPI.Models.Message(
            _id: "testId",
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
        ).toModel()

        assertMessage(expectedMessage: expectedMessage, message: message)
    }

    func assertMessage(expectedMessage: NotificareInAppMessage, message: NotificareInAppMessage) {
        #expect(expectedMessage.id == message.id)
        #expect(expectedMessage.name == message.name)
        #expect(expectedMessage.type == message.type)
        #expect(expectedMessage.context == message.context)
        #expect(expectedMessage.title == message.title)
        #expect(expectedMessage.message == message.message)
        #expect(expectedMessage.image == message.image)
        #expect(expectedMessage.landscapeImage == message.landscapeImage)
        #expect(expectedMessage.delaySeconds == message.delaySeconds)
        #expect(expectedMessage.primaryAction?.label == message.primaryAction?.label)
        #expect(expectedMessage.primaryAction?.destructive == message.primaryAction?.destructive)
        #expect(expectedMessage.primaryAction?.url == message.primaryAction?.url)
        #expect(expectedMessage.secondaryAction?.label == message.secondaryAction?.label)
        #expect(expectedMessage.secondaryAction?.destructive == message.secondaryAction?.destructive)
        #expect(expectedMessage.secondaryAction?.url == message.secondaryAction?.url)
    }
}
