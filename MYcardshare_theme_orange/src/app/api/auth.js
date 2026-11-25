import { NextResponse } from "next/server";
import { admin, firestoreDb } from "../../../../backend/config/firebase";

export async function verifyAuth(request) {
  const authHeader = request.headers.get("authorization");
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return { error: "Authentication required", status: 401 };
  }

  const token = authHeader.split("Bearer ")[1];
  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    return { uid: decodedToken.uid, email: decodedToken.email };
  } catch (error) {
    return { error: "Invalid or expired token", status: 401 };
  }
}
