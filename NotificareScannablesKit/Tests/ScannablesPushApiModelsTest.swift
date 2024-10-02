//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareKit
@testable import NotificareScannablesKit
import Testing

internal struct ScannablesPushApiModelsTest {
    @Test
    internal func testScannableToModel() {
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
                    ),
                ],
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

        #expect(expectedScannable == scannable)
    }

    @Test
    internal func testScannableWithNilPropsToModel() {
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

        #expect(expectedScannable == scannable)
    }
}
