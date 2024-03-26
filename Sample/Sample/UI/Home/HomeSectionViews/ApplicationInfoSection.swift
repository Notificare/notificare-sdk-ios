//
// Copyright (c) 2024 Notificare. All rights reserved.
//

import SwiftUI

internal struct ApplicationInfoSection: View {
    internal let applicationName: String
    internal let applicationIdentifier: String

    internal var body: some View {
        Section {
            HStack {
                Text(String(localized: "home_application_name"))

                Spacer()

                Text(verbatim: applicationName)
            }

            HStack {
                Text(String(localized: "home_application_identifier"))

                Spacer()

                Text(verbatim: applicationIdentifier)
            }
        } header: {
            Text(String(localized: "home_application_info"))
        }
    }
}

internal struct ApplicationInfoSection_Previews: PreviewProvider {
    internal static var previews: some View {
        ApplicationInfoSection(
            applicationName: "Sample",
            applicationIdentifier: "re.notifica.sample"
        )
    }
}
