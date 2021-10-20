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
            Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToPresentNotification: notification)
            return
        }

        if urlStr.contains("ntc.re") {
            // It's an universal link from Notificare, let's get the target.
            Notificare.shared.fetchDynamicLink(urlStr) { result in
                switch result {
                case let .success(link):
                    guard let url = URL(string: link.target) else {
                        Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToPresentNotification: self.notification)
                        return
                    }

                    Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didPresentNotification: self.notification)

                    DispatchQueue.main.async {
                        UIApplication.shared.open(url, options: [:]) { _ in
                            Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFinishPresentingNotification: self.notification)
                        }
                    }
                case .failure:
                    Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToPresentNotification: self.notification)
                }
            }
        } else {
            // It's a non-universal link from Notificare, let's just try and open it.
            guard let url = URL(string: urlStr), let urlScheme = url.scheme else {
                Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToPresentNotification: notification)
                return
            }

            guard NotificareUtils.getSupportedUrlSchemes().contains(urlScheme) else {
                NotificareLogger.warning("Cannot open a deep link that's not supported by the application.")
                Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToPresentNotification: notification)
                return
            }

            Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didPresentNotification: notification)

            DispatchQueue.main.async {
                UIApplication.shared.open(url, options: [:]) { _ in
                    Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFinishPresentingNotification: self.notification)
                }
            }
        }
    }
}
