//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareKit
import Testing

internal struct PushAPIModelsTest {
    @Test
    internal func testNotificareApplicationToModel() {
        let expectedApplication = NotificareApplication(
            id: "testId",
            name: "testName",
            category: "testCategory",
            appStoreId: "testAppStoreId",
            services: ["testKey": true],
            inboxConfig: NotificareApplication.InboxConfig(
                useInbox: true,
                useUserInbox: true,
                autoBadge: true
            ),
            regionConfig: NotificareApplication.RegionConfig(proximityUUID: "testUUID"),
            userDataFields: [
                NotificareApplication.UserDataField(
                    type: "testType",
                    key: "testKey",
                    label: "testLabel"
                ),
            ],
            actionCategories: [
                NotificareApplication.ActionCategory(
                    name: "testName",
                    description: "testDescription",
                    type: "testType",
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
                                ios: "testIOS",
                                web: "testWeb"
                            )
                        ),
                    ]
                ),
            ]
        )

        let application = NotificareInternals.PushAPI.Models.Application(
            _id: "testId",
            name: "testName",
            category: "testCategory",
            appStoreId: "testAppStoreId",
            services: ["testKey": true],
            inboxConfig: NotificareApplication.InboxConfig(
                useInbox: true,
                useUserInbox: true,
                autoBadge: true
            ),
            regionConfig: NotificareApplication.RegionConfig(proximityUUID: "testUUID"),
            userDataFields: [
                NotificareApplication.UserDataField(
                    type: "testType",
                    key: "testKey",
                    label: "testLabel"
                ),
            ],
            actionCategories: [
                NotificareInternals.PushAPI.Models.Application.ActionCategory(
                    name: "testName",
                    description: "testDescription",
                    type: "testType",
                    actions: [
                        NotificareInternals.PushAPI.Models.Notification.Action(
                            type: "testType",
                            label: "testLabel",
                            target: "testTarget",
                            keyboard: true,
                            camera: true,
                            destructive: true,
                            icon: NotificareNotification.Action.Icon(
                                android: "testAndroid",
                                ios: "testIOS",
                                web: "testWeb"
                            )
                        ),
                    ]
                ),
            ]
        ).toModel()

        #expect(expectedApplication == application)
    }

    @Test
    internal func testNotificareApplicationWithNilPropsToModel() {
        let expectedApplication = NotificareApplication(
            id: "testId",
            name: "testName",
            category: "testCategory",
            appStoreId: nil,
            services: [:],
            inboxConfig: nil,
            regionConfig: nil,
            userDataFields: [],
            actionCategories: []
        )

        let application = NotificareInternals.PushAPI.Models.Application(
            _id: "testId",
            name: "testName",
            category: "testCategory",
            appStoreId: nil,
            services: [:],
            inboxConfig: nil,
            regionConfig: nil,
            userDataFields: [],
            actionCategories: []
        ).toModel()

        #expect(expectedApplication == application)
    }

    @Test
    internal func testNotificationToModel() {
        let expectedNotification = NotificareNotification(
            partial: false,
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
                        web: "testWeb"
                    )
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
        )

        let notification = NotificareInternals.PushAPI.Models.Notification(
            _id: "testId",
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
                NotificareInternals.PushAPI.Models.Notification.Action(
                    type: "testType",
                    label: "testLabel",
                    target: "testTarget",
                    keyboard: true,
                    camera: true,
                    destructive: true,
                    icon: NotificareNotification.Action.Icon(
                        android: "testAndroid",
                        ios: "testIos",
                        web: "testWeb"
                    )
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
        ).toModel()

        #expect(expectedNotification == notification)
    }

    @Test
    internal func testNotificationWithNilPropsToModel() {
        let expectedNotification = NotificareNotification(
            partial: false,
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
        )

        let notification = NotificareInternals.PushAPI.Models.Notification(
            _id: "testId",
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
        ).toModel()

        #expect(expectedNotification == notification)
    }

    @Test
    internal func testActionToModel() {
        let expectedAction = NotificareNotification.Action(
            type: "testType",
            label: "testLabel",
            target: "testTarget",
            keyboard: true,
            camera: true,
            destructive: true,
            icon: NotificareNotification.Action.Icon(
                android: "testAndroid",
                ios: "testIos",
                web: "testWeb"
            )
        )

        let action = NotificareInternals.PushAPI.Models.Notification.Action(
            type: "testType",
            label: "testLabel",
            target: "testTarget",
            keyboard: true,
            camera: true,
            destructive: true,
            icon: NotificareNotification.Action.Icon(
                android: "testAndroid",
                ios: "testIos",
                web: "testWeb"
            )
        ).toModel()

        #expect(expectedAction == action)
    }

    @Test
    internal func testActionWithNilPropsToModel() {
        let expectedAction = NotificareNotification.Action(
            type: "testType",
            label: "testLabel",
            target: nil,
            keyboard: false,
            camera: false,
            destructive: nil,
            icon: nil
        )

        let action = NotificareInternals.PushAPI.Models.Notification.Action(
            type: "testType",
            label: "testLabel",
            target: nil,
            keyboard: nil,
            camera: nil,
            destructive: nil,
            icon: nil
        ).toModel()

        #expect(expectedAction == action)
    }

    @Test
    internal func testActionWithNilLabelToModel() {
        let action = NotificareInternals.PushAPI.Models.Notification.Action(
            type: "testType",
            label: nil,
            target: "testTarget",
            keyboard: true,
            camera: true,
            destructive: true,
            icon: NotificareNotification.Action.Icon(
                android: "testAndroid",
                ios: "testIos",
                web: "testWeb"
            )
        ).toModel()

        #expect(action == nil)
    }
}
