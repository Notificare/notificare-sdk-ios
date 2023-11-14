//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct LocationSection: View {
    @Binding var hasLocationAndPermission: Bool

    let hasLocationEnabled: Bool
    let hasBluetoothEnabled: Bool
    let locationPermission: HomeViewModel.LocationPermissionStatus?
    let updateLocationServicesStatus: (Bool) -> Void

    var body: some View {
        Section {
            Toggle(isOn: $hasLocationAndPermission) {
                Label {
                    Text(String(localized: "home_location"))
                } icon: {
                    ListIconView(
                        icon: "location.fill",
                        foregroundColor: .white,
                        backgroundColor: .blue
                    )
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

                Text(String(locationPermission?.localized ?? ""))
            }

            NavigationLink {
                BeaconsView()
            } label: {
                Label {
                    Text(String(localized: "home_beacons"))
                } icon: {
                    ListIconView(
                        icon: "sensor.tag.radiowaves.forward",
                        foregroundColor: .white,
                        backgroundColor: .green
                    )
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
            locationPermission: HomeViewModel.LocationPermissionStatus.permanentlyDenied,
            updateLocationServicesStatus: { _ in }
        )
    }
}
