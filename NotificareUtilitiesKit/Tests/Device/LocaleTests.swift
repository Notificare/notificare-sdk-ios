//
// Copyright (c) 2024 . All rights reserved.
//

import Foundation
import Testing

internal struct LocaleExtensionsTests {

    @Test
    internal func testDeviceLanguageWithValidLanguage() {
        let mockPreferredLanguages = ["pt-PT"]

        let deviceLanguage = Locale.current.deviceLanguage(preferredLanguages: mockPreferredLanguages)

        #expect(deviceLanguage == "pt")
    }

    @Test
    internal func testDeviceLanguageWithEmptyLanguage() {
        let mockPreferredLanguages: [String] = []

        let deviceLanguage = Locale.current.deviceLanguage(preferredLanguages: mockPreferredLanguages)

        #expect(deviceLanguage == "en")
    }

    @Test
    internal func testDeviceRegionWithValidLanguage() {
        let mockPreferredLanguages = ["pt-PT"]

        let deviceRegion = Locale.current.deviceRegion(preferredLanguages: mockPreferredLanguages)

        #expect(deviceRegion == "PT")
    }

    @Test
    internal func testDeviceRegionWithEmptyLanguage() {
        let mockPreferredLanguages: [String] = []

        let deviceRegion = Locale.current.deviceRegion(preferredLanguages: mockPreferredLanguages)

        #expect(deviceRegion == "US")
    }
}
