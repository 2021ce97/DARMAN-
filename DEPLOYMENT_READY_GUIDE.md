# 🚀 DARMAN Deployment Guide

**Ready to Deploy DARMAN to Production?**

This guide will help you prepare everything for a successful production launch.

---

## 📋 Pre-Deployment Checklist

### 1. Backend Health Verification
```bash
# Test if Render backend is responding
curl https://darman-api.onrender.com/health

# If it times out, check Render dashboard:
# https://dashboard.render.com
# - Find service "darman-api"
# - Check logs for errors
# - Redeploy if necessary
```

### 2. Firebase Configuration
```bash
# Verify Firebase project is active
firebase projects:list

# Current project: mediconnect-4b155
# Region: asia-south1

# Check if deployed
firebase hosting:list
```

### 3. Environment Variables Status
- Backend Render vars: ✅ Configured (need real API keys)
- Firebase credentials: ✅ Configured
- App Check: ⚠️ Needs ReCAPTCHA v3 site key
- API keys needed:
  - [ ] Gemini API key (Google AI Studio)
  - [ ] Agora App ID & Certificate
  - [ ] HesabPay credentials
  - [ ] JWT Secret (already generated)

---

## 🔑 Production Credentials Setup

### Step 1: Change Demo Credentials

**Current demo users** (MUST change):
- `patient@darman.af` / `Darman2026!`
- `doctor@darman.af` / `Darman2026!`
- `admin@darman.af` / `Darman2026!`

**To change in Firebase**:
```bash
cd backend
node src/scripts/create-test-user.js
# Edit the script to use new credentials
```

### Step 2: Configure API Keys

#### Google Gemini (AI Chatbot)
1. Go to https://aistudio.google.com/app/apikey
2. Create API key
3. Add to Render env vars:
```
GEMINI_API_KEY=<your-key>
```

#### Agora (Video Calls)
1. Go to https://console.agora.io
2. Create project
3. Get App ID & Certificate
4. Add to Render env vars:
```
AGORA_APP_ID=<your-app-id>
AGORA_APP_CERTIFICATE=<your-certificate>
```

#### HesabPay (Payments)
1. Go to https://hesabpay.com
2. Register merchant account
3. Get API key & Merchant ID
4. Add to Render env vars:
```
HESABPAY_API_KEY=<your-key>
HESABPAY_MERCHANT_ID=<your-id>
HESABPAY_BASE_URL=https://api.hesabpay.com
```

### Step 3: Render Environment Variables
```bash
# Update these on Render dashboard:
https://dashboard.render.com/services

# Service: darman-api
# Variables to update:
GEMINI_API_KEY=<value>
AGORA_APP_ID=<value>
AGORA_APP_CERTIFICATE=<value>
HESABPAY_API_KEY=<value>
HESABPAY_MERCHANT_ID=<value>
HESABPAY_BASE_URL=<value>
```

---

## 📱 Mobile App Builds

### Generate Android APK

```bash
cd medi_connect

# Clean build
flutter clean

# Get dependencies
flutter pub get

# Build APK (release)
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
# Size: ~50-80 MB

# Upload to Play Store or send to users
```

### Generate Play Store Bundle

```bash
cd medi_connect

# Build App Bundle (for Play Store)
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
# Size: ~40-60 MB
```

### Build iOS App (requires Mac)

```bash
cd medi_connect

# Build iOS release
flutter build ios --release

# Then open in Xcode:
open ios/Runner.xcworkspace
# Archive and upload to App Store
```

### Signing Configuration (Android)

**File**: `medi_connect/android/app/build.gradle.kts`

Currently uses debug signing. For release:

```gradle
signingConfigs {
    release {
        storeFile = file("keystore.jks")
        storePassword = "your-password"
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

---

## 🌐 Web App Redeployment

### Deploy to Firebase Hosting

```bash
cd medi_connect

# Build web app
flutter build web --release

# Deploy to Firebase
firebase deploy --only hosting --project mediconnect-4b155

# Wait for deployment (1-2 minutes)
# View at: https://mediconnect-4b155.web.app
```

### Deployment Verification

```bash
# Test production endpoints
curl https://mediconnect-4b155.web.app/

# Check if assets loaded
curl https://mediconnect-4b155.web.app/index.html
```

---

## 🔐 Security Hardening

### 1. Firestore Security Rules

**Current status**: Basic rules in place  
**Needed**: Comprehensive rules for production

```bash
# Review rules
cat firestore.rules

# Deploy rules
firebase deploy --only firestore:rules

# Test rules in Firestore Console
```

### 2. Firebase App Check

```bash
# Configure App Check
firebase projects:list

# Enable in Firebase Console:
# 1. Go to App Check section
# 2. Register your app
# 3. Add reCAPTCHA v3 site key
# 4. Deploy with App Check enabled
```

### 3. Storage Rules

```bash
# Review rules
cat storage.rules

# Deploy
firebase deploy --only storage
```

### 4. Admin MFA

In Firebase Console:
1. Go to Authentication → Settings
2. Enable MFA for admin user
3. Test 2FA setup

---

## ✅ Testing Before Launch

### 1. Smoke Tests

```bash
# Backend
curl https://darman-api.onrender.com/health

