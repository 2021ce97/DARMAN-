# 🔐 DARMAN — Complete Login Credentials & Access Guide

**Last Updated**: May 16, 2026  
**Status**: ✅ ALL SYSTEMS LIVE

---

## 🌐 LIVE URLS

| Service | URL | Status |
|---------|-----|--------|
| **Web App (Patient/Doctor/Admin)** | https://mediconnect-4b155.web.app | ✅ LIVE |
| **Backend API** | https://darman.onrender.com | ✅ LIVE |
| **API Health Check** | https://darman.onrender.com/health | ✅ LIVE |
| **Admin Dashboard (Vercel)** | https://darman-health.vercel.app | ✅ LIVE |
| **GitHub Repository** | https://github.com/2021ce97/DARMAN- | ✅ LIVE |
| **Firebase Console** | https://console.firebase.google.com/project/mediconnect-4b155 | ✅ LIVE |

---

## 👤 PATIENT ACCOUNTS

### Test Patient
| Field | Value |
|-------|-------|
| **Login URL** | https://mediconnect-4b155.web.app/login |
| **Email** | `patient@darman.af` |
| **Password** | `Darman2026!` |
| **Role** | Patient |
| **Access** | Home, Search, Book Appointments, Health Records, Prescriptions, AI Chat |

### Your Personal Account
| Field | Value |
|-------|-------|
| **Email** | `fazlullahsardarkhil@gmail.com` |
| **Role** | Patient (registered via Google) |

---

## 👨‍⚕️ DOCTOR ACCOUNTS (8 Real Doctors)

All doctors login at: **https://mediconnect-4b155.web.app/login**  
After login, they are automatically redirected to the **Doctor Dashboard** at `/doctor`

| Doctor | Email | Password | Specialty | Hospital |
|--------|-------|----------|-----------|----------|
| **Dr. Ahmad Karimi** | `dr.karimi@darman.af` | `Darman2026!` | Cardiologist | Wazir Akbar Khan Hospital, Kabul |
| **Dr. Fatima Noori** | `dr.noori@darman.af` | `Darman2026!` | Gynecologist | Rabia Balkhi Hospital, Kabul |
| **Dr. Khalid Ahmadzai** | `dr.ahmadzai@darman.af` | `Darman2026!` | Pediatrician | Herat Regional Hospital |
| **Dr. Mariam Sultani** | `dr.sultani@darman.af` | `Darman2026!` | Dermatologist | French Medical Institute, Kabul |
| **Dr. Noor Rahman** | `dr.rahman@darman.af` | `Darman2026!` | General Physician | Balkh Regional Hospital |
| **Dr. Zarghona Rahimi** | `dr.rahimi@darman.af` | `Darman2026!` | Neurologist | Jamhuriat Hospital, Kabul |
| **Dr. Habibullah Safi** | `dr.safi@darman.af` | `Darman2026!` | Orthopedic Surgeon | Mirwais Hospital, Kandahar |
| **Dr. Laila Ahmadi** | `dr.ahmadi@darman.af` | `Darman2026!` | Psychiatrist | Kabul Mental Health Hospital |

### Doctor Dashboard Features
After login as doctor, you can:
- ✅ View your appointment schedule
- ✅ Accept/reject patient appointments
- ✅ Write digital prescriptions
- ✅ View patient list
- ✅ Edit your profile and availability
- ✅ Start video consultations

---

## 🔑 ADMIN ACCOUNTS

### Web App Admin
| Field | Value |
|-------|-------|
| **Login URL** | https://mediconnect-4b155.web.app/login |
| **Email** | `admin@darman.af` |
| **Password** | `Darman2026!` |
| **Role** | Admin |
| **Access** | Admin Dashboard at `/admin` |

### Your Student Account (Admin)
| Field | Value |
|-------|-------|
| **Email** | `2021ce97@student.uet.edu.pk` |
| **Role** | Admin |

