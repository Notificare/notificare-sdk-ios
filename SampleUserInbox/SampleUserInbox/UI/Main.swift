//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import NotificareKit
import OSLog
import SwiftUI

@main
internal struct Sample: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) internal var appDelegate
    @State private var presentedDeepLink: URL?

    internal var body: some Scene {
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
            .banner(item: $presentedDeepLink) { url in
                BannerView(
                    title: String(localized: "main_deep_link_opened_title"),
                    subtitle: url.absoluteString
                )
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
        presentedDeepLink = url
    }
}
