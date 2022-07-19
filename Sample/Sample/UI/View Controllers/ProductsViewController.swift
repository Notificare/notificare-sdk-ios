//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation
import NotificareKit
import NotificareMonetizeKit
import UIKit

class ProductsViewController: UITableViewController {
    private var products: [NotificareProduct] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        products = Notificare.shared.monetize().products
        tableView.reloadData()
    }

    override func numberOfSections(in _: UITableView) -> Int {
        1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        products.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "product-cell", for: indexPath) as! ProductTableViewCell
        cell.bind(to: products[indexPath.row])

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let product = products[indexPath.row]
        Notificare.shared.monetize().startPurchaseFlow(for: product)
    }
}
