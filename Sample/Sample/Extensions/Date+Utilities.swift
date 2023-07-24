//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import Foundation

extension Date {
    static var today: Date {
        Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
    }

    static var yesterday: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: today)!
    }

    static var startOfWeek: Date {
        Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today).date!
    }
}
