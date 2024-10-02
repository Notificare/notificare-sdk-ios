//
// Copyright (c) 2024 Notificare. All rights reserved.
//

import Foundation
import Testing

internal struct JSONCodersTests {

    private struct TestModel: Codable, Equatable {
        let name: String
        let date: Date
    }

    @Test
    internal func testISODateDecoder() throws {
        let jsonString = """
        {
            "name": "Test Event",
            "date": "2024-09-30T12:00:00.000Z"
        }
        """

        let jsonData = jsonString.data(using: .utf8)!

        let decoder = JSONDecoder.notificare
        let model = try decoder.decode(TestModel.self, from: jsonData)

        let expectedDate = Date.isoDateParser.date(from: "2024-09-30T12:00:00.000Z")
        #expect(model.name == "Test Event")
        #expect(model.date == expectedDate)
    }

    @Test
    internal func testISODateEncoder() throws {
        let testDate = Date.isoDateParser.date(from: "2024-09-30T12:00:00.000Z")!
        let model = TestModel(name: "Test Event", date: testDate)

        let encoder = JSONEncoder.notificare
        let jsonData = try encoder.encode(model)

        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]

        let expectedDictionary = [
            "name": "Test Event",
            "date": "2024-09-30T12:00:00.000Z",
        ]

        #expect(jsonObject as? NSDictionary == expectedDictionary as NSDictionary)
    }
}
