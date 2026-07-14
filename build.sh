#!/bin/bash
# build.sh - Local build script for Viper Android FX Driver

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Viper Android FX Driver Build Script ===${NC}"

# Check if NDK is set
if [ -z "$ANDROID_NDK" ]; then
    echo -e "${RED}Error: ANDROID_NDK environment variable not set${NC}"
    echo "Usage: export ANDROID_NDK=/path/to/android-ndk && ./build.sh"
    exit 1
fi

# Check if CMake is installed
if ! command -v cmake &> /dev/null; then
    echo -e "${RED}Error: CMake not found. Please install CMake.${NC}"
    exit 1
fi

# Build configurations
ABIS=("arm64-v8a" "armeabi-v7a" "x86_64" "x86")
BUILD_TYPE="Release"

echo -e "${YELLOW}NDK Path: $ANDROID_NDK${NC}"
echo -e "${YELLOW}Build Type: $BUILD_TYPE${NC}"
echo -e "${YELLOW}Target ABIs: ${ABI[@]}${NC}"
echo ""

# Create build directories and compile
for abi in "${ABS[@]}"; do
    BUILD_DIR="build-$abi"
    
    echo -e "${YELLOW}Building for $abi...${NC}"
    
    # Clean previous build
    rm -rf $BUILD_DIR
    mkdir -p $BUILD_DIR
    
    cd $BUILD_DIR
    
    # Configure with CMake
    cmake .. \
        -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
        -DANDROID_ABI=$abi \
        -DANDROID_PLATFORM=android-21 \
        -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
        -G Ninja
    
    # Build
    ninja
    
    cd ..
    
    echo -e "${GREEN}✓ Built for $abi${NC}"
    echo ""
done

echo -e "${GREEN}=== All builds completed successfully! ===${NC}"
echo ""
echo -e "${YELLOW}Built libraries:${NC}"
for abi in "${ABS[@]}"; do
    if [ -f "libs/$abi/libviper_audio.so" ]; then
        size=$(du -h "libs/$abi/libviper_audio.so" | cut -f1)
        echo -e "  ${GREEN}✓${NC} libs/$abi/libviper_audio.so ($size)"
    fi
done

echo ""
echo -e "${YELLOW}To create a Magisk module:${NC}"
echo "  ./package_module.sh"
