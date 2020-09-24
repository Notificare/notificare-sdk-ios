#!/bin/sh

# ----------------------------------
# BUILD PLATFORM SPECIFIC FRAMEWORKS
# ----------------------------------

# iOS devices
xcodebuild archive \
    -workspace Notificare.xcworkspace \
    -scheme NotificareMonetize \
    -archivePath ".build/NotificareMonetize-iOS.xcarchive" \
    -destination "generic/platform=iOS" \
    -sdk iphoneos \
    -quiet \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# iOS simulators
xcodebuild archive \
    -workspace Notificare.xcworkspace \
    -scheme NotificareMonetize \
    -archivePath ".build/NotificareMonetize-iOS-simulator.xcarchive" \
    -destination "generic/platform=iOS Simulator" \
    -sdk iphonesimulator \
    -quiet \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# Build the xcframework
xcodebuild -create-xcframework \
    -framework ".build/NotificareMonetize-iOS.xcarchive/Products/Library/Frameworks/NotificareMonetize.framework" \
    -framework ".build/NotificareMonetize-iOS-simulator.xcarchive/Products/Library/Frameworks/NotificareMonetize.framework" \
    -output ".artefacts/NotificareMonetize.xcframework"
