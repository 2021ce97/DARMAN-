# 🏥 MediConnect (HealthLink) - Healthcare Platform for Afghanistan

A comprehensive healthcare discovery and telemedicine platform connecting patients with healthcare providers across Afghanistan.

---

## 🎉 **PROJECT STATUS: Phase 1 COMPLETE!**

✅ **Backend API**: Running on http://localhost:3000  
✅ **Flutter App**: Running on http://localhost:8080  
✅ **API Integration**: Complete  
✅ **Mock Data**: Seeded and ready  
✅ **Authentication**: Working with Firebase + Backend  
✅ **Booking System**: Functional  

---

## 📋 Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [API Documentation](#api-documentation)
- [Testing](#testing)
- [Development](#development)
- [Deployment](#deployment)
- [Contributing](#contributing)

---

## ✨ Features

### For Patients
- 🔍 **Search & Discovery**: Find doctors, hospitals, labs, and pharmacies
- 📅 **Appointment Booking**: Book in-person or online consultations
- 💬 **AI Chatbot**: Get health advice and symptom checking
- 📱 **Telemedicine**: Video consultations with doctors
- 📋 **Health Records**: Manage your medical history digitally
- 💊 **Prescriptions**: Digital prescription management
- ⭐ **Reviews & Ratings**: Read and write provider reviews
- 🔔 **Notifications**: Get reminders for appointments

### For Doctors
- 📊 **Dashboard**: Manage appointments and patients
- 🗓️ **Schedule Management**: Set availability and working hours
- 💰 **Earnings Tracking**: Monitor consultation fees
- 📝 **Digital Prescriptions**: Create and manage prescriptions
- 👥 **Patient Records**: Access patient medical history (with consent)
- 📹 **Video Consultations**: Conduct online appointments

### For Hospitals/Labs/Pharmacies
- 🏥 **Profile Management**: Showcase services and facilities
- 📍 **Location Services**: Help patients find you
- 📊 **Analytics**: Track bookings and reviews
- 💳 **Payment Integration**: Accept digital payments

---

## 🛠️ Tech Stack

### Frontend (Mobile App)
- **Framework**: Flutter 3.41.9
- **State Management**: Riverpod 3.3.1
- **Navigation**: GoRouter 17.2.2
- **UI**: Material Design 3
- **HTTP Client**: http 1.2.2
- **Local Storage**: SharedPreferences 2.3.4

### Backend (API Server)
- **Runtime**: Node.js 24.14.1
- **Framework**: Fastify 5.2.0
- **Database**: Firebase Firestore
- **Authentication**: Firebase Auth
- **Storage**: Firebase Storage
- **Cache**: Redis (optional)
- **Analytics**: PostgreSQL (optional)

### External Services
- **Firebase**: Auth, Firestore, Storage, Cloud Messaging
- **Google Gemini**: AI chatbot
- **Agora**: Video consultations
- **HesabPay**: Payment processing (Afghanistan)
- **OpenStreetMap**: Maps and location services

---

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ installed
- Flutter 3.0+ installed
- Git installed

### 1. Clone the Repository
```bash
git clone <repository-url>
cd mediconnect
```

### 2. Start Backend Server
```bash
cd backend
npm install
node src/server.js
```
✅ Server running on: http://localhost:3000

### 3. Start Flutter App
```bash
cd medi_connect
flutter pub get
flutter run -d chrome --web-port=8080
```
✅ App running on: http://localhost:8080

### 4. Test the Integration
Open http://localhost:8080 in Chrome and:
1. Register a new account
2. Browse doctors
3. Create a booking
4. View your appointments

See [TESTING_GUIDE.md](TESTING_GUIDE.md) for detailed testing instructions.

---

## 📁 Project Structure

```
mediconnect/
├── backend/                    # Node.js/Fastify backend
│   ├── src/
│   │   ├── config/            # Configuration files
│   │   │   └── firebase.js    # Firebase Admin SDK setup
│   │   ├── middleware/        # Custom middleware
│   │   │   └── auth.middleware.js
│   │   ├── routes/            # API routes (12 modules)
│   │   │   ├── auth.routes.js
│   │   │   ├── doctor.routes.js
│   │   │   ├── booking.routes.js
│   │   │   ├── consultation.routes.js
│   │   │   ├── hospital.routes.js
│   │   │   ├── lab.routes.js
│   │   │   ├── pharmacy.routes.js
│   │   │   ├── emr.routes.js
│   │   │   ├── payment.routes.js
│   │   │   ├── search.routes.js
│   │   │   ├── ai.routes.js
│   │   │   └── notification.routes.js
│   │   └── server.js          # Main server file
│   ├── .env                   # Environment variables
│   ├── .env.example           # Example environment variables
│   ├── package.json           # Dependencies
│   └── README.md              # Backend documentation
│
├── medi_connect/              # Flutter mobile app
│   ├── lib/
│   │   ├── config/           # Configuration
│   │   │   └── api_config.dart
│   │   ├── models/           # Data models (6 models)
│   │   │   ├── doctor_model.dart
│   │   │   ├── user_model.dart
│   │   │   ├── appointment_model.dart
│   │   │   ├── prescription_model.dart
│   │   │   ├── review_model.dart
│   │   │   └── notification_model.dart
│   │   ├── screens/          # UI screens (14+ screens)
│   │   │   ├── home_screen.dart
│   │   │   ├── home_screen_api.dart
│   │   │   ├── search_screen.dart
│   │   │   ├── doctor_listing_screen.dart
│   │   │   ├── doctor_profile_screen.dart
│   │   │   ├── booking_summary_screen.dart
│   │   │   ├── appointments_screen.dart
│   │   │   ├── profile_screen.dart
│   │   │   ├── health_records_screen.dart
│   │   │   ├── medical_history_screen.dart
│   │   │   ├── symptom_checker_screen.dart
│   │   │   ├── help_screen.dart
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   ├── register_screen_api.dart
│   │   │   └── main_scaffold.dart
│   │   ├── services/         # Service layers (8 services)
│   │   │   ├── api_client.dart
│   │   │   ├── auth_service.dart
│   │   │   ├── doctor_service.dart
│   │   │   ├── booking_service.dart
│   │   │   ├── booking_service_api.dart
│   │   │   ├── notification_service.dart
│   │   │   ├── prescription_service.dart
│   │   │   ├── review_service.dart
│   │   │   └── user_service.dart
│   │   ├── theme/            # App theme
│   │   │   ├── app_colors.dart
│   │   │   └── app_theme.dart
│   │   ├── widgets/          # Reusable widgets
│   │   │   ├── doctor_card.dart
│   │   │   ├── custom_button.dart
│   │   │   ├── section_header.dart
│   │   │   └── ...
│   │   ├── firebase_options.dart
│   │   └── main.dart         # App entry point
│   ├── pubspec.yaml          # Flutter dependencies
│   └── README.md             # Flutter app documentation
│
├── .kiro/specs/              # Specification documents
│   └── afghanistan-healthcare-platform/
│       ├── requirements.md   # Requirements document
│       └── design.md         # Design document
│
├── PROJECT_STATUS.md         # Detailed project status
├── QUICK_START.md           # Quick start guide
├── PHASE1_PROGRESS.md       # Phase 1 progress report
├── TESTING_GUIDE.md         # Testing guide
└── README.md                # This file
```

---

## 📡 API Documentation

### Base URL
```
http://localhost:3000/api/v1
```

### Authentication
Most endpoints require authentication. Include Firebase ID token in header:
```
Authorization: Bearer <firebase-id-token>
```

For mock mode testing, use:
```
Authorization: Bearer mock_user123
```

### Endpoints

#### Authentication
- `POST /auth/register` - Register new user
- `GET /auth/profile` - Get user profile
- `PUT /auth/profile` - Update user profile
- `POST /auth/verify-token` - Verify Firebase token

#### Doctors
- `GET /doctors` - List doctors (filters: specialty, province, city)
- `GET /doctors/:id` - Get doctor details
- `GET /doctors/:id/availability?date=YYYY-MM-DD` - Get availability
- `POST /doctors/profile` - Create doctor profile
- `PUT /doctors/:id/availability` - Update availability
- `GET /doctors/meta/specialties` - Get specialties list

#### Bookings
- `POST /bookings` - Create booking
- `GET /bookings/my-bookings` - Get user bookings
- `GET /bookings/:id` - Get booking details
- `PUT /bookings/:id/cancel` - Cancel booking

#### Hospitals, Labs, Pharmacies
- `GET /hospitals` - List hospitals
- `GET /hospitals/:id` - Get hospital details
- `GET /labs` - List diagnostic labs
- `GET /pharmacies` - List pharmacies

#### Search
- `GET /search?q=<query>` - Global search

#### Medical Records
- `GET /emr/records` - Get patient records
- `POST /emr/records` - Add medical record

#### Payments
- `POST /payments/create-intent` - Create payment
- `POST /payments/:id/confirm` - Confirm payment

#### AI & Notifications
- `POST /ai/chat` - AI chatbot
- `POST /ai/symptom-checker` - Symptom checker
- `GET /notifications` - Get notifications
- `PUT /notifications/:id/read` - Mark as read
- `POST /notifications/register-token` - Register FCM token

See [backend/README.md](backend/README.md) for detailed API documentation.

---

## 🧪 Testing

### Run Backend Tests
```bash
cd backend
npm test
```

### Run Flutter Tests
```bash
cd medi_connect
flutter test
```

### Manual Testing
See [TESTING_GUIDE.md](TESTING_GUIDE.md) for comprehensive testing scenarios.

### Test with Mock Data
The backend runs in mock mode by default with seeded data:
- 5 doctors across different specialties
- 3 hospitals
- 2 diagnostic labs
- 2 pharmacies

---

## 💻 Development

### Backend Development
```bash
cd backend
npm run dev  # Start with nodemon (auto-reload)
```

### Flutter Development
```bash
cd medi_connect
flutter run -d chrome  # Run on Chrome
flutter run -d windows  # Run on Windows
flutter run  # Run on connected device
```

### Hot Reload
While Flutter app is running:
- Press `r` for hot reload
- Press `R` for hot restart
- Press `q` to quit

### Code Style
- Backend: ESLint + Prettier
- Flutter: Dart analyzer + flutter_lints

---

## 🚀 Deployment

### Backend Deployment
1. Set up Firebase project
2. Add production credentials to `.env`
3. Deploy to Cloud Run, AWS, or Heroku
4. Configure environment variables
5. Set up Redis and PostgreSQL (optional)

### Flutter Web Deployment
```bash
cd medi_connect
flutter build web
# Deploy to Firebase Hosting, Netlify, or Vercel
```

### Mobile App Deployment
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS (requires Mac)
flutter build ios --release
```

---

## 📊 Project Progress

### Phase 1: Integration ✅ **COMPLETE (100%)**
- ✅ Connect Flutter to Backend API
- ✅ Real Firebase Setup (optional for now)
- ✅ Complete Booking Flow
- ✅ Test End-to-End

### Phase 2: Enhanced Features ⏳ **PENDING**
- ⏳ Video consultation (Agora SDK)
- ⏳ AI chatbot (Google Gemini API)
- ⏳ Prescription management
- ⏳ Medical records with file uploads

### Phase 3: Additional Apps ⏳ **PENDING**
- ⏳ Doctor mobile app
- ⏳ Admin web dashboard
- ⏳ Hospital/Lab/Pharmacy portals

### Phase 4: Production Ready ⏳ **PENDING**
- ⏳ Dari/Pashto localization
- ⏳ RTL text direction
- ⏳ Production deployment
- ⏳ App store release
- ⏳ Testing & QA

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 👥 Team

- **Project Lead**: [Fazlullah Sardarkhil]
- **Backend Developer**: [Fazlullah Sardarkhil]
- **Frontend Developer**: [Fazlullah Sardarkhil]
- **UI/UX Designer**: [Fazlullah Sardarkhil]

---

## 📞 Support

For issues or questions:
- 📧 Email: support@mediconnect.af
- 🐛 Issues: [GitHub Issues](https://github.com/your-repo/issues)
- 📖 Documentation: See docs/ folder

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Afghan healthcare workers for their dedication
- Open source community

---

## 📈 Statistics

- **Backend Routes**: 12 modules, 40+ endpoints
- **Flutter Screens**: 14+ screens
- **Data Models**: 6 models
- **Service Layers**: 8 services
- **Mock Entities**: 12 entities
- **Lines of Code**: ~6,000+
- **Development Time**: Phase 1 complete

---

## 🎯 Vision

To make quality healthcare accessible to every Afghan citizen, regardless of location, through technology and innovation.

---

*Last Updated: May 3, 2026*  
*Version: 1.0.0*  
*Status: Phase 1 Complete ✅*
