# Requirements Document

## Introduction

MediConnect (HealthLink) is a large-scale healthcare and medical discovery platform for Afghanistan, built as a Flutter/Firebase mobile application. The platform connects patients with doctors, hospitals, diagnostic laboratories, and pharmacies across all 34 provinces of Afghanistan. It is modeled after platforms such as Marham (Pakistan), Practo (India), and Tata 1mg (India), adapted for Afghanistan's unique context: predominantly cash-based economy, low-bandwidth connectivity, Dari and Pashto language requirements, and a healthcare system that is rebuilding after decades of conflict.

The existing Flutter project (medi_connect/) has approximately 85% of the patient-facing frontend built, including screens for Home, Search, Doctor Listing, Doctor Profile, Booking Summary, Appointments, Profile, Health Records, Symptom Checker, Login, Register, Medical History, and Help. The existing service layer covers Auth, Doctor, Booking, Notification, Prescription, Review, and User services. This requirements document defines all features that must be added, extended, or refined on top of the existing foundation.

The platform serves five primary roles: Patient, Doctor, Hospital Administrator, Lab/Pharmacy Operator, and Platform Administrator. It is designed for phased rollout: Phase 1 (Kabul MVP), Phase 2 (Hospital/Lab/Pharmacy + online consultation), Phase 3 (AI + video + RTL languages + more provinces), and Phase 4 (Admin dashboard + monetization + national rollout).

## Glossary

- **MediConnect**: The mobile application platform, also branded as HealthLink.
- **Patient**: A registered user seeking medical services.
- **Doctor**: A licensed medical professional registered and verified on the platform.
- **Hospital**: A registered and verified healthcare facility offering inpatient and outpatient services.
- **Lab**: A registered and verified diagnostic laboratory offering test services.
- **Pharmacy**: A registered and verified medicine dispensary.
- **Admin**: A platform administrator with full management access.
- **Province**: One of the 34 administrative provinces of Afghanistan (e.g., Kabul, Herat, Balkh).
- **City**: A city or district within a province (e.g., Kabul City within Kabul Province).
- **Specialty**: A medical discipline (e.g., Cardiology, Pediatrics, Dermatology).
- **Appointment**: A scheduled consultation between a Patient and a Doctor.
- **Slot**: A specific date and time window available for booking an Appointment.
- **Prescription**: A medical document written by a Doctor listing medicines, dosages, and instructions for a Patient.
- **EMR**: Electronic Medical Record — a digital record of a Patient's health history.
- **EHR**: Electronic Health Record — a broader, shareable version of EMR.
- **Triage**: The process of assessing symptom severity to determine urgency of care.
- **Chatbot**: The AI-powered conversational assistant within MediConnect.
- **Gemini_API**: Google Gemini large language model API used for AI chatbot responses.
- **Rule_Engine**: The local rule-based triage logic used as fallback when Gemini_API is unavailable.
- **HesabPay**: An Afghan mobile payment platform used for digital transactions.
- **Agora**: A third-party WebRTC video SDK used for online video consultations.
- **Jitsi**: An open-source WebRTC video platform used as fallback for video consultations.
- **flutter_map**: A Flutter mapping library using OpenStreetMap tiles, used as the primary map provider.
- **OpenStreetMap**: A free, open map data source used as the primary map tile provider.
- **Hive**: A lightweight Flutter key-value store used for local offline caching.
- **FCM**: Firebase Cloud Messaging — the push notification delivery service.
- **RBAC**: Role-Based Access Control — the security model governing what each role can do.
- **RTL**: Right-to-Left text direction, required for Dari and Pashto languages.
- **AFN**: Afghan Afghani — the currency unit used for all fees and payments.
- **Doctor_ID**: A unique identifier for a Doctor, scoped by province (e.g., KBL-2024-00123).
- **Consent**: Explicit permission granted by a Patient allowing a Doctor to access the Patient's medical records.
- **Verification**: The admin approval process that transitions a Doctor, Hospital, Lab, or Pharmacy from Pending to Verified status.
- **Commission**: A percentage fee charged by MediConnect on online consultation payments.
- **Subscription**: A recurring payment plan for Doctors, Hospitals, Labs, or Pharmacies to access premium platform features.
- **Featured_Listing**: A paid placement that elevates a provider's visibility in search results.
- **Audit_Log**: An immutable record of sensitive actions (e.g., medical record access, admin approvals).
- **Offline_Cache**: Locally stored data accessible without an internet connection.
- **Pagination**: Loading data in discrete pages to reduce bandwidth and memory usage.
- **CDN**: Content Delivery Network — Firebase Hosting used for static asset delivery.
- **WebRTC**: Web Real-Time Communication protocol used for peer-to-peer video and audio.
- **Firestore**: Google Cloud Firestore — the primary NoSQL database for MediConnect.
- **Firebase_Storage**: Google Firebase Storage — used for file uploads (photos, reports, prescriptions).
- **Riverpod**: The state management library used in the Flutter app.
- **GoRouter**: The navigation library used in the Flutter app.
