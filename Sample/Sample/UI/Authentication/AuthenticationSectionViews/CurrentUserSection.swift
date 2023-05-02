//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct CurrentUserSection: View {
    @StateObject var viewModel: AuthenticationViewModel

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy HH:mm"
        return formatter
    }()

    var body: some View {
        Section {
            if let user = viewModel.currentUser {
                HStack {
                    Text(String(localized: "authentication_user_id"))
                    Spacer()
                    Text(user.id)
                }

                HStack {
                    Text(String(localized: "authentication_user_name"))
                    Spacer()
                    Text(user.name)
                }

                HStack {
                    Text(String(localized: "authentication_user_segments"))

                    Spacer()

                    VStack {
                        ForEach(user.segments.indices, id: \.self) { index in
                            let notificareSegment = viewModel.fetchedSegments.first { $0.id == user.segments[index] }
                            if let segment = notificareSegment {
                                Text(segment.name)
                            } else {
                                Text(String(localized: "authentication_segment_no_match_found"))
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }

                HStack {
                    Text(String(localized: "authentication_registration_date"))
                    Spacer()
                    Text(dateFormatter.string(from: user.registrationDate))
                }

                HStack {
                    Text(String(localized: "authentication_last_active"))
                    Spacer()
                    Text(dateFormatter.string(from: user.lastActive))
                }
            } else {
                Label(String(localized: "authentication_not_available_please_login"), systemImage: "info.circle.fill")
            }
        } header: {
            Text(String(localized: "authentication_current_user"))
        }
    }
}

struct CurrentUserSection_Previews: PreviewProvider {
    static var previews: some View {
        CurrentUserSection(viewModel: AuthenticationViewModel())
    }
}
