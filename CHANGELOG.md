# CHANGELOG

## Upcoming Release

- Introduce `itemsStream` and `badgeStream` Combine publishers for inbox module
- Introduce `subscriptionStream` and `allowedUIStream` Combine publishers for push module
- Fix issue where the notification UI was not dismissed when an action was executed through a custom markup or actions context sheet
- Allow unsetting user data fields

## 4.0.1

- Add documentation to public methods.
- Fix crash when executing the completion handlers in the implemented `UNUserNotificationCenter` after disabling the default Notificare implementation.
- Remove User Inbox messages from the notification center when apropriate.
- Fix `refreshBadge()` calls error handling when auto badge is off.
- Fix crash when sending photos using the camera notification action.
- Fix camera notification action behaviour when no camera permission is granted, opening the photo library.

## 4.0.0

- Device identifiers become long-lived
- `launch()`, `unlaunch()`, `enableRemoteNotifications()` and `disableRemoteNotifications()` become async functions with a callback alternative
- Add support for customisable hosts
- Fix `NotificarePass.data` decoding
- Add `Equatable` compliance to applicable data models
- Allow `configure()` to be called more than once, provided Notificare is unlaunched.

#### Breaking changes

- `NotificareDevice.id` attribute no longer contains the push token. Use `Notificare.shared.push().subscription` instead.
- The `NotificareDevice` data model was reduced to only publicly relevant attributes.
- `didRegisterDevice` only triggers once, when the device is created.
- `launch()`, `unlaunch()`, `enableRemoteNotifications()` and `disableRemoteNotifications()` become suspending functions that complete after all the work is done.
- `NotificareTransport` was moved to the push module.
- Drops support for the monetize module.
- Removed deprecated  `notificare(_:didReceiveNotification:)`. Use `notificare(_:didReceiveNotification:deliveryMechanism:)` instead.
- Removed deprecated `notificare(_:didReceiveUnknownAction:for:responseText:)` delegate method. Renamed to `notificare(_:didOpenUnknownAction:for:responseText:)`.
- Removed deprecated `handleNotificationRequest()` from push module. Include the NotificareNotificationServiceExtensionKit and use `NotificareNotificationServiceExtension.handleNotificationRequest()` instead.

## 4.0.0-beta.2

- Fix `NotificarePass.data` decoding
- Add `Equatable` compliance to applicable data models
- Changed the `subscriptionId` properties to a more robust data model
- Allow `configure()` to be called more than once, provided Notificare is unlaunched.

## 4.0.0-beta.1

- Device identifiers become long-lived
- `launch()`, `unlaunch()`, `enableRemoteNotifications()` and `disableRemoteNotifications()` become async functions with a callback alternative
- Add support for customisable hosts

#### Breaking changes

- `NotificareDevice.id` attribute no longer contains the push token. Use `Notificare.shared.push().subscriptionId` instead.
- The `NotificareDevice` data model was reduced to only publicly relevant attributes.
- `didRegisterDevice` only triggers once, when the device is created.
- `launch()`, `unlaunch()`, `enableRemoteNotifications()` and `disableRemoteNotifications()` become suspending functions that complete after all the work is done.
- `NotificareTransport` was moved to the push module.
- Drops support for the monetize module.
- Removed deprecated  `notificare(_:didReceiveNotification:)`. Use `notificare(_:didReceiveNotification:deliveryMechanism:)` instead.
- Removed deprecated `notificare(_:didReceiveUnknownAction:for:responseText:)` delegate method. Renamed to `notificare(_:didOpenUnknownAction:for:responseText:)`.
- Removed deprecated `handleNotificationRequest()` from push module. Include the NotificareNotificationServiceExtensionKit and use `NotificareNotificationServiceExtension.handleNotificationRequest()` instead.

## 3.10.0

- Add support for the URLResolver notification type
- Fix anonymous device registration

## 3.9.1

- Preload images before showing in-app messages
- Fix `NotificarePass.type` decoding

## 3.9.0

- Add support for deferred links
- Add privacy manifests
- Code sign XCFrameworks

## 3.8.0

- Prevent processing location updates too close to the last known location
- Fix race condition where geo triggers and region sessions were sent multiple times
- Limit the amount of location points and ranged beacons in geo sessions
- Improve polygon regions handling
- Improve notifications UI

## 3.7.0

- Prevent the `device_registered` event from invoking before the `ready` event
- Automatically enable remote notifications during launch when possible
- Automatically enable location updates during launch when possible
- Drop support for iOS 12.0

**Important notice:** Re-enabling remote notifications and location services is no longer required.
You can safely remove the following piece of code as the SDK will automatically handle it for you during the launch flow.

