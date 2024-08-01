//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareKit
import Testing

struct PushAPIModelsTest {
    @Test
    func testNotificareApplicationToModel() {
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

        assertApplication(expectedApplication: expectedApplication, application: application)
    }

    @Test
    func testNotificareApplicationWithNilPropsToModel() {
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

        assertApplication(expectedApplication: expectedApplication, application: application)
    }

    @Test
    func testNotificationToModel() {
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

        assertNotification(expectedNotification: expectedNotification, notification: notification)
    }

    @Test
    func testNotificationWithNilPropsToModel() {
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

        assertNotification(expectedNotification: expectedNotification, notification: notification)
    }

    @Test
    func testActionToModel() {
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

        #expect(expectedAction.type == action?.type)
        #expect(expectedAction.label == action?.label)
        #expect(expectedAction.target == action?.target)
        #expect(expectedAction.keyboard == action?.keyboard)
        #expect(expectedAction.camera == action?.camera)
        #expect(expectedAction.destructive == action?.destructive)
        #expect(expectedAction.icon?.android == action?.icon?.android)
        #expect(expectedAction.icon?.ios == action?.icon?.ios)
        #expect(expectedAction.icon?.web == action?.icon?.web)
    }

    @Test
    func testActionWithNilPropsToModel() {
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

        #expect(expectedAction.type == action?.type)
        #expect(expectedAction.label == action?.label)
        #expect(expectedAction.target == action?.target)
        #expect(expectedAction.keyboard == action?.keyboard)
        #expect(expectedAction.camera == action?.camera)
        #expect(expectedAction.destructive == action?.destructive)
        #expect(expectedAction.icon?.android == action?.icon?.android)
        #expect(expectedAction.icon?.ios == action?.icon?.ios)
        #expect(expectedAction.icon?.web == action?.icon?.web)
    }

    @Test
    func testActionWithNilLabelToModel() {
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

    func assertApplication(expectedApplication: NotificareApplication, application: NotificareApplication) {
        #expect(expectedApplication.id == application.id)
        #expect(expectedApplication.name == application.name)
        #expect(expectedApplication.category == application.category)
        #expect(expectedApplication.appStoreId == application.appStoreId)
        #expect(NSDictionary(dictionary: application.services) == NSDictionary(dictionary: application.services))
        #expect(expectedApplication.inboxConfig?.useInbox == application.inboxConfig?.useInbox)
        #expect(expectedApplication.inboxConfig?.useUserInbox == application.inboxConfig?.useUserInbox)
        #expect(expectedApplication.inboxConfig?.autoBadge == application.inboxConfig?.autoBadge)
        #expect(expectedApplication.regionConfig?.proximityUUID == application.regionConfig?.proximityUUID)

        for index in expectedApplication.userDataFields.indices {
            #expect(expectedApplication.userDataFields[index].type == application.userDataFields[index].type)
            #expect(expectedApplication.userDataFields[index].key == application.userDataFields[index].key)
            #expect(expectedApplication.userDataFields[index].label == application.userDataFields[index].label)
        }

        for index in expectedApplication.actionCategories.indices {
            #expect(expectedApplication.actionCategories[index].name == application.actionCategories[index].name)
            #expect(expectedApplication.actionCategories[index].description == application.actionCategories[index].description)
            #expect(expectedApplication.actionCategories[index].type == application.actionCategories[index].type)

            for actionIndex in expectedApplication.actionCategories[index].actions.indices {
                #expect(expectedApplication.actionCategories[index].actions[actionIndex].type == application.actionCategories[index].actions[actionIndex].type)
                #expect(expectedApplication.actionCategories[index].actions[actionIndex].label == application.actionCategories[index].actions[actionIndex].label)
                #expect(expectedApplication.actionCategories[index].actions[actionIndex].target == application.actionCategories[index].actions[actionIndex].target)
                #expect(expectedApplication.actionCategories[index].actions[actionIndex].keyboard == application.actionCategories[index].actions[actionIndex].keyboard)
                #expect(expectedApplication.actionCategories[index].actions[actionIndex].camera == application.actionCategories[index].actions[actionIndex].camera)
                #expect(expectedApplication.actionCategories[index].actions[actionIndex].destructive == application.actionCategories[index].actions[actionIndex].destructive)
                #expect(expectedApplication.actionCategories[index].actions[actionIndex].icon?.android == application.actionCategories[index].actions[actionIndex].icon?.android)
                #expect(expectedApplication.actionCategories[index].actions[actionIndex].icon?.ios == application.actionCategories[index].actions[actionIndex].icon?.ios)
                #expect(expectedApplication.actionCategories[index].actions[actionIndex].icon?.web == application.actionCategories[index].actions[actionIndex].icon?.web)
            }
        }
    }

    func assertNotification(expectedNotification: NotificareNotification, notification: NotificareNotification) {
        #expect(expectedNotification.partial == notification.partial)
        #expect(expectedNotification.id == notification.id)
        #expect(expectedNotification.type == notification.type)
        #expect(expectedNotification.time == notification.time)
        #expect(expectedNotification.title == notification.title)
        #expect(expectedNotification.subtitle == notification.subtitle)
        #expect(expectedNotification.message == notification.message)

        for index in expectedNotification.content.indices {
            #expect(expectedNotification.content[index].type == notification.content[index].type)
            #expect(TestUtils.isEqual(type: String.self, a: expectedNotification.content[index].data, b: notification.content[index].data))
        }

        for index in expectedNotification.actions.indices {
            #expect(expectedNotification.actions[index].type == notification.actions[index].type)
            #expect(expectedNotification.actions[index].label == notification.actions[index].label)
            #expect(expectedNotification.actions[index].target == notification.actions[index].target)
            #expect(expectedNotification.actions[index].keyboard == notification.actions[index].keyboard)
            #expect(expectedNotification.actions[index].camera == notification.actions[index].camera)
            #expect(expectedNotification.actions[index].destructive == notification.actions[index].destructive)
            #expect(expectedNotification.actions[index].icon?.android == notification.actions[index].icon?.android)
            #expect(expectedNotification.actions[index].icon?.ios == notification.actions[index].icon?.ios)
            #expect(expectedNotification.actions[index].icon?.web == notification.actions[index].icon?.web)
        }

        for index in expectedNotification.attachments.indices {
            #expect(expectedNotification.attachments[index].mimeType == notification.attachments[index].mimeType)
            #expect(expectedNotification.attachments[index].uri == notification.attachments[index].uri)
        }

        #expect(NSDictionary(dictionary: expectedNotification.extra) == NSDictionary(dictionary: notification.extra))
        #expect(expectedNotification.targetContentIdentifier == notification.targetContentIdentifier)
    }

}
