//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

extension Notificare {
    public func device() -> NotificareDeviceModule {
        NotificareDeviceModuleImpl.instance
    }

    public func events() -> NotificareEventsModule {
        NotificareEventsModuleImpl.instance
    }
}

extension Notificare {
    internal func deviceImplementation() -> NotificareDeviceModuleImpl {
        NotificareDeviceModuleImpl.instance
    }

    internal func eventsImplementation() -> NotificareEventsModuleImpl {
        NotificareEventsModuleImpl.instance
    }

    internal func session() -> NotificareSessionModuleImpl {
        NotificareSessionModuleImpl.instance
    }

    internal func crashReporter() -> NotificareCrashReporterModuleImpl {
        NotificareCrashReporterModuleImpl.instance
    }
}
