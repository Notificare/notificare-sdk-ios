//
// Copyright (c) 2023 Notificare. All rights reserved.
//

//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import Combine
import Foundation
import SwiftUI
import NotificareGeoKit

class BeaconsViewModel: ObservableObject {
    @Published var rangedBeacons = [NotificareBeacon]()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
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
