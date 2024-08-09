//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareLoyaltyKit
import Testing

internal struct NotificarePassTest {
    @Test
    internal func testNotificarePassSerialization() {
        let pass = NotificarePass(
            id: "testId",
            type: NotificarePass.PassType.boarding,
            version: 1,
            passbook: "testPassbook",
            template: "testTemplate",
            serial: "testSerial",
            barcode: "testBarcode",
            redeem: NotificarePass.Redeem.once,
            redeemHistory: [
                NotificarePass.Redemption(
                    comments: "testComents",
                    date: Date(timeIntervalSince1970: 1)
                ),
            ],
            limit: 1,
            token: "testToken",
            data: ["testDataKey": "testDataValue"],
            date: Date(timeIntervalSince1970: 1)
        )

        do {
            let convertedPass = try NotificarePass.fromJson(json: pass.toJson())

            #expect(pass == convertedPass)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testNotificarePassSerializationWithNilProps() {
        let pass = NotificarePass(
            id: "testId",
            type: nil,
            version: 1,
            passbook: nil,
            template: nil,
            serial: "testSerial",
            barcode: "testBarcode",
            redeem: NotificarePass.Redeem.once,
            redeemHistory: [],
            limit: 1,
            token: "testToken",
            data: [:],
            date: Date(timeIntervalSince1970: 1)
        )

        do {
            let convertedPass = try NotificarePass.fromJson(json: pass.toJson())

            #expect(pass == convertedPass)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testRedemptionSerialization() {
        let redemption = NotificarePass.Redemption(
            comments: "testString",
            date: Date(timeIntervalSince1970: 1)
        )

        do {
            let convertedRedemption = try NotificarePass.Redemption.fromJson(json: redemption.toJson())

            #expect(redemption == convertedRedemption)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testRedemptionSerializationWithNilProps() {
        let redemption = NotificarePass.Redemption(
            comments: nil,
            date: Date(timeIntervalSince1970: 1)
        )

        do {
            let convertedRedemption = try NotificarePass.Redemption.fromJson(json: redemption.toJson())

            #expect(redemption == convertedRedemption)
        } catch {
            Issue.record()
        }
    }
}
