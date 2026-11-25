import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import fs from 'fs';

const serviceAccount = JSON.parse(fs.readFileSync('firebase-admin-key.json', 'utf8'));

initializeApp({
  credential: cert(serviceAccount)
});

const db = getFirestore();

async function run() {
  console.log('Searching for Master Admin users...');
  const users = await db.collection('users').where('role', '==', 'master_admin').get();
  
  if (users.empty) {
    console.log('No users with "master_admin" role found.');
    
    console.log('\nOther users found:');
    const allUsers = await db.collection('users').limit(10).get();
    for (const user of allUsers.docs) {
      const data = user.data();
      console.log(`- UID: ${user.id}, Email: ${data.email || 'N/A'}, Role: ${data.role || 'N/A'}`);
    }
  } else {
    for (const user of users.docs) {
      const data = user.data();
      console.log(`FOUND Master Admin:`);
      console.log(`- UID: ${user.id}`);
      console.log(`- Email: ${data.email}`);
      console.log(`- Name: ${data.fullName}`);
    }
  }
}
run();
