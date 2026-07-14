#!/bin/bash
# quick-build.sh - One-command build and package script

set -e

echo "====================================="
echo "Viper Android FX Driver - Quick Build"
echo "====================================="
echo ""

if [ -z "$ANDROID_NDK" ]; then
    echo "Error: ANDROID_NDK not set"
    echo "Run: export ANDROID_NDK=/path/to/android-ndk"
    exit 1
fi

echo "Step 1: Building native libraries..."
./build.sh

echo ""
echo "Step 2: Packaging Magisk module..."
./package_module.sh

echo ""
echo "====================================="
echo "Build and packaging complete!"
echo "====================================="
