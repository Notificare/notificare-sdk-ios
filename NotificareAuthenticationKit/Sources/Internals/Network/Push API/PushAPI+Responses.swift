//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

internal extension NotificareInternals.PushAPI.Responses {
    struct OAuthResponse: Decodable {
        let access_token: String
        let refresh_token: String
        let expires_in: Int
    }

    struct UserDetailsResponse: Decodable {
        let user: NotificareInternals.PushAPI.Models.User
    }

    struct FetchUserPreferencesResponse: Decodable {
        let userPreferences: [NotificareInternals.PushAPI.Models.UserPreference]
    }

    struct FetchUserSegmentsResponse: Decodable {
        let userSegments: [NotificareInternals.PushAPI.Models.UserSegment]
    }
}
