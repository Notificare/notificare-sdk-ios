# frozen_string_literal: true

require 'fileutils'

# Builder service to automate the whole build process.
class Bob
  attr_reader :version

  def initialize
    unless ARGV.empty?
      @version = ARGV[0]
      return
    end

    puts <<~DESC
      Missing version argument.

      To run the command use:
      ruby build.rb 3.0.0
    DESC

    exit 1
  end

  def work
    puts "Building version #{version}"

    prepare_environment

    Xcode.clean
    Xcode.build

    SPM.new(version).generate_artefacts
    Cocoapods.new(version).generate_artefacts

    puts 'Done! 🚀'
  end

  class << self
    def zip(working_directory:, files:, output:)
      system("cd #{working_directory} && zip -rq #{output} #{files}", exception: true)
    end
  end

  private

  def prepare_environment
    FileUtils.rm_rf '.build'
    FileUtils.mkdir_p '.build/archives'
    FileUtils.mkdir_p '.build/intermediates'
    FileUtils.mkdir_p '.build/outputs'
    FileUtils.mkdir_p '.build/tmp'
  end
end

# Utility to enumerate the buildable modules.
class Framework
  attr_reader :scheme, :spm_zip_filename, :spm_checksum_placeholder

  def initialize(scheme:, spm_zip_filename:, spm_checksum_placeholder:)
    @scheme = scheme
    @spm_zip_filename = spm_zip_filename
    @spm_checksum_placeholder = spm_checksum_placeholder
  end

  class << self
    def all
      [
        Framework.new(scheme: 'NotificareKit',
                      spm_zip_filename: 'spm-notificare.zip',
                      spm_checksum_placeholder: '{{NOTIFICARE_CHECKSUM}}'),
        Framework.new(scheme: 'NotificareAssetsKit',
                      spm_zip_filename: 'spm-notificare-assets.zip',
                      spm_checksum_placeholder: '{{NOTIFICARE_ASSETS_CHECKSUM}}'),
        Framework.new(scheme: 'NotificareAuthenticationKit',
                      spm_zip_filename: 'spm-notificare-authentication.zip',
                      spm_checksum_placeholder: '{{NOTIFICARE_AUTHENTICATION_CHECKSUM}}'),
        Framework.new(scheme: 'NotificareGeoKit',
                      spm_zip_filename: 'spm-notificare-geo.zip',
                      spm_checksum_placeholder: '{{NOTIFICARE_GEO_CHECKSUM}}'),
        Framework.new(scheme: 'NotificareInAppMessagingKit',
                      spm_zip_filename: 'spm-notificare-in-app-messaging.zip',
                      spm_checksum_placeholder: '{{NOTIFICARE_IN_APP_MESSAGING_CHECKSUM}}'),
        Framework.new(scheme: 'NotificareInboxKit',
                      spm_zip_filename: 'spm-notificare-inbox.zip',
                      spm_checksum_placeholder: '{{NOTIFICARE_INBOX_CHECKSUM}}'),
        Framework.new(scheme: 'NotificareLoyaltyKit',
                      spm_zip_filename: 'spm-notificare-loyalty.zip',
                      spm_checksum_placeholder: '{{NOTIFICARE_LOYALTY_CHECKSUM}}'),
        Framework.new(scheme: 'NotificareMonetizeKit',
                      spm_zip_filename: 'spm-notificare-monetize.zip',
                      spm_checksum_placeholder: '{{NOTIFICARE_MONETIZE_CHECKSUM}}'),
        Framework.new(scheme: 'NotificareNotificationServiceExtensionKit',
                      spm_zip_filename: 'spm-notificare-notification-service-extension.zip',
                      spm_checksum_placeholder: '{{NOTIFICARE_NOTIFICATION_SERVICE_EXTENSION_CHECKSUM}}'),
        Framework.new(scheme: 'NotificarePushKit',
                      spm_zip_filename: 'spm-notificare-push.zip',
                      spm_checksum_placeholder: '{{NOTIFICARE_PUSH_CHECKSUM}}'),
        Framework.new(scheme: 'NotificarePushUIKit',
                      spm_zip_filename: 'spm-notificare-push-ui.zip',
                      spm_checksum_placeholder: '{{NOTIFICARE_PUSH_UI_CHECKSUM}}'),
        Framework.new(scheme: 'NotificareScannablesKit',
                      spm_zip_filename: 'spm-notificare-scannables.zip',
                      spm_checksum_placeholder: '{{NOTIFICARE_SCANNABLES_CHECKSUM}}'),
        Framework.new(scheme: 'NotificareUserInboxKit',
                      spm_zip_filename: 'spm-notificare-user-inbox.zip',
                      spm_checksum_placeholder: '{{NOTIFICARE_USER_INBOX_CHECKSUM}}'),
      ]
    end
  end
end

