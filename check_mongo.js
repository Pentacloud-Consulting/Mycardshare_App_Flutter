const { MongoClient } = require('./DBC_Revamp - Copy/node_modules/mongodb');
const fs = require('fs');

// Read MONGODB_URI from .env or .env.local
let uri = process.env.MONGODB_URI;
if (!uri) {
  try {
    const env = fs.readFileSync('./DBC_Revamp - Copy/.env.local', 'utf8');
    for (const line of env.split('\n')) {
      if (line.startsWith('MONGODB_URI=')) {
        uri = line.substring('MONGODB_URI='.length).trim();
      }
    }
  } catch(e) {}
}
if (!uri) {
  try {
    const env = fs.readFileSync('./DBC_Revamp - Copy/.env', 'utf8');
    for (const line of env.split('\n')) {
      if (line.startsWith('MONGODB_URI=')) {
        uri = line.substring('MONGODB_URI='.length).trim();
      }
    }
  } catch(e) {}
}

console.log('MongoDB URI exists:', !!uri);
if (!uri) process.exit(1);

const client = new MongoClient(uri, { serverSelectionTimeoutMS: 5000 });

async function run() {
  try {
    await client.connect();
    const db = client.db();
    const cards = await db.collection('cards').find({}).toArray();
    console.log(`Found ${cards.length} cards in MongoDB:`);
    for (const c of cards) {
      if (c.views || (c.userId && (c.userId.includes('ogxb') || c.userId.includes('waseem')))) {
        console.log(`Card: userId=${c.userId}, views=${c.views}, cardStatus=${c.cardStatus}, title=${c.title || c.name}`);
      }
    }
    const users = await db.collection('users').find({ email: /waseem|zuhaib/i }).toArray();
    console.log(`Found ${users.length} users in MongoDB:`);
    for (const u of users) {
      console.log(`User: _id=${u._id}, uid=${u.uid || u.userId}, email=${u.email}, views=${u.views}`);
    }
  } catch (e) {
    console.log('MongoDB error:', e.message);
  } finally {
    await client.close();
  }
}
run();
