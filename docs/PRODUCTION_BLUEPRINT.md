# DARMAN Production Blueprint

Last updated: 2026-05-12

## Executive Direction

DARMAN should be treated as a healthcare operations platform, not just a doctor listing app. The product has three core jobs:

1. Help patients discover trusted healthcare providers and book care quickly.
2. Help doctors manage appointments, patients, prescriptions, and follow-up.
3. Give admins controlled tools for verification, moderation, audit, and platform health.

The current codebase already contains most screens and route modules for an MVP. The next work is not to add random features. The next work is to harden the system into a reliable launch path: consistent data ownership, clean API contracts, deployed backend health, security rules, observability, and real payment/video/AI integrations.

## Current System Map

| Area | Location | Current role | Production target |
| --- | --- | --- | --- |
| Flutter app | `medi_connect/` | Patient, doctor, and in-app admin UI | Main patient and doctor app for web/mobile |
| Backend API | `backend/` | Fastify API for auth, doctors, bookings, AI, payments, consultations, uploads | Authoritative API for sensitive writes and external integrations |
| Firebase | `firebase.json`, `firestore.rules`, `storage.rules`, `functions/` | Auth, Firestore, Storage, Hosting, push notification triggers | Managed identity, operational database, storage, notifications |
| Next.js admin | `admin-dashboard/` | Separate admin dashboard prototype | Either deploy as official admin console or retire in favor of Flutter admin |
| Deployment scripts | `deploy.ps1`, `render.yaml`, `backend/render.yaml`, `.github/workflows/` | Partial deployment automation | One repeatable CI/CD pipeline per service |

## Recommended Production Architecture

### Client Layer

- Flutter app for patients and doctors.
- Admin console should be web-first. Choose one admin surface:
  - Preferred: Next.js admin for desktop admin operations.
  - Alternative: Flutter `/admin` route for simple unified deployment.
- Use role-based routing from Firebase Auth and `/users/{uid}.role`.

### API Layer

- Fastify backend remains the public API at `/api/v1`.
- Backend owns:
  - Payment creation, confirmation, refund.
  - Video token generation.
  - Doctor verification decisions.
  - Upload validation and signed upload flows.
  - Admin-only mutations.
  - Audit logging.
- Flutter can keep direct Firestore reads for realtime UX, but sensitive writes should move behind the backend.

### Data Layer

Primary operational database: Firestore.

Core collections:

- `users`: patient, doctor, admin profiles and role metadata.
- `doctors`: doctor public profile, verification status, availability metadata.
- `appointments`: patient-doctor appointment workflow used by Flutter doctor screens.
- `bookings`: backend booking workflow currently used by API routes.
- `prescriptions`: doctor-written prescriptions.
- `notifications`: in-app and push notification records.
- `payments`: payment intents, confirmations, refunds.
- `consultations`: video consultation sessions and status.
- `reviews`: provider reviews.
- `health_metrics`: patient-entered metrics.
- `medical_records` or `health_records`: clinical documents and summaries.
- `audit_logs`: immutable admin and backend security events.

Production decision needed: merge `appointments` and `bookings` into one canonical collection. Today both names exist. Pick `appointments` for healthcare language, then adapt backend routes to write/read the same collection.

### Integration Layer

- Gemini: use backend-mediated AI calls with safety instructions and clear medical disclaimers.
- Agora: generate tokens server-side only.
- HesabPay: backend-only payment integration; do not expose merchant secrets to Flutter.
- FCM: Cloud Functions or backend sends push notifications, with Firestore notification record as the source of truth.

## Deployment Status

| Component | Current evidence | Status |
| --- | --- | --- |
| Firebase project | `mediconnect-4b155` exists | Active |
| Firestore | database `default`, location `asia-south1` | Active |
| Firebase Hosting | `https://mediconnect-4b155.web.app` returned HTTP 200 | Active |
| Backend Render URL | `https://darman-api.onrender.com/health` timed out | Not healthy |
| Admin Vercel URL | `https://darman-admin.vercel.app` returned 404 | Not deployed or wrong URL |
| Firebase Functions | CLI list failed | Not verified |
| Local backend | `node src/server.js` health check returned 200 | Works locally |

