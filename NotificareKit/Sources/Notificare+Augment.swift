//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

public extension Notificare {
    func device() -> NotificareDeviceModule {
        NotificareDeviceModuleImpl.instance
    }

    func events() -> NotificareEventsModule {
        NotificareEventsModuleImpl.instance
    }
}

internal extension Notificare {
    func deviceImplementation() -> NotificareDeviceModuleImpl {
        NotificareDeviceModuleImpl.instance
    }

    func eventsImplementation() -> NotificareEventsModuleImpl {
        NotificareEventsModuleImpl.instance
    }

    func session() -> NotificareSessionModuleImpl {
        NotificareSessionModuleImpl.instance
    }

    func crashReporter() -> NotificareCrashReporterModuleImpl {
        NotificareCrashReporterModuleImpl.instance
    }
}
