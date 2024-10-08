//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import NotificareAssetsKit
import SwiftUI

internal struct AssetsView: View {
    @StateObject private var viewModel = AssetsViewModel()

    internal var body: some View {
        List {
            Section {
                TextField(String(localized: "assets_group_input"), text: $viewModel.assetsGroup)
                    .disabled(viewModel.viewState.isLoading)

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
                ZStack {
                    ProgressView()
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)

            case let .success(assets):
                SearchResultView(assets: assets)

            case .failure:
                ZStack {
                    Label {
                        Text(String(localized: "error_message_assets_fetch"))
                    } icon: {
                        Image(systemName: "exclamationmark.octagon.fill")
                            .foregroundColor(.red)
                    }
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
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

internal struct AssetsView_Previews: PreviewProvider {
    internal static var previews: some View {
        AssetsView()
    }
}
