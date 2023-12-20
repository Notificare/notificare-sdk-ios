[<img src="https://raw.githubusercontent.com/notificare/notificare-sdk-ios/main/assets/logo.png"/>](https://notificare.com)

# Notificare iOS SDK

[![GitHub release](https://img.shields.io/github/v/release/notificare/notificare-sdk-ios?include_prereleases)](https://github.com/notificare/notificare-sdk-ios/releases)
[![License](https://img.shields.io/github/license/notificare/notificare-sdk-ios)](https://github.com/notificare/notificare-sdk-ios/blob/main/LICENSE)

The Notificare iOS SDK makes it quick and easy to communicate efficiently with many of the Notificare API services and enables you to seamlessly integrate our various features, from Push Notifications to Contextualised Storage.

Get started with our [📚 integration guides](https://docs.notifica.re/sdk/v3/ios/setup) and [example projects](#examples), or [📘 browse the SDK reference]() (coming soon).


Table of contents
=================

* [Features](#features)
* [Releases](#releases)
* [Installation](#installation)
  * [Requirements](#requirements)
  * [Configuration](#configuration)
* [Getting Started](#getting-started)
* [Examples](#examples)


## Features

**Push notifications**: Receive push notifications and automatically track its engagement.

**Push notifications UI**: Use native screens and elements to display your push notifications and handle its actions with zero effort.

**In-app messaging**: Automatically show relevant in-app content to your users with zero effort.

**Inbox**: Apps with a built-in message inbox enjoy higher conversions due to its nature of keeping messages around that can be opened as many times as users want. The SDK gives you all the tools necessary to build your inbox UI.

**Geo**: Transform your user's location into relevant information, automate how you segment your users based on location behaviour and create truly contextual notifications.

**Loyalty**: Harness the power of digital cards that live beyond your app and are always in your customer’s pocket.

**Monetize**: Quickly support in-app purchases in both the App Store and Google Play.

**Assets**: Add powerful contextual marketing features to your apps. Show the right content to the right users at the right time or location. Maximise the content you're already creating without increasing development costs.

**Scannables**: Unlock new content by scanning NFC tags or QR codes that integrate seamlessly in your mobile applications.


## Installation

### Requirements

* iOS 13.0 and above
* Xcode 12 or later

### Configuration

##### Swift Package Manager
If you are using SPM, open the following menu item in Xcode:

**File > Swift Packages > Add Package Dependency...**

In the **Choose Package Repository** prompt, add the following URL and complete the next steps.

```
https://github.com/notificare/notificare-sdk-ios.git
```

> For more information on SPM, check their [official documentation](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app).

##### Cocoapods
If you are using [Cocoapods](https://cocoapods.org), add the following lines to your `Podfile` and then run `pod install`:

```ruby
# Required
pod 'Notificare/NotificareKit'

# Optional modules
pod 'Notificare/NotificareAssetsKit'
pod 'Notificare/NotificareGeoKit'
pod 'Notificare/NotificareInboxKit'
pod 'Notificare/NotificareLoyaltyKit'
pod 'Notificare/NotificarePushKit'
pod 'Notificare/NotificarePushUIKit'
pod 'Notificare/NotificareScannablesKit'
```

> For more information on Cocoapods, check their [official documentation](https://guides.cocoapods.org/using/getting-started.html).

## Getting Started

### Integration
Get started with our [📚 integration guides](https://docs.notifica.re/sdk/v3/ios/setup) and [example projects](#examples), or [📘 browse the SDK reference]() (coming soon).


### Examples
- The [example project](https://github.com/Notificare/notificare-sdk-ios/tree/main/Sample) demonstrates integrations in a simplified fashion, to quickly understand how a given feature should be implemented.
