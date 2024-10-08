//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import SafariServices
import StoreKit
import UIKit

extension UIViewController {
    internal func presentOrPush(_ controller: UIViewController, completion: (() -> Void)? = nil) {
        if controller is UIAlertController || controller is SKStoreProductViewController || controller is UINavigationController || controller is SFSafariViewController {
            if presentedViewController != nil {
                dismiss(animated: true) {
                    self.present(controller, animated: true, completion: completion)
                }
            } else {
                present(controller, animated: true, completion: completion)
            }

            return
        }

        if let navigationController = self as? UINavigationController {
            navigationController.pushViewController(controller, animated: true)
            completion?()
        } else {
            present(controller, animated: true, completion: completion)
        }
    }
}

extension UIView {
    internal var ncSafeAreaLayoutGuide: UILayoutGuide {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide
        }

        return layoutMarginsGuide
    }
}
