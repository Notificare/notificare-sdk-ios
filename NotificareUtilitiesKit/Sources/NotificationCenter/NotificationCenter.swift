//
// Copyright (c) 2025 Notificare. All rights reserved.
//

extension NotificationCenter {
    public func upsertObserver(_ observer: Any, selector aSelector: Selector, name aName: NSNotification.Name?, object anObject: Any?) {
        removeObserver(observer, name: aName, object: anObject)
        addObserver(observer, selector: aSelector, name: aName, object: anObject)
    }
}
