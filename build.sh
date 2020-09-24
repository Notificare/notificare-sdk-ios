#!/bin/sh

echo "Cleaning build folder"
rm -rf .build .artefacts

echo "Building: Notificare SDK"
sh build.sdk.sh

echo "Building: Notificare Assets"
sh build.assets.sh

echo "Building: Notificare Location"
sh build.location.sh

echo "Building: Notificare Loyalty"
sh build.loyalty.sh

echo "Building: Notificare Monetize"
sh build.monetize.sh

echo "Building: Notificare Push"
sh build.push.sh

echo "Building: Notificare Scannable"
sh build.scannable.sh
