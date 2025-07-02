import Testing
import NotificareKit
@testable import NotificareInboxKit

internal struct InboxConcurrencyTests {

    @Test
    internal func testMassiveRefreshOperations() async throws {
        try await setupNotificare()

        await withTaskGroup(of: Void.self) { group in
            for _ in 0...10 {
                group.addTask {
                    Notificare.shared.inbox().refresh()
                }
            }
        }

        try await Task.sleep(nanoseconds: 5_000_000_000)
    }

    @Test
    internal func testMassiveOpenOperations() async throws {
        try await setupNotificare()

        let item = try #require(Notificare.shared.inbox().items.first(where: { !$0.opened }))

        await withThrowingTaskGroup(of: NotificareNotification.self) { group in
            for _ in 0...10 {
                group.addTask {
                    try await Notificare.shared.inbox().open(item)
                }
            }
        }

        let updatedItem = try #require(Notificare.shared.inbox().items.first(where: { $0.id == item.id }))
        #expect(updatedItem.opened == true)
    }

    private func setupNotificare() async throws {
        await Notificare.shared.configure(
            servicesInfo: NotificareServicesInfo(
                applicationKey: "",
                applicationSecret: ""
            ),
            options: NotificareOptions(
                debugLoggingEnabled: true
            )
        )

        try await Notificare.shared.launch()
    }
}
