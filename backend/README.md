# MediConnect Backend API

Backend API server for the MediConnect (HealthLink) healthcare platform.

## Tech Stack

- **Runtime**: Node.js
- **Framework**: Fastify
- **Database**: Firebase Firestore
- **Authentication**: Firebase Auth
- **Storage**: Firebase Storage
- **Cache**: Redis (optional)
- **Analytics DB**: PostgreSQL (optional)

## Setup

### Prerequisites

- Node.js 18+ installed
- Firebase project created
- Firebase Admin SDK credentials

### Installation

1. Install dependencies:
```bash
npm install
```

2. Configure environment variables:
```bash
cp .env.example .env
```

Edit `.env` and add your Firebase credentials and other configuration.

3. Add Firebase Admin SDK credentials:
   - Download your Firebase Admin SDK JSON file from Firebase Console
   - Either:
     - Place it in the backend directory and set `FIREBASE_SERVICE_ACCOUNT_PATH` in `.env`
     - OR extract the values and set `FIREBASE_PROJECT_ID`, `FIREBASE_PRIVATE_KEY`, and `FIREBASE_CLIENT_EMAIL` in `.env`

### Running the Server

Development mode (with auto-reload):
```bash
npm run dev
```

Production mode:
```bash
npm start
```

The server will start on `http://localhost:3000` by default.

## API Endpoints

### Health Check
- `GET /health` - Server health status

### Authentication
- `POST /api/v1/auth/register` - Register new user
- `GET /api/v1/auth/profile` - Get current user profile
- `PUT /api/v1/auth/profile` - Update user profile
- `POST /api/v1/auth/verify-token` - Verify Firebase token

### Doctors
- `GET /api/v1/doctors` - List doctors (with filters)
- `GET /api/v1/doctors/:id` - Get doctor details
- `GET /api/v1/doctors/:id/availability` - Get doctor availability
- `POST /api/v1/doctors/profile` - Create doctor profile
- `PUT /api/v1/doctors/:id/availability` - Update availability
- `GET /api/v1/doctors/meta/specialties` - Get specialties list

### Bookings
- `POST /api/v1/bookings` - Create booking
- `GET /api/v1/bookings/my-bookings` - Get user bookings
- `GET /api/v1/bookings/:id` - Get booking details
- `PUT /api/v1/bookings/:id/cancel` - Cancel booking

### Hospitals
- `GET /api/v1/hospitals` - List hospitals
- `GET /api/v1/hospitals/:id` - Get hospital details

### Labs
- `GET /api/v1/labs` - List diagnostic labs

### Pharmacies
- `GET /api/v1/pharmacies` - List pharmacies

### Medical Records (EMR)
- `GET /api/v1/emr/records` - Get patient medical records
- `POST /api/v1/emr/records` - Add medical record

### Payments
- `POST /api/v1/payments/create-intent` - Create payment intent
- `POST /api/v1/payments/:id/confirm` - Confirm payment

### Search
- `GET /api/v1/search?q=query` - Global search

### AI
- `POST /api/v1/ai/chat` - AI chatbot
- `POST /api/v1/ai/symptom-checker` - Symptom checker

### Notifications
- `GET /api/v1/notifications` - Get user notifications
- `PUT /api/v1/notifications/:id/read` - Mark as read
- `POST /api/v1/notifications/register-token` - Register FCM token

### Consultations
- `GET /api/v1/consultations/:bookingId` - Get consultation
- `POST /api/v1/consultations/:bookingId/start` - Start video consultation

## Authentication

Most endpoints require authentication. Include the Firebase ID token in the Authorization header:

```
Authorization: Bearer <firebase-id-token>
```

## Error Responses

All errors follow this format:
```json
{
  "error": {
    "message": "Error description",
    "statusCode": 400
  }
}
```

## Development

### Project Structure

```
backend/
├── src/
│   ├── config/          # Configuration files
│   │   └── firebase.js  # Firebase initialization
│   ├── middleware/      # Custom middleware
│   │   └── auth.middleware.js
│   ├── routes/          # API routes
│   │   ├── auth.routes.js
│   │   ├── doctor.routes.js
│   │   ├── booking.routes.js
│   │   └── ...
│   └── server.js        # Main server file
├── .env                 # Environment variables
├── .env.example         # Example environment variables
├── package.json
└── README.md
```

## License

MIT
