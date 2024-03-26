//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import Foundation
import NotificareAssetsKit
import NotificareKit
import OSLog

@MainActor
internal class AssetsViewModel: ObservableObject {
    @Published internal var assetsGroup = ""
    @Published internal private(set) var viewState: ViewState = .idle

    internal var isSearchAllowed: Bool {
        !viewState.isLoading && !assetsGroup.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    internal func fetchAssets() {
        Logger.main.info("Fetch assets clicked")
        viewState = .loading

        Task {
            do {
                let result = try await Notificare.shared.assets().fetch(group: assetsGroup)

                Logger.main.info("Successfully fetched  assets group: \(self.assetsGroup)")
                viewState = .success(assets: result)
            } catch {
                Logger.main.error("Failed to fetch asset group: \(self.assetsGroup): \(error)")
                viewState = .failure(error: error)
            }
        }
    }

    internal enum ViewState {
        case idle
        case loading
        case success(assets: [NotificareAsset])
        case failure(error: Error)

        internal var isLoading: Bool {
            switch self {
            case .loading:
                return true
            default:
                return false
            }
        }
    }
}
