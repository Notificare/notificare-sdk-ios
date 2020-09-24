#!/bin/sh

# ----------------------------------
# BUILD PLATFORM SPECIFIC FRAMEWORKS
# ----------------------------------

# iOS devices
xcodebuild archive \
    -workspace Notificare.xcworkspace \
    -scheme NotificarePush \
    -archivePath ".build/NotificarePush-iOS.xcarchive" \
    -destination "generic/platform=iOS" \
    -sdk iphoneos \
    -quiet \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# iOS simulators
xcodebuild archive \
    -workspace Notificare.xcworkspace \
    -scheme NotificarePush \
    -archivePath ".build/NotificarePush-iOS-simulator.xcarchive" \
    -destination "generic/platform=iOS Simulator" \
    -sdk iphonesimulator \
    -quiet \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# Build the xcframework
xcodebuild -create-xcframework \
    -framework ".build/NotificarePush-iOS.xcarchive/Products/Library/Frameworks/NotificarePush.framework" \
    -framework ".build/NotificarePush-iOS-simulator.xcarchive/Products/Library/Frameworks/NotificarePush.framework" \
    -output ".artefacts/NotificarePush.xcframework"
