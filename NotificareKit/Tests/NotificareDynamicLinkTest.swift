//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareKit
import Testing

struct NotificareDynamicLinkTest {
    @Test
    func testNotificareDynamicLinkSerialization() {
        let link = NotificareDynamicLink(target: "testLink")

        do {
            let convertedLink = try NotificareDynamicLink.fromJson(json: link.toJson())

            #expect(link.target == convertedLink.target)
        } catch {
            Issue.record()
        }
    }
}
