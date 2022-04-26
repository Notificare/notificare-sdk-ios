# CHANGELOG

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
