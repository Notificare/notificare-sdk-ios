//
// Copyright (c) 2024 Notificare. All rights reserved.
//

import SwiftUI

struct ApplicationInfoSection: View {
    let applicationName: String
    let applicationIdentifier: String

    var body: some View {
        Section {
            HStack {
                Text(String(localized: "home_application_name"))

                Spacer()

                Text(String(applicationName ?? "null"))
            }

            HStack {
                Text(String(localized: "home_application_identifier"))

                Spacer()

                Text(String(applicationIdentifier ?? "null"))
            }
        } header: {
            Text(String(localized: "home_application_info"))
        }
    }
}

struct ApplicationInfoSection_Previews: PreviewProvider {
    static var previews: some View {
        ApplicationInfoSection(
            applicationName: "Sample",
            applicationIdentifier: "re.notifica.sample"
        )
    }
}
