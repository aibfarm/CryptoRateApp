#!/bin/bash

# Test build script - Go only first
set -e

echo "🧪 Testing Go Backend Build..."

cd backend
export PATH=$PATH:/usr/local/go/bin

echo "📝 Installing Go dependencies..."
go mod tidy

echo "🔧 Building Go binary..."
go build -o ../build/crypto-exchange-api .

echo "✅ Go build test completed!"
ls -la ../build/crypto-exchange-api