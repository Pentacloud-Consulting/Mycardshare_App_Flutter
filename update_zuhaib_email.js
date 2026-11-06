const admin = require('./DBC_Revamp - Copy/node_modules/firebase-admin');
const serviceAccount = require('./DBC_Revamp - Copy/firebase-admin-key.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();
const targetEmail = 'contact@pentacloudconsulting.com';

async function updateZuhaibAndAll() {
  console.log('Searching for Zuhaib and Tushti in all collections...');
  const usersSnap = await db.collection('users').get();
  for (const doc of usersSnap.docs) {
    const d = doc.data();
    const str = JSON.stringify(d).toLowerCase();
    if (str.includes('zuhaib') || str.includes('tushti')) {
      console.log(`User Match: [${doc.id}] ${d.fullName || d.name} | email: ${d.email}`);
      await doc.ref.update({
        companyEmail: targetEmail,
      });
      console.log(`  Updated user ${doc.id} companyEmail to ${targetEmail}`);
    }
  }

  // Also check employees across all companies/enterprises
  for (const col of ['companies', 'enterprises', 'workspaces']) {
    try {
      const snap = await db.collection(col).get();
      for (const entDoc of snap.docs) {
        const empSnap = await entDoc.ref.collection('employees').get();
        for (const emp of empSnap.docs) {
          const ed = emp.data();
          const estr = JSON.stringify(ed).toLowerCase();
          if (estr.includes('zuhaib') || estr.includes('tushti') || estr.includes('pentacloud')) {
            console.log(`Employee Match in ${col}/${entDoc.id}/employees/${emp.id}: ${ed.fullName || ed.name || ed.email}`);
            await emp.ref.update({
              companyEmail: targetEmail,
            });
            console.log(`  Updated employee ${emp.id} companyEmail to ${targetEmail}`);
          }
        }
      }
    } catch (e) {
      console.error(`Error in ${col}:`, e.message);
    }
  }

  console.log('Finished updating company emails!');
  process.exit(0);
}

updateZuhaibAndAll().catch(e => {
  console.error(e);
  process.exit(1);
});