# Utility run xcodebuild tasks.
class Xcode
  class << self
    def clean
      Framework.all.each do |framework|
        command = <<~COMMAND
          xcodebuild clean \\
            -workspace Notificare.xcworkspace \\
            -scheme #{framework.scheme} \\
            -sdk iphoneos \\
            -quiet
        COMMAND

        system(command, exception: true)
      end
    end

    def build
      Framework.all.each do |framework|
        create_ios_device_archive(framework)
        create_ios_simulator_archive(framework)
        create_xcframework(framework)
      end
    end

    private

    def create_ios_device_archive(framework)
      command = <<~COMMAND
        xcodebuild archive \\
          -workspace Notificare.xcworkspace \\
          -scheme #{framework.scheme} \\
          -archivePath ".build/archives/#{framework.scheme}-iOS.xcarchive" \\
          -destination "generic/platform=iOS" \\
          -sdk iphoneos \\
          -quiet \\
          SKIP_INSTALL=NO \\
          BUILD_LIBRARY_FOR_DISTRIBUTION=YES
      COMMAND

      system(command, exception: true)
    end

    def create_ios_simulator_archive(framework)
      command = <<~COMMAND
        xcodebuild archive \\
          -workspace Notificare.xcworkspace \\
          -scheme #{framework.scheme} \\
          -archivePath ".build/archives/#{framework.scheme}-iOS-simulator.xcarchive" \\
          -destination "generic/platform=iOS Simulator" \\
          -sdk iphonesimulator \\
          -quiet \\
          SKIP_INSTALL=NO \\
          BUILD_LIBRARY_FOR_DISTRIBUTION=YES
      COMMAND

      system(command, exception: true)
    end

    def create_xcframework(framework)
      command = <<~COMMAND
        xcodebuild -create-xcframework \\
          -framework ".build/archives/#{framework.scheme}-iOS.xcarchive/Products/Library/Frameworks/#{framework.scheme}.framework" \\
          -debug-symbols #{File.expand_path(".build/archives/#{framework.scheme}-iOS.xcarchive/dSYMs/#{framework.scheme}.framework.dSYM")} \\
          -framework ".build/archives/#{framework.scheme}-iOS-simulator.xcarchive/Products/Library/Frameworks/#{framework.scheme}.framework" \\
          -debug-symbols #{File.expand_path(".build/archives/#{framework.scheme}-iOS-simulator.xcarchive/dSYMs/#{framework.scheme}.framework.dSYM")} \\
          -output ".build/intermediates/#{framework.scheme}.xcframework"
      COMMAND

      system(command, exception: true)
    end
  end
end

# Utility to prepare SPM artefacts.
class SPM
  def initialize(version)
    @version = version
  end

  def generate_artefacts
    Framework.all.each do |framework|
      create_zip_file(framework)
      create_checksum_file(framework)
    end

    create_config_file
  end

  private

  def create_zip_file(framework)
    FileUtils.cp_r ".build/intermediates/#{framework.scheme}.xcframework", '.build/tmp'
    Bob.zip(working_directory: '.build/tmp',
            files: "#{framework.scheme}.xcframework",
            output: "../outputs/#{framework.spm_zip_filename}")
  end

  def create_config_file
    config_file = File.read '.github/templates/Package.swift'
    config_file = config_file.gsub(/{{(.*?)}}/) do |key|
      if key == '{{VERSION}}'
        @version
      else
        framework = Framework.all.find { |f| f.spm_checksum_placeholder == key }
        calculate_checksum(framework)
      end
    end

    File.write 'Package.swift', config_file
  end

  def calculate_checksum(framework)
    `swift package compute-checksum .build/outputs/#{framework.spm_zip_filename}`.strip
  end

  def create_checksum_file(framework)
    File.write ".build/outputs/#{framework.spm_zip_filename}.checksum.txt", calculate_checksum(framework)
  end
end

# Utility to prepare Cocoapods artefacts.
class Cocoapods
  def initialize(version)
    @version = version
  end

  def generate_artefacts
    prepare_temp_folder
    create_zip_file
    create_config_file
  end

  def create_config_file
    config_file = File.read '.github/templates/Notificare.podspec'
    config_file = config_file.gsub(/{{(.*?)}}/) do |key|
      @version if key == '{{VERSION}}'
    end

    File.write 'Notificare.podspec', config_file
  end

  private

  def prepare_temp_folder
    FileUtils.mkdir_p '.build/tmp/Notificare'
    FileUtils.cp 'LICENSE', '.build/tmp/Notificare'
    Framework.all.each { |f| FileUtils.cp_r ".build/intermediates/#{f.scheme}.xcframework", '.build/tmp/Notificare' }
  end

  def create_zip_file
    Bob.zip(working_directory: '.build/tmp',
            files: 'Notificare',
            output: '../outputs/cocoapods.zip')
  end
end

#
# Do the work. 🛠️
#
Bob.new.work
