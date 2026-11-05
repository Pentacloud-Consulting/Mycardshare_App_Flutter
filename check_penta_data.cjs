const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

const keyPath = path.resolve('DBC_Revamp - Copy', 'firebase-admin-key.json');
const credentials = JSON.parse(fs.readFileSync(keyPath, 'utf8'));

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(credentials)
  });
}

const db = admin.firestore();

async function check() {
  console.log("=== CHECKING USERS ===");
  const usersSnap = await db.collection('users').get();
  usersSnap.forEach(doc => {
    const d = doc.data();
    if ((d.email && d.email.toLowerCase().includes('pentacloud')) || (d.fullName && d.fullName.toLowerCase().includes('zuhaib'))) {
      console.log("USER DOC ID:", doc.id);
      console.log(JSON.stringify(d, null, 2));
    }
  });

  console.log("=== CHECKING ENTERPRISES ===");
  const entSnap = await db.collection('enterprises').get();
  entSnap.forEach(doc => {
    const d = doc.data();
    const str = JSON.stringify(d).toLowerCase();
    if (str.includes('penta')) {
      console.log("ENTERPRISE DOC ID:", doc.id);
      console.log(JSON.stringify(d, null, 2));
    }
  });
}

check().then(() => process.exit(0)).catch(e => { console.error(e); process.exit(1); });
