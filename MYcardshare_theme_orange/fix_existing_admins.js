import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import fs from 'fs';

const serviceAccount = JSON.parse(fs.readFileSync('firebase-admin-key.json', 'utf8'));

initializeApp({
  credential: cert(serviceAccount)
});

const db = getFirestore();

async function run() {
  // Set status: "approved" on all existing super_admin, master_admin, platform_admin users
  const users = await db.collection('users').get();
  let updated = 0;
  
  for (const user of users.docs) {
    const data = user.data();
    const role = (data.role || '').toLowerCase();
    
    if (['super_admin', 'master_admin', 'platform_admin'].includes(role) && data.status !== 'approved') {
      await db.collection('users').doc(user.id).set(
        { status: 'approved' },
        { merge: true }
      );
      console.log(`✅ Set status=approved for ${user.id} (role: ${role})`);
      updated++;
    }
  }
  
  console.log(`\nDone. Updated ${updated} users.`);
}
run();
