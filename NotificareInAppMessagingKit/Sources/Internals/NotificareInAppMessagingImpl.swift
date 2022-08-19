//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

internal class NotificareInAppMessagingImpl: NSObject, NotificareModule, NotificareInAppMessaging {
    internal static let instance = NotificareInAppMessagingImpl()

    // MARK: - Notificare Module

    static func launch(_ completion: @escaping NotificareCallback<Void>) {
        completion(.success(()))
    }

    // MARK: - Notificare In-App Messaging

    // MARK: - Private API

    private func fetchInAppMessage(for context: ApplicationContext, _ completion: @escaping NotificareCallback<NotificareInAppMessage>) {
        guard let device = Notificare.shared.device().currentDevice else {
            completion(.failure(NotificareError.deviceUnavailable))
            return
        }

        NotificareRequest.Builder()
            .get("/inappmessage/forcontext/\(context.rawValue)")
            .query(name: "deviceID", value: device.id)
            .responseDecodable(NotificareInternals.PushAPI.Responses.InAppMessage.self) { result in
                switch result {
                case let .success(response):
                    completion(.success(response.message.toModel()))

                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }
}
