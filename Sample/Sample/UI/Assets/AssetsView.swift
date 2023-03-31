//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct AssetsView: View {
    @StateObject private var viewModel: AssetsViewModel
    
    init() {
        self._viewModel = StateObject(wrappedValue: AssetsViewModel())
    }
    
    var body: some View {
        List {
            Section {
                TextField(String(localized: "assets_group_input"), text: $viewModel.assetsGroup)
                
                Button(String(localized: "button_search")) {
                    viewModel.fetchAssets()
                }
                .frame(maxWidth: .infinity)
                .disabled(viewModel.assetsGroup.isEmpty)
            } header: {
                Text(String(localized: "assets_fetch"))
            }
            
            if viewModel.shouldShowResult {
                Section {
                    if viewModel.assets.isEmpty {
                        Label(String(localized: "assets_not_found"), systemImage: "info.circle.fill")
                    } else {
                        ForEach(viewModel.assets) { asset in
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
        .navigationTitle(String(localized: "assets_title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AssetsView_Previews: PreviewProvider {
    static var previews: some View {
        AssetsView()
    }
}
