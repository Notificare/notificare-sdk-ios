//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import UIKit

class InboxDetailViewController: UIViewController {
    @IBOutlet var badgeBackground: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        badgeBackground.clipsToBounds = true
        badgeBackground.layer.cornerRadius = 8
    }
}
