//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import NotificareGeoKit
import SwiftUI

struct BeaconRow: View {
    let beacon: NotificareBeacon

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(verbatim: beacon.name)

                if let minor = beacon.minor {
                    Text(verbatim: "\(beacon.major) • \(minor)")
                        .font(.caption)
                } else {
                    Text(verbatim: "\(beacon.major)")
                        .font(.caption)
                }
            }

            Spacer()

            if beacon.triggers {
                Image(systemName: "bolt.fill")
                    .padding(.trailing)
            }

            switch beacon.proximity {
            case .immediate:
                Image("wifi_signal_3")
            case .far:
                Image("wifi_signal_2")
            case .near:
                Image("wifi_signal_1")
            case .unknown:
                Image(systemName: "wifi.slash")
            }
        }
    }
}

struct BeaconRow_Previews: PreviewProvider {
    static var previews: some View {
        let beacon = NotificareBeacon(
            id: UUID().uuidString,
            name: "Test beacon",
            major: 1,
            minor: 100,
            triggers: true
        )

        BeaconRow(beacon: beacon)
    }
}
