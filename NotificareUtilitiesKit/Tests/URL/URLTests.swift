//
// Copyright (c) 2024 Notificare. All rights reserved.
//

import Foundation
@testable import NotificareUtilitiesKit
import Testing

internal struct URLTests {

    @Test
    internal func testAppendingQueryComponentToURLWithoutQuery() {
        var url = URL(string: "https://example.com")!
        url = url.appendingQueryComponent(name: "key", value: "value")
        #expect(url.absoluteString == "https://example.com?key=value")
    }

    @Test
    internal func testAppendingQueryComponentToURLWithExistingQuery() {
        var url = URL(string: "https://example.com?foo=bar")!
        url = url.appendingQueryComponent(name: "key", value: "value")
        #expect(url.absoluteString == "https://example.com?foo=bar&key=value")
    }

    @Test
    internal func testUpdatingQueryComponent() {
        var url = URL(string: "https://example.com?foo=bar")!
        url = url.appendingQueryComponent(name: "foo", value: "baz")
        #expect(url.absoluteString == "https://example.com?foo=baz")
    }

    @Test
    internal func testRemovingQueryComponentFromURLWithSingleQueryItem() {
        var url = URL(string: "https://example.com?key=value")!
        url = url.removingQueryComponent(name: "key")
        #expect(url.absoluteString == "https://example.com?")
    }

    @Test
    internal func testRemovingQueryComponentFromURLWithMultipleQueryItems() {
        var url = URL(string: "https://example.com?key1=value1&key2=value2")!
        url = url.removingQueryComponent(name: "key1")
        #expect(url.absoluteString == "https://example.com?key2=value2")
    }

    @Test
    internal func testRemovingNonExistentQueryComponent() {
        var url = URL(string: "https://example.com?key1=value1")!
        url = url.removingQueryComponent(name: "key2")
        #expect(url.absoluteString == "https://example.com?key1=value1")
    }
}
