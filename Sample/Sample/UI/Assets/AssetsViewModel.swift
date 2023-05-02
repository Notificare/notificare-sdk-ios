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
    @Published private(set) var shouldShowResult = false
    @Published private(set) var assets = [NotificareAsset]()

    func fetchAssets() {
        Logger.main.info("-----> Fetch assets clicked <-----")
        if !assets.isEmpty {
            Logger.main.info("-----> Cleaning previously fetched assets <-----")
            assets.removeAll()
        }

        Task {
            do {
                let result = try await Notificare.shared.assets().fetch(group: assetsGroup)
                Logger.main.info("-----> Successfully fetched  assets group: \(self.assetsGroup) <-----")
                assetsGroup = ""
                assets = result
            } catch {
                print("-----> Failed to fetch asset group: \(self.assetsGroup): \(error.localizedDescription)")
            }

            if !shouldShowResult {
                shouldShowResult = true
            }
        }
    }
}
