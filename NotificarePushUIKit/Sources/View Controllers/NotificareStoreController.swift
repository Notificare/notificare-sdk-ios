//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareCore
import NotificarePushKit
import StoreKit

public class NotificareStoreController: NSObject, SKStoreProductViewControllerDelegate {
    static let shared = NotificareStoreController()

    override private init() {}

    func createViewController(for notification: NotificareNotification) -> SKStoreProductViewController? {
        guard let content = notification.content.first, content.type == "re.notifica.content.AppStore" else {
            NotificarePush.shared.delegate?.notificare(NotificarePush.shared, didFailToOpenNotification: notification)
            return nil
        }

        guard let data = content.data as? [String: Any], let identifier = data["identifier"] else {
            NotificarePush.shared.delegate?.notificare(NotificarePush.shared, didFailToOpenNotification: notification)
            return nil
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
                NotificarePush.shared.delegate?.notificare(NotificarePush.shared, didFailToOpenNotification: notification)
            }
        }

        return storeController
    }

    public func productViewControllerDidFinish(_: SKStoreProductViewController) {
        NotificareLogger.info("----> productViewControllerDidFinish <-----")
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: {
            // TODO: [[self delegate] notificationType:self didCloseNotification:[self notification]];
        })
    }
}
