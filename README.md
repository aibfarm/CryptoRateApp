# 🚀 Crypto Exchange Rate App

A complete cryptocurrency exchange rate application featuring a Go backend API and Flutter mobile app, showing real-time USDT/BTC exchange rates from Binance.

## 📋 Features

- **Real-time Exchange Rates**: Fetches live USDT/BTC rates from Binance API
- **Cross-platform Mobile App**: Flutter app with auto-refresh every 30 seconds
- **RESTful Go API**: High-performance backend with comprehensive logging
- **Docker Support**: Containerized builds and deployment
- **One-command Build**: Automated build system for both backend and mobile app
- **Production Ready**: Optimized builds with proper error handling

## 🏗️ Project Structure

```
crypto-exchange-app/
├── backend/                 # Go API server
│   ├── main.go             # Main API server code
│   ├── go.mod              # Go dependencies
│   ├── go.sum              # Go dependency checksums
│   └── Dockerfile          # Go API Docker build
├── mobile/                 # Flutter mobile app
│   ├── lib/                # Flutter source code
│   ├── android/            # Android build configuration
│   ├── pubspec.yaml        # Flutter dependencies
│   └── Dockerfile          # Flutter build environment
├── scripts/                # Build and utility scripts
│   └── build.sh            # Main build script
├── build/                  # Generated build artifacts
├── .github/workflows/      # GitHub Actions CI/CD
├── docker-compose.build.yml # Docker build configuration
├── build.sh               # Quick build script
└── README.md              # This file
```

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose
- Git

### One-Command Build

```bash
# Clone the repository
git clone <your-repo-url>
cd crypto-exchange-app

# Build everything (Go binary + Android APK)
./build.sh
```

This will create:
- `build/crypto-exchange-api` - Go backend binary
- `build/crypto-exchange-app.apk` - Android APK file

### Running the Application

#### Option 1: Using Docker Compose (Recommended)
```bash
# Start the API server
docker-compose -f docker-compose.build.yml up api-server

# The API will be available at http://localhost:8080
```

#### Option 2: Direct Binary Execution
```bash
# Run the Go API server directly
./build/crypto-exchange-api

# Install APK on Android device
adb install build/crypto-exchange-app.apk
```

## 🔧 Development

### Local Development Setup

#### Backend Development
```bash
cd backend
go mod tidy
go run main.go
```

#### Mobile Development
```bash
cd mobile
flutter pub get
flutter run
```

### API Endpoints

- `GET /health` - Health check
- `GET /api/exchange-rate/usdt-btc` - Get current USDT/BTC exchange rate

#### Example API Response
```json
{
  "symbol": "USDT/BTC",
  "price": "43250.50",
  "rate": 0.00002312,
  "time": "2023-12-16T10:30:45Z"
}
```

## 🐳 Docker Usage

### Building Images
```bash
# Build backend only
docker build -t crypto-exchange-backend ./backend

# Build mobile app only
docker build -t crypto-exchange-mobile ./mobile

# Build everything with Docker Compose
docker-compose -f docker-compose.build.yml build
```

### Running with Docker Compose
```bash
# Production deployment
docker-compose -f docker-compose.build.yml up -d api-server
```

## 📱 Mobile App Configuration

The Flutter app automatically connects to the API server. For different environments:

### Local Development
- API URL: `http://10.0.2.2:8080` (Android Emulator)
- API URL: `http://localhost:8080` (iOS Simulator)

### Production/Device
- Update the API URL in `mobile/lib/main.dart` to your server's IP address
- Example: `http://192.168.1.100:8080`

## 🔧 Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `GIN_MODE` | Gin framework mode | `debug` |
| `PORT` | API server port | `8080` |

### Customizing API URL

1. **For Development**: Edit `mobile/lib/main.dart`
2. **For Production**: Use environment variables or config files

## 📊 Logging

### Backend Logs
```bash
# View real-time logs
docker logs -f crypto-api-server

# Or if running directly
tail -f api.log
```

### Mobile App Logs
```bash
# Android device logs
adb logcat | grep -E "(Flutter|flutter)"
```

## 🚀 Deployment

### GitHub Actions CI/CD

The repository includes GitHub Actions workflows for:
- Automated testing
- Building Docker images
- Creating releases with APK artifacts
- Multi-platform builds (Android/iOS)

### Manual Deployment

1. **Build the application**:
   ```bash
   ./build.sh
   ```

2. **Deploy the API server**:
   ```bash
   # Copy binary to server
   scp build/crypto-exchange-api user@server:/opt/crypto-exchange/
   
   # Or use Docker
   docker-compose -f docker-compose.build.yml up -d api-server
   ```

3. **Distribute the mobile app**:
   - Upload `build/crypto-exchange-app.apk` to your distribution platform
   - Or install directly: `adb install build/crypto-exchange-app.apk`

## 🔍 Troubleshooting

### Common Issues

1. **Connection refused**: Check if API server is running and accessible
2. **Build failures**: Ensure Docker has sufficient memory allocated
3. **APK install fails**: Enable "Unknown sources" in Android settings

### Debug Mode

```bash
# Run API in debug mode
cd backend && go run main.go

# View Flutter logs
cd mobile && flutter logs
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes
4. Run tests: `./scripts/test.sh`
5. Build and verify: `./build.sh`
6. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Binance API](https://binance-docs.github.io/apidocs/) for real-time cryptocurrency data
- [Flutter](https://flutter.dev/) for cross-platform mobile development
- [Gin](https://gin-gonic.com/) for the Go web framework
- [Docker](https://www.docker.com/) for containerization

---

## 📞 Support

For support and questions:
- Open an issue on GitHub
- Check the [troubleshooting section](#-troubleshooting)
- Review the logs for detailed error information

Built with ❤️ using Go and Flutter