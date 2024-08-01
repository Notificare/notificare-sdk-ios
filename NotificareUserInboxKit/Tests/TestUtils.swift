//
// Copyright (c) 2024 Notificare. All rights reserved.
//

public enum TestUtils {
    public static func isEqual<T: Equatable>(type: T.Type, a: Any, b: Any) -> Bool {
        guard let a = a as? T, let b = b as? T else { return false }

        return a == b
    }
}
