//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareCore
import NotificarePushKit
import StoreKit

class NotificareStoreController: NSObject, SKStoreProductViewControllerDelegate, NotificareNotificationPresenter {
    private let notification: NotificareNotification

    init(notification: NotificareNotification) {
        self.notification = notification
    }

    func present(in controller: UIViewController) {
        guard let content = notification.content.first, content.type == "re.notifica.content.AppStore" else {
            NotificarePush.shared.delegate?.notificare(NotificarePush.shared, didFailToOpenNotification: notification)
            return
        }

        guard let data = content.data as? [String: Any], let identifier = data["identifier"] else {
            NotificarePush.shared.delegate?.notificare(NotificarePush.shared, didFailToOpenNotification: notification)
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
            if !success || error != nil {
                NotificarePush.shared.delegate?.notificare(NotificarePush.shared, didFailToOpenNotification: self.notification)
            }
        }

        NotificarePushUI.shared.presentController(storeController, in: controller)
    }

    public func productViewControllerDidFinish(_: SKStoreProductViewController) {
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: {
            // TODO: [[self delegate] notificationType:self didCloseNotification:[self notification]];
        })
    }
}
