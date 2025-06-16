#!/bin/bash

# Crypto Exchange Rate App - Automated Build Script
# This script builds both the Go backend and Flutter mobile app

set -e  # Exit on any error

echo "🚀 Starting Crypto Exchange Rate App Build Process..."
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create build directory
echo -e "${BLUE}📁 Creating build directory...${NC}"
mkdir -p build
rm -rf build/*

# Get the current directory
PROJECT_ROOT=$(pwd)

echo -e "${BLUE}🔧 Building Go Backend API...${NC}"
cd backend

# Test if we can build with Go directly first (faster)
if command -v go >/dev/null 2>&1; then
    echo -e "${YELLOW}📝 Building with local Go installation...${NC}"
    go mod tidy
    go build -o ../build/crypto-exchange-api .
    echo -e "${GREEN}✅ Go backend build completed with local Go!${NC}"
else
    echo -e "${YELLOW}📝 Building with Docker...${NC}"
    docker build -t crypto-exchange-backend:latest .
    # Extract binary from Docker
    CONTAINER_ID=$(docker create crypto-exchange-backend:latest)
    docker cp "$CONTAINER_ID:/root/main" ../build/crypto-exchange-api
    docker rm "$CONTAINER_ID"
    echo -e "${GREEN}✅ Go backend build completed with Docker!${NC}"
fi

chmod +x "$PROJECT_ROOT/build/crypto-exchange-api"
cd "$PROJECT_ROOT"

echo -e "${BLUE}📱 Building Flutter Mobile App...${NC}"
cd mobile

# Check if Flutter is available locally
if command -v flutter >/dev/null 2>&1; then
    echo -e "${YELLOW}📝 Building with local Flutter installation...${NC}"
    flutter pub get
    flutter build apk --release
    cp build/app/outputs/flutter-apk/app-release.apk ../build/crypto-exchange-app.apk
    echo -e "${GREEN}✅ Flutter mobile app build completed with local Flutter!${NC}"
else
    echo -e "${YELLOW}📝 Building with Docker...${NC}"
    docker build -t crypto-exchange-mobile:latest .
    
    # Extract APK from Docker using volume mount
    echo -e "${YELLOW}⚠️  Extracting APK from Docker container...${NC}"
    CONTAINER_ID=$(docker create crypto-exchange-mobile:latest)
    docker cp "$CONTAINER_ID:/app/build/app/outputs/flutter-apk/app-release.apk" ../build/crypto-exchange-app.apk
    docker rm "$CONTAINER_ID"
    echo -e "${GREEN}✅ Flutter mobile app build completed with Docker!${NC}"
fi

cd "$PROJECT_ROOT"

echo -e "${BLUE}📊 Build Summary${NC}"
echo "=================================================="
echo -e "${GREEN}✅ Go Backend Binary:${NC} build/crypto-exchange-api"
echo -e "${GREEN}✅ Android APK:${NC} build/crypto-exchange-app.apk"
echo ""

# Show file sizes
if [ -f "build/crypto-exchange-api" ]; then
    API_SIZE=$(du -h build/crypto-exchange-api | cut -f1)
    echo -e "${BLUE}📏 API Binary Size:${NC} $API_SIZE"
else
    echo -e "${RED}❌ API binary not found!${NC}"
fi

if [ -f "build/crypto-exchange-app.apk" ]; then
    APK_SIZE=$(du -h build/crypto-exchange-app.apk | cut -f1)
    echo -e "${BLUE}📏 APK Size:${NC} $APK_SIZE"
else
    echo -e "${RED}❌ APK file not found!${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Build completed successfully!${NC}"
echo ""
echo -e "${BLUE}📝 Next Steps:${NC}"
echo "1. Run the API server: ./build/crypto-exchange-api"
echo "2. Install APK on Android: adb install build/crypto-exchange-app.apk"
echo "3. Or use Docker Compose: docker-compose -f docker-compose.build.yml up api-server"
echo ""
echo -e "${YELLOW}💡 Tip: Check build/ directory for all generated artifacts${NC}"