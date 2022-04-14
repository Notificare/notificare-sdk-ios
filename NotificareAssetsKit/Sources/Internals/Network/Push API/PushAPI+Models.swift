//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

internal extension NotificareInternals.PushAPI.Models {
    struct Asset: Decodable {
        let _id: String
        let key: String?
        let title: String
        let description: String?
        let extra: NotificareAnyCodable?
        let button: Button?
        let metaData: MetaData?

        struct Button: Decodable {
            let label: String?
            let action: String?
        }

        struct MetaData: Decodable {
            let originalFileName: String
            let contentType: String
            let contentLength: Int
        }

        func toModel() -> NotificareAsset {
            let url: String?
            if let key = key, let host = Notificare.shared.servicesInfo?.services.pushHost {
                url = "\(host)/asset/file/\(key)"
            } else {
                url = nil
            }

            return NotificareAsset(
                id: _id,
                title: title,
                description: description,
                key: key,
                url: url,
                button: button.map {
                    NotificareAsset.Button(
                        label: $0.label,
                        action: $0.action
                    )
                },
                metaData: metaData.map {
                    NotificareAsset.MetaData(
                        originalFileName: $0.originalFileName,
                        contentType: $0.contentType,
                        contentLength: $0.contentLength
                    )
                },
                extra: extra?.value as? [String: Any] ?? [:]
            )
        }
    }
}
