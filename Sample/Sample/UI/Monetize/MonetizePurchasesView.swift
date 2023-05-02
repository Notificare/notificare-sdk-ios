//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct MonetizePurchasesView: View {
    @StateObject var viewModel: MonetizeViewModel

    var body: some View {
        List {
            Section {
                if viewModel.purchases.isEmpty {
                    Label(String(localized: "monetize_no_purchases_found"), systemImage: "info.circle.fill")
                } else {
                    ForEach(viewModel.purchases) { purchase in
                        VStack {
                            HStack {
                                Text(String(localized: "monetize_purchase_id"))
                                    .fontWeight(.medium)
                                Text(purchase.id)
                            }

                            HStack {
                                Text(String(localized: "monetize_purchase_time"))
                                    .fontWeight(.medium)
                                Text(DateFormatter().string(from: purchase.time))
                            }
                        }
                    }
                }
            } header: {
                Text(String(localized: "monetize_purchase_history"))
            }
        }
    }
}

struct MonetizePurchasesView_Previews: PreviewProvider {
    static var previews: some View {
        MonetizePurchasesView(viewModel: MonetizeViewModel())
    }
}
