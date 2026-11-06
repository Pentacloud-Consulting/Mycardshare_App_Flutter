const admin = require('./DBC_Revamp - Copy/node_modules/firebase-admin');
const serviceAccount = require('./DBC_Revamp - Copy/firebase-admin-key.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function updateEmails() {
  // Zuhaib UID from context summary
  const zuhaibUid = 'ogxbNjldE5YtIOQf4Y3TbMJMok52';
  // company email to set
  const companyEmail = 'contact@pentacloudconsulting.com';

  console.log('Starting Firestore email update...');

  // 1. Update Zuhaib
  try {
    await db.collection('users').doc(zuhaibUid).update({
      companyEmail: companyEmail,
    });
    console.log(`✅ Zuhaib (${zuhaibUid}) companyEmail updated to ${companyEmail}`);
  } catch (e) {
    console.error(`❌ Zuhaib update failed: ${e.message}`);
  }

  // 2. Find Tushti and other Pentacloud employees
  try {
    const entId = 'W3hDpYWqSgzFQJSb1ZcC'; // Pentacloud enterprise UID
    const empSnap = await db.collection('enterprises').doc(entId).collection('employees').get();
    console.log(`Found ${empSnap.docs.length} employees in Pentacloud enterprise`);

    for (const empDoc of empSnap.docs) {
      const empData = empDoc.data();
      const empEmail = empData.email || '';
      const empUid = empDoc.id;
      const empName = empData.name || empData.fullName || empUid;

      console.log(`  Employee: ${empName} | email: ${empEmail} | uid: ${empUid}`);

      // Update the employee doc
      await empDoc.ref.update({ companyEmail: companyEmail });

      // Also update user doc if uid is known
      if (empUid && empUid.length > 5) {
        try {
          await db.collection('users').doc(empUid).update({ companyEmail: companyEmail });
          console.log(`    ✅ User doc updated for ${empName}`);
        } catch (_) {
          // Try by email lookup
          if (empEmail) {
            const userQuery = await db.collection('users').where('email', '==', empEmail).limit(1).get();
            if (!userQuery.empty) {
              await userQuery.docs[0].ref.update({ companyEmail: companyEmail });
              console.log(`    ✅ User doc updated by email for ${empName}`);
            }
          }
        }
      }
    }
  } catch (e) {
    console.error(`Enterprise employees update error: ${e.message}`);
  }

  // 3. Also update enterprise doc itself
  try {
    const entId = 'W3hDpYWqSgzFQJSb1ZcC';
    await db.collection('enterprises').doc(entId).update({
      companyEmail: companyEmail,
      contactEmail: companyEmail,
    });
    console.log(`✅ Enterprise doc companyEmail updated`);
  } catch (e) {
    console.error(`Enterprise update error: ${e.message}`);
  }

  console.log('\nDone!');
  process.exit(0);
}

updateEmails().catch(console.error);
