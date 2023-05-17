//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import NotificareAssetsKit
import SwiftUI

struct AssetsView: View {
    @StateObject private var viewModel = AssetsViewModel()

    var body: some View {
        List {
            Section {
                TextField(String(localized: "assets_group_input"), text: $viewModel.assetsGroup)

                Button(String(localized: "button_search")) {
                    viewModel.fetchAssets()
                }
                .frame(maxWidth: .infinity)
                .disabled(!viewModel.isSearchAllowed)
            } header: {
                Text(String(localized: "assets_fetch"))
            }

            switch viewModel.viewState {
            case .idle:
                EmptyView()

            case .loading:
                ZStack(alignment: .center) {
                    ProgressView()
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)

            case let .success(assets):
                SearchResultView(assets: assets)

            case .failure:
                Text("ooops")
            }
        }
        .navigationTitle(String(localized: "assets_title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct SearchResultView: View {
    let assets: [NotificareAsset]

    var body: some View {
        Section {
            if assets.isEmpty {
                Label(String(localized: "assets_not_found"), systemImage: "info.circle.fill")
            } else {
                ForEach(assets) { asset in
                    NavigationLink {
                        AssetDetailsView(asset: asset)
                    } label: {
                        AssetItemView(asset: asset)
                    }
                }
            }
        } header: {
            Text(String(localized: "result"))
        }
    }
}

struct AssetsView_Previews: PreviewProvider {
    static var previews: some View {
        AssetsView()
    }
}
