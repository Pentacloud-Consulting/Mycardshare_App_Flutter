import { initializeApp, cert } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';
import fs from 'fs';

const serviceAccount = JSON.parse(fs.readFileSync('firebase-admin-key.json', 'utf8'));

initializeApp({
  credential: cert(serviceAccount)
});

const auth = getAuth();
const db = getFirestore();

async function setupAdmin() {
  const email = 'admin@pentacloud.com';
  const password = 'PentacloudAdmin2025!';
  
  console.log(`🚀 Starting setup for ${email}...`);

  let userRecord;
  try {
    // Check if user exists
    userRecord = await auth.getUserByEmail(email);
    console.log(`✅ User already exists in Firebase Auth (UID: ${userRecord.uid})`);
    
    // Update password
    await auth.updateUser(userRecord.uid, { password });
    console.log(`✅ Password updated successfully.`);
  } catch (error) {
    if (error.code === 'auth/user-not-found') {
      console.log(`➕ Creating new user in Firebase Auth...`);
      userRecord = await auth.createUser({
        email,
        password,
        emailVerified: true,
      });
      console.log(`✅ User created successfully (UID: ${userRecord.uid})`);
    } else {
      console.error('❌ Error in Firebase Auth:', error);
      return;
    }
  }

  // Update Firestore role
  try {
    await db.collection('users').doc(userRecord.uid).set({
      email,
      role: 'master_admin',
      onboardingCompleted: true,
      updatedAt: new Date().toISOString()
    }, { merge: true });
    console.log(`✅ Firestore record updated with "master_admin" role.`);
  } catch (error) {
    console.error('❌ Error in Firestore:', error);
  }

  console.log('\n──────────────────────────────────────────────────');
  console.log('🎉 SETUP COMPLETE!');
  console.log(`Email: ${email}`);
  console.log(`Password: ${password}`);
  console.log('──────────────────────────────────────────────────');
}

setupAdmin();
