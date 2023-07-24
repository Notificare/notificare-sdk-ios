//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import NotificareMonetizeKit
import SwiftUI

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
                        ProductDetailsFieldView(key: String(localized: "monetize_product_id"), value: product.id)
                        ProductDetailsFieldView(key: String(localized: "monetize_product_name"), value: product.name)
                        ProductDetailsFieldView(key: String(localized: "monetize_product_type"), value: product.type)

                        if let price = product.storeDetails?.price {
                            ProductDetailsFieldView(key: String(localized: "monetize_product_price"), value: String(price))
                        } else {
                            ProductDetailsFieldView(key: String(localized: "monetize_product_price"), value: nil)
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

private struct ProductDetailsFieldView: View {
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

struct MonetizeProductsView_Previews: PreviewProvider {
    static var previews: some View {
        MonetizeProductsView(products: [], purchase: { _ in })
    }
}
