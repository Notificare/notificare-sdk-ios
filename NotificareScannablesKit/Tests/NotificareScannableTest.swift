//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareScannablesKit
@testable import NotificareKit
import Testing

struct NotificareScannableTest {
    @Test
    func testNotificareScannableSerialization() {
        let scannable = NotificareScannable(
            id: "testId",
            name: "testName",
            tag: "tesTag",
            type: "testType",
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
            )
        )

        do {
            let convertedScannable = try NotificareScannable.fromJson(json: scannable.toJson())

            assertScannable(scannable: scannable, convertedScannable: convertedScannable)
        } catch {
            Issue.record()
        }
    }

    @Test
    func testNotificareScannableSerializationWithNilProps() {
        let scannable = NotificareScannable(
            id: "testId",
            name: "testName",
            tag: "tesTag",
            type: "testType",
            notification: nil
        )

        do {
            let convertedScannable = try NotificareScannable.fromJson(json: scannable.toJson())

            assertScannable(scannable: scannable, convertedScannable: convertedScannable)
        } catch {
            Issue.record()
        }
    }

    func assertScannable(scannable: NotificareScannable, convertedScannable: NotificareScannable) {
        #expect(scannable.id == convertedScannable.id)
        #expect(scannable.name == convertedScannable.name)
        #expect(scannable.tag == convertedScannable.tag)
        #expect(scannable.type == convertedScannable.type)
        if let notification = scannable.notification,
           let convertedNotification = convertedScannable.notification
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
