//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareKit
import Testing

internal struct NotificareApplicationTest {
    @Test
    internal func testNotificareApplicationSerialization() {
        let application = NotificareApplication(
            id: "testString",
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

        do {
            let convertedApplication = try NotificareApplication.fromJson(json: application.toJson())

            #expect(application == convertedApplication)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testNotificareApplicationSerializationWithNilProps() {
        let application = NotificareApplication(
            id: "testString",
            name: "testName",
            category: "testCategory",
            appStoreId: nil,
            services: [:],
            inboxConfig: nil,
            regionConfig: nil,
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
                    description: nil,
                    type: "testType",
                    actions: []
                ),
            ]
        )

        do {
            let convertedApplication = try NotificareApplication.fromJson(json: application.toJson())

            #expect(application == convertedApplication)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testInboxConfigSerialization() {
        let config = NotificareApplication.InboxConfig(
            useInbox: true,
            useUserInbox: true,
            autoBadge: true
        )

        do {
            let convertedConfig = try NotificareApplication.InboxConfig.fromJson(json: config.toJson())

            #expect(config == convertedConfig)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testRegionConfigSerialization() {
        let config = NotificareApplication.RegionConfig(proximityUUID: "testUUID")

        do {
            let convertedConfig = try NotificareApplication.RegionConfig.fromJson(json: config.toJson())

            #expect(config == convertedConfig)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testUserDataFieldSerialization() {
        let field = NotificareApplication.UserDataField(
            type: "testType",
            key: "testKey",
            label: "testLabel"
        )

        do {
            let convertedField = try NotificareApplication.UserDataField.fromJson(json: field.toJson())

            #expect(field == convertedField)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testActionCategorySerialization() {
        let category = NotificareApplication.ActionCategory(
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
        )

        do {
            let convertedCategory = try NotificareApplication.ActionCategory.fromJson(json: category.toJson())

            #expect(category == convertedCategory)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testActionCategorySerializationWithNilProps() {
        let category = NotificareApplication.ActionCategory(
            name: "testName",
            description: nil,
            type: "testType",
            actions: []
        )

        do {
            let convertedCategory = try NotificareApplication.ActionCategory.fromJson(json: category.toJson())

            #expect(category == convertedCategory)
        } catch {
            Issue.record()
        }
    }
}
