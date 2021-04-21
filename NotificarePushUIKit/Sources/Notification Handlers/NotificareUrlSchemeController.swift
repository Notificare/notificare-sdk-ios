//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit
import UIKit

class NotificareUrlSchemeController: NotificareNotificationPresenter {
    private let notification: NotificareNotification

    init(notification: NotificareNotification) {
        self.notification = notification
    }

    func present(in _: UIViewController) {
        guard let content = notification.content.first,
              let urlStr = content.data as? String
        else {
            NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didFailToPresentNotification: notification)
            return
        }

        if urlStr.contains("ntc.re") {
            // It's an universal link from Notificare, let's get the target.
            Notificare.shared.fetchDynamicLink(urlStr) { result in
                switch result {
                case let .success(link):
                    guard let url = URL(string: link.target) else {
                        NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didFailToPresentNotification: self.notification)
                        return
                    }

                    NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didPresentNotification: self.notification)

                    DispatchQueue.main.async {
                        UIApplication.shared.open(url, options: [:]) { _ in
                            NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didFinishPresentingNotification: self.notification)
                        }
                    }
                case .failure:
                    NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didFailToPresentNotification: self.notification)
                }
            }
        } else {
            // It's a non-universal link from Notificare, let's just try and open it.
            guard let url = URL(string: urlStr) else {
                NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didFailToPresentNotification: notification)
                return
            }

            NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didPresentNotification: notification)

            DispatchQueue.main.async {
                UIApplication.shared.open(url, options: [:]) { _ in
                    NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didFinishPresentingNotification: self.notification)
                }
            }
        }
    }
}
