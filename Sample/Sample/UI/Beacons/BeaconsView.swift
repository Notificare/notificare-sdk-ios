//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct BeaconsView: View {
    @StateObject private var viewModel: BeaconsViewModel

    init() {
        _viewModel = StateObject(wrappedValue: BeaconsViewModel())
    }

    var body: some View {
        List {
            Section {
                if viewModel.rangedBeacons.isEmpty {
                    Label(String(localized: "beacons_not_found"), systemImage: "info.circle.fill")
                } else {
                    ForEach(viewModel.rangedBeacons) { beacon in
                        BeaconRow(beacon: beacon)
                    }
                }
            } header: {
                Text(String(localized: "beacons_ranged"))
            }
        }
        .navigationTitle(String(localized: "beacons_title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BeaconsView_Previews: PreviewProvider {
    static var previews: some View {
        BeaconsView()
    }
}
