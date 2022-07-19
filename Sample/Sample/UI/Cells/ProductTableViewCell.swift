//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation
import NotificareMonetizeKit
import UIKit

class ProductTableViewCell: UITableViewCell {
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var identifierLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var priceLabel: UILabel!

    func bind(to product: NotificareProduct) {
        nameLabel.text = product.name
        identifierLabel.text = product.identifier
        descriptionLabel.text = product.storeDetails?.description ?? "---"

        if let details = product.storeDetails {
            priceLabel.text = "\(details.currencyCode) \(details.price)"
        } else {
            priceLabel.text = "---"
        }
    }
}
