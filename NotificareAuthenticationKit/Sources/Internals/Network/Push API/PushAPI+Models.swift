//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

internal extension NotificareInternals.PushAPI.Models {
    struct User: Decodable {
        let _id: String
        let userName: String
        let accessToken: String?
        let segments: [String]
        let registrationDate: Date
        let lastActive: Date

        func toModel() -> NotificareUser {
            var pushEmailAddress: String?
            if let accessToken = accessToken {
                pushEmailAddress = "\(accessToken)@pushmail.notifica.re"
            }

            return NotificareUser(
                id: _id,
                name: userName,
                pushEmailAddress: pushEmailAddress,
                segments: segments,
                registrationDate: registrationDate,
                lastActive: lastActive
            )
        }
    }
}

internal extension NotificareInternals.PushAPI.Models {
    struct UserPreference: Decodable {
        let _id: String
        let label: String
        let preferenceType: String
        let preferenceOptions: [UserPreferenceOption]
        let indexPosition: Int

        func toModel(user: NotificareUser) throws -> NotificareUserPreference? {
            guard let type = NotificareUserPreference.PreferenceType(rawValue: preferenceType) else {
                NotificareLogger.warning("Could not decode preference type '\(preferenceType)'.")
                return nil
            }

            return NotificareUserPreference(
                id: _id,
                label: label,
                type: type,
                options: preferenceOptions.map { $0.toModel(user: user) },
                position: indexPosition
            )
        }
    }

    struct UserPreferenceOption: Decodable {
        let userSegment: String
        let label: String

        func toModel(user: NotificareUser) -> NotificareUserPreference.Option {
            NotificareUserPreference.Option(
                label: label,
                segmentId: userSegment,
                selected: user.segments.contains(userSegment)
            )
        }
    }
}

internal extension NotificareInternals.PushAPI.Models {
    struct UserSegment: Decodable {
        let _id: String
        let name: String
        let description: String?

        func toModel() -> NotificareUserSegment {
            NotificareUserSegment(
                id: _id,
                name: name,
                description: description
            )
        }
    }
}
