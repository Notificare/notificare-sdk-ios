//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareKit
import Testing

internal struct NotificareDeviceTest {
    @Test
    internal func testNotificareDeviceSerialization() {
        do {
            let device = NotificareDevice(
                id: "testId",
                userId: "testUserId",
                userName: "testUserName",
                timeZoneOffset: 0,
                dnd: NotificareDoNotDisturb(
                    start: try NotificareTime(hours: 21, minutes: 30),
                    end: try NotificareTime(hours: 8, minutes: 0)
                ),
                userData: ["testKey": "testValue"],
                backgroundAppRefresh: true
            )

            let convertedDevice = try NotificareDevice.fromJson(json: device.toJson())

            #expect(device == convertedDevice)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testNotificareDeviceSerializationWithNilProps() {
        let device = NotificareDevice(
            id: "testId",
            userId: nil,
            userName: nil,
            timeZoneOffset: 0,
            dnd: nil,
            userData: [:],
            backgroundAppRefresh: true
        )

        do {
            let convertedDevice = try NotificareDevice.fromJson(json: device.toJson())

            #expect(device == convertedDevice)
        } catch {
            Issue.record()
        }
    }
}
