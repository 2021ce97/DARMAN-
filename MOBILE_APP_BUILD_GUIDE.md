# 📱 DARMAN Mobile App Build Guide

**How to Generate APK, AAB, and iOS App**

---

## ⚡ Quick Commands

### Generate Android APK (Release)
```bash
cd medi_connect
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Generate Play Store Bundle (AAB)
```bash
cd medi_connect
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### Build iOS App (Mac only)
```bash
cd medi_connect
flutter build ios --release
# Open in Xcode: open ios/Runner.xcworkspace
```

---

## 📋 Prerequisites

### For Android
- ✅ Android SDK installed
- ✅ Java Development Kit (JDK)
- ✅ Environment variables configured
- ✅ Gradle configured

**Check Status**:
```bash
flutter doctor -v
# Should show Android SDK ✓
```

### For iOS (Mac only)
- ✅ Xcode installed
- ✅ CocoaPods installed
- ✅ iOS deployment target: 11.0+

**Check Status**:
```bash
flutter doctor -v
# Should show Xcode ✓
```

---

## 🔄 Full Build Process for APK

### Step 1: Prepare
```bash
cd medi_connect

# Clean previous builds
flutter clean

# Get dependencies
flutter pub get
```

### Step 2: Build APK
```bash
# Build release APK
flutter build apk --release

# This will:
# - Compile Dart code
# - Build native libraries
# - Create APK package
# - Show progress in console

# Wait 2-5 minutes depending on machine speed
```

### Step 3: Verify Build
```bash
# Check if APK was created
ls -la build/app/outputs/flutter-apk/

# Should show: app-release.apk (50-80 MB)
```

### Step 4: Test APK
```bash
# Install on connected Android device
flutter install --release

# Or manually:
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## 📦 Play Store Bundle (AAB)

### Why AAB?
- Smaller download size for users
- Google Play automatically generates APKs per device configuration
- Better optimization
- Required for new apps on Play Store

### Build AAB
```bash
cd medi_connect

# Build App Bundle
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
# Size: 40-60 MB (smaller than APK)
```

### Upload to Play Store
1. Go to https://play.google.com/console
2. Create new app (if not already)
3. Upload AAB file:
   - Production > Release > Create new release
   - Upload app-release.aab
4. Fill in store listing (description, screenshots, etc.)
5. Submit for review (usually 2-24 hours)

---

## 🍎 iOS App Build (Mac Required)

### Prerequisites on Mac
```bash
# Install Xcode
xcode-select --install

# Install CocoaPods
sudo gem install cocoapods

# Verify installation
flutter doctor -v
```

### Build iOS App
```bash
cd medi_connect

# Build iOS release
flutter build ios --release

# This will:
# - Compile for iOS
# - Build native libraries
# - Create app bundle

# Wait 5-10 minutes
```

### Archive and Upload
```bash
# Open in Xcode
open ios/Runner.xcworkspace

# In Xcode:
# 1. Select Product > Archive
# 2. Wait for build
# 3. Click "Distribute App"
# 4. Select "App Store Connect"
# 5. Follow upload wizard
# 6. Submit for review
```

---

## 🔐 Signing Configuration

### Current Status
- Uses debug signing keys
- Not suitable for production/store releases

### Create Release Keystore (Android)

```bash
# Generate keystore file
keytool -genkey -v -keystore ~/keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias mediconnect

# This will ask for:
# - Password (remember this!)
# - Key password (same as above)
# - Your name, organization, etc.

# It creates: ~/keystore.jks (keep this safe!)
```

### Configure Flutter to Use Keystore

**File**: `medi_connect/android/app/build.gradle.kts`

```gradle
signingConfigs {
    release {
        storeFile = file(System.getenv('HOME') + "/keystore.jks")
        storePassword = "your-keystore-password"
        keyAlias = "mediconnect"
        keyPassword = "your-key-password"
    }
}

buildTypes {
    release {
        signingConfig = signingConfigs.release
    }
}
```

### Or Use Environment Variables (More Secure)

```bash
# Set environment variables
export KEYSTORE_PATH=~/keystore.jks
export KEYSTORE_PASSWORD=your-password
export KEY_ALIAS=mediconnect
export KEY_PASSWORD=your-password

# Then build
flutter build apk --release
```

---

## 🎯 Build Optimization

### Reduce APK Size

```bash
# Build with obfuscation (slightly smaller, harder to reverse-engineer)
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols

# Build split APKs by ABI (much smaller individual files)
flutter build apk --release --split-per-abi
# Creates: app-armeabi-v7a-release.apk, app-arm64-v8a-release.apk, etc.
```

### Enable Compression

Dart already uses compression, but ensure:
```bash
# In android/app/build.gradle.kts
buildTypes {
    release {
        // Already optimized by Flutter
        signingConfig = signingConfigs.release
    }
}
```

---

## 🧪 Testing the Built App

### Test on Emulator
```bash
# List available emulators
flutter emulators

