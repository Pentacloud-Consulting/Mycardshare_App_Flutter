const admin = require('./DBC_Revamp - Copy/node_modules/firebase-admin');
const serviceAccount = require('./DBC_Revamp - Copy/firebase-admin-key.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();
const companyEmail = 'contact@pentacloudconsulting.com';

async function run() {
  // Find Tushti by name or email
  console.log('Searching for Tushti...');
  const snap = await db.collection('users')
    .where('enterpriseUid', '==', 'W3hDpYWqSgzFQJSb1ZcC')
    .get();

  if (snap.empty) {
    console.log('No users found with enterpriseUid. Trying fullName search...');
    const snap2 = await db.collection('users').get();
    for (const doc of snap2.docs) {
      const d = doc.data();
      if ((d.fullName || '').toLowerCase().includes('tushti') || 
          (d.email || '').toLowerCase().includes('tushti') ||
          (d.name || '').toLowerCase().includes('tushti')) {
        console.log(`Found: ${doc.id} | name=${d.fullName || d.name} | email=${d.email}`);
        await doc.ref.update({ companyEmail: companyEmail });
        console.log(`✅ Updated companyEmail for ${d.fullName || doc.id}`);
      }
      // Also update waseem
      if ((d.fullName || '').toLowerCase().includes('waseem') ||
          (d.email || '').toLowerCase().includes('waseem')) {
        console.log(`Found Waseem: ${doc.id} | email=${d.email}`);
        await doc.ref.update({ companyEmail: companyEmail });
        console.log(`✅ Updated companyEmail for ${d.fullName || doc.id}`);
      }
    }
  } else {
    for (const doc of snap.docs) {
      const d = doc.data();
      console.log(`Enterprise user: ${doc.id} | ${d.fullName || d.name} | ${d.email}`);
      await doc.ref.update({ companyEmail: companyEmail });
      console.log(`✅ Updated companyEmail`);
    }
  }
  
  // Also check employees subcollection under multiple possible enterprise paths
  const entPaths = ['enterprises', 'companies', 'workspaces'];
  for (const col of entPaths) {
    try {
      const allEnts = await db.collection(col).limit(20).get();
      for (const ent of allEnts.docs) {
        const entData = ent.data();
        const name = (entData.companyName || entData.name || '').toLowerCase();
        if (name.includes('pentacloud')) {
          console.log(`Found Pentacloud in ${col}/${ent.id}: ${entData.companyName || entData.name}`);
          const empSnap = await ent.ref.collection('employees').get();
          console.log(`  ${empSnap.docs.length} employees`);
          for (const emp of empSnap.docs) {
            console.log(`  Employee: ${emp.id} | ${emp.data().name || emp.data().fullName}`);
            await emp.ref.update({ companyEmail: companyEmail });
          }
          // Update the enterprise/company doc too
          try { await ent.ref.update({ companyEmail, contactEmail: companyEmail }); } catch(_){}
        }
      }
    } catch(_) {}
  }

  console.log('\nDone!');
  process.exit(0);
}

run().catch(e => { console.error(e); process.exit(1); });
