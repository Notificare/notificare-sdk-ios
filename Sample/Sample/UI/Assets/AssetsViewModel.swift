//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import Foundation
import NotificareAssetsKit
import NotificareKit
import OSLog

@MainActor
class AssetsViewModel: ObservableObject {
    @Published var assetsGroup = ""
    @Published private(set) var viewState: ViewState = .idle

    var isSearchAllowed: Bool {
        !viewState.isLoading && !assetsGroup.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func fetchAssets() {
        Logger.main.info("-----> Fetch assets clicked <-----")
        viewState = .loading

        Task {
            do {
                try? await Task.sleep(nanoseconds: 5_000_000_000)
                let result = try await Notificare.shared.assets().fetch(group: assetsGroup)

                Logger.main.info("-----> Successfully fetched  assets group: \(self.assetsGroup) <-----")
                viewState = .success(assets: result)
            } catch {
                print("-----> Failed to fetch asset group: \(self.assetsGroup): \(error.localizedDescription)")
                viewState = .failure(error: error)
            }
        }
    }

    enum ViewState {
        case idle
        case loading
        case success(assets: [NotificareAsset])
        case failure(error: Error)

        var isLoading: Bool {
            switch self {
            case .loading:
                return true
            default:
                return false
            }
        }
    }
}
