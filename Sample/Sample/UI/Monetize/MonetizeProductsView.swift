//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI
import NotificareMonetizeKit

struct MonetizeProductsView: View {
    let products: [NotificareProduct]
    let purchase: (NotificareProduct) -> Void

    var body: some View {
        List {
            if products.isEmpty {
                Section {
                    Label(String(localized: "monetize_no_products_found"), systemImage: "info.circle.fill")
                }
            } else {
                ForEach(products) { product in
                    Section {
                        HStack {
                            Text(String(localized: "monetize_product_id"))
                            Spacer()
                            Text(product.id)
                        }

                        HStack {
                            Text(String(localized: "monetize_product_name"))
                            Spacer()
                            Text(product.name)
                        }

                        HStack {
                            Text(String(localized: "monetize_product_type"))
                            Spacer()
                            Text(product.type)
                        }

                        HStack {
                            Text(String(localized: "monetize_product_price"))
                            Spacer()
                            if let price = product.storeDetails?.price {
                                Text(String(price))
                            } else {
                                Text("-")
                            }
                        }

                        Button(String(localized: "monetize_buy")) {
                            purchase(product)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
}

struct MonetizeProductsView_Previews: PreviewProvider {
    static var previews: some View {
        MonetizeProductsView(products: [], purchase: { _ in })
    }
}
