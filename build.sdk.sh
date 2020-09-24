#!/bin/sh

# ----------------------------------
# BUILD PLATFORM SPECIFIC FRAMEWORKS
# ----------------------------------

# iOS devices
xcodebuild archive \
    -workspace Notificare.xcworkspace \
    -scheme NotificareSDK \
    -archivePath ".build/NotificareSDK-iOS.xcarchive" \
    -destination "generic/platform=iOS" \
    -sdk iphoneos \
    -quiet \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# iOS simulators
xcodebuild archive \
    -workspace Notificare.xcworkspace \
    -scheme NotificareSDK \
    -archivePath ".build/NotificareSDK-iOS-simulator.xcarchive" \
    -destination "generic/platform=iOS Simulator" \
    -sdk iphonesimulator \
    -quiet \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# Build the xcframework
xcodebuild -create-xcframework \
    -framework ".build/NotificareSDK-iOS.xcarchive/Products/Library/Frameworks/NotificareSDK.framework" \
    -framework ".build/NotificareSDK-iOS-simulator.xcarchive/Products/Library/Frameworks/NotificareSDK.framework" \
    -output ".artefacts/NotificareSDK.xcframework"
