//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

internal struct MonetizeView: View {
    @StateObject private var viewModel = MonetizeViewModel()

    internal var body: some View {
        TabView {
            MonetizeProductsView(
                products: viewModel.products,
                purchase: viewModel.purchase
            )
            .tabItem {
                Label(String(localized: "monetize_products"), systemImage: "list.dash")
            }

            MonetizePurchasesView(
                purchases: viewModel.purchases
            )
            .tabItem {
                Label(String(localized: "monetize_purchases"), systemImage: "cart")
            }
        }
    }
}

internal struct MonetizeView_Previews: PreviewProvider {
    internal static var previews: some View {
        MonetizeView()
    }
}