### Vercel Admin Dashboard
| Field | Value |
|-------|-------|
| **URL** | https://darman-health.vercel.app |
| **Email** | `admin@darman.af` |
| **Password** | `Darman2026!` |
| **Features** | Overview, Doctors Panel, Analytics, System Status |

---

## 📱 MOBILE APP (Android)

### APK Details
| Field | Value |
|-------|-------|
| **APK Location** | `medi_connect/build/app/outputs/flutter-apk/app-release.apk` |
| **APK Size** | 57.5 MB |
| **Built** | May 16, 2026 |
| **Device Tested** | Infinix X6831 (Android 13) |
| **Status** | ✅ INSTALLED & RUNNING |

### How to Install on New Device
```bash
# Connect device via USB with Developer Mode ON
flutter install --device-id YOUR_DEVICE_ID

# Or manually copy APK and install
# APK is at: medi_connect/build/app/outputs/flutter-apk/app-release.apk
```

### Login on Mobile
Same credentials as web app — all accounts work on mobile too.

---

## 🔄 HOW ROLE-BASED LOGIN WORKS

When you login, the app automatically redirects based on your role:

```
Patient login → Home screen (/)
Doctor login  → Doctor Dashboard (/doctor)
Admin login   → Admin Dashboard (/admin)
```

**The role is determined by Firebase Custom Claims** set when the account was created.

---

## 🧪 QUICK TEST CHECKLIST

### Test Patient Login
1. Open https://mediconnect-4b155.web.app
2. Enter: `patient@darman.af` / `Darman2026!`
3. Should see: Home screen with doctors list
4. Try: Search for "Cardiologist", book an appointment

### Test Doctor Login
1. Open https://mediconnect-4b155.web.app
2. Enter: `dr.karimi@darman.af` / `Darman2026!`
3. Should see: Doctor Dashboard with appointments
4. Try: View appointments, write a prescription

### Test Admin Login
1. Open https://mediconnect-4b155.web.app
2. Enter: `admin@darman.af` / `Darman2026!`
3. Should see: Admin Dashboard with stats
4. Try: View all users, check system status

### Test Admin Dashboard (Vercel)
1. Open https://darman-health.vercel.app
2. Enter: `admin@darman.af` / `Darman2026!`
3. Should see: Overview with 9 doctors, 6 hospitals, etc.

---

## 🔧 BACKEND API TESTING

```bash
# Health check
curl https://darman.onrender.com/health

# Get all doctors
curl https://darman.onrender.com/api/v1/doctors

# Search
curl "https://darman.onrender.com/api/v1/search?q=cardio"

# Get hospitals
curl https://darman.onrender.com/api/v1/hospitals
```

**Note**: Render free tier spins down after 15 min inactivity.  
First request may take 30-60 seconds to wake up.

---

## 📊 CURRENT PROJECT STATUS

```
Overall Progress: ████████████  85% Complete

✅ Firebase Auth:        100% — 18 users, all roles working
✅ Firestore Database:   100% — 9 doctors, 6 hospitals, 4 labs, 4 pharmacies
✅ Backend API:          100% — 14 modules, 50+ endpoints, LIVE on Render
✅ Web App:              100% — LIVE on Firebase Hosting
✅ Doctor App:           90%  — Dashboard, appointments, prescriptions
✅ Admin Dashboard:      85%  — Overview, doctors panel, analytics
✅ Mobile APK:           100% — Built & installed on Infinix X6831
✅ GitHub:               100% — All code pushed

⏳ Remaining:
- Dari/Pashto localization (0%)
- Real Agora video integration (0%)
- Real Gemini AI integration (0%)
- Real HesabPay payments (0%)
- Google Play Store submission (0%)
```

---

## 🚀 NEXT STEPS TO COMPLETE

### This Week
1. Test all login flows on mobile
2. Fix any UI issues found during testing
3. Add more patient test accounts

### Next Month
1. Get Gemini API key → https://aistudio.google.com (free)
2. Get Agora account → https://agora.io (free tier)
3. Add Dari language support
4. Submit to Google Play Store

---

*DARMAN Healthcare Platform — Connecting Afghanistan to Quality Healthcare*
