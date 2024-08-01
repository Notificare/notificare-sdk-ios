//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareKit
import Testing

struct NotificareDeviceTest {
    @Test
    func testNotificareDeviceSerialization() {
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

            assertDevice(device: device, convertedDevice: convertedDevice)
        } catch {
            Issue.record()
        }
    }

    @Test
    func testNotificareDeviceSerializationWithNilProps() {
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

            assertDevice(device: device, convertedDevice: convertedDevice)
        } catch {
            Issue.record()
        }
    }

    func assertDevice(device: NotificareDevice, convertedDevice: NotificareDevice) {
        #expect(device.id == convertedDevice.id)
        #expect(device.userId == convertedDevice.userId)
        #expect(device.userName == convertedDevice.userName)
        #expect(device.timeZoneOffset == convertedDevice.timeZoneOffset)
        #expect(device.dnd?.start.hours == convertedDevice.dnd?.start.hours)
        #expect(device.dnd?.start.minutes == convertedDevice.dnd?.start.minutes)
        #expect(device.dnd?.end.hours == convertedDevice.dnd?.end.hours)
        #expect(device.dnd?.end.minutes == convertedDevice.dnd?.end.minutes)
        #expect(NSDictionary(dictionary: device.userData) == NSDictionary(dictionary: convertedDevice.userData))
        #expect(device.backgroundAppRefresh == convertedDevice.backgroundAppRefresh)
    }
}
