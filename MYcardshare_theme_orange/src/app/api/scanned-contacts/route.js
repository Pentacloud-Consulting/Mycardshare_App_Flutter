import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import { connectDB } from "@/backend/config/db";
import { firestoreDb } from "@/backend/config/firebase";
import { success } from "@/backend/utils/apiResponse";

/**
 * Helper to fetch and merge contacts from both MongoDB and Firestore
 */
export async function getMergedContacts(userId) {
  let mongoContacts = [];
  try {
    const db = await connectDB();
    mongoContacts = await db
      .collection("contacts")
      .find({ userId })
      .sort({ createdAt: -1 })
      .limit(200)
      .toArray();
  } catch (err) {
    console.warn("[Contacts] MongoDB fetch failed:", err?.message);
  }

  let firestoreContacts = [];
  try {
    const snap = await firestoreDb
      .collection("users")
      .doc(userId)
      .collection("contacts")
      .get();

    firestoreContacts = snap.docs.map((doc) => {
      const d = doc.data();
      return {
        _id: doc.id,
        id: doc.id,
        userId,
        fullName: d.name || d.fullName || "Contact",
        name: d.name || d.fullName || "Contact",
        jobTitle: d.role || d.jobTitle || "",
        role: d.role || d.jobTitle || "",
        company: d.company || "",
        phone: d.phone || "",
        phone2: d.phone2 || "",
        email: d.email || "",
        website: d.website || "",
        address: d.address || "",
        notes: d.notes || "",
        tag: d.tag || "Manual",
        source: d.tag || "mobile",
        createdAt: d.createdAt?.toDate?.() || (d.dateAdded ? new Date(d.dateAdded) : new Date()),
      };
    });
  } catch (err) {
    console.warn("[Contacts] Firestore fetch failed:", err?.message);
  }

  const seen = new Set();
  const merged = [];

  for (const c of [...firestoreContacts, ...mongoContacts]) {
    const email = (c.email || "").toLowerCase().trim();
    const phone = (c.phone || "").replace(/\D/g, "");
    const name = (c.fullName || c.name || "").toLowerCase().trim();
    const key = email || phone || (name ? `${name}_${(c.company || "").toLowerCase().trim()}` : String(c._id || c.id));

    if (key && seen.has(key)) continue;
    if (key) seen.add(key);

    merged.push({
      ...c,
      _id: c._id ? String(c._id) : c.id,
      id: c.id || String(c._id),
      fullName: c.fullName || c.name || "Contact",
      name: c.name || c.fullName || "Contact",
      jobTitle: c.jobTitle || c.role || "",
      role: c.role || c.jobTitle || "",
    });
  }

  return merged;
}

/**
 * GET /api/scanned-contacts — List scanned contacts for user
 */
export const GET = apiAdapter(async (request) => {
  const context = await resolveAuth(request);
  const contacts = await getMergedContacts(context.uid);
  return NextResponse.json(success(contacts));
});

/**
 * POST /api/scanned-contacts — Save a scanned contact (Dual-write to Mongo & Firestore)
 */
export const POST = apiAdapter(async (request) => {
  const context = await resolveAuth(request);
  const body = await request.json();

  const db = await connectDB();

  const contact = {
    userId: context.uid,
    fullName: body.fullName || "",
    email: body.email || "",
    phone: body.phone || "",
    phone2: body.phone2 || "",
    company: body.company || "",
    jobTitle: body.jobTitle || "",
    website: body.website || "",
    address: body.address || "",
    notes: body.notes || "",
    cardImageUrl: body.cardImageUrl || null,
    raw_transcript: body.raw_transcript || "",
    source: body.source || "scanner",
    createdAt: new Date(),
  };

  const result = await db.collection("contacts").insertOne(contact);
  const contactId = String(result.insertedId);

  // Dual-write to Firestore for instant mobile sync
  try {
    await firestoreDb
      .collection("users")
      .doc(context.uid)
      .collection("contacts")
      .doc(contactId)
      .set({
        id: contactId,
        name: contact.fullName,
        fullName: contact.fullName,
        role: contact.jobTitle,
        jobTitle: contact.jobTitle,
        company: contact.company,
        phone: contact.phone,
        phone2: contact.phone2,
        email: contact.email,
        website: contact.website,
        address: contact.address,
        notes: contact.notes,
        tag: contact.source === "scanner" ? "OCR" : "Manual",
        dateAdded: new Date().toISOString(),
        createdAt: new Date(),
      }, { merge: true });
  } catch (fsErr) {
    console.warn("[scanned-contacts] Firestore dual-write notice:", fsErr.message);
  }

  return NextResponse.json(
    success({ ...contact, _id: result.insertedId }),
    { status: 201 },
  );
});
