//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import NotificareMonetizeKit
import SwiftUI

internal struct MonetizePurchasesView: View {
    internal let purchases: [NotificarePurchase]

    internal var body: some View {
        List {
            if purchases.isEmpty {
                Section {
                    Label(String(localized: "monetize_no_purchases_found"), systemImage: "info.circle.fill")
                }
            } else {
                ForEach(purchases) { purchase in
                    Section {
                        PurchaseDetailsFieldView(key: String(localized: "monetize_purchase_id"), value: purchase.id)
                        PurchaseDetailsFieldView(key: String(localized: "monetize_purchase_time"), value: DateFormatter().string(from: purchase.time))
                    }
                }
            }
        }
    }
}

private struct PurchaseDetailsFieldView: View {
    let key: String
    let value: String?

    var body: some View {
        HStack {
            Text(key)
                .padding(.trailing)

            Spacer()

            Text(value ?? "-")
                .lineLimit(1)
                .truncationMode(.head)
                .foregroundColor(Color.gray)
        }
    }
}

internal struct MonetizePurchasesView_Previews: PreviewProvider {
    internal static var previews: some View {
        MonetizePurchasesView(purchases: [])
    }
}
