/**
 * Backend Auth Handler Middleware
 * Captures decodedToken.picture from Google Sign-In / Firebase Auth token
 * and synchronizes avatarUrl & photoURL into user and digital card documents.
 */

// Simulating Firestore / MongoDB sync handler
const syncGoogleProfilePicture = async (decodedToken, db) => {
  try {
    const uid = decodedToken.uid || decodedToken.user_id;
    const email = decodedToken.email || "";
    const name = decodedToken.name || decodedToken.displayName || "";
    // Google profile picture standard claim: 'picture'
    const picture = decodedToken.picture || decodedToken.photoURL || null;

    if (!uid) return;

    const userUpdates = {
      uid,
      email: email.toLowerCase(),
      fullName: name,
      displayName: name,
      updatedAt: new Date().toISOString(),
    };

    if (picture) {
      // Save in all common key representations to prevent client/server key mismatch
      userUpdates.avatarUrl = picture;
      userUpdates.photoURL = picture;
      userUpdates.picture = picture;
      userUpdates.profilePhoto = picture;
    }

    // Update or insert into Firestore / DB
    if (db) {
      await db.collection("users").doc(uid).set(userUpdates, { merge: true });

      // Check if user card has avatarUrl missing, if so auto-populate
      const cardDoc = await db.collection("cards").where("userId", "==", uid).limit(1).get();
      if (!cardDoc.empty && picture) {
        const cardData = cardDoc.docs[0].data();
        if (!cardData.avatarUrl && !cardData.profilePhoto) {
          await cardDoc.docs[0].ref.update({
            avatarUrl: picture,
            profilePhoto: picture,
            photoURL: picture,
            updatedAt: new Date().toISOString(),
          });
        }
      }
    }

    return userUpdates;
  } catch (error) {
    console.error("[AuthHandler] Error syncing Google profile photo:", error);
  }
};

/**
 * Verifies Master Admin authorization from Firebase decodedToken
 * Recognizes platform administrator emails (admin@pentcloud.me, master admin claims)
 */
const resolveMasterAdminAuth = (decodedToken) => {
  if (!decodedToken) return false;
  const email = (decodedToken.email || "").toLowerCase();
  const isAdminClaim = decodedToken.admin === true || decodedToken.role === "master-admin";
  const isMasterAdminEmail =
    email === "admin@pentcloud.me" ||
    email.includes("masteradmin") ||
    email.endsWith("@pentacloud.me") ||
    email.endsWith("@mycardshare.com");
  return isAdminClaim || isMasterAdminEmail;
};

module.exports = {
  syncGoogleProfilePicture,
  resolveMasterAdminAuth,
};

