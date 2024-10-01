//
// Copyright (c) 2024 . All rights reserved.
//

import UIKit
import Testing

private class MockBundle: Bundle, @unchecked Sendable {
    var mockInfoDictionary: [String: Any] = [:]

    override var infoDictionary: [String: Any]? {
        return mockInfoDictionary
    }
}

internal struct UIDeviceTests {

    @Test
    internal  func testUserAgent() {
        let mockBundle = MockBundle()
        mockBundle.mockInfoDictionary = [
            "CFBundleDisplayName": "TestApp",
            "CFBundleShortVersionString": "1.2.3",
        ]

        let sdkVersion = "2.0"
        let expectedOSVersion = UIDevice.current.systemVersion

        let userAgent = UIDevice.current.userAgent(bundle: mockBundle, sdkVersion: sdkVersion)

        let expectedUserAgent = "TestApp/1.2.3 Notificare/\(sdkVersion) iOS/\(expectedOSVersion)"
        #expect(userAgent == expectedUserAgent)
    }
}
