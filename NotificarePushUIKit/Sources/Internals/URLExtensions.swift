//
// Copyright (c) 2024 Notificare. All rights reserved.
//

import NotificareKit

extension URL {
    internal var isHttpUrl: Bool {
        scheme == "http" || scheme == "https"
    }
}
