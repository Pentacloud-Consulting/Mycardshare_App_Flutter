const admin = require('./DBC_Revamp - Copy/node_modules/firebase-admin');
const serviceAccount = require('./DBC_Revamp - Copy/firebase-admin-key.json');
const { MongoClient } = require('./DBC_Revamp - Copy/node_modules/mongodb');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const firestore = admin.firestore();
const uri = 'mongodb+srv://DBC_Pentacoud:Pentacloud2025@cluster0.yjflp6k.mongodb.net/business_cards?retryWrites=true&w=majority&appName=Cluster0';
const client = new MongoClient(uri, { serverSelectionTimeoutMS: 5000 });

async function syncMongoToFirestore() {
  console.log('Connecting to MongoDB...');
  await client.connect();
  const db = client.db();

  console.log('Fetching all cards from MongoDB...');
  const mongoCards = await db.collection('cards').find({}).toArray();
  console.log(`Found ${mongoCards.length} cards in MongoDB.`);

  let syncedCount = 0;
  for (const card of mongoCards) {
    const userId = card.userId;
    if (!userId) continue;

    const views = card.views || 0;
    const cardStatus = card.cardStatus || 'Draft';
    const isPublished = cardStatus === 'Published' || cardStatus === 'Active' || card.isPublished === true;

    try {
      // 1. Update users/{userId} doc
      await firestore.collection('users').doc(userId).set({
        views: views,
        cardViews: views,
        impressions: views,
        cardStatus: cardStatus,
        isPublished: isPublished,
        profileStatus: isPublished ? 'published' : 'draft',
        status: isPublished ? 'Active' : 'Draft',
        metrics: {
          views: views,
          viewsTrend: card.viewsTrend || '+0%',
          leads: 0,
          leadsTrend: '+0%',
          scans: 0,
          scansTrend: '+0%',
        }
      }, { merge: true });

      // 2. Also update cards/{userId} doc in Firestore
      await firestore.collection('cards').doc(userId).set({
        userId: userId,
        views: views,
        cardViews: views,
        impressions: views,
        cardStatus: cardStatus,
        isPublished: isPublished,
      }, { merge: true });

      if (views > 0 || userId === 'ogxbNjldE5YtIOQf4Y3TbMJMok52') {
        console.log(`Synced user ${userId}: views = ${views}, status = ${cardStatus}`);
      }
      syncedCount++;
    } catch (e) {
      console.error(`Failed to sync ${userId}:`, e.message);
    }
  }

  console.log(`\n✅ Successfully synced ${syncedCount} users from MongoDB to Firestore!`);
  await client.close();
  process.exit(0);
}

syncMongoToFirestore().catch(e => {
  console.error('Fatal sync error:', e);
  process.exit(1);
});
