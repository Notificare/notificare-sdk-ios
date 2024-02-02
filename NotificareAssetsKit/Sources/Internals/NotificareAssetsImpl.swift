//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

internal class NotificareAssetsImpl: NSObject, NotificareModule, NotificareAssets {
    // MARK: - Notificare Module

    static let instance = NotificareAssetsImpl()

    // MARK: - Notificare Assets

    func fetch(group: String, _ completion: @escaping NotificareCallback<[NotificareAsset]>) {
        Task {
            do {
                let result = try await fetch(group: group)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func fetch(group: String) async throws -> [NotificareAsset] {
        try checkPrerequisites()

        guard let urlEncodedGroup = group.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            throw NotificareError.invalidArgument(message: "Invalid group value.")
        }

        let response = try await NotificareRequest.Builder()
            .get("/asset/forgroup/\(urlEncodedGroup)")
            .query(name: "deviceID", value: Notificare.shared.device().currentDevice?.id)
            .query(name: "userID", value: Notificare.shared.device().currentDevice?.userId)
            .responseDecodable(NotificareInternals.PushAPI.Responses.Assets.self)

        let assets = response.assets.map { $0.toModel() }

        return assets
    }

    // MARK: - Internal API

    private func checkPrerequisites() throws {
        if !Notificare.shared.isReady {
            NotificareLogger.warning("Notificare is not ready yet.")
            throw NotificareError.notReady
        }

        guard let application = Notificare.shared.application else {
            NotificareLogger.warning("Notificare application is not yet available.")
            throw NotificareError.applicationUnavailable
        }

        if application.services[NotificareApplication.ServiceKey.storage.rawValue] != true {
            NotificareLogger.warning("Notificare storage functionality is not enabled.")
            throw NotificareError.serviceUnavailable(service: NotificareApplication.ServiceKey.storage.rawValue)
        }
    }
}
