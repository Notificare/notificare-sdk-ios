//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareKit
@testable import NotificareInAppMessagingKit
import Testing

internal struct PushAPIModelsTest {
    @Test
    internal func testMessageToModel() {
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

        #expect(expectedMessage == message)
    }

    @Test
    internal func testMessageWithNilPropsToModel() {
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

        #expect(expectedMessage == message)
    }
}