## Security Model

Baseline security target: OWASP ASVS Level 2 for web/API controls, plus healthcare-grade privacy discipline even if local law does not explicitly require HIPAA-style controls.

Required controls:

1. Authentication
   - Firebase Auth for identity.
   - Custom claims or server-verified role lookup.
   - MFA for admins.

2. Authorization
   - Server-side role checks for all admin, payment, upload, and prescription actions.
   - Firestore rules deny by default.
   - Users can only read/write their own private records.
   - Doctors can only access patients connected through appointments.

3. Data protection
   - No secrets in client code.
   - No service account keys committed.
   - Use environment variables in Render/Vercel/Firebase.
   - Use Firebase Storage rules and content-type/size checks.

4. Auditability
   - Write `audit_logs` for admin role changes, doctor verification, refunds, record access, prescription creation, and account bans.
   - Logs should be immutable from the client.

5. Abuse protection
   - Rate limit backend API.
   - Add Firebase App Check for app and web clients.
   - Validate file uploads server-side.
   - Add bot protection for registration and public search if abuse appears.

6. Clinical safety
   - AI symptom output must be triage support only, not diagnosis.
   - Urgent symptoms must direct users to emergency care.
   - Keep medical disclaimers visible inside AI and symptom flows.

References:

- WHO Global Strategy on Digital Health 2020-2025: https://www.who.int/publications/i/item/9789240020924
- OWASP ASVS: https://owasp.org/www-project-application-security-verification-standard/
- Firebase Security Rules: https://firebase.google.com/docs/rules
- Render health checks: https://render.com/docs/health-checks

## Product Phases

### Phase 0: Stabilization

Goal: Make the current MVP build, run, deploy, and show predictable data.

Deliverables:

- Fix Flutter analyzer build blockers.
- Align Flutter service endpoints with backend route prefixes.
- Choose one canonical appointment collection.
- Fix Render backend deployment.
- Confirm Firebase rules and indexes deploy from the correct files.
- Seed realistic demo data for doctors, labs, pharmacies, and hospitals.
- Add smoke tests for auth, doctor listing, booking, payment mock, and admin verification.

Exit criteria:

- `flutter build web --release --dart-define=ENV=production` succeeds.
- Backend `/health` and `/api/v1/doctors` respond publicly.
- Firebase Hosting serves the latest build.
- New patient, doctor, and admin test accounts can complete core flows.

### Phase 1: MVP Launch

Goal: Launch core discovery and booking safely.

Features:

- Patient registration/login.
- Doctor discovery with filters.
- Doctor profile and appointment booking.
- Doctor dashboard for accept/reject/complete.
- Admin doctor verification.
- In-app notifications.
- Basic health records and prescriptions.
- Mock payment allowed only if clearly labeled in staging.

Exit criteria:

- Admin can verify doctors.
- Patients only see their own private records.
- Doctors only see their own appointments/patients.
- Audit logs are written for sensitive actions.

### Phase 2: Real Payments, Video, and Files

Goal: Replace demo flows with production integrations.

Features:

- HesabPay production payment flow and webhook confirmation.
- Agora token generation with real app ID/certificate.
- Secure document upload for doctor licenses, medical records, prescriptions, and lab results.
- Appointment reminder notifications.
- Refund/cancellation rules.

Exit criteria:

- No payment state is trusted from the client.
- Uploads are scanned/validated and size-limited.
- Failed payments and refunds are auditable.

### Phase 3: Clinical Workflow

Goal: Make the doctor side actually useful.

Features:

- Doctor availability calendar.
- Patient timeline.
- Prescription templates.
- Follow-up scheduling.
- Basic consent workflow for doctor access to records.
- Lab order request flow.

Exit criteria:

- Doctor can manage a patient encounter end-to-end.
- Patient has a persistent medical timeline.
- Consent and access are visible and revocable.

