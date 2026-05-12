const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const db = admin.firestore();

async function listDoctors() {
  console.log('Fetching doctors from mediconnect-4b155...');
  const snapshot = await db.collection('doctors').get();
  console.log(`Found ${snapshot.docs.length} doctors.`);
  snapshot.docs.forEach(doc => {
    const data = doc.data();
    console.log(`- ID: ${doc.id}, Name: ${data.name}, Status: ${data.status}`);
  });
}

listDoctors().catch(console.error);
