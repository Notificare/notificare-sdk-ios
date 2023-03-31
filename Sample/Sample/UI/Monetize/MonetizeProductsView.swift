//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct MonetizeProductsView: View {
    @StateObject var viewModel: MonetizeViewModel
    
    var body: some View {
        List {
            if viewModel.products.isEmpty {
                Section {
                    Label(String(localized: "monetize_no_products_found"), systemImage: "info.circle.fill")
                }
            } else {
                ForEach(viewModel.products) { product in
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
                            viewModel.purchase(product: product)
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
        MonetizeProductsView(viewModel: MonetizeViewModel())
    }
}
