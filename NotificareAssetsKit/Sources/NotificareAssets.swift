//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

public class NotificareAssets: NSObject, NotificareModule {
    public static let shared = NotificareAssets()

    // MARK: Notificare module

    public static func configure() {}

    public static func launch(_ completion: @escaping NotificareCallback<Void>) {
        completion(.success(()))
    }

    public static func unlaunch(_ completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }

    // MARK: - Public API

    public func fetchAssets(for group: String, _ completion: @escaping NotificareCallback<[NotificareAsset]>) {
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
            .query(name: "deviceID", value: Notificare.shared.deviceManager.currentDevice?.id)
            .query(name: "userID", value: Notificare.shared.deviceManager.currentDevice?.userId)
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
