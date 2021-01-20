//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareCore
import NotificareKit
import NotificarePushKit
import UIKit

class NotificareUrlSchemeController: NotificareNotificationPresenter {
    private let notification: NotificareNotification

    init(notification: NotificareNotification) {
        self.notification = notification
    }

    func present(in _: UIViewController) {
        if let content = notification.content.first,
           let urlStr = content.data as? String
        {
            if urlStr.contains("ntc.re") {
                // It's an universal link from Notificare, let's get the target.
                Notificare.shared.fetchDynamicLink(urlStr) { result in
                    switch result {
                    case let .success(link):
                        if let url = URL(string: link.target) {
                            DispatchQueue.main.async {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }
                    case .failure:
                        break
                    }
                }
            } else {
                // It's a non-universal link from Notificare, let's just try and open it.
                if let url = URL(string: urlStr) {
                    DispatchQueue.main.async {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
        }
    }
}
