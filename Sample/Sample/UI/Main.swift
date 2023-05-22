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
        }
    }
}
