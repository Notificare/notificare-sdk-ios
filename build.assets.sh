#!/bin/sh

# ----------------------------------
# BUILD PLATFORM SPECIFIC FRAMEWORKS
# ----------------------------------

# iOS devices
xcodebuild archive \
    -workspace Notificare.xcworkspace \
    -scheme NotificareAssets \
    -archivePath ".build/NotificareAssets-iOS.xcarchive" \
    -destination "generic/platform=iOS" \
    -sdk iphoneos \
    -quiet \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# iOS simulators
xcodebuild archive \
    -workspace Notificare.xcworkspace \
    -scheme NotificareAssets \
    -archivePath ".build/NotificareAssets-iOS-simulator.xcarchive" \
    -destination "generic/platform=iOS Simulator" \
    -sdk iphonesimulator \
    -quiet \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# Build the xcframework
xcodebuild -create-xcframework \
    -framework ".build/NotificareAssets-iOS.xcarchive/Products/Library/Frameworks/NotificareAssets.framework" \
    -framework ".build/NotificareAssets-iOS-simulator.xcarchive/Products/Library/Frameworks/NotificareAssets.framework" \
    -output ".artefacts/NotificareAssets.xcframework"
