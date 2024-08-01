//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareKit
import Testing

struct NotificareApplicationTest {
    @Test
    func testNotificareApplicationSerialization() {
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

            assertApplication(application: application, convertedApplication: convertedApplication)
        } catch {
            Issue.record()
        }
    }

    @Test
    func testNotificareApplicationSerializationWithNilProps() {
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

            assertApplication(application: application, convertedApplication: convertedApplication)
        } catch {
            Issue.record()
        }
    }

    @Test
    func testInboxConfigSerialization() {
        let config = NotificareApplication.InboxConfig(
            useInbox: true,
            useUserInbox: true,
            autoBadge: true
        )

        do {
            let convertedConfig = try NotificareApplication.InboxConfig.fromJson(json: config.toJson())

            #expect(config.useInbox == convertedConfig.useInbox)
            #expect(config.useUserInbox == convertedConfig.useUserInbox)
            #expect(config.autoBadge == convertedConfig.autoBadge)
        } catch {
            Issue.record()
        }
    }

    @Test
    func testRegionConfigSerialization() {
        let config = NotificareApplication.RegionConfig(proximityUUID: "testUUID")

        do {
            let convertedConfig = try NotificareApplication.RegionConfig.fromJson(json: config.toJson())

            #expect(config.proximityUUID == convertedConfig.proximityUUID)
        } catch {
            Issue.record()
        }
    }

    @Test
    func testUserDataFieldSerialization() {
        let field = NotificareApplication.UserDataField(
            type: "testType",
            key: "testKey",
            label: "testLabel"
        )

        do {
            let convertedField = try NotificareApplication.UserDataField.fromJson(json: field.toJson())

            #expect(field.type == convertedField.type)
            #expect(field.key == convertedField.key)
            #expect(field.label == convertedField.label)
        } catch {
            Issue.record()
        }
    }

    @Test
    func testActionCategorySerialization() {
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

            assertActionCategory(category: category, convertedCategory: convertedCategory)
        } catch {
            Issue.record()
        }
    }

    @Test
    func testActionCategorySerializationWithNilProps() {
        let category = NotificareApplication.ActionCategory(
            name: "testName",
            description: nil,
            type: "testType",
            actions: []
        )

        do {
            let convertedCategory = try NotificareApplication.ActionCategory.fromJson(json: category.toJson())

            assertActionCategory(category: category, convertedCategory: convertedCategory)
        } catch {
            Issue.record()
        }
    }

    func assertApplication(application: NotificareApplication, convertedApplication: NotificareApplication) {
        #expect(application.id == convertedApplication.id)
        #expect(application.name == convertedApplication.name)
        #expect(application.category == convertedApplication.category)
        #expect(application.appStoreId == convertedApplication.appStoreId)
        #expect(NSDictionary(dictionary: convertedApplication.services) == NSDictionary(dictionary: convertedApplication.services))
        #expect(application.inboxConfig?.useInbox == convertedApplication.inboxConfig?.useInbox)
        #expect(application.inboxConfig?.useUserInbox == convertedApplication.inboxConfig?.useUserInbox)
        #expect(application.inboxConfig?.autoBadge == convertedApplication.inboxConfig?.autoBadge)
        #expect(application.regionConfig?.proximityUUID == convertedApplication.regionConfig?.proximityUUID)
        for index in application.userDataFields.indices {
            #expect(application.userDataFields[index].type == convertedApplication.userDataFields[index].type)
            #expect(application.userDataFields[index].key == convertedApplication.userDataFields[index].key)
            #expect(application.userDataFields[index].label == convertedApplication.userDataFields[index].label)
        }
        for index in application.actionCategories.indices {
            #expect(application.actionCategories[index].name == convertedApplication.actionCategories[index].name)
            #expect(application.actionCategories[index].description == convertedApplication.actionCategories[index].description)
            #expect(application.actionCategories[index].type == convertedApplication.actionCategories[index].type)
            for actionIndex in application.actionCategories[index].actions.indices {
                #expect(application.actionCategories[index].actions[actionIndex].type == convertedApplication.actionCategories[index].actions[actionIndex].type)
                #expect(application.actionCategories[index].actions[actionIndex].label == convertedApplication.actionCategories[index].actions[actionIndex].label)
                #expect(application.actionCategories[index].actions[actionIndex].target == convertedApplication.actionCategories[index].actions[actionIndex].target)
                #expect(application.actionCategories[index].actions[actionIndex].keyboard == convertedApplication.actionCategories[index].actions[actionIndex].keyboard)
                #expect(application.actionCategories[index].actions[actionIndex].camera == convertedApplication.actionCategories[index].actions[actionIndex].camera)
                #expect(application.actionCategories[index].actions[actionIndex].destructive == convertedApplication.actionCategories[index].actions[actionIndex].destructive)
                #expect(application.actionCategories[index].actions[actionIndex].icon?.android == convertedApplication.actionCategories[index].actions[actionIndex].icon?.android)
                #expect(application.actionCategories[index].actions[actionIndex].icon?.ios == convertedApplication.actionCategories[index].actions[actionIndex].icon?.ios)
                #expect(application.actionCategories[index].actions[actionIndex].icon?.web == convertedApplication.actionCategories[index].actions[actionIndex].icon?.web)
            }
        }
    }

    func assertActionCategory(category: NotificareApplication.ActionCategory, convertedCategory: NotificareApplication.ActionCategory) {
        #expect(category.name == convertedCategory.name)
        #expect(category.description == convertedCategory.description)
        #expect(category.type == convertedCategory.type)
        for index in category.actions.indices {
            #expect(category.actions[index].type == convertedCategory.actions[index].type)
            #expect(category.actions[index].label == convertedCategory.actions[index].label)
            #expect(category.actions[index].target == convertedCategory.actions[index].target)
            #expect(category.actions[index].keyboard == convertedCategory.actions[index].keyboard)
            #expect(category.actions[index].camera == convertedCategory.actions[index].camera)
            #expect(category.actions[index].destructive == convertedCategory.actions[index].destructive)
            #expect(category.actions[index].icon?.android == convertedCategory.actions[index].icon?.android)
            #expect(category.actions[index].icon?.ios == convertedCategory.actions[index].icon?.ios)
            #expect(category.actions[index].icon?.web == convertedCategory.actions[index].icon?.web)
        }
    }
}
