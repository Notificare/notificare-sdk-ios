//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit
import PassKit
import UIKit

internal class NotificareLoyaltyImpl: NSObject, NotificareModule, NotificareLoyalty, NotificareLoyaltyIntegration {
    // MARK: - Notificare Module

    static let instance = NotificareLoyaltyImpl()

    // MARK: - Notificare Loyalty

    func fetchPass(serial: String, _ completion: @escaping NotificareCallback<NotificarePass>) {
        do {
            try checkPrerequisites()
        } catch {
            completion(.failure(error))
            return
        }

        guard let urlEncodedSerial = serial.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            completion(.failure(NotificareError.invalidArgument(message: "Invalid serial value.")))
            return
        }

        NotificareRequest.Builder()
            .get("/pass/forserial/\(urlEncodedSerial)")
            .responseDecodable(NotificareInternals.PushAPI.Responses.Pass.self) { result in
                switch result {
                case let .success(response):
                    self.enhancePass(response.pass, completion)
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    @available(iOS 13.0, *)
    func fetchPass(serial: String) async throws -> NotificarePass {
        try await withCheckedThrowingContinuation { continuation in
            fetchPass(serial: serial) { result in
                continuation.resume(with: result)
            }
        }
    }

    func fetchPass(barcode: String, _ completion: @escaping NotificareCallback<NotificarePass>) {
        do {
            try checkPrerequisites()
        } catch {
            completion(.failure(error))
            return
        }

        guard let urlEncodedBarcode = barcode.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            completion(.failure(NotificareError.invalidArgument(message: "Invalid barcode value.")))
            return
        }

        NotificareRequest.Builder()
            .get("/pass/forbarcode/\(urlEncodedBarcode)")
            .responseDecodable(NotificareInternals.PushAPI.Responses.Pass.self) { result in
                switch result {
                case let .success(response):
                    self.enhancePass(response.pass, completion)
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    @available(iOS 13.0, *)
    func fetchPass(barcode: String) async throws -> NotificarePass {
        try await withCheckedThrowingContinuation { continuation in
            fetchPass(barcode: barcode) { result in
                continuation.resume(with: result)
            }
        }
    }

    func present(pass: NotificarePass, in controller: UIViewController) {
        guard let host = Notificare.shared.servicesInfo?.services.pkPassHost,
              let url = URL(string: "\(host)/\(pass.serial)")
        else {
            NotificareLogger.warning("Unable to determine the PKPass URL.")
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

    // MARK: - Notificare Loyalty Integration

    var canPresentPasses: Bool {
        PKPassLibrary.isPassLibraryAvailable() && PKAddPassesViewController.canAddPasses()
    }

    func present(notification: NotificareNotification, in viewController: UIViewController) {
        guard let content = notification.content.first(where: { $0.type == "re.notifica.content.PKPass" }),
              let urlStr = content.data as? String,
              let url = URL(string: urlStr)
        else {
            NotificareLogger.warning("Trying to present a notification that doesn't contain a pass.")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let pass = try PKPass(data: data)

            present(pass, in: viewController)
        } catch {
            NotificareLogger.error("Failed to create PKPass from URL.", error: error)
        }
    }

    // MARK: - Internal API

    private func checkPrerequisites() throws {
        if !Notificare.shared.isReady {
            NotificareLogger.warning("Notificare is not ready yet.")
            throw NotificareError.notReady
        }

        if Notificare.shared.device().currentDevice == nil {
            NotificareLogger.warning("Notificare device is not yet available.")
            throw NotificareError.deviceUnavailable
        }

        guard let application = Notificare.shared.application else {
            NotificareLogger.warning("Notificare application is not yet available.")
            throw NotificareError.applicationUnavailable
        }

        guard application.services[NotificareApplication.ServiceKey.passbook.rawValue] == true else {
            NotificareLogger.warning("Notificare loyalty functionality is not enabled.")
            throw NotificareError.serviceUnavailable(service: NotificareApplication.ServiceKey.passbook.rawValue)
        }
    }

    private func enhancePass(_ pass: NotificareInternals.PushAPI.Models.Pass, _ completion: @escaping NotificareCallback<NotificarePass>) {
        if pass.version == 1, let passbook = pass.passbook {
            fetchPassType(passbook: passbook) { result in
                switch result {
                case let .success(type):
                    let model = self.createPassModel(pass, passType: type)
                    completion(.success(model))
                case let .failure(error):
                    completion(.failure(error))
                }
            }

            return
        }

        let model = createPassModel(pass, passType: nil)
        completion(.success(model))
    }

    private func fetchPassType(passbook: String, _ completion: @escaping NotificareCallback<NotificarePass.PassType>) {
        NotificareRequest.Builder()
            .get("/passbook/\(passbook)")
            .responseDecodable(NotificareInternals.PushAPI.Responses.FetchPassbookTemplate.self) { result in
                switch result {
                case let .success(response):
                    completion(.success(response.passbook.passStyle))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
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
}