```swift
func notificare(_ notificare: Notificare, onReady application: NotificareApplication) {
    // This check is no longer necessary.
    if Notificare.shared.push().hasRemoteNotificationsEnabled {
        Notificare.shared.push().enableRemoteNotifications { _ in }
    }

    // This check is no longer necessary.
    if Notificare.shared.geo().hasLocationServicesEnabled {
        Notificare.shared.geo().enableLocationUpdates()
    }
}
```

## 3.7.0-beta.1

- Prevent the `device_registered` event from invoking before the `ready` event
- Automatically enable remote notifications during launch when possible
- Automatically enable location updates during launch when possible
- Drop support for iOS 12.0

**Important notice:** Re-enabling remote notifications and location services is no longer required.
You can safely remove the following piece of code as the SDK will automatically handle it for you during the launch flow.

```swift
func notificare(_ notificare: Notificare, onReady application: NotificareApplication) {
    // This check is no longer necessary.
    if Notificare.shared.push().hasRemoteNotificationsEnabled {
        Notificare.shared.push().enableRemoteNotifications { _ in }
    }

    // This check is no longer necessary.
    if Notificare.shared.geo().hasLocationServicesEnabled {
        Notificare.shared.geo().enableLocationUpdates()
    }
}
```

## 3.6.1

- Fix race condition when setting the database merge policy eagerly loads the data stores
- Prevent fatal error when failing to open the databases

## 3.6.0

- Allow checking which regions are being monitored
- Allow checking which regions the device is inside of
- Allow setting the amount of regions to monitor

## 3.5.4

- Prevent queued events without an associated device
- Prevent `logCustom` usage before Notificare becomes ready

## 3.5.3

- Improve supported deep links validation
- Fix debug symbols search paths
- Stricter unlaunch flow

## 3.5.2

- Emit the `didChangeNotificationSettings` event when disabling remote notifications
- Add opt-in flag to prevent file access restrictions for Core Data
- Prevent push registration race condition when enabling remote notifications
- Correctly track device on initial application open event

## 3.5.1

- Improved auto-config mechanism
- Improved action categories parsing
- Fix user validation request
- Fix cached language when the network request fails
- Include debug symbols in the distributed frameworks
- Fix store notification required view controller flag
- Fix main-thread warning on device registration
- Use YouTube privacy-enhanced mode

## 3.5.0

#### Important changes since 3.4.2

- Add user-level inbox module
- Add support for live activities
- Allow a context evaluation upon un-suppressing in-app messages
- Include the delivery mechanism for notification received events

## 3.5.0-beta.1

- Add user-level inbox module
- Add support for live activities

## 3.4.2

- Fix notification settings update race condition
- Prevent WebView notifications content from being dismissed while the view is presented
- Add `Identifiable` compliance to applicable data models
- Optional CoreNFC framework linking to support older devices
- Refactor internal modules to keep track of their instances
- Improve pass-support availability checks

## 3.4.1

- Fix locale-sensitive time formatting on `NotificareTime` objects

## 3.4.0

#### Important changes since 3.3.0

- In-app messaging module
- Add option to preserve existing notification categories
- Drop support for iOS 10

## 3.4.0-beta.3

- Add option to preserve existing notification categories

## 3.4.0-beta.2

- Fix in-app message action click event

## 3.4.0-beta.1

- In-app messaging

## 3.3.0

- Monetise module
- Prevent internal _main beacon region_ from triggering events
- Remove interruption level & relevance score from notification service extension

## 3.2.0

- Fix notification content when opening partial inbox items
- Fix marking partial items as read
- Improve ISO date parser
- Add safeguards and warnings for corrupted items in the inbox database
- Log events methods correctly throw when failures are not recoverable
- Improve session control mechanism
- Add `InAppBrowser` notification type
- Aliased `WebView` action into `InAppBrowser`, aligning with the notification type
- Ensure delegate methods are called on the main thread

## 3.1.0

- Include `Accept-Language` and custom `User-Agent` headers
- Improve `allowedUI` to accurately reflect push capabilities
- Rename internal `AnyCodable` to prevent collisions
- Expose unknown notification open events via `notificare(_:didOpenUnknownNotification:)` and `notificare(_:didOpenUnknownAction:for:responseText:)`
- Launch each peer module sequentially to prevent race conditions

## 3.0.1

- Prevent multiple push registration events
- Prevent Apple-processed builds from modifying the SDK version

## 3.0.0

Please check our [migration guide](./MIGRATION.md) before adopting the v3.x generation.
