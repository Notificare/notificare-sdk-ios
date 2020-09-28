Pod::Spec.new do |spec|
  spec.name               = "Notificare"
  spec.version            = "3.0.0"
  spec.summary            = "Notificare Library for iOS apps"
  spec.description        = <<-DESC
Notificare iOS Library implements the power of smart notifications, location services, contextual marketing and powerful loyalty solutions provided by the Notificare platform in iOS applications.

For documentation please refer to: http://docs.notifica.re

For support please use: http://support.notifica.re
                            DESC
  spec.homepage           = "https://notificare.com"
  spec.documentation_url  = "https://docs.notifica.re"
  spec.license            = { :type => "MIT" }
  spec.author             = { "Notificare" => "info@notifica.re" }
  spec.source             = { :git => 'https://github.com/notificare/notificare-sdk-ios', :tag => "#{spec.version}" }
  spec.swift_version      = "5.3"

  # Supported deployment targets
  spec.ios.deployment_target  = "10.0"

  # Subspecs

  spec.subspec 'NotificareSDK' do |subspec|
    subspec.vendored_frameworks = ".artefacts/NotificareSDK.xcframework"
  end

  spec.subspec 'NotificareAssets' do |subspec|
    subspec.vendored_frameworks = ".artefacts/NotificareAssets.xcframework"
  end

  spec.subspec 'NotificareLocation' do |subspec|
    subspec.vendored_frameworks = ".artefacts/NotificareLocation.xcframework"
  end

  spec.subspec 'NotificareLoyalty' do |subspec|
    subspec.vendored_frameworks = ".artefacts/NotificareLoyalty.xcframework"
  end

  spec.subspec 'NotificareMonetize' do |subspec|
    subspec.vendored_frameworks = ".artefacts/NotificareMonetize.xcframework"
  end

  spec.subspec 'NotificarePush' do |subspec|
    subspec.vendored_frameworks = ".artefacts/NotificarePush.xcframework"
  end

  spec.subspec 'NotificareScannable' do |subspec|
    subspec.vendored_frameworks = ".artefacts/NotificareScannable.xcframework"
  end
end
