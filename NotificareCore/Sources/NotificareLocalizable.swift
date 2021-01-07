//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

public class NotificareLocalizable {
    public static func string(resource: StringResource) -> String {
        string(resource: resource.rawValue, fallback: "")
    }

    public static func string(resource: String, fallback: String) -> String {
        let bundle = Bundle(for: Self.self) // The bundle for the framework.
        let notificareStr = NSLocalizedString(resource, tableName: nil, bundle: bundle, value: fallback, comment: "")

        return NSLocalizedString(resource, tableName: nil, bundle: Bundle.main, value: notificareStr, comment: "")
    }

    public enum StringResource: String {
        case ok = "notificare_ok"
        case cancel = "notificare_cancel"

        case pushDefaultCategory = "notificare_push_default_category"

        case actionsSend = "notificare_actions_send"
        case actionsInputPlaceholder = "notificare_actions_input_placeholder"
    }
}
