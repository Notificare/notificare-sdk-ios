//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct OtherFeaturesSection: View {
    var body: some View {
        Section {
            NavigationLink {
                ScannablesView()
            } label: {
                Label {
                    Text(String(localized: "home_scannables"))
                } icon: {
                    ListIconView(
                        icon: "qrcode.viewfinder",
                        foregroundColor: .white,
                        backgroundColor: .blue
                    )
                }
            }

            NavigationLink {
                AssetsView()
            } label: {
                Label {
                    Text(String(localized: "home_assets"))
                } icon: {
                    ListIconView(
                        icon: "folder.fill",
                        foregroundColor: .white,
                        backgroundColor: Color(.systemIndigo)
                    )
                }
            }

            NavigationLink {
                MonetizeView()
            } label: {
                Label {
                    Text(String(localized: "home_monetize"))
                } icon: {
                    ListIconView(
                        icon: "bag.fill",
                        foregroundColor: .white,
                        backgroundColor: Color(.systemIndigo)
                    )
                }
            }

            NavigationLink {
                EventsView()
            } label: {
                Label {
                    Text(String(localized: "home_custom_events"))
                } icon: {
                    ListIconView(
                        icon: "light.beacon.max",
                        foregroundColor: .white,
                        backgroundColor: .red
                    )
                }
            }
        } header: {
            Text(String(localized: "home_other_features"))
        }
    }
}

struct OtherFeaturesSection_Previews: PreviewProvider {
    static var previews: some View {
        OtherFeaturesSection()
    }
}
