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
        case ok = "notificare_ok"
        case cancel = "notificare_cancel"
        case actions = "notificare_actions"

        case pushDefaultCategory = "notificare_push_default_category"

        case actionsSend = "notificare_actions_send"
        case actionsInputPlaceholder = "notificare_actions_input_placeholder"
        case actionsShareImageTextPlaceholder = "notification_actions_share_image_text_placeholder"
    }

    public enum ImageResource: String {
        case actions = "notificare_actions"
    }
}
