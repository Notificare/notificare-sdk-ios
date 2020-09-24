#!/bin/sh

# ----------------------------------
# BUILD PLATFORM SPECIFIC FRAMEWORKS
# ----------------------------------

# iOS devices
xcodebuild archive \
    -workspace Notificare.xcworkspace \
    -scheme NotificareLoyalty \
    -archivePath ".build/NotificareLoyalty-iOS.xcarchive" \
    -destination "generic/platform=iOS" \
    -sdk iphoneos \
    -quiet \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# iOS simulators
xcodebuild archive \
    -workspace Notificare.xcworkspace \
    -scheme NotificareLoyalty \
    -archivePath ".build/NotificareLoyalty-iOS-simulator.xcarchive" \
    -destination "generic/platform=iOS Simulator" \
    -sdk iphonesimulator \
    -quiet \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# Build the xcframework
xcodebuild -create-xcframework \
    -framework ".build/NotificareLoyalty-iOS.xcarchive/Products/Library/Frameworks/NotificareLoyalty.framework" \
    -framework ".build/NotificareLoyalty-iOS-simulator.xcarchive/Products/Library/Frameworks/NotificareLoyalty.framework" \
    -output ".artefacts/NotificareLoyalty.xcframework"
