#!/bin/sh

# Automatically exit on error.
set -e

frameworks=( "NotificareCore" "NotificareKit" "NotificarePushKit" "NotificarePushUIKit" "NotificareInboxKit" )

echo "Cleaning build folder"
rm -rf .build

clean_framework () {
  local framework=$1

  xcodebuild clean \
      -workspace Notificare.xcworkspace \
      -scheme $framework \
      -sdk iphoneos \
      -quiet
}

build_framework () {
  local framework=$1

  # iOS devices
  xcodebuild archive \
      -workspace Notificare.xcworkspace \
      -scheme $framework \
      -archivePath ".build/archives/$framework-iOS.xcarchive" \
      -destination "generic/platform=iOS" \
      -sdk iphoneos \
      -quiet \
      SKIP_INSTALL=NO \
      BUILD_LIBRARY_FOR_DISTRIBUTION=YES

  # iOS simulators
  xcodebuild archive \
      -workspace Notificare.xcworkspace \
      -scheme $framework \
      -archivePath ".build/archives/$framework-iOS-simulator.xcarchive" \
      -destination "generic/platform=iOS Simulator" \
      -sdk iphonesimulator \
      -quiet \
      SKIP_INSTALL=NO \
      BUILD_LIBRARY_FOR_DISTRIBUTION=YES

  # Build the xcframework
  xcodebuild -create-xcframework \
      -framework ".build/archives/$framework-iOS.xcarchive/Products/Library/Frameworks/$framework.framework" \
      -framework ".build/archives/$framework-iOS-simulator.xcarchive/Products/Library/Frameworks/$framework.framework" \
      -output ".build/$framework.xcframework"
}

for framework in "${frameworks[@]}"
do
	echo "Cleaning: $framework"
  clean_framework $framework
done

for framework in "${frameworks[@]}"
do
	echo "Building: $framework"
  build_framework $framework
done

rm -rf .build/archives
echo "Done."