# Run specific emulator
flutter emulators launch <emulator_name>

# Install app
flutter install --release
```

### Test on Real Device
```bash
# Enable USB Debugging on Android device
# Connect device via USB

# List connected devices
flutter devices

# Install and run
flutter install --release
flutter run --release
```

### Test APK Directly
```bash
# Using adb (Android Debug Bridge)
adb install -r build/app/outputs/flutter-apk/app-release.apk

# Verify installation
adb shell pm list packages | grep medi_connect
```

---

## 📊 Build Status Checker

### Check What's Needed

```bash
cd medi_connect
flutter doctor -v

# Look for:
# ✓ Flutter (version 3.41.9)
# ✓ Android toolchain
# ✓ Android SDK
# ✓ Connected devices (or emulator)
```

### Troubleshooting Common Issues

#### "Flutter not found"
```bash
# Add Flutter to PATH
# Windows: Add C:\path\to\flutter\bin to PATH
# Mac/Linux: Add ~/flutter/bin to PATH
flutter --version
```

#### "Android SDK not found"
```bash
# Set ANDROID_HOME
export ANDROID_HOME=~/Android/Sdk
flutter config --android-sdk ~/Android/Sdk
```

#### "Java not found"
```bash
# Install JDK 11 or later
# Verify installation
java -version

# Or use Flutter's bundled Java
export JAVA_HOME=~/Android/Studio/jre
```

---

## 📦 Publish to App Stores

### Google Play Store

1. **Developer Account**: https://play.google.com/console
   - Cost: $25 one-time
   - Create account

2. **App Listing**:
   - App name: DARMAN
   - Package ID: com.example.medi_connect (from build.gradle.kts)
   - Description, screenshots, category

3. **Upload APK/AAB**:
   - Use AAB (preferred)
   - Size: 40-60 MB

4. **Review & Launch**:
   - Google reviews (2-24 hours)
   - Goes live if approved

### Apple App Store

1. **Developer Account**: https://developer.apple.com
   - Cost: $99/year
   - Create account

2. **App Bundle ID**: com.example.mediConnect
3. **App Certificate**: Required
4. **Upload via Xcode**: TestFlight first, then Production

---

## 📋 Release Checklist

Before building for production:

- [ ] Update version in pubspec.yaml (e.g., 1.0.0+1)
- [ ] Update app icon: `medi_connect/android/app/src/main/AndroidManifest.xml`
- [ ] Update splash screen
- [ ] Run flutter test
- [ ] Test all features on real device
- [ ] Create keystore file
- [ ] Configure signing
- [ ] Build APK for testing
- [ ] Test APK on multiple devices
- [ ] Build AAB for Play Store
- [ ] Upload to Play Store
- [ ] Fill in store listing
- [ ] Submit for review
- [ ] Monitor review status

---

## 🚀 Quick Reference

| Task | Command |
|------|---------|
| Build APK | `flutter build apk --release` |
| Build AAB | `flutter build appbundle --release` |
| Build iOS | `flutter build ios --release` |
| Clean | `flutter clean` |
| Get deps | `flutter pub get` |
| Test app | `flutter test` |
| Run debug | `flutter run` |
| Check status | `flutter doctor -v` |
| Install APK | `adb install app-release.apk` |

---

## 📁 Build Outputs

After building, find your files here:

```
medi_connect/
├── build/
│   ├── app/
│   │   ├── outputs/
│   │   │   ├── flutter-apk/
│   │   │   │   ├── app-release.apk              ← Android APK
│   │   │   │   └── app-release-symbols.zip
│   │   │   ├── bundle/
│   │   │   │   └── release/
│   │   │   │       └── app-release.aab          ← Play Store Bundle
│   │   │   └── apks/                            ← Split APKs
│   │   └── (other build artifacts)
│   └── ios/
│       └── (iOS build artifacts)
```

---

## ✅ Next Steps

1. **Generate APK**: Run the quick command above
2. **Test Locally**: Install on Android device/emulator
3. **Generate AAB**: For Play Store submission
4. **Submit to Play Store**: Via Play Console
5. **Build iOS**: On Mac (if available)
6. **Submit to App Store**: Via App Store Connect

---

## 💡 Tips

- **First build is slowest**: Subsequent builds are faster
- **Use split APKs**: For testing (faster builds)
- **Use AAB for store**: Smaller, better optimization
- **Test thoroughly**: Before submitting to stores
- **Keep keystore safe**: It's needed for all future updates
- **Version numbers**: Increment before each store submission

---

## 🆘 Getting Help

If build fails:
1. Run `flutter clean`
2. Run `flutter pub get`
3. Run `flutter doctor -v` to identify issues
4. Check build output for specific errors
5. Search Flutter documentation or Stack Overflow

---

*Mobile Build Guide v1.0*  
*Last Updated: 2026-05-15*
