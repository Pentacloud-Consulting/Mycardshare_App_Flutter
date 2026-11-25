import { connectDB } from "./src/backend/config/db.js";

async function checkCards() {
  try {
    const db = await connectDB();
    const cards = await db.collection("cards").find({}).limit(5).toArray();
    console.log("Current Cards in MongoDB:", JSON.stringify(cards, null, 2));
  } catch (err) {
    console.error("Error checking cards:", err);
  } finally {
    process.exit();
  }
}

checkCards();
