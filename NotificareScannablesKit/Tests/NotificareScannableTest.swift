//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareScannablesKit
@testable import NotificareKit
import Testing

internal struct NotificareScannableTest {
    @Test
    internal func testNotificareScannableSerialization() {
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

            #expect(scannable == convertedScannable)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testNotificareScannableSerializationWithNilProps() {
        let scannable = NotificareScannable(
            id: "testId",
            name: "testName",
            tag: "tesTag",
            type: "testType",
            notification: nil
        )

        do {
            let convertedScannable = try NotificareScannable.fromJson(json: scannable.toJson())

            #expect(scannable == convertedScannable)
        } catch {
            Issue.record()
        }
    }
}
