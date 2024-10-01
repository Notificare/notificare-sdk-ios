//
// Copyright (c) 2024 Notificare. All rights reserved.
//

import Foundation
import Testing

private class MockBundle: Bundle, @unchecked Sendable {
    var mockInfoDictionary: [String: Any]?

    override func object(forInfoDictionaryKey key: String) -> Any? {
        return mockInfoDictionary?[key]
    }
}

internal struct BundleTests {

    @Test
    internal func testGetSupportedUrlSchemesWithValidSchemes() {
        let mockBundle = MockBundle()
        mockBundle.mockInfoDictionary = [
            "CFBundleURLTypes": [
                ["CFBundleURLSchemes": ["scheme1", "scheme2"]],
                ["CFBundleURLSchemes": ["scheme3"]],
            ],
        ]

        let supportedSchemes = mockBundle.getSupportedUrlSchemes()

        #expect(supportedSchemes == ["scheme1", "scheme2", "scheme3"])
    }

    @Test
    internal func testGetSupportedUrlSchemesWithEmptySchemes() {
        let mockBundle = MockBundle()
        mockBundle.mockInfoDictionary = [
            "CFBundleURLTypes": [
                ["CFBundleURLSchemes": []],
            ],
        ]

        let supportedSchemes = mockBundle.getSupportedUrlSchemes()

        #expect(supportedSchemes.isEmpty == true)
    }

    @Test
    internal func testGetSupportedUrlSchemesWithMissingCFBundleURLTypes() {
        let mockBundle = MockBundle()
        mockBundle.mockInfoDictionary = [:]

        let supportedSchemes = mockBundle.getSupportedUrlSchemes()

        #expect(supportedSchemes.isEmpty == true)
    }
}
