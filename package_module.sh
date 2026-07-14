#!/bin/bash
# package_module.sh - Package built driver as Magisk module

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Magisk Module Packaging ===${NC}"

MODULE_VERSION=$(grep "^version=" module.prop | cut -d'=' -f2)
MODULE_ID=$(grep "^id=" module.prop | cut -d'=' -f2)
MODULE_NAME="${MODULE_ID}_${MODULE_VERSION}"

echo -e "${YELLOW}Module: $MODULE_NAME${NC}"
echo ""

# Check if libraries exist
echo -e "${YELLOW}Checking for built libraries...${NC}"
for abi in arm64-v8a armeabi-v7a x86_64 x86; do
    if [ ! -f "libs/$abi/libviper_audio.so" ]; then
        echo -e "${RED}Error: Missing library for $abi. Run ./build.sh first.${NC}"
        exit 1
    fi
done
echo -e "${GREEN}✓ All libraries found${NC}"
echo ""

# Create module structure
echo -e "${YELLOW}Creating module structure...${NC}"
MODDIR="$MODULE_NAME"

rm -rf $MODDIR
mkdir -p $MODDIR/lib64/arm64-v8a
mkdir -p $MODDIR/lib64/armeabi-v7a
mkdir -p $MODDIR/lib64/x86_64
mkdir -p $MODDIR/lib64/x86
mkdir -p $MODDIR/config
mkdir -p $MODDIR/data

echo -e "${GREEN}✓ Module directory created${NC}"
echo ""

# Copy module files
echo -e "${YELLOW}Copying module files...${NC}"
cp module.prop $MODDIR/
cp module/post-fs-data.sh $MODDIR/post-fs-data.sh
cp module/service.sh $MODDIR/service.sh
cp module/install.sh $MODDIR/install.sh
echo -e "${GREEN}✓ Module scripts copied${NC}"

# Copy libraries
echo -e "${YELLOW}Copying compiled libraries...${NC}"
cp libs/arm64-v8a/libviper_audio.so $MODDIR/lib64/arm64-v8a/
cp libs/armeabi-v7a/libviper_audio.so $MODDIR/lib64/armeabi-v7a/
cp libs/x86_64/libviper_audio.so $MODDIR/lib64/x86_64/
cp libs/x86/libviper_audio.so $MODDIR/lib64/x86/
echo -e "${GREEN}✓ Libraries copied${NC}"
echo ""

# Set permissions
echo -e "${YELLOW}Setting permissions...${NC}"
find $MODDIR -type f -exec chmod 0644 {} \;
find $MODDIR -type d -exec chmod 0755 {} \;
echo -e "${GREEN}✓ Permissions set${NC}"
echo ""

# Create ZIP file
echo -e "${YELLOW}Creating Magisk module ZIP...${NC}"
cd $MODDIR
zip -r ../${MODULE_NAME}.zip . > /dev/null
cd ..
echo -e "${GREEN}✓ ZIP file created${NC}"
echo ""

# Verify ZIP
ZIP_SIZE=$(du -h "${MODULE_NAME}.zip" | cut -f1)
ZIP_ENTRIES=$(unzip -l "${MODULE_NAME}.zip" | tail -1 | awk '{print $2}')

echo -e "${GREEN}=== Packaging Complete ===${NC}"
echo ""
echo -e "${YELLOW}Module Information:${NC}"
echo -e "  Name: $MODULE_NAME"
echo -e "  File: ${MODULE_NAME}.zip"
echo -e "  Size: $ZIP_SIZE"
echo -e "  Entries: $ZIP_ENTRIES files/directories"
echo ""
echo -e "${YELLOW}Installation Instructions:${NC}"
echo -e "  1. Copy ${MODULE_NAME}.zip to your Android device"
echo -e "  2. Open Magisk Manager"
echo -e "  3. Tap 'Modules' → 'Install from storage'"
echo -e "  4. Select the ${MODULE_NAME}.zip file"
echo -e "  5. Reboot your device"
echo ""
echo -e "${GREEN}Ready to flash!${NC}"
