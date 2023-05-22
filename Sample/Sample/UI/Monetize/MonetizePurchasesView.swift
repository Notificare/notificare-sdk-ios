//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI
import NotificareMonetizeKit

struct MonetizePurchasesView: View {
    let purchases: [NotificarePurchase]

    var body: some View {
        List {
            Section {
                if purchases.isEmpty {
                    Label(String(localized: "monetize_no_purchases_found"), systemImage: "info.circle.fill")
                } else {
                    ForEach(purchases) { purchase in
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
        MonetizePurchasesView(purchases: [])
    }
}
