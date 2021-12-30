# MIGRATING

Notificare 3.x upgrades our implementation language from Objective-C to Swift and brings a highly modular system.
This new generation aims to give Swift developers a first class experience when using our libraries.

## Requirements

We have increased the minimum iOS version required to run the Notificare library to iOS 10.0+. This minimum version should support, virtually, every iOS device worldwide.

## Configuration file

Instead of the `Notificare.plist` you are used to having in the v2.x library and that contains two sets of app keys — development and production — we have moved to a `NotificareServices.plist` for each environment, similar to what Firebase offers.

We have also created a blog post that illustrates how we can use Build Phases to pick which configuration to embed in the app during the build. You can read more about it [here](https://notificare.com/blog/2021/12/17/Configuration-files-in-a-multiple-environment-app).

## Packages

We have moved to several new packages. Here's all the dependencies available (in `Podfile` syntax):

```ruby
# Required
pod 'Notificare/NotificareKit'

# Optional modules
pod 'Notificare/NotificareAssetsKit'
pod 'Notificare/NotificareAuthenticationKit'
pod 'Notificare/NotificareGeoKit'
pod 'Notificare/NotificareInboxKit'
pod 'Notificare/NotificareLoyaltyKit'
pod 'Notificare/NotificarePushKit'
pod 'Notificare/NotificarePushUIKit'
pod 'Notificare/NotificareScannablesKit'
```

## Package cherry-picking

In the v2.x iteration, we already took the first steps to a more modular library. In this iteration we took it a whole new level.

We understand that not every app will take advantage of every bit of functionality provided by our platform. To help reduce your app's size, dependency footprint and automatically linked system libraries, now you are able to cherry-pick which modules you want to include in your app.

In the hypothetical scenario where you have an app that wants to add push notifications and an in-app inbox, you would include the following dependencies.

```ruby
pod 'Notificare/NotificareKit'
pod 'Notificare/NotificareInboxKit'
pod 'Notificare/NotificarePushKit'
pod 'Notificare/NotificarePushUIKit'
```

## Moving forward

Given the foundational changes and large differences in the Public API in the new libraries, we found the best way to cover every detail is to go through the [documentation](https://docs.notifica.re/sdk/v3/ios/implementation) for each of the modules you want to include and adjust accordingly.

As always, if you have anything to add or require further assistance, we are available via our [Support Channel](mailto:support@notifica.re).
