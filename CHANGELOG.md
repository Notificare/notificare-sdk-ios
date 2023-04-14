# CHANGELOG

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
