//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

class NotificareLaunchManager {
    static let shared = NotificareLaunchManager()

    private init() {}

    func launch(_ completion: @escaping (Result<NotificareApplicationInfo, NotificareError>) -> Void) {
        guard let pushApi = Notificare.shared.pushApi else {
            completion(.failure(.notConfigured))
            return
        }

        // Fetch the application info.
        pushApi.getApplicationInfo { result in
            switch result {
            case let .success(applicationInfo):
                // Launch the device manager: registration.
                NotificareDeviceManager.shared.launch { _ in
                    // Ignore the error if device registration fails.
                    completion(.success(applicationInfo))
                }
            case let .failure(error):
                Notificare.shared.logger.error("Failed to load the application info: \(error)")
                completion(.failure(error))
            }
        }
    }
}
