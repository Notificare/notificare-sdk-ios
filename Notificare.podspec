Pod::Spec.new do |spec|
  spec.name               = "Notificare"
  spec.version            = "4.2.1"
  spec.summary            = "Notificare Library for iOS apps"
  spec.description        = <<-DESC
The Notificare iOS Library implements the power of smart notifications, location services, contextual marketing and powerful loyalty solutions provided by the Notificare platform in iOS applications.

For documentation please refer to: http://docs.notifica.re
For support please use: http://support.notifica.re
                            DESC
  spec.homepage           = "https://notificare.com"
  spec.documentation_url  = "https://docs.notifica.re"
  spec.license            = { :type => "MIT", :file => 'Notificare/LICENSE' }
  spec.author             = { "Notificare" => "info@notifica.re" }
  spec.source             = { :http => "https://cdn.notifica.re/libs/ios/#{spec.version}/cocoapods.zip" }
  spec.swift_version      = "5.3"

  # Supported deployment targets
  spec.ios.deployment_target  = "13.0"

  # Subspecs

  spec.subspec 'NotificareKit' do |subspec|
    subspec.vendored_frameworks = "Notificare/NotificareKit.xcframework"
    subspec.dependency 'Notificare/NotificareUtilitiesKit'
  end

  spec.subspec 'NotificareAssetsKit' do |subspec|
    subspec.vendored_frameworks = "Notificare/NotificareAssetsKit.xcframework"
    subspec.dependency 'Notificare/NotificareUtilitiesKit'
  end

  spec.subspec 'NotificareGeoKit' do |subspec|
    subspec.vendored_frameworks = "Notificare/NotificareGeoKit.xcframework"
    subspec.dependency 'Notificare/NotificareUtilitiesKit'
  end

  spec.subspec 'NotificareInAppMessagingKit' do |subspec|
    subspec.vendored_frameworks = "Notificare/NotificareInAppMessagingKit.xcframework"
    subspec.dependency 'Notificare/NotificareUtilitiesKit'
  end

  spec.subspec 'NotificareInboxKit' do |subspec|
    subspec.vendored_frameworks = "Notificare/NotificareInboxKit.xcframework"
    subspec.dependency 'Notificare/NotificareUtilitiesKit'
  end

  spec.subspec 'NotificareLoyaltyKit' do |subspec|
    subspec.vendored_frameworks = "Notificare/NotificareLoyaltyKit.xcframework"
    subspec.dependency 'Notificare/NotificareUtilitiesKit'
  end

  spec.subspec 'NotificareNotificationServiceExtensionKit' do |subspec|
    subspec.vendored_frameworks = "Notificare/NotificareNotificationServiceExtensionKit.xcframework"
  end

  spec.subspec 'NotificarePushKit' do |subspec|
    subspec.vendored_frameworks = "Notificare/NotificarePushKit.xcframework"
    subspec.dependency 'Notificare/NotificareUtilitiesKit'
  end

  spec.subspec 'NotificarePushUIKit' do |subspec|
    subspec.vendored_frameworks = "Notificare/NotificarePushUIKit.xcframework"
    subspec.dependency 'Notificare/NotificareUtilitiesKit'
  end

  spec.subspec 'NotificareScannablesKit' do |subspec|
    subspec.vendored_frameworks = "Notificare/NotificareScannablesKit.xcframework"
    subspec.dependency 'Notificare/NotificareUtilitiesKit'
  end

  spec.subspec 'NotificareUserInboxKit' do |subspec|
    subspec.vendored_frameworks = "Notificare/NotificareUserInboxKit.xcframework"
    subspec.dependency 'Notificare/NotificareUtilitiesKit'
  end

  spec.subspec 'NotificareUtilitiesKit' do |subspec|
    subspec.vendored_frameworks = "Notificare/NotificareUtilitiesKit.xcframework"
  end

end