### Phase 4: Admin Operations

Goal: Make the platform manageable.

Features:

- Admin dashboard for users, doctors, bookings, payments, reports.
- Doctor document review.
- Ban/suspend user.
- Broadcast notifications.
- Support ticket view.
- Operational analytics.

Exit criteria:

- Admin actions are role-gated and audited.
- Admin dashboard is deployed and protected by MFA.

### Phase 5: Scale and Reliability

Goal: Prepare for real traffic and operational incidents.

Features:

- CI checks for Flutter, backend, functions, and admin.
- Error monitoring.
- Structured backend logs.
- Uptime checks.
- Backup/export policy.
- Firestore index review.
- Load test public search and doctor listing.

Exit criteria:

- Deployments are repeatable.
- Backend can be rolled back.
- Alerts exist for API downtime and error spikes.

## UI/UX Direction

Patients need speed and trust:

- First screen after login should show search, upcoming appointment, quick services, and emergency guidance.
- Doctor cards should expose specialty, city, fee, rating, language, and verified badge.
- Booking should be a short stepper: select date/time, reason, confirmation, payment.
- AI symptom checker should produce a recommended specialty and emergency warning, not pretend to diagnose.

Doctors need operational density:

- Dashboard should prioritize today's appointments, pending requests, active patients, and prescription actions.
- Appointment detail should show patient reason, history, actions, chat/video, and prescription creation.
- Profile edit should make verification status obvious.

Admins need control:

- Admin UI should be table-driven, searchable, filterable, and audit-friendly.
- Avoid mobile-first card overload for admin workflows.
- Every destructive action needs confirmation and audit logging.

## DevOps Plan

Recommended environments:

- `dev`: local Firebase emulator or dev project.
- `staging`: deployed backend/admin/web with test Firebase project and mock payment/video.
- `production`: real Firebase project, real payment/video/AI credentials.

Recommended pipelines:

- Flutter web: GitHub Actions builds and deploys Firebase Hosting.
- Backend: Render auto-deploy from `main` after CI passes.
- Admin dashboard: Vercel deploy from `admin-dashboard/`.
- Firebase rules/functions: deploy through GitHub Actions, not manual CLI on random machines.

Minimum CI checks:

- `flutter pub get`
- `flutter analyze --no-fatal-infos`
- `flutter test`
- `npm ci && npm test` in `backend/`
- `npm ci && npm run build` in `admin-dashboard/`
- Firebase rules emulator tests for critical access paths.

## Immediate Engineering Backlog

P0:

- Fix Render deployment timeout.
- Fix Firestore rules/index source confusion.
- Merge `appointments` and `bookings`.
- Add backend tests for health, doctors, bookings, payments, consultations.
- Remove placeholder production keys and enforce required env vars.
- Configure Firebase App Check for web/mobile apps before public launch.

P1:

- Deploy admin dashboard or remove dead Vercel URL from CORS.
- Add doctor verification document upload.
- Add admin audit logs.
- Add App Check.
- Add seed script that is safe to run repeatedly.

P2:

- Add real payment webhook flow.
- Add real Agora SDK client integration.
- Add analytics dashboard.
- Add backup/export procedures.

## External Credential Setup

Production credentials must be added only in provider dashboards and CI/CD secrets:

- Gemini: set `GEMINI_API_KEY` in Render for backend AI calls. Do not compile this key into Flutter.
- Agora: set `AGORA_APP_ID` and `AGORA_APP_CERTIFICATE` in Render. Token generation must stay server-side.
- HesabPay: set `HESABPAY_API_KEY`, `HESABPAY_MERCHANT_ID`, and `HESABPAY_BASE_URL` in Render. Payment confirmation should be verified server-side and later through webhooks.
- Firebase App Check: enable App Check for Web, Android, and iOS in Firebase Console, then enforce Firestore/Storage/Functions only after test devices are registered.
- CI secrets: set `FIREBASE_SERVICE_ACCOUNT` for Firebase Hosting deploys; do not commit service-account JSON.
