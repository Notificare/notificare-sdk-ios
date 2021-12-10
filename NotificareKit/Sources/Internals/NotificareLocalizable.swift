//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import UIKit

public class NotificareLocalizable {
    public static func string(resource: StringResource) -> String {
        string(resource: resource.rawValue, fallback: "")
    }

    public static func string(resource: String, fallback: String) -> String {
        let bundle = Bundle(for: Self.self) // The bundle for the framework.
        let notificareStr = NSLocalizedString(resource, tableName: nil, bundle: bundle, value: fallback, comment: "")

        return NSLocalizedString(resource, tableName: nil, bundle: Bundle.main, value: notificareStr, comment: "")
    }

    public static func image(resource: ImageResource) -> UIImage? {
        if let overwrittenImage = UIImage(named: resource.rawValue, in: Bundle.main, compatibleWith: nil) {
            return overwrittenImage
        }

        let bundle = Bundle(for: Self.self) // The bundle for the framework.
        return UIImage(named: resource.rawValue, in: bundle, compatibleWith: nil)
    }

    public enum StringResource: String {
        case okButton = "notificare_ok_button"
        case cancelButton = "notificare_cancel_button"
        case closeButton = "notificare_close_button"
        case sendButton = "notificare_send_button"
        case actionsButton = "notificare_actions_button"

        case pushDefaultCategory = "notificare_push_default_category"

        case actionsInputPlaceholder = "notificare_actions_input_placeholder"
        case actionsShareImageTextPlaceholder = "notification_actions_share_image_text_placeholder"

        case rateAlertYesButton = "notificare_rate_alert_yes_button"
        case rateAlertNoButton = "notificare_rate_alert_no_button"

        case mapUnknownTitleMarker = "notificare_map_unknown_title_marker"

        case actionMailSubject = "notificare_action_mail_subject"
        case actionMailBody = "notificare_action_mail_body"
    }

    public enum ImageResource: String {
        case actions = "notificare_actions"
        case mapMarker = "notificare_map_marker"
        case mapMarkerUserLocation = "notificare_map_marker_user_location"
        case close = "notificare_close"
        case send = "notificare_send"
    }
}
