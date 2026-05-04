# 🏥 MediConnect - Healthcare Platform for Afghanistan

A comprehensive healthcare platform connecting patients with doctors, featuring AI health assistance, video consultations, and integrated payment systems.

## 🎯 Project Status

- ✅ **Phase 1:** Complete (User Auth, Doctor Discovery, Booking)
- ✅ **Phase 2:** Complete (Payments, AI Chat, Video, Prescriptions, File Upload)
- 📱 **Platform:** Flutter (Web, Android, iOS)
- 🔧 **Backend:** Node.js + Express + Firebase
- 🔥 **Database:** Firebase Firestore
- 📊 **Progress:** 90% Complete

## ✨ Features

### Phase 1 Features
- 🔐 User Authentication (Email/Password + Google)
- 👨‍⚕️ Doctor Discovery & Search
- 📅 Appointment Booking
- 👤 Profile Management
- 📋 Health Records
- 🩺 Basic Symptom Checker

### Phase 2 Features (NEW!)
- 💳 **Payment Integration** - HesabPay, Card, Cash
- 🤖 **AI Health Assistant** - Chat with AI for health advice
- 📹 **Video Consultation** - Agora SDK integration
- 💊 **Prescription Management** - Digital prescriptions
- 📁 **File Upload** - Medical records, documents

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (3.0+)
- Node.js (18+)
- Firebase account

### Backend Setup
```bash
cd backend
npm install
node src/server.js
```

Server runs on: http://localhost:3000

### Flutter Setup
```bash
cd medi_connect
flutter pub get
flutter run -d chrome
```

App runs on: http://localhost:8080

## 📱 Screens

1. **Authentication**
   - Login Screen
   - Register Screen

2. **Main App**
   - Home Screen
   - Doctor Listing
   - Doctor Profile
   - Search Screen

3. **Booking & Appointments**
   - Booking Summary
   - Appointments List
   - Payment Screen (NEW!)

4. **Health Features**
   - AI Chatbot (NEW!)
   - Symptom Checker
   - Health Records
   - Medical History

5. **Profile**
   - User Profile
   - Settings
   - Help & Support

## 🔌 API Endpoints

### Authentication
- POST `/api/v1/auth/register`
- POST `/api/v1/auth/login`
- GET `/api/v1/auth/me`

### Doctors
- GET `/api/v1/doctors`
- GET `/api/v1/doctors/:id`
- GET `/api/v1/doctors/search`

### Bookings
- POST `/api/v1/bookings`
- GET `/api/v1/bookings`
- PUT `/api/v1/bookings/:id`

### Payments (NEW!)
- POST `/api/v1/payment/create`
- POST `/api/v1/payment/confirm`
- GET `/api/v1/payment/history`

### AI Chatbot (NEW!)
- POST `/api/v1/ai/chat`
- POST `/api/v1/ai/symptom-checker`
- GET `/api/v1/ai/chat/history`

### Video Consultation (NEW!)
- POST `/api/v1/consultation/:id/video/token`
- POST `/api/v1/consultation/:id/video/start`
- POST `/api/v1/consultation/:id/video/end`

### Prescriptions (NEW!)
- POST `/api/v1/prescriptions`
- GET `/api/v1/prescriptions/patient/:id`
- PUT `/api/v1/prescriptions/:id`

### File Upload (NEW!)
- POST `/api/v1/upload/profile-picture`
- POST `/api/v1/upload/medical-record`
- POST `/api/v1/upload/prescription`

**Total: 50+ API endpoints**

## 🏗️ Project Structure

```
medi_connect/
├── lib/
│   ├── config/          # API configuration
│   ├── models/          # Data models (8 models)
│   ├── services/        # API services (10 services)
│   ├── screens/         # UI screens (15 screens)
│   ├── widgets/         # Reusable widgets
│   ├── theme/           # App theme
│   └── main.dart
├── pubspec.yaml
└── README.md
```

## 🔥 Firebase Configuration

### Project Details
- **Project ID:** mediconnect-4b155
- **Region:** asia-south1 (Mumbai)
- **Services:** Auth, Firestore, Storage

### Setup
1. Create Firebase project
2. Enable Authentication (Email + Google)
3. Create Firestore database (Native mode)
4. Enable Firebase Storage
5. Download service account key
6. Configure `firebase_options.dart`

See `../FIREBASE_SETUP.md` for detailed instructions.

## 🧪 Testing

### Run Tests
```bash
flutter test
```

### Test Backend APIs
```bash
# Test doctors
curl http://localhost:3000/api/v1/doctors

# Test AI chat
curl -X POST http://localhost:3000/api/v1/ai/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello"}'
```

## 📚 Documentation

- **PHASE2_COMPLETE_FINAL.md** - Complete feature documentation
- **QUICK_START_GUIDE.md** - Quick start instructions
- **PROJECT_STATUS_SUMMARY.md** - Project status overview
- **FIREBASE_SETUP.md** - Firebase setup guide

## 🛠️ Tech Stack

### Frontend
- **Framework:** Flutter 3.0+
- **Language:** Dart
- **State Management:** Provider (ready)
- **HTTP Client:** http package
- **Firebase:** firebase_core, firebase_auth

### Backend
- **Runtime:** Node.js 18+
- **Framework:** Express.js
- **Database:** Firebase Firestore
- **Storage:** Firebase Storage
- **Authentication:** Firebase Auth + JWT

### Integrations
- **Payment:** HesabPay (mock ready)
- **AI:** Google Gemini (mock ready)
- **Video:** Agora SDK (mock ready)

## 🔜 Roadmap

### Phase 3 (Planned)
- [ ] Push notifications
- [ ] In-app messaging
- [ ] Health tracking
- [ ] Medication reminders
- [ ] Lab test booking
- [ ] Pharmacy integration
- [ ] Insurance support

### Production Deployment
- [ ] Real API keys (HesabPay, Gemini, Agora)
- [ ] Production Firestore rules
- [ ] SSL certificate
- [ ] Domain setup
- [ ] App store deployment

## 🤝 Contributing

This is a private project for Afghanistan healthcare. For questions or contributions, contact the development team.

## 📄 License

Copyright © 2026 MediConnect. All rights reserved.

## 🆘 Support

For issues or questions:
1. Check documentation in root folder
2. Review `FIRESTORE_TROUBLESHOOTING.md`
3. Contact development team

---

**Built with ❤️ for Afghanistan's healthcare system**

*Last Updated: May 3, 2026*
