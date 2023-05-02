//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct MonetizeView: View {
    @StateObject private var viewModel: MonetizeViewModel

    init() {
        _viewModel = StateObject(wrappedValue: MonetizeViewModel())
    }

    var body: some View {
        TabView {
            MonetizeProductsView(viewModel: viewModel)
                .tabItem {
                    Label(String(localized: "monetize_products"), systemImage: "list.dash")
                }

            MonetizePurchasesView(viewModel: viewModel)
                .tabItem {
                    Label(String(localized: "monetize_purchases"), systemImage: "cart")
                }
        }
    }
}

struct MonetizeView_Previews: PreviewProvider {
    static var previews: some View {
        MonetizeView()
    }
}
