#!/bin/bash

# Quick test of build system - Go backend only
set -e

echo "🧪 Quick Build Test (Go Backend Only)..."
echo "======================================="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Create build directory
echo -e "${BLUE}📁 Creating build directory...${NC}"
mkdir -p build
rm -rf build/*

# Build Go backend
echo -e "${BLUE}🔧 Building Go Backend...${NC}"
cd backend
export PATH=$PATH:/usr/local/go/bin
go mod tidy
go build -o ../build/crypto-exchange-api .
cd ..

# Check results
if [ -f "build/crypto-exchange-api" ]; then
    API_SIZE=$(du -h build/crypto-exchange-api | cut -f1)
    echo -e "${GREEN}✅ Go Backend Built Successfully!${NC}"
    echo -e "${BLUE}📏 Binary Size:${NC} $API_SIZE"
    echo ""
    echo -e "${BLUE}📝 To run the API:${NC}"
    echo "./build/crypto-exchange-api"
else
    echo "❌ Build failed!"
    exit 1
fi