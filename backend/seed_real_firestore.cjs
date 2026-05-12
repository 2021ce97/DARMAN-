const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const db = admin.firestore();

const doctors = [
  {
    name: 'Dr. Ahmad Karimi',
    specialty: 'Cardiologist',
    province: 'Kabul',
    city: 'Kabul City',
    hospital: 'Wazir Akbar Khan Hospital',
    experience: 12,
    fee: 800,
    rating: 4.8,
    reviewCount: 124,
    status: 'Verified',
    languages: ['Dari', 'Pashto', 'English'],
    education: 'MBBS, MD Cardiology - Kabul University',
    about: 'Experienced cardiologist with 12 years of practice in Kabul.',
    photoUrl: 'https://i.pravatar.cc/150?img=11',
    availableDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday'],
    createdAt: admin.firestore.Timestamp.now(),
  },
  {
    name: 'Dr. Fatima Noori',
    specialty: 'Gynecologist',
    province: 'Kabul',
    city: 'Kabul City',
    hospital: 'Rabia Balkhi Hospital',
    experience: 8,
    fee: 600,
    rating: 4.9,
    reviewCount: 89,
    status: 'Verified',
    languages: ['Dari', 'Pashto'],
    education: 'MBBS, MD Gynecology - Kabul Medical University',
    about: 'Specialist in women\'s health and maternal care.',
    photoUrl: 'https://i.pravatar.cc/150?img=5',
    availableDays: ['Sunday', 'Monday', 'Tuesday', 'Wednesday'],
    createdAt: admin.firestore.Timestamp.now(),
  },
  {
    name: 'Dr. Khalid Ahmadzai',
    specialty: 'Pediatrician',
    province: 'Herat',
    city: 'Herat City',
    hospital: 'Herat Regional Hospital',
    experience: 15,
    fee: 700,
    rating: 4.7,
    reviewCount: 201,
    status: 'Verified',
    languages: ['Dari', 'Pashto', 'English'],
    education: 'MBBS, MD Pediatrics - Herat University',
    about: 'Dedicated pediatrician serving children in Herat province.',
    photoUrl: 'https://i.pravatar.cc/150?img=15',
    availableDays: ['Monday', 'Wednesday', 'Thursday', 'Saturday'],
    createdAt: admin.firestore.Timestamp.now(),
  },
  {
    name: 'Dr. Mariam Sultani',
    specialty: 'Dermatologist',
    province: 'Kabul',
    city: 'Kabul City',
    hospital: 'French Medical Institute',
    experience: 6,
    fee: 900,
    rating: 4.6,
    reviewCount: 67,
    status: 'Verified',
    languages: ['Dari', 'French', 'English'],
    education: 'MBBS, MD Dermatology - Paris University',
    about: 'Skin specialist trained in France with expertise in modern dermatology.',
    photoUrl: 'https://i.pravatar.cc/150?img=9',
    availableDays: ['Tuesday', 'Thursday', 'Saturday'],
    createdAt: admin.firestore.Timestamp.now(),
  },
  {
    name: 'Dr. Noor Rahman',
    specialty: 'General Physician',
    province: 'Balkh',
    city: 'Mazar-i-Sharif',
    hospital: 'Balkh Regional Hospital',
    experience: 10,
    fee: 400,
    rating: 4.5,
    reviewCount: 312,
    status: 'Verified',
    languages: ['Dari', 'Uzbek', 'Pashto'],
    education: 'MBBS - Balkh University',
    about: 'General physician providing primary healthcare in northern Afghanistan.',
    photoUrl: 'https://i.pravatar.cc/150?img=20',
    availableDays: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday'],
    createdAt: admin.firestore.Timestamp.now(),
  }
];

async function seed() {
  console.log('🚀 Seeding real Firestore database...');
  const batch = db.batch();

  doctors.forEach((doctor) => {
    const docRef = db.collection('doctors').doc();
    batch.set(docRef, doctor);
  });

  await batch.commit();
  console.log(`✅ Successfully seeded ${doctors.length} doctors into the REAL Firestore.`);
}

seed().catch(console.error);
