//
// Copyright (c) 2024 Notificare. All rights reserved.
//
import  UIKit

extension UIApplication {
    public var rootViewController: UIViewController? {
        var window: UIWindow? = UIApplication.shared.delegate?.window ?? nil

        if window == nil {
            window = UIApplication.shared.connectedScenes
                .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
                .last { $0.isKeyWindow }
        }

        return window?.rootViewController
    }
}
