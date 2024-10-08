//
// Copyright (c) 2023 Notificare. All rights reserved.
//

//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import Combine
import Foundation
import NotificareGeoKit
import SwiftUI

internal class BeaconsViewModel: ObservableObject {
    @Published internal var rangedBeacons = [NotificareBeacon]()

    private var cancellables = Set<AnyCancellable>()

    internal init() {
        observeRangedBeacons()
    }

    private func observeRangedBeacons() {
        NotificationCenter.default.publisher(for: .beaconsRanged)
            .sink { [weak self] notification in
                guard let beacons = notification.userInfo?["beacons"] as? [NotificareBeacon] else {
                    return
                }

                self?.rangedBeacons = beacons
            }
            .store(in: &cancellables)
    }
}
