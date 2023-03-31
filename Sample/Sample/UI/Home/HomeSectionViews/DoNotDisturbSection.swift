//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct DoNotDisturbSection: View {
    @StateObject var viewModel: HomeViewModel
    
    var body: some View {
        Section {
            Toggle(isOn: $viewModel.hasDndEnabled) {
                Label {
                    Text(String(localized: "home_do_not_disturb"))
                } icon: {
                    Image(systemName: "moon.fill")
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .padding(6)
                        .background(Color("system_indigo"))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
            .onChange(of: viewModel.hasDndEnabled) { enabled in
                viewModel.handleDndToggle(enabled: enabled)
            }
            
            if viewModel.hasDndEnabled {
                DatePicker(
                    String(localized: "home_do_not_disturb_start"),
                    selection: $viewModel.startTime,
                    displayedComponents: .hourAndMinute
                )
                .onChange(of: viewModel.startTime) { time in
                    viewModel.handleDndTimeUpdate()
                }
                
                DatePicker(
                    String(localized: "home_do_not_disturb_end"),
                    selection: $viewModel.endTime,
                    displayedComponents: .hourAndMinute
                )
                .onChange(of: viewModel.endTime) { time in
                    viewModel.handleDndTimeUpdate()
                }
            }
        }
    }
}

struct DoNotDisturbSection_Previews: PreviewProvider {
    static var previews: some View {
        DoNotDisturbSection(viewModel: HomeViewModel())
    }
}
