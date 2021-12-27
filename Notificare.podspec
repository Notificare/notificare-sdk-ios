Pod::Spec.new do |spec|
  spec.name               = "Notificare"
  spec.version            = "3.0.0-alpha.1"
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
  spec.source             = { :http => "https://github.com/notificare/notificare-sdk-ios/releases/download/#{spec.version}/Notificare.zip" }
  spec.swift_version      = "5.3"

  # Supported deployment targets
  spec.ios.deployment_target  = "10.0"

  # Subspecs

  spec.subspec 'NotificareKit' do |subspec|
    subspec.vendored_frameworks = "Notificare/NotificareKit.xcframework"
  end

  spec.subspec 'NotificareInboxKit' do |subspec|
    subspec.vendored_frameworks = "Notificare/NotificareInboxKit.xcframework"
  end

  spec.subspec 'NotificareAssetsKit' do |subspec|
    subspec.vendored_frameworks = "Notificare/NotificareAssetsKit.xcframework"
  end

  spec.subspec 'NotificarePushKit' do |subspec|
    subspec.vendored_frameworks = "Notificare/NotificarePushKit.xcframework"
  end

  spec.subspec 'NotificarePushUIKit' do |subspec|
    subspec.vendored_frameworks = "Notificare/NotificarePushUIKit.xcframework"
  end

end
