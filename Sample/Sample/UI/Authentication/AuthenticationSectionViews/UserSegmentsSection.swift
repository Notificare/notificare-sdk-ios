//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct UserSegmentsSection: View {
    @StateObject var viewModel: AuthenticationViewModel

    var body: some View {
        Section {
            Text(String(localized: "authentication_user_segments"))
                .fontWeight(.medium)

            if let userSegments = viewModel.currentUser?.segments {
                if userSegments.isEmpty {
                    Label(String(localized: "authentication_no_segemnts_found"), systemImage: "info.circle.fill")
                }
                ForEach(userSegments, id: \.self) { segment in
                    let notificareSegment = viewModel.fetchedSegments.first { $0.id == segment }
                    if let segment = notificareSegment {
                        HStack {
                            Text(segment.name)

                            Spacer()

                            Button(String(localized: "button_remove")) {
                                viewModel.removeUserSegment(segment: segment)
                            }
                        }
                    }
                }
            } else {
                Label(String(localized: "authentication_not_available_please_login"), systemImage: "info.circle.fill")
            }
        }
    }
}

struct UserSegmentsSection_Previews: PreviewProvider {
    static var previews: some View {
        UserSegmentsSection(viewModel: AuthenticationViewModel())
    }
}
