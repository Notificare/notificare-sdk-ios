//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import Auth0
import Alamofire
import Combine
import Foundation
import NotificareUserInboxKit
import NotificareKit
import OSLog
import UIKit

@MainActor
internal class InboxViewModel: ObservableObject {
    @Published internal private(set) var items: [NotificareUserInboxItem] = []
    @Published internal private(set) var userMessages: [UserMessage] = []

    private let credentialsManager = CredentialsManager(authentication: Auth0.authentication())
    private var cancellables = Set<AnyCancellable>()

    internal init() {
        NotificationCenter.default
            .publisher(for: .notifyInboxUpdate, object: nil)
            .sink { [weak self] _ in
                self?.refreshInbox()
            }
            .store(in: &cancellables)
    }

    internal func presentInboxItem(_ item: NotificareUserInboxItem) {
        Logger.main.info("Inbox item clicked")

        Task {
            do {
                let notification = try await Notificare.shared.userInbox().open(item)
                UIApplication.shared.present(notification)

                if !item.opened {
                    notifyInboxUpdate()
                }

                userMessages.append(
                    UserMessage(variant: .presentItemSuccess)
                )
            } catch {
                Logger.main.error("Failed to open an inbox item. \(error)")

                userMessages.append(
                    UserMessage(variant: .presentItemFailure)
                )
            }
        }
    }

    internal func markItemAsRead(_ item: NotificareUserInboxItem) {
        Logger.main.info("Mark as read clicked")

        Task {
            do {
                try await Notificare.shared.userInbox().markAsRead(item)

                if !item.opened {
                    notifyInboxUpdate()
                }

                userMessages.append(
                    UserMessage(variant: .markItemAsReadSuccess)
                )
            } catch {
                Logger.main.error("Failed to mark an item as read. \(error)")

                userMessages.append(
                    UserMessage(variant: .markItemAsReadFailure)
                )
            }
        }
    }

    internal func removeItem(_ item: NotificareUserInboxItem) {
        Logger.main.info("Remove inbox item clicked")

        Task {
            do {
                try await Notificare.shared.userInbox().remove(item)

                if !item.opened {
                    notifyInboxUpdate()
                } else {
                    refreshInbox()
                }

                userMessages.append(
                    UserMessage(variant: .removeItemSuccess)
                )
            } catch {
                Logger.main.error("Failed to remove an item. \(error)")

                userMessages.append(
                    UserMessage(variant: .removeItemFailure)
                )
            }
        }
    }

    internal func refreshInbox() {
        Task {
            do {
                try await refresh()

                Logger.main.info("Refreshed inbox successfully.")

                userMessages.append(
                    UserMessage(variant: .refreshInboxSuccess)
                )
            } catch {
                Logger.main.error("Failed to refresh inbox: \(error)")

                userMessages.append(
                    UserMessage(variant: .refreshInboxFailure)
                )
            }
        }
    }

    private func refresh() async throws {
        guard credentialsManager.canRenew() else {
            Logger.main.error("No valid credentials found. Update badge failed.")

            throw UserInboxError.noStoredCredentionals
        }

        let accessToken = try await credentialsManager.credentials().accessToken

        guard let userInboxClient = SampleUserInboxClient.loadFromPlist(), userInboxClient.isAllDataFilled else {
            throw UserInboxError.missingClientData
        }

        let response = await AF.request(userInboxClient.fetchInboxUrl, method: .get, headers: .authorizationHeader(accessToken: accessToken))
            .validate()
            .serializingString()
            .response

        if let error = response.error {
            throw error
        }

        let userInboxResponse = try Notificare.shared.userInbox().parseResponse(data: response.data!)
        self.items = userInboxResponse.items
    }

    private func notifyInboxUpdate() {
        NotificationCenter.default.post(
            name: .notifyInboxUpdate,
            object: nil
        )
    }
}

extension InboxViewModel {
    internal func processUserMessage(_ userMessageId: String) {
        userMessages.removeAll(where: { $0.uniqueId == userMessageId })
    }

    internal struct UserMessage: Equatable {
        internal let uniqueId = UUID().uuidString
        internal let variant: Variant

        internal enum Variant: Equatable {
            case presentItemSuccess
            case presentItemFailure
            case markItemAsReadSuccess
            case markItemAsReadFailure
            case removeItemSuccess
            case removeItemFailure
            case refreshInboxSuccess
            case refreshInboxFailure
        }
    }
}
