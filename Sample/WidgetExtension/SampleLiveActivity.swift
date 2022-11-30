//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import ActivityKit
import SwiftUI
import WidgetKit

struct SampleLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SampleActivityAttributes.self) { context in
            // Lock screen/banner UI goes here
            HStack {
                Text(context.attributes.text)
                    .font(.headline)

                Spacer()

                Text("\(context.state.value)")
                    .font(.title)
            }
            .padding()
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.attributes.text)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.value)")
                }
            } compactLeading: {
                Text(context.attributes.text)
            } compactTrailing: {
                Text("\(context.state.value)")
            } minimal: {
                Text("\(context.state.value)")
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}
