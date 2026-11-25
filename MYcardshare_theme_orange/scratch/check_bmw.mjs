import { initializeApp, cert } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { getFirestore } from "firebase-admin/firestore";
import fs from "fs";

const creds = JSON.parse(fs.readFileSync("./firebase-admin-key.json", "utf8"));
initializeApp({ credential: cert(creds), projectId: creds.project_id });
const db = getFirestore();

async function check() {
  try {
    const user = await getAuth().getUserByEmail("waseem@bmw.com");
    console.log("Auth User:", user.uid, user.email);
    
    const userDoc = await db.collection("users").doc(user.uid).get();
    console.log("User Doc:", userDoc.data());

    const companyId = userDoc.data()?.companyId;
    if (companyId) {
      const companyDoc = await db.collection("companies").doc(companyId).get();
      console.log("Company Doc:", companyDoc.data());
    } else {
        const companies = await db.collection("companies").where("slug", "==", "bmw").get();
        if (!companies.empty) {
             console.log("Found company by slug:");
             companies.forEach(doc => console.log(doc.id, doc.data()));
        } else {
            console.log("No company with slug bmw found.");
        }
    }
  } catch (err) {
    console.error(err);
  }
}
check();
