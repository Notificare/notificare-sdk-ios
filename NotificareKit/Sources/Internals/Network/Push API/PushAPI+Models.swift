//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

internal extension PushAPI.Models {
    struct Application: Decodable {
        public let _id: String
        public let name: String
        public let category: String
        public let appStoreId: String?
        public let services: [String: Bool]
        public let inboxConfig: NotificareApplication.InboxConfig?
        public let regionConfig: NotificareApplication.RegionConfig?
        public let userDataFields: [NotificareApplication.UserDataField]
        public let actionCategories: [NotificareApplication.ActionCategory]

        func toModel() -> NotificareApplication {
            NotificareApplication(
                id: _id,
                name: name,
                category: category,
                appStoreId: appStoreId,
                services: services,
                inboxConfig: inboxConfig,
                regionConfig: regionConfig,
                userDataFields: userDataFields,
                actionCategories: actionCategories
            )
        }
    }

    struct Notification: Decodable {
        // TODO: create internal model to perform the mappings later on.
    }
}
