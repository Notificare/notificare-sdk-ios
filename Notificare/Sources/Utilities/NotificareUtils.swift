//
// Created by Helder Pinhal on 15/07/2020.
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

struct NotificareUtils {

    private init() {
    }


    static func getConfiguration() -> NotificareConfiguration? {
        guard let path = Bundle.main.path(forResource: "Notificare", ofType: "plist") else {
            fatalError("Notificare.plist is missing.")
        }

        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            fatalError("Notificare.plist data appears to be corrupted.")
        }

        let decoder = PropertyListDecoder()
        guard let configuration = try? decoder.decode(NotificareConfiguration.self, from: data) else {
            fatalError("Failed to parse Notificare.plist. Please check the contents are valid.")
        }

        return configuration
    }

    static func logLoadedModules() {
        var modules: [String] = []
        if Notificare.shared.pushManager != nil {
            modules.append("push")
        }
        if Notificare.shared.locationManager != nil {
            modules.append("location")
        }

        if modules.isEmpty {
            Notificare.shared.logger.warning("No modules have been loaded.")
        } else {
            Notificare.shared.logger.info("Loaded modules: [\(modules.joined(separator: ", "))]")
        }
    }

    static func logCapabilities() {

    }
}
