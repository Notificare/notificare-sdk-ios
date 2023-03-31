//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI
import NotificareKit
import OSLog

@main
struct Sample: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView()
            }
            .navigationViewStyle(.stack)
        }
    }
}
