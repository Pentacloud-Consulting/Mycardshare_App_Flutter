import { MongoClient } from "mongodb";
import { env } from "./env";
import dns from "dns";

// Override default DNS servers to bypass Windows/ISP local DNS blocks on SRV queries
try {
  dns.setServers(["8.8.8.8", "1.1.1.1"]);
} catch (error) {
  console.warn("Could not set custom DNS servers:", error);
}

const MONGODB_URI = env.MONGODB_URI;

// Use global scoped caching for connection pooling in Next.js Serverless runtime
let cachedClient = global.mongoClient;
let cachedDb = global.mongoDb;

if (!cachedClient) {
  cachedClient = global.mongoClient = null;
  cachedDb = global.mongoDb = null;
}

export async function connectDB() {
  if (!MONGODB_URI) {
    throw new Error("MONGODB_URI is not configured");
  }

  if (cachedDb && cachedClient) return cachedDb;

  try {
    if (cachedClient) {
      try {
        await cachedClient.close();
      } catch (e) {}
    }

    console.log("🔄 Connecting to MongoDB...");
    cachedClient = new MongoClient(MONGODB_URI, {
      maxPoolSize: 10,
      serverSelectionTimeoutMS: 15000,
      connectTimeoutMS: 15000,
      socketTimeoutMS: 45000,
    });

    global.mongoClient = cachedClient;
    await cachedClient.connect();
    console.log("✅ Connected to MongoDB");

    const db = cachedClient.db("business_cards");
    cachedDb = db;
    global.mongoDb = db;

    cachedClient.on("close", () => {
      console.log("⚠️ MongoDB connection closed.");
      if (global.mongoClient === cachedClient) {
        cachedDb = null;
        cachedClient = null;
        global.mongoClient = null;
        global.mongoDb = null;
      }
    });

    // Indexes are typically handled once on startup or via migrations
    const cardsCollection = db.collection("cards");
    // Only attempt index creation if desired
    cardsCollection
      .createIndex({ userId: 1 }, { unique: true })
      .catch(() => {});
    cardsCollection
      .createIndex({ cardSlug: 1 }, { sparse: true })
      .catch(() => {});

    const leadsCollection = db.collection("leads");
    leadsCollection.createIndex({ companyId: 1 }).catch(() => {});
    leadsCollection.createIndex({ mobile: 1 }).catch(() => {});
    leadsCollection.createIndex({ companyId: 1, mobile: 1 }).catch(() => {});

    return cachedDb;
  } catch (e) {
    console.error("❌ MongoDB connection error:", e);
    cachedDb = null;
    cachedClient = null;
    throw e;
  }
}
