#!/bin/sh

# ----------------------------------
# BUILD PLATFORM SPECIFIC FRAMEWORKS
# ----------------------------------

# iOS devices
xcodebuild archive \
    -workspace Notificare.xcworkspace \
    -scheme NotificareScannable \
    -archivePath ".build/NotificareScannable-iOS.xcarchive" \
    -destination "generic/platform=iOS" \
    -sdk iphoneos \
    -quiet \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# iOS simulators
xcodebuild archive \
    -workspace Notificare.xcworkspace \
    -scheme NotificareScannable \
    -archivePath ".build/NotificareScannable-iOS-simulator.xcarchive" \
    -destination "generic/platform=iOS Simulator" \
    -sdk iphonesimulator \
    -quiet \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# Build the xcframework
xcodebuild -create-xcframework \
    -framework ".build/NotificareScannable-iOS.xcarchive/Products/Library/Frameworks/NotificareScannable.framework" \
    -framework ".build/NotificareScannable-iOS-simulator.xcarchive/Products/Library/Frameworks/NotificareScannable.framework" \
    -output ".artefacts/NotificareScannable.xcframework"
