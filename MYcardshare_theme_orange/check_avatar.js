import { initializeApp, cert, getApps } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import fs from 'fs';

const serviceAccount = JSON.parse(fs.readFileSync('.env', 'utf8').match(/FIREBASE_SERVICE_ACCOUNT_KEY='(.*?)'/)[1]);

if (getApps().length === 0) {
  initializeApp({
    credential: cert(serviceAccount)
  });
}

const db = getFirestore();

async function run() {
  const users = await db.collection('users').get();
  for (const user of users.docs) {
    const data = user.data();
    if (data.avatarUrl && data.avatarUrl.includes('Ynnl')) {
      console.log('User UID:', user.id);
      console.log('Avatar URL in Firestore:', data.avatarUrl);
    }
  }
}
run();
