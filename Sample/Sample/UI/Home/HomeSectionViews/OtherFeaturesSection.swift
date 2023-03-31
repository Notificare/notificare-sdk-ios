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
                    Image(systemName: "qrcode.viewfinder")
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .padding(6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
            
            NavigationLink {
                AssetsView()
            } label: {
                Label {
                    Text(String(localized: "home_assets"))
                } icon: {
                    Image(systemName: "folder.fill")
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .padding(6)
                        .background(Color("system_indigo"))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
            
            NavigationLink {
                MonetizeView()
            } label: {
                Label {
                    Text(String(localized: "home_monetize"))
                } icon: {
                    Image(systemName: "bag.fill")
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .padding(6)
                        .background(Color("system_indigo"))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
            
            NavigationLink {
                AuthenticationView()
            } label: {
                Label {
                    Text(String(localized: "home_athentication"))
                } icon: {
                    Image(systemName: "person.badge.key.fill")
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .padding(6)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
            
            NavigationLink {
                EventsView()
            } label: {
                Label {
                    Text(String(localized: "home_custom_events"))
                } icon: {
                    Image(systemName: "light.beacon.max")
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .padding(6)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
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
