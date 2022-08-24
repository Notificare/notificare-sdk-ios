//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation

internal extension String {
    func isBlank() -> Bool {
        trimmingCharacters(in: .whitespaces).isEmpty
    }
}

internal extension Optional where Wrapped == String {
    func isNullOrBlank() -> Bool {
        guard let str = self else { return false }

        return str.isBlank()
    }
}
