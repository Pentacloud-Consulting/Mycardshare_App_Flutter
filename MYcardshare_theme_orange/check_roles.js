import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import fs from 'fs';

const serviceAccount = JSON.parse(fs.readFileSync('firebase-admin-key.json', 'utf8'));

initializeApp({
  credential: cert(serviceAccount)
});

const db = getFirestore();

async function run() {
  const users = await db.collection('users').get();
  console.log(`Total users: ${users.size}\n`);
  for (const user of users.docs) {
    const data = user.data();
    console.log(`UID: ${user.id} | role: ${data.role || '(none)'} | type: ${data.type || '(none)'} | status: ${data.status || data.approvalStatus || '(none)'} | onboarding: ${data.onboardingCompleted} | company: ${data.companyId || data.companyName || '(none)'}`);
  }
}
run();
