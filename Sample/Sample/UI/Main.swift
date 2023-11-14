//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import NotificareKit
import OSLog
import SwiftUI

@main
struct Sample: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView()
            }
            .onOpenURL { url in
                handleUrl(url: url)
            }
            .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                guard let url = userActivity.webpageURL else {
                    return
                }

                handleUrl(url: url)
            }
        }
    }

    private func handleUrl(url: URL) {
        if Notificare.shared.handleTestDeviceUrl(url) {
            Logger.main.info("Test device url: \(url.absoluteString).")
            return
        }

        if Notificare.shared.handleDynamicLinkUrl(url) {
            Logger.main.info("Dynamic link url: \(url.absoluteString).")
            return
        }

        Logger.main.info("Received deep link: \(url.absoluteString).")
    }
}
