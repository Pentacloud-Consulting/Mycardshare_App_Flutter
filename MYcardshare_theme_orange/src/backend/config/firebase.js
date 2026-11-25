import firebaseAdminPkg from "firebase-admin";
import fs from "fs";
import path from "path";

let firebaseAdmin = null;
let _firestoreDb = null;

/**
 * Find the first candidate bucket name that actually exists for our admin
 * credentials. Returns the live Bucket handle (or `null` if none match).
 *
 * `bucket.exists()` costs a single HEAD so this is cheap and avoids every
 * image upload individually failing with "bucket does not exist".
 */
async function resolveStorageBucket(adminPkg, candidates) {
  for (const name of candidates) {
    try {
      const bucket = adminPkg.storage().bucket(name);
      const [exists] = await bucket.exists();
      if (exists) return bucket;
      console.warn(`⚠️  Storage bucket "${name}" not found, trying next…`);
    } catch (err) {
      console.warn(
        `⚠️  Storage bucket probe failed for "${name}":`,
        err?.message || err,
      );
    }
  }
  return null;
}

function initializeFirebase() {
  if (firebaseAdminPkg.apps.length > 0) {
    return {
      admin: firebaseAdminPkg,
      firestoreDb: firebaseAdminPkg.firestore(),
    };
  }

  try {
    console.log("📁 Loading Firebase Admin credentials...");
    let credentials;

    // 1. Prioritize Environment Variables for Vercel/Production
    if (
      process.env.FIREBASE_PROJECT_ID &&
      process.env.FIREBASE_CLIENT_EMAIL &&
      process.env.FIREBASE_PRIVATE_KEY
    ) {
      credentials = {
        project_id: process.env.FIREBASE_PROJECT_ID,
        client_email: process.env.FIREBASE_CLIENT_EMAIL,
        private_key: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, "\n"),
      };
      console.log("✅ Loaded credentials from Environment Variables");
    } else {
      // 2. Fallback to local file for Development
      let firebaseAdminPath = path.resolve(
        process.cwd(),
        "firebase-admin-key.json",
      );

      if (!fs.existsSync(firebaseAdminPath)) {
        firebaseAdminPath = path.resolve(
          process.cwd(),
          "..",
          "firebase-admin-key.json",
        );
      }

      if (!fs.existsSync(firebaseAdminPath)) {
        throw new Error(
          `firebase-admin-key.json not found and Environment Variables are missing.`,
        );
      }

      credentials = JSON.parse(fs.readFileSync(firebaseAdminPath, "utf8"));
      console.log("✅ Loaded credentials from local JSON file");
    }

    // Resolve the storage bucket. Priority:
    //   1. FIREBASE_STORAGE_BUCKET env (explicit override)
    //   2. `storageBucket` field inside the admin key JSON (if present)
    //   3. Project-derived default: <projectId>.firebasestorage.app
    //      (modern Firebase Storage bucket naming)
    //   4. Legacy default: <projectId>.appspot.com (older projects)
    // We initialize with the first candidate and probe the rest lazily if
    // the first one turns out not to exist — this stops the "bucket does
    // not exist" upload error when a project is on the older naming.
    const bucketCandidates = [
      process.env.FIREBASE_STORAGE_BUCKET,
      credentials.storageBucket,
      `${credentials.project_id}.firebasestorage.app`,
      `${credentials.project_id}.appspot.com`,
    ]
      .map((b) => (typeof b === "string" ? b.trim() : ""))
      .filter(Boolean)
      // de-dupe while preserving order
      .filter((b, i, arr) => arr.indexOf(b) === i);

    const primaryBucket = bucketCandidates[0];

    firebaseAdmin = firebaseAdminPkg.initializeApp({
      credential: firebaseAdminPkg.credential.cert(credentials),
      projectId: credentials.project_id,
      storageBucket: primaryBucket,
    });

    _firestoreDb = firebaseAdminPkg.firestore();
    console.log("✅ Firebase Admin SDK initialized for Firestore");

    // Probe each candidate bucket and wire up the first one that really
    // exists. We expose the probe as a global promise so the first upload
    // request can `await` the resolution rather than racing it and falling
    // back to local storage unnecessarily.
    // Skip the probe entirely at build time — storage is only needed at
    // runtime when actual upload requests arrive.
    global.gcsBucket = null;
    const isBuildPhase = process.env.NEXT_PHASE === "phase-production-build";
    if (isBuildPhase) {
      global.gcsBucketReady = Promise.resolve(null);
    } else {
      global.gcsBucketReady = resolveStorageBucket(
        firebaseAdminPkg,
        bucketCandidates,
      )
        .then((resolved) => {
          if (resolved) {
            global.gcsBucket = resolved;
            console.log(`✅ Storage bucket wired for uploads: ${resolved.name}`);
          } else {
            console.warn(
              "⚠️  No writable Firebase Storage bucket found. Tried: " +
                bucketCandidates.join(", ") +
                ". Uploads will use the local /public/uploads filesystem.",
            );
          }
          return resolved;
        })
        .catch((err) => {
          console.error(
            "⚠️  Storage bucket probe failed:",
            err?.message || err,
          );
          return null;
        });
    }

    return { admin: firebaseAdminPkg, firestoreDb: _firestoreDb };
  } catch (error) {
    console.error("❌ Error initializing Firebase Admin SDK:", error.message);
    return { admin: null, firestoreDb: null };
  }
}

const firebaseConfig = initializeFirebase();
export const admin = firebaseConfig.admin;
export const firestoreDb = firebaseConfig.firestoreDb;
export const firebaseApp = admin;
export const db = firestoreDb;
export default firebaseConfig;
