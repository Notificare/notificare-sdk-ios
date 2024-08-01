//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareLoyaltyKit
import Testing

struct NotificarePassTest {
    @Test
    func testNotificarePassSerialization() {
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

            assertPass(pass: pass, convertedPass: convertedPass)
        } catch {
            Issue.record()
        }
    }

    @Test
    func testNotificarePassSerializationWithNilProps() {
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

            assertPass(pass: pass, convertedPass: convertedPass)
        } catch {
            Issue.record()
        }
    }

    @Test
    func testRedemptionSerialization() {
        let redemption = NotificarePass.Redemption(
            comments: "testString",
            date: Date(timeIntervalSince1970: 1)
        )

        do {
            let convertedRedemption = try NotificarePass.Redemption.fromJson(json: redemption.toJson())

            #expect(redemption.comments == convertedRedemption.comments)
            #expect(redemption.date == redemption.date)
        } catch {
            Issue.record()
        }
    }

    @Test
    func testRedemptionSerializationWithNilProps() {
        let redemption = NotificarePass.Redemption(
            comments: nil,
            date: Date(timeIntervalSince1970: 1)
        )

        do {
            let convertedRedemption = try NotificarePass.Redemption.fromJson(json: redemption.toJson())

            #expect(redemption.comments == convertedRedemption.comments)
            #expect(redemption.date == redemption.date)
        } catch {
            Issue.record()
        }
    }

    func assertPass(pass: NotificarePass, convertedPass: NotificarePass) {
        #expect(pass.id == convertedPass.id)
        #expect(pass.type == convertedPass.type)
        #expect(pass.version == convertedPass.version)
        #expect(pass.passbook == convertedPass.passbook)
        #expect(pass.template == convertedPass.template)
        #expect(pass.barcode == convertedPass.barcode)
        #expect(pass.redeem == convertedPass.redeem)
        for index in pass.redeemHistory.indices {
            #expect(pass.redeemHistory[index].comments == convertedPass.redeemHistory[index].comments)
            #expect(pass.redeemHistory[index].date == convertedPass.redeemHistory[index].date)
        }
        #expect(pass.limit == convertedPass.limit)
        #expect(pass.token == convertedPass.token)
        #expect(NSDictionary(dictionary: pass.data) == NSDictionary(dictionary: convertedPass.data))
        #expect(pass.date == convertedPass.date)
    }
}
