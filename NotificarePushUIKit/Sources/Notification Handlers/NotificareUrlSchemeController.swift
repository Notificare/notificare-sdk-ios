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
              let urlStr = content.data as? String,
              let url = URL(string: urlStr)
        else {
            DispatchQueue.main.async {
                Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToPresentNotification: self.notification)
            }

            return
        }

        guard url.host?.hasSuffix("ntc.re") == true else {
            // It's a non-universal link, let's just try and open it.
            presentDeepLink(url)
            return
        }

        // It's an universal link from Notificare, let's get the target.
        Notificare.shared.fetchDynamicLink(urlStr) { result in
            switch result {
            case let .success(link):
                guard let url = URL(string: link.target) else {
                    DispatchQueue.main.async {
                        Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToPresentNotification: self.notification)
                    }

                    return
                }

                self.presentDeepLink(url)
            case .failure:
                DispatchQueue.main.async {
                    Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToPresentNotification: self.notification)
                }
            }
        }
    }

    private func presentDeepLink(_ url: URL) {
        guard let urlScheme = url.scheme else {
            DispatchQueue.main.async {
                Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToPresentNotification: self.notification)
            }

            return
        }

        guard NotificareUtils.getSupportedUrlSchemes().contains(urlScheme) else {
            NotificareLogger.warning("Cannot open a deep link that's not supported by the application.")

            DispatchQueue.main.async {
                Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToPresentNotification: self.notification)
            }

            return
        }

        DispatchQueue.main.async {
            Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didPresentNotification: self.notification)
        }

        DispatchQueue.main.async {
            UIApplication.shared.open(url, options: [:]) { _ in
                DispatchQueue.main.async {
                    Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFinishPresentingNotification: self.notification)
                }
            }
        }
    }
}
