//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

public enum NotificareServices: String {
    case test
    case production

    struct Configuration {
        let pushHost: URL
        let cloudHost: URL
        let webPassHost: URL
    }

    var pushHost: URL {
        switch self {
        case .test: return URL(string: "https://push-test.notifica.re")!
        case .production: return URL(string: "https://push.notifica.re")!
        }
    }

    var cloudHost: URL {
        switch self {
        case .test: return URL(string: "https://cloud-test.notifica.re")!
        case .production: return URL(string: "https://cloud.notifica.re")!
        }
    }

    var webPassHost: URL {
        switch self {
        case .test: return URL(string: "https://pass-test.notifica.re")!
        case .production: return URL(string: "https://pass.notifica.re")!
        }
    }
}
