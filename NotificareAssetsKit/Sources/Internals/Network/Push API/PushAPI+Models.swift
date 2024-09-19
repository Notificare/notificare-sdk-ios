//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit
import NotificareUtilitiesKit

extension NotificareInternals.PushAPI.Models {
    internal struct Asset: Decodable, Equatable {
        internal let _id: String
        internal let key: String?
        internal let title: String
        internal let description: String?
        internal let extra: NotificareAnyCodable?
        internal let button: Button?
        internal let metaData: MetaData?

        internal struct Button: Decodable, Equatable {
            internal let label: String?
            internal let action: String?
        }

        internal struct MetaData: Decodable, Equatable {
            internal let originalFileName: String
            internal let contentType: String
            internal let contentLength: Int
        }

        internal func toModel() -> NotificareAsset {
            let url: String?
            if let key = key, let host = Notificare.shared.servicesInfo?.hosts.restApi {
                url = "https://\(host)/asset/file/\(key)"
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
