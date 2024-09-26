//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import UIKit

public enum ModuleUtils {
    public static func getEnabledPeerModules() -> [String] {
        NotificareInternals.Module.allCases
            .filter { $0.isPeer && $0.isAvailable }
            .map { "\($0)" }
    }
}
