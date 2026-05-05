/**
 * Creates a test user in Firebase Auth for testing login
 * Run: node src/scripts/create-test-user.js
 */
import admin from 'firebase-admin';
import { readFileSync } from 'fs';
import dotenv from 'dotenv';
dotenv.config();

const sa = JSON.parse(readFileSync('./serviceAccountKey.json', 'utf8'));
admin.initializeApp({ credential: admin.credential.cert(sa) });

async function createTestUser() {
  console.log('👤 Creating test users...\n');

  const users = [
    {
      email: 'patient@darman.af',
      password: 'Darman2026!',
      displayName: 'Ahmad Khan (Test Patient)',
      role: 'patient',
    },
    {
      email: 'doctor@darman.af',
      password: 'Darman2026!',
      displayName: 'Dr. Test Doctor',
      role: 'doctor',
    },
    {
      email: 'admin@darman.af',
      password: 'Darman2026!',
      displayName: 'DARMAN Admin',
      role: 'admin',
    },
  ];

  for (const user of users) {
    try {
      // Check if user already exists
      try {
        const existing = await admin.auth().getUserByEmail(user.email);
        console.log(`ℹ️  User already exists: ${user.email} (uid: ${existing.uid})`);
        continue;
      } catch (_) {
        // User doesn't exist, create it
      }

      const created = await admin.auth().createUser({
        email: user.email,
        password: user.password,
        displayName: user.displayName,
        emailVerified: true,
      });

      // Set custom claims for role
      await admin.auth().setCustomUserClaims(created.uid, { role: user.role });

      console.log(`✅ Created: ${user.email}`);
      console.log(`   UID: ${created.uid}`);
      console.log(`   Role: ${user.role}`);
      console.log(`   Password: ${user.password}\n`);
    } catch (e) {
      console.error(`❌ Failed to create ${user.email}:`, e.message);
    }
  }

  console.log('\n🎉 Test users ready!');
  console.log('\n📱 Login credentials:');
  console.log('   Patient:  patient@darman.af  /  Darman2026!');
  console.log('   Doctor:   doctor@darman.af   /  Darman2026!');
  console.log('   Admin:    admin@darman.af     /  Darman2026!');
  console.log('\n🌐 Test at: https://mediconnect-4b155.web.app');

  process.exit(0);
}

createTestUser().catch(e => {
  console.error('❌', e.message);
  process.exit(1);
});
