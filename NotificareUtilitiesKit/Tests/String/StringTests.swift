//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareUtilitiesKit
import Testing

internal struct StringTests {
    @Test
    internal func testToRegexValidPattern() {
            let pattern = "^[a-zA-Z]+$"
            let regex = pattern.toRegex()

        #expect(regex != nil)
        }

    @Test
    internal func testMatchesWithMatchingPattern() {
        let string = "abc"
        let regex = "^[a-z]+$".toRegex()

        let result = string.matches(regex)

        #expect(result == true)
    }

    @Test
    internal func testMatchesWithNonMatchingPattern() {
        let string = "123"
        let regex = "^[a-z]+$".toRegex()

        let result = string.matches(regex)

        #expect(result == false)
    }

    @Test
    internal func testRemovingSuffixWithExistingSuffix() {
        let string = "HelloWorld"
        let suffix = "World"

        let result = string.removingSuffix(suffix)

        #expect(result == "Hello")
    }

    @Test
    internal func testRemovingSuffixWithNonExistingSuffix() {
        let string = "HelloWorld"
        let suffix = "Universe"

        let result = string.removingSuffix(suffix)

        #expect(result == "HelloWorld")
    }
}
