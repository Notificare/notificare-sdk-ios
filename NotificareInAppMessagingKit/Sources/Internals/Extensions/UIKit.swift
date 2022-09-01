//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import UIKit

internal extension UIView {
    var ncSafeAreaLayoutGuide: UILayoutGuide {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide
        }

        return layoutMarginsGuide
    }
}