# Web app
curl https://mediconnect-4b155.web.app

# Firebase Hosting
firebase hosting:channel:list
```

### 2. Feature Testing Checklist

**Authentication**
- [ ] Login as patient
- [ ] Login as doctor
- [ ] Login as admin
- [ ] Redirect works correctly
- [ ] Logout works

**Patient Features**
- [ ] Browse doctors
- [ ] Search by specialty
- [ ] View doctor profile
- [ ] Book appointment
- [ ] Make payment
- [ ] View health records
- [ ] Chat with doctor
- [ ] Video consultation

**Doctor Features**
- [ ] Doctor registration
- [ ] View appointments
- [ ] Accept/reject appointments
- [ ] Write prescription
- [ ] View patient list
- [ ] Video consultation

**Admin Features**
- [ ] View users
- [ ] View bookings
- [ ] See analytics
- [ ] Audit logs
- [ ] User management

### 3. Performance Testing

```bash
# Test load times
time curl https://mediconnect-4b155.web.app

# Monitor backend
curl https://darman-api.onrender.com/metrics

# Check Firebase metrics in Console
```

### 4. Cross-Browser Testing

Test on:
- [ ] Chrome (desktop)
- [ ] Firefox (desktop)
- [ ] Safari (desktop)
- [ ] Chrome (mobile)
- [ ] Safari (iOS)
- [ ] Custom Android app

---

## 🚨 Troubleshooting

### Backend Not Responding

```bash
# Check Render logs
# https://dashboard.render.com/services/darman-api

# Redeploy
git push origin main  # Triggers auto-deploy

# Manual redeploy
# 1. Go to Render dashboard
# 2. Find darman-api service
# 3. Click "Deploy"
# 4. Wait for build to complete
```

### Web App Not Updating

```bash
# Clear Firebase cache
firebase hosting:channel:delete preview

# Rebuild and redeploy
cd medi_connect
flutter clean
flutter build web --release
firebase deploy --only hosting
```

### Firebase Connectivity Issues

```bash
# Check network connectivity
firebase emulators:start

# Or test with curl
curl -H "Authorization: Bearer YOUR_TOKEN" \
  https://firestore.googleapis.com/v1/projects/mediconnect-4b155/databases
```

### Payment/Video/AI Not Working

1. Check Render env vars are set
2. Verify API keys are valid
3. Check backend logs: `firebase functions:log`
4. Test endpoints directly:

```bash
# Test AI
curl -X POST https://darman-api.onrender.com/api/v1/ai/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello"}'

# Test video
curl -X POST https://darman-api.onrender.com/api/v1/consultation/token \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## 📊 Monitoring & Maintenance

### Set Up Monitoring

**Render Dashboard**:
- Monitor CPU & memory usage
- Check error rates
- Review logs

**Firebase Console**:
- Monitor Firestore usage
- Check Storage quota
- Review Auth metrics
- Monitor Hosting traffic

**Third-party Monitoring**:
- Consider: Sentry, DataDog, or New Relic
- Set up alerts for errors

### Regular Maintenance

**Daily**:
- [ ] Check backend health
- [ ] Review error logs
- [ ] Monitor payment transactions

**Weekly**:
- [ ] Review analytics
- [ ] Check user feedback
- [ ] Monitor performance metrics

**Monthly**:
- [ ] Update dependencies
- [ ] Review security logs
- [ ] Optimize database indexes
- [ ] Clean up old files in Storage

---

## 📞 Deployment Support

If you encounter issues:

1. **Check logs**: Firebase Console → Logging
2. **Test endpoints**: Use curl or Postman
3. **Review rules**: Check Firestore/Storage rules
4. **Verify credentials**: Confirm all env vars are set
5. **Ask Claude**: For debugging help

---

## 🎯 Final Steps

### Before Going Live

```bash
# 1. Commit all changes
git add -A
git commit -m "release: production deployment v1.0.0"
git push origin main

# 2. Create git tag
git tag -a v1.0.0 -m "Release v1.0.0 - Production Deployment"
git push origin v1.0.0

# 3. Notify stakeholders
# Update status: https://mediconnect-4b155.web.app/

# 4. Enable monitoring
# Set up alerts for errors
```

### Day 1 Monitoring

- [ ] Monitor error rates
- [ ] Track active users
- [ ] Check payment success rate
- [ ] Review video call quality
- [ ] Monitor API response times
- [ ] Check Firestore performance

### Week 1 Monitoring

- [ ] Weekly performance report
- [ ] User feedback collection
- [ ] Bug fixes and patches
- [ ] Performance optimization
- [ ] User documentation updates

---

## 🎉 Congratulations!

Your DARMAN healthcare platform is now **PRODUCTION READY** for Afghanistan!

**Next Phase**: Monitor, optimize, and prepare for Phase 3 features (hospital/lab/pharmacy portals).

---

*Deployment Guide v1.0*  
*Last Updated: 2026-05-15*
