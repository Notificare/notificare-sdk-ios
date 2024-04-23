//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit
import StoreKit

class NotificareStoreController: NSObject, SKStoreProductViewControllerDelegate, NotificareNotificationPresenter {
    private let notification: NotificareNotification

    init(notification: NotificareNotification) {
        self.notification = notification
    }

    func present(in controller: UIViewController) {
        guard let content = notification.content.first, content.type == "re.notifica.content.AppStore" else {
            DispatchQueue.main.async {
                Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToPresentNotification: self.notification)
            }

            return
        }

        guard let data = content.data as? [String: Any], let identifier = data["identifier"] else {
            DispatchQueue.main.async {
                Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToPresentNotification: self.notification)
            }

            return
        }

        let storeController = SKStoreProductViewController()
        storeController.delegate = self

        var parameters: [String: Any] = [SKStoreProductParameterITunesItemIdentifier: identifier]

        if let token = data["campaignToken"] {
            parameters[SKStoreProductParameterCampaignToken] = token
        }

        if let token = data["providerToken"] {
            parameters[SKStoreProductParameterProviderToken] = token
        }

        if let token = data["affiliateToken"] {
            parameters[SKStoreProductParameterAffiliateToken] = token
        }

        if let token = data["advertisingPartnerToken"] {
            parameters[SKStoreProductParameterAdvertisingPartnerToken] = token
        }

        storeController.loadProduct(withParameters: parameters) { success, error in
            DispatchQueue.main.async {
                if !success || error != nil {
                    Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToPresentNotification: self.notification)
                } else {
                    Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didPresentNotification: self.notification)
                }
            }
        }

        controller.presentOrPush(storeController)
    }

    public func productViewControllerDidFinish(_: SKStoreProductViewController) {
        NotificareUtils.rootViewController?.dismiss(animated: true, completion: {
            DispatchQueue.main.async {
                Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFinishPresentingNotification: self.notification)
            }
        })
    }
}
