//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit
import PassKit
import UIKit

private let PASS_RECEIVED_NOTIFICATION = NSNotification.Name(rawValue: "NotificareLoyaltyKit.PassReceived")

internal class NotificareLoyaltyImpl: NSObject, NotificareModule, NotificareLoyalty {
    internal static let instance = NotificareLoyaltyImpl()

    public weak var delegate: NotificareLoyaltyDelegate?

    // MARK: Notificare module

    static func configure() {
        // Listen to received pass requests.
        NotificationCenter.default.addObserver(instance,
                                               selector: #selector(onPassReceivedNotification(_:)),
                                               name: PASS_RECEIVED_NOTIFICATION,
                                               object: nil)
    }

    // MARK: - Notificare Loyalty

    public func present(_ notification: NotificareNotification, in controller: UIViewController) {
        guard notification.type == NotificareNotification.NotificationType.passbook.rawValue,
              let content = notification.content.first,
              content.type == "re.notifica.content.PKPass",
              let urlStr = content.data as? String,
              let url = URL(string: urlStr)
        else {
            NotificareLogger.warning("Trying to present a notification that doesn't contain a pass.")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let pass = try PKPass(data: data)

            present(pass, in: controller)
        } catch {
            NotificareLogger.error("Failed to create PKPass from URL.", error: error)
        }
    }

    public func present(_ pass: PKPass, in controller: UIViewController) {
        guard let passController = PKAddPassesViewController(pass: pass) else {
            NotificareLogger.warning("Failed to create pass view controller.")
            return
        }

        if controller.presentedViewController != nil {
            controller.dismiss(animated: true) {
                controller.present(passController, animated: true)
            }
        } else {
            controller.present(passController, animated: true)
        }
    }

    public func fetchPass(serial: String, _ completion: @escaping NotificareCallback<NotificarePass>) {
        guard let application = Notificare.shared.application else {
            NotificareLogger.warning("Notificare application is not yet available.")
            completion(.failure(NotificareError.applicationUnavailable))
            return
        }

        guard application.services["storage"] == true else {
            NotificareLogger.warning("Notificare storage functionality is not enabled.")
            completion(.failure(NotificareError.serviceUnavailable(module: "storage")))
            return
        }

        NotificareRequest.Builder()
            .get("/pass/forserial/\(serial)")
            .responseDecodable(NotificareInternals.PushAPI.Responses.Pass.self) { result in
                switch result {
                case let .success(response):
                    completion(.success(response.pass.toModel()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    public func fetchPass(barcode: String, _ completion: @escaping NotificareCallback<NotificarePass>) {
        guard let application = Notificare.shared.application else {
            NotificareLogger.warning("Notificare application is not yet available.")
            completion(.failure(NotificareError.applicationUnavailable))
            return
        }

        guard application.services["storage"] == true else {
            NotificareLogger.warning("Notificare storage functionality is not enabled.")
            completion(.failure(NotificareError.serviceUnavailable(module: "storage")))
            return
        }

        NotificareRequest.Builder()
            .get("/pass/forbarcode/\(barcode)")
            .responseDecodable(NotificareInternals.PushAPI.Responses.Pass.self) { result in
                switch result {
                case let .success(response):
                    completion(.success(response.pass.toModel()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    // MARK: - NotificationCenter events

    @objc private func onPassReceivedNotification(_ request: Notification) {
        NotificareLogger.debug("Received a signal to handle a received pass.")

        guard let userInfo = request.userInfo,
              let notification = userInfo["notification"] as? NotificareNotification
        else {
            NotificareLogger.warning("Unable to handle 'received pass' signal.")
            return
        }

        guard let content = notification.content.first,
              content.type == "re.notifica.content.PKPass",
              let urlStr = content.data as? String,
              let url = URL(string: urlStr)
        else {
            NotificareLogger.warning("Unable to extract the pass URL from the notification.")
            return
        }

        guard let delegate = delegate else {
            NotificareLogger.warning("Notificare Loyalty Delegate has not been set. To handle received passes you must implement it.")
            return
        }

        delegate.notificare(self, didReceivePass: url, in: notification)
    }
}
