//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareKit
import Testing

internal struct NotificareDynamicLinkTest {
    @Test
    internal func testNotificareDynamicLinkSerialization() {
        let link = NotificareDynamicLink(target: "testLink")

        do {
            let convertedLink = try NotificareDynamicLink.fromJson(json: link.toJson())

            #expect(link == convertedLink)
        } catch {
            Issue.record()
        }
    }
}
