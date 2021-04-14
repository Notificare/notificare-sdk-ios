Pod::Spec.new do |spec|
  spec.name               = "Notificare"
  spec.version            = "3.0.0-alpha.1"
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
  spec.source             = { :git => 'https://github.com/notificare/notificare-sdk-ios.git', :tag => "#{spec.version}" }
  spec.swift_version      = "5.3"

  # Supported deployment targets
  spec.ios.deployment_target  = "10.0"

  # Subspecs

  spec.subspec 'NotificareKit' do |subspec|
    subspec.vendored_frameworks = ".build/NotificareKit.xcframework", ".build/NotificareCore.xcframework"
  end

  spec.subspec 'NotificareInboxKit' do |subspec|
    subspec.vendored_frameworks = ".build/NotificareInboxKit.xcframework", ".build/NotificareCore.xcframework"
  end

  spec.subspec 'NotificarePushKit' do |subspec|
    subspec.vendored_frameworks = ".build/NotificarePushKit.xcframework", ".build/NotificareCore.xcframework"
  end

  spec.subspec 'NotificarePushUIKit' do |subspec|
    subspec.vendored_frameworks = ".build/NotificarePushUIKit.xcframework", ".build/NotificareCore.xcframework"
  end

end
