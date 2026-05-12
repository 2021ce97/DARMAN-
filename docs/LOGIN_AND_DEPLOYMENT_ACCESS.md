# Login and Deployment Access

Last updated: 2026-05-12

## App Login Credentials

These demo accounts have been created/updated in Firebase Auth for project `mediconnect-4b155`.

| Role | Email | Password | Where to login |
| --- | --- | --- | --- |
| Patient | `patient@darman.af` | `Darman2026!` | https://mediconnect-4b155.web.app/login |
| Doctor | `doctor@darman.af` | `Darman2026!` | https://mediconnect-4b155.web.app/login |
| Admin | `admin@darman.af` | `Darman2026!` | https://mediconnect-4b155.web.app/login |

Expected redirect after login:

- Patient: home dashboard `/`
- Doctor: doctor dashboard `/doctor`
- Admin: admin dashboard `/admin`

Direct app links:

- Patient app: https://mediconnect-4b155.web.app/
- Doctor dashboard: https://mediconnect-4b155.web.app/doctor
- Admin dashboard: https://mediconnect-4b155.web.app/admin
- Register patient: https://mediconnect-4b155.web.app/register
- Register doctor: https://mediconnect-4b155.web.app/register-doctor

## Important Security Note

These are demo credentials. Change or disable them before a real public launch.

Recommended production policy:

- Unique password per role.
- MFA required for admin.
- Remove shared demo users from production.
- Create named staff accounts instead of shared admin credentials.

## Provider / Platform Access

I can create app users inside Firebase because this repo has a local service account file. I cannot create or know your personal GitHub, Firebase Console, Render, Vercel, Gemini, Agora, or HesabPay dashboard passwords. Those accounts use your own login/OAuth.

Use these links:

| Platform | Purpose | Login URL |
| --- | --- | --- |
| GitHub repo | Source code and CI | https://github.com/2021ce97-jpg/DARMAN- |
| Firebase Console | Auth, Firestore, Hosting, Storage, Functions | https://console.firebase.google.com/project/mediconnect-4b155 |
| Render | Backend hosting for `darman-api` | https://dashboard.render.com |
| Vercel | Optional retired Next.js admin dashboard | https://vercel.com/dashboard |
| Google AI Studio | Gemini API key | https://aistudio.google.com/app/apikey |
| Agora Console | Video app ID/certificate | https://console.agora.io |
| HesabPay | Payment merchant credentials | https://hesabpay.com |

Firebase Console is signed in with this Google/student account:

```text
2021ce97@student.uet.edu.pk
```

Firebase project URL:

```text
https://console.firebase.google.com/project/mediconnect-4b155/overview
```

## How to Login to Each App Role

1. Open https://mediconnect-4b155.web.app/login.
2. Enter one of the role emails above.
3. Enter `Darman2026!`.
4. After login, the app reads the role from Firestore `/users/{uid}` and redirects.

If redirect does not happen:

1. Open the direct link for the role.
2. Refresh once after login so Firebase custom claims/Firestore role state reloads.
3. Confirm the user document exists in Firebase Console under `users`.

## How to Recreate Demo Accounts

From the repo:

```bash
cd backend
node src/scripts/create-test-user.js
```

The script is idempotent. It updates existing passwords, custom claims, and Firestore role documents.

## Current Deployment Status

| Component | URL | Status |
| --- | --- | --- |
| Flutter web app | https://mediconnect-4b155.web.app | Live |
| Backend API | https://darman-api.onrender.com/health | Currently timing out from local checks |
| Next.js admin | https://darman-admin.vercel.app | Retired/not deployed, returns 404 |

## Render Backend Recovery Process

Your Render dashboard currently shows:

- `DARMAN-`: Deployed, Node, Singapore.
- `DARMAN-API`: Failed deploy, Node, Singapore.

Use the deployed `DARMAN-` service if it points to this backend and has a working public URL. Otherwise, fix/redeploy `DARMAN-API` with the settings below.

1. Open https://dashboard.render.com.
2. Open service `darman-api`.
3. Confirm it is connected to GitHub repo `2021ce97-jpg/DARMAN-`.
4. Confirm root directory is `backend`.
5. Confirm build command is `npm ci`.
6. Confirm start command is `node src/server.js`.
7. Confirm health check path is `/health`.
8. Ensure env vars exist:
   - `NODE_ENV=production`
   - `HOST=0.0.0.0`
   - `FIREBASE_PROJECT_ID=mediconnect-4b155`
   - `FIREBASE_CLIENT_EMAIL=firebase-adminsdk-fbsvc@mediconnect-4b155.iam.gserviceaccount.com`
   - `FIREBASE_PRIVATE_KEY=<full private key with newline escapes>`
   - `JWT_SECRET=<generated secret>`
   - `RATE_LIMIT_MAX=100`
   - `RATE_LIMIT_TIMEWINDOW=60000`
   - `GEMINI_API_KEY=<Google AI Studio key>`
   - `AGORA_APP_ID=<Agora app id>`
   - `AGORA_APP_CERTIFICATE=<Agora app certificate>`
   - `HESABPAY_API_KEY=<HesabPay merchant API key>`
   - `HESABPAY_MERCHANT_ID=<HesabPay merchant id>`
   - `HESABPAY_BASE_URL=<HesabPay API base URL>`
9. Redeploy manually from Render.
10. Check https://darman-api.onrender.com/health.

If the service name in Render is `DARMAN-` instead of `darman-api`, use the same settings there and copy its public URL into:

- `medi_connect/lib/config/api_config.dart`
- `admin-dashboard/vercel.json`
- backend CORS allowlist if you disable the generic Render/Vercel regexes.

## App Check Setup

1. Sign into Firebase with `2021ce97@student.uet.edu.pk`.
2. Open https://console.firebase.google.com/project/mediconnect-4b155/appcheck.
3. Register the web app and create a reCAPTCHA v3 site key.
4. Build/deploy Flutter web with:

```bash
flutter build web --release --dart-define=ENV=production --dart-define=APP_CHECK_RECAPTCHA_SITE_KEY=<site-key>
firebase deploy --only hosting --project mediconnect-4b155
```

5. Keep App Check in monitoring mode first. Enforce Firestore/Storage only after login, booking, profile, and admin flows are verified.
