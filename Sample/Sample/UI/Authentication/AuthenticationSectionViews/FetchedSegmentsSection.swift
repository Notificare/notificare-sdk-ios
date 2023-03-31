//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct FetchedSegmentsSection: View {
    @StateObject var viewModel: AuthenticationViewModel
    
    var body: some View {
        Section {
            Text(String(localized: "authentication_fetched_segments"))
                .fontWeight(.medium)
            
            ForEach(viewModel.fetchedSegments) { segment in
                HStack {
                    Text(segment.name)
                    Spacer()
                    
                    if let userSegments = viewModel.currentUser?.segments {
                        if !userSegments.contains(segment.id) {
                            Button(action: {
                                viewModel.addUserSegment(segment: segment)
                                
                            }) {
                                Text(String(localized: "button_add"))
                            }
                        }
                    }
                }
            }
        } header: {
            Text(String(localized: "authentication_segments"))
        }
    }
}

struct FetchedSegmentsSection_Previews: PreviewProvider {
    static var previews: some View {
        FetchedSegmentsSection(viewModel: AuthenticationViewModel())
    }
}
