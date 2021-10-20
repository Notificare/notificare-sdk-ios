//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

internal class NotificareAssetsImpl: NSObject, NotificareModule, NotificareAssets {
    internal static let instance = NotificareAssetsImpl()

    // MARK: - Notificare Assets

    func fetch(group: String, _ completion: @escaping NotificareCallback<[NotificareAsset]>) {
        guard let application = Notificare.shared.application else {
            NotificareLogger.warning("Notificare application is not yet available.")
            completion(.failure(NotificareAssetsError.applicationNotAvailable))
            return
        }

        guard application.services["storage"] == true else {
            NotificareLogger.warning("Notificare storage functionality is not enabled.")
            completion(.failure(NotificareAssetsError.storageNotEnabled))
            return
        }

        NotificareRequest.Builder()
            .get("/asset/forgroup/\(group)")
            .query(name: "deviceID", value: Notificare.shared.device().currentDevice?.id)
            .query(name: "userID", value: Notificare.shared.device().currentDevice?.userId)
            .responseDecodable(NotificareInternals.PushAPI.Responses.Assets.self) { result in
                switch result {
                case let .success(response):
                    let assets = response.assets.map { NotificareAsset(asset: $0) }
                    completion(.success(assets))

                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }
}

public enum NotificareAssetsError: Error {
    case applicationNotAvailable
    case storageNotEnabled
}
