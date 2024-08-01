//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareKit
@testable import NotificareScannablesKit
import Testing

struct ScannablesPushApiModelsTest {
    @Test
    func testScannableToModel() {
        let expectedScannable = NotificareScannable(
            id: "testId",
            name: "testName",
            tag: "testTag",
            type: "testType",
            notification: NotificareNotification(
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
                            web: "testWeb")
                    ),
                ],
                attachments: [
                    NotificareNotification.Attachment(
                        mimeType: "testMimeType",
                        uri: "testUri"
                    ), ],
                extra: ["testExtraKey": "testExtraValue"],
                targetContentIdentifier: "testTargetIdentifier"
            )
        )

        let scannable = NotificareInternals.PushAPI.Models.Scannable(
            _id: "testId",
            name: "testName",
            type: "testType",
            tag: "testTag",
            data: NotificareInternals.PushAPI.Models.Scannable.ScannableData(
                notification: NotificareInternals.PushAPI.Models.Notification(
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
                )
            )
        ).toModel()

        assertScannable(expectedScannable: expectedScannable, scannable: scannable)
    }

    @Test
    func testScannableWithNilPropsToModel() {
        let expectedScannable = NotificareScannable(
            id: "testId",
            name: "testName",
            tag: "testTag",
            type: "testType",
            notification: nil
        )

        let scannable = NotificareInternals.PushAPI.Models.Scannable(
            _id: "testId",
            name: "testName",
            type: "testType",
            tag: "testTag",
            data: nil
        ).toModel()

        assertScannable(expectedScannable: expectedScannable, scannable: scannable)
    }

    func assertScannable(expectedScannable: NotificareScannable, scannable: NotificareScannable) {
        #expect(expectedScannable.id == scannable.id)
        #expect(expectedScannable.name == scannable.name)
        #expect(expectedScannable.tag == scannable.tag)
        #expect(expectedScannable.type == scannable.type)
        if let notification = expectedScannable.notification,
           let convertedNotification = scannable.notification
        {
            #expect(notification.partial == convertedNotification.partial)
            #expect(notification.id == convertedNotification.id)
            #expect(notification.type == convertedNotification.type)
            #expect(notification.time == convertedNotification.time)
            #expect(notification.title == convertedNotification.title)
            #expect(notification.subtitle == convertedNotification.subtitle)
            #expect(notification.message == convertedNotification.message)
            for index in notification.content.indices {
                #expect(notification.content[index].type == convertedNotification.content[index].type)
                #expect(TestUtils.isEqual(type: String.self, a: notification.content[index].data, b: convertedNotification.content[index].data))
            }
            for index in notification.actions.indices {
                #expect(notification.actions[index].type == convertedNotification.actions[index].type)
                #expect(notification.actions[index].label == convertedNotification.actions[index].label)
                #expect(notification.actions[index].target == convertedNotification.actions[index].target)
                #expect(notification.actions[index].keyboard == convertedNotification.actions[index].keyboard)
                #expect(notification.actions[index].camera == convertedNotification.actions[index].camera)
                #expect(notification.actions[index].destructive == convertedNotification.actions[index].destructive)
                #expect(notification.actions[index].icon?.android == convertedNotification.actions[index].icon?.android)
                #expect(notification.actions[index].icon?.ios == convertedNotification.actions[index].icon?.ios)
                #expect(notification.actions[index].icon?.web == convertedNotification.actions[index].icon?.web)
            }
            for index in notification.attachments.indices {
                #expect(notification.attachments[index].mimeType == convertedNotification.attachments[index].mimeType)
                #expect(notification.attachments[index].uri == convertedNotification.attachments[index].uri)
            }
            #expect(NSDictionary(dictionary: notification.extra) == NSDictionary(dictionary: convertedNotification.extra))
            #expect(notification.targetContentIdentifier == convertedNotification.targetContentIdentifier)
        }
    }
}
