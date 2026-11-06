const admin = require('./DBC_Revamp - Copy/node_modules/firebase-admin');
const serviceAccount = require('./DBC_Revamp - Copy/firebase-admin-key.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function inspectViews() {
  const users = await db.collection('users').get();
  for (const doc of users.docs) {
    const d = doc.data();
    const str = JSON.stringify(d).toLowerCase();
    if (str.includes('waseem') || str.includes('zuhaib') || str.includes('tushti')) {
      console.log(`\n--- User: ${doc.id} (${d.fullName || d.name} - ${d.email}) ---`);
      console.log('User fields: views =', d.views, 'cardViews =', d.cardViews, 'impressions =', d.impressions, 'metrics =', d.metrics);
      
      // Check subcollections
      const analyticsSnap = await doc.ref.collection('analytics').get();
      for (const a of analyticsSnap.docs) {
        console.log(`  analytics/${a.id}:`, a.data());
      }
      const viewsSnap = await doc.ref.collection('views').get();
      console.log(`  views collection count:`, viewsSnap.docs.length);
    }
  }

  // Also check cards collection
  console.log('\n--- Checking cards collection ---');
  const cards = await db.collection('cards').get();
  for (const c of cards.docs) {
    const cd = c.data();
    if (cd.views || cd.impressions) {
      console.log(`Card ${c.id} (user: ${cd.userId}): views = ${cd.views}, impressions = ${cd.impressions}, cardStatus = ${cd.cardStatus}`);
    }
  }

  process.exit(0);
}

inspectViews().catch(console.error);
