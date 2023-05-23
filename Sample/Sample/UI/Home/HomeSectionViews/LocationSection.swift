//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct LocationSection: View {
    @Binding var hasLocationAndPermission: Bool

    let hasLocationEnabled: Bool
    let hasBluetoothEnabled: Bool
    let locationPermission: String
    let updateLocationServicesStatus: (Bool) -> Void

    var body: some View {
        Section {
            Toggle(isOn: $hasLocationAndPermission) {
                Label {
                    Text(String(localized: "home_location"))
                } icon: {
                    Image(systemName: "location.fill")
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .padding(6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
            .onChange(of: hasLocationAndPermission) { enabled in
                updateLocationServicesStatus(enabled)
            }

            HStack {
                Text(String(localized: "home_enabled"))

                Text(String(localized: "sdk"))
                    .font(.caption2)

                Spacer()

                Text(String(hasLocationEnabled))
            }

            HStack {
                Text(String(localized: "home_bluetooth_enabled"))

                Text(String(localized: "sdk"))
                    .font(.caption2)

                Spacer()

                Text(String(hasBluetoothEnabled))
            }

            HStack {
                Text(String(localized: "home_permission"))

                Spacer()

                Text(String(locationPermission))
            }

            NavigationLink {
                BeaconsView()
            } label: {
                Label {
                    Text(String(localized: "home_beacons"))
                } icon: {
                    Image(systemName: "sensor.tag.radiowaves.forward")
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .padding(6)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
        } header: {
            Text(String(localized: "home_geo"))
        }
    }
}

struct LocationSection_Previews: PreviewProvider {
    static var previews: some View {
        @State var hasLocationAndPermission = false
        LocationSection(
            hasLocationAndPermission: $hasLocationAndPermission,
            hasLocationEnabled: false, hasBluetoothEnabled: false,
            locationPermission: "None",
            updateLocationServicesStatus: { _ in }
        )
    }
}
