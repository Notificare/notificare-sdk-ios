//
// Created by Helder Pinhal on 05/08/2020.
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
            case .success(let applicationInfo):
                // Launch the device manager: registration.
                NotificareDeviceManager.shared.launch { result in
                    // Ignore the error if device registration fails.
                    completion(.success(applicationInfo))
                }
            case .failure(let error):
                Notificare.shared.logger.error("Failed to load the application info: \(error)")
                completion(.failure(error))
            }
        }
    }
}
