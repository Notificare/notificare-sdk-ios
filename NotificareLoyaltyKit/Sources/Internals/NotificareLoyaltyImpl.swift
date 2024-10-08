//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit
import PassKit
import UIKit

internal class NotificareLoyaltyImpl: NSObject, NotificareModule, NotificareLoyalty, NotificareLoyaltyIntegration {
    // MARK: - Notificare Module

    internal static let instance = NotificareLoyaltyImpl()

    internal func configure() {
        logger.hasDebugLoggingEnabled = Notificare.shared.options?.debugLoggingEnabled ?? false
    }

    // MARK: - Notificare Loyalty

    public func fetchPass(serial: String, _ completion: @escaping NotificareCallback<NotificarePass>) {
        Task {
            do {
                let result = try await fetchPass(serial: serial)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func fetchPass(serial: String) async throws -> NotificarePass {
        try checkPrerequisites()

        guard let urlEncodedSerial = serial.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            throw NotificareError.invalidArgument(message: "Invalid serial value.")
        }

        let response = try await NotificareRequest.Builder()
            .get("/pass/forserial/\(urlEncodedSerial)")
            .responseDecodable(NotificareInternals.PushAPI.Responses.Pass.self)

        return try await enhancePass(response.pass)
    }

    public func fetchPass(barcode: String, _ completion: @escaping NotificareCallback<NotificarePass>) {
        Task {
            do {
                let result = try await fetchPass(barcode: barcode)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func fetchPass(barcode: String) async throws -> NotificarePass {
        try checkPrerequisites()

        guard let urlEncodedBarcode = barcode.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            throw NotificareError.invalidArgument(message: "Invalid barcode value.")
        }

        let response = try await NotificareRequest.Builder()
            .get("/pass/forbarcode/\(urlEncodedBarcode)")
            .responseDecodable(NotificareInternals.PushAPI.Responses.Pass.self)

        return try await enhancePass(response.pass)
    }

    public func present(pass: NotificarePass, in controller: UIViewController) {
        guard let host = Notificare.shared.servicesInfo?.hosts.restApi,
              let url = URL(string: "https://\(host)/pass/pkpass/\(pass.serial)")
        else {
            logger.warning("Unable to determine the PKPass URL.")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let pass = try PKPass(data: data)

            present(pass, in: controller)
        } catch {
            logger.error("Failed to create PKPass from URL.", error: error)
        }
    }

    // MARK: - Notificare Loyalty Integration

    internal var canPresentPasses: Bool {
        PKPassLibrary.isPassLibraryAvailable() && PKAddPassesViewController.canAddPasses()
    }

    internal func present(notification: NotificareNotification, in viewController: UIViewController) {
        guard let content = notification.content.first(where: { $0.type == "re.notifica.content.PKPass" }),
              let urlStr = content.data as? String,
              let url = URL(string: urlStr)
        else {
            logger.warning("Trying to present a notification that doesn't contain a pass.")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let pass = try PKPass(data: data)

            present(pass, in: viewController)
        } catch {
            logger.error("Failed to create PKPass from URL.", error: error)
        }
    }

    // MARK: - Internal API

    private func checkPrerequisites() throws {
        if !Notificare.shared.isReady {
            logger.warning("Notificare is not ready yet.")
            throw NotificareError.notReady
        }

        if Notificare.shared.device().currentDevice == nil {
            logger.warning("Notificare device is not yet available.")
            throw NotificareError.deviceUnavailable
        }

        guard let application = Notificare.shared.application else {
            logger.warning("Notificare application is not yet available.")
            throw NotificareError.applicationUnavailable
        }

        guard application.services[NotificareApplication.ServiceKey.passbook.rawValue] == true else {
            logger.warning("Notificare loyalty functionality is not enabled.")
            throw NotificareError.serviceUnavailable(service: NotificareApplication.ServiceKey.passbook.rawValue)
        }
    }

    private func enhancePass(_ pass: NotificareInternals.PushAPI.Models.Pass) async throws -> NotificarePass {
        if pass.version == 1, let passbook = pass.passbook {
            let type = try await fetchPassType(passbook: passbook)

            return createPassModel(pass, passType: type)
        }

        return createPassModel(pass, passType: nil)
    }

    private func fetchPassType(passbook: String) async throws -> NotificarePass.PassType {
        let response = try await NotificareRequest.Builder()
            .get("/passbook/\(passbook)")
            .responseDecodable(NotificareInternals.PushAPI.Responses.FetchPassbookTemplate.self)

        return response.passbook.passStyle
    }

    private func createPassModel(_ pass: NotificareInternals.PushAPI.Models.Pass, passType: NotificarePass.PassType?) -> NotificarePass {
        NotificarePass(
            id: pass._id,
            type: passType,
            version: pass.version,
            passbook: pass.passbook,
            template: pass.template,
            serial: pass.serial,
            barcode: pass.barcode,
            redeem: pass.redeem,
            redeemHistory: pass.redeemHistory,
            limit: pass.limit,
            token: pass.token,
            data: pass.data?.value as? [String: Any] ?? [:],
            date: pass.date
        )
    }

    private func present(_ pass: PKPass, in controller: UIViewController) {
        guard let passController = PKAddPassesViewController(pass: pass) else {
            logger.warning("Failed to create pass view controller.")
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
}
