//
// Copyright (c) 2024 Notificare. All rights reserved.
//

import Foundation

extension String {
    internal var isBlank: Bool {
        self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
