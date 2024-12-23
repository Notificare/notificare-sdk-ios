//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import Foundation

extension URL: Identifiable {
    public var id: String {
        absoluteString
    }
}
