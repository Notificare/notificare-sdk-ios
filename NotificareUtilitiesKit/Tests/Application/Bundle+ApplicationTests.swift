//
// Copyright (c) 2024 Notificare. All rights reserved.
//

import Testing
@testable import NotificareUtilitiesKit

private class MockBundle: Bundle, @unchecked Sendable {
    var mockInfoDictionary: [String: Any] = [:]

    override var infoDictionary: [String: Any]? {
        return mockInfoDictionary
    }
}

public struct BundleApplicationTests {

    @Test
    internal func testApplicationNameWithDisplayName() {
        let mockBundle = MockBundle()
        mockBundle.mockInfoDictionary = [
            "CFBundleDisplayName": "TestAppDisplayName"
        ]

        let appName = mockBundle.applicationName

        #expect(appName == "TestAppDisplayName")
    }

    @Test
    internal func testApplicationNameWithBundleName() {
        let mockBundle = MockBundle()
        mockBundle.mockInfoDictionary = [
            "CFBundleName": "TestAppBundleName"
        ]

        let appName = mockBundle.applicationName

        #expect(appName == "TestAppBundleName")
    }

    @Test
    internal func testApplicationNameWithNoName() {
        let mockBundle = MockBundle()
        mockBundle.mockInfoDictionary = [:]

        let appName = mockBundle.applicationName

        #expect(appName == "")
    }

    @Test
    internal func testApplicationVersionWithShortVersion() {
        let mockBundle = MockBundle()
        mockBundle.mockInfoDictionary = [
            "CFBundleShortVersionString": "1.2.3"
        ]

        let appVersion = mockBundle.applicationVersion

        #expect(appVersion == "1.2.3")
    }

    @Test
    internal func testApplicationVersionWithVersion() {
        let mockBundle = MockBundle()
        mockBundle.mockInfoDictionary = [
            "CFBundleVersion": "123"
        ]

        let appVersion = mockBundle.applicationVersion

        #expect(appVersion == "123")
    }

    @Test
    internal func testApplicationVersionWithNoVersion() {
        let mockBundle = MockBundle()
        mockBundle.mockInfoDictionary = [:]

        let appVersion = mockBundle.applicationVersion

        #expect(appVersion == "1.0.0")
    }
}
