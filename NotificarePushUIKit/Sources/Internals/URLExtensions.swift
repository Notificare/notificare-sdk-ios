//
// Copyright (c) 2024 Notificare. All rights reserved.
//

extension URL {
    internal var isHttpUrl: Bool {
        scheme == "http" || scheme == "https"
    }
}
