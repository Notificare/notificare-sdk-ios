//
//  NotificareEnvironment.swift
//  Notificare
//
//  Created by Helder Pinhal on 23/07/2020.
//  Copyright © 2020 Notificare. All rights reserved.
//

import Foundation

public enum NotificareEnvironment: String {
    case test
    case production

    func getConfiguration() -> Configuration {
        switch self {
        case .production:
            return Configuration(
                    pushHost: URL(string: "https://push.notifica.re")!,
                    cloudHost: URL(string: "https://cloud.notifica.re")!,
                    webPassHost: URL(string: "https://pass.notifica.re")!
            )
        case .test:
            return Configuration(
                    pushHost: URL(string: "https://push-test.notifica.re")!,
                    cloudHost: URL(string: "https://cloud-test.notifica.re")!,
                    webPassHost: URL(string: "https://pass-test.notifica.re")!
            )
        }
    }


    struct Configuration {
        let pushHost: URL
        let cloudHost: URL
        let webPassHost: URL
    }
}