# Flutter Build Environment
FROM openjdk:17-jdk-slim AS flutter-builder

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
ENV FLUTTER_VERSION=3.16.9
RUN curl -LO https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz && \
    tar xf flutter_linux_${FLUTTER_VERSION}-stable.tar.xz && \
    mv flutter /opt/ && \
    rm flutter_linux_${FLUTTER_VERSION}-stable.tar.xz

# Install Android SDK
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH="$PATH:/opt/flutter/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"

RUN mkdir -p $ANDROID_HOME && \
    curl -LO https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip && \
    unzip commandlinetools-linux-9477386_latest.zip -d $ANDROID_HOME && \
    mkdir -p $ANDROID_HOME/cmdline-tools/latest && \
    mv $ANDROID_HOME/cmdline-tools/* $ANDROID_HOME/cmdline-tools/latest/ 2>/dev/null || true && \
    rm commandlinetools-linux-9477386_latest.zip

# Accept licenses and install SDK components
RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"

WORKDIR /app
COPY . .

RUN flutter pub get && \
    flutter build apk --release

# Final stage with shell for extraction
FROM alpine:latest
COPY --from=flutter-builder /app/build/app/outputs/flutter-apk/app-release.apk /app/build/app/outputs/flutter-apk/app-release.apk