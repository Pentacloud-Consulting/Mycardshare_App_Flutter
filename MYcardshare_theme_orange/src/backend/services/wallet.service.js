import { GoogleAuth } from "google-auth-library";
import jwt from "jsonwebtoken";
import fs from "fs";
import path from "path";
import { env } from "../config/env";

const ISSUER_ID = env.ISSUER_ID;
const baseUrl = "https://walletobjects.googleapis.com/walletobjects/v1";

// ============================================
// IMAGE STORE (FOR GOOGLE WALLET CACHE BUSTING)
// ============================================
const imageStore = new Map();

function storeImage(userId, imageType, base64Data) {
  const timestamp = Date.now();
  const key = `${userId}_${imageType}_${timestamp}`;

  for (const [existingKey] of imageStore.entries()) {
    if (existingKey.startsWith(`${userId}_${imageType}_`)) {
      imageStore.delete(existingKey);
    }
  }

  imageStore.set(key, base64Data);
  return key;
}

function getImage(key) {
  return imageStore.get(key);
}

// ============================================
// GOOGLE AUTH CLIENT
// ============================================
let credentials = null;
try {
  // Try multiple paths for the wallet credentials
  const possiblePaths = [
    process.env.GOOGLE_APPLICATION_CREDENTIALS,
    path.resolve(process.cwd(), "google-wallet-key.json"),
    path.resolve(process.cwd(), "..", "google-wallet-key.json"),
    // Fall back to the Firebase Admin SDK key — same GCP project, same
    // service-account.  Works as long as the SA has the "Google Wallet
    // Object Issuer" IAM role.
    path.resolve(process.cwd(), "firebase-admin-key.json"),
  ].filter(Boolean);

  for (const credPath of possiblePaths) {
    try {
      if (fs.existsSync(credPath)) {
        credentials = JSON.parse(fs.readFileSync(credPath, "utf8"));
        console.log("✅ Wallet credentials loaded from:", credPath);
        break;
      }
    } catch {
      // path didn't work, try next
    }
  }

  if (!credentials && process.env.GOOGLE_WALLET_CREDENTIALS) {
    credentials = JSON.parse(process.env.GOOGLE_WALLET_CREDENTIALS);
    console.log("✅ Wallet credentials loaded from GOOGLE_WALLET_CREDENTIALS env");
  }

  if (!credentials) {
    console.warn(
      "⚠️  Wallet Service: No credentials file found. Tried:",
      possiblePaths.join(", "),
    );
  }
} catch (e) {
  console.error(
    "❌ Wallet Service Error: Failed to load credentials",
    e.message,
  );
}

const auth = new GoogleAuth({
  credentials,
  scopes: ["https://www.googleapis.com/auth/wallet_object.issuer"],
});

let authClient = null;

async function getAuthClient() {
  if (!authClient) {
    authClient = await auth.getClient();
  }
  return authClient;
}

async function makeApiRequest(endpoint, method = "GET", body = null) {
  const client = await getAuthClient();
  const url = `${baseUrl}${endpoint}`;

  const options = {
    method: method,
    headers: { "Content-Type": "application/json" },
  };

  if (body) {
    options.body = JSON.stringify(body);
  }

  const response = await client.request({ url, ...options });
  return response.data;
}

// ============================================
// HELPERS
// ============================================
function formatHexColor(color) {
  if (!color) return "#1e293b";
  let hex = color.replace("#", "");
  if (!/^[0-9A-Fa-f]{6}$/.test(hex)) return "#1e293b";
  return `#${hex}`;
}

function getValidImageUrl(url, type = "logo", userId = null) {
  if (!url || url.includes("placeholder") || typeof url !== "string")
    return null;

  if (url.startsWith("https://")) return url;

  if (url.startsWith("data:image/") && userId) {
    let backendUrl = process.env.BACKEND_URL || "";
    backendUrl = backendUrl.trim().replace(/\/$/, "");

    if (!backendUrl || backendUrl.includes("localhost")) {
      return "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&q=80&w=200";
    }

    const imageKey = storeImage(userId, type, url);
    // Next.js route: /api/wallet/image/[key]
    // Express route (if using standalone backend): /wallet/image/:key (depending on proxy/base path)
    // We standardize on the Next.js API path here.
    return `${backendUrl}/api/wallet/image/${imageKey}`;
  }
  return null;
}

// ============================================
// CORE WALLET LOGIC
// ============================================
const walletService = {
  getImageStore: () => imageStore,
  getImageByKey: (key) => getImage(key),

  /** False when service account JSON / env credentials are missing (common on Vercel without secrets). */
  isGoogleWalletConfigured() {
    return Boolean(credentials && ISSUER_ID);
  },

  async ensureGenericClass() {
    // Bumping the class ID forces Google Wallet to pick up the new template
    // layout for existing users (old cards still reference the v1 class).
    const classId = `${ISSUER_ID}.business_card_class_v2`;
    const genericClass = {
      id: classId,
      // Modern business-card layout:
      //   Row 1  →  Email   |   Phone       (two columns)
      //   Row 2  →  Website                 (full width)
      //   Row 3  →  Location                (full width)
      classTemplateInfo: {
        cardTemplateOverride: {
          cardRowTemplateInfos: [
            {
              twoItems: {
                startItem: {
                  firstValue: {
                    fields: [
                      { fieldPath: "object.textModulesData['email']" },
                    ],
                  },
                },
                endItem: {
                  firstValue: {
                    fields: [
                      { fieldPath: "object.textModulesData['phone']" },
                    ],
                  },
                },
              },
            },
            {
              oneItem: {
                item: {
                  firstValue: {
                    fields: [
                      { fieldPath: "object.textModulesData['website']" },
                    ],
                  },
                },
              },
            },
            {
              oneItem: {
                item: {
                  firstValue: {
                    fields: [
                      { fieldPath: "object.textModulesData['location']" },
                    ],
                  },
                },
              },
            },
          ],
        },
        // Keep the detail view tidy: surface the primary fields in a
        // predictable order instead of whatever arrival order the array has.
        detailsTemplateOverride: {
          detailsItemInfos: [
            {
              item: {
                firstValue: {
                  fields: [{ fieldPath: "object.textModulesData['email']" }],
                },
              },
            },
            {
              item: {
                firstValue: {
                  fields: [{ fieldPath: "object.textModulesData['phone']" }],
                },
              },
            },
            {
              item: {
                firstValue: {
                  fields: [{ fieldPath: "object.textModulesData['website']" }],
                },
              },
            },
            {
              item: {
                firstValue: {
                  fields: [{ fieldPath: "object.textModulesData['location']" }],
                },
              },
            },
          ],
        },
      },
    };

    try {
      try {
        await makeApiRequest(`/genericClass/${classId}`, "GET");
        await makeApiRequest(`/genericClass/${classId}`, "PUT", genericClass);
      } catch (getError) {
        if (getError.code === 404 || getError.response?.status === 404) {
          await makeApiRequest("/genericClass", "POST", genericClass);
        } else {
          throw getError;
        }
      }
      return classId;
    } catch (error) {
      console.error("❌ Error ensuring generic class:", error.message);
      throw error;
    }
  },

  async createWalletPass(cardData) {
    const objectId = `${ISSUER_ID}.${cardData.userId || Date.now()}`;
    const classId = `${ISSUER_ID}.business_card_class_v2`;
    const userId = cardData.userId || `user_${Date.now()}`;

    const logoUrl = getValidImageUrl(cardData.avatarUrl, "logo", userId);
    const bannerUrl = getValidImageUrl(cardData.bannerUrl, "banner", userId);

    const email = (cardData.workEmail || cardData.email || "").trim();
    const phone = (cardData.workPhone || cardData.phoneNumber || "").trim();
    const website = (cardData.website || "").trim();
    const locationParts = [
      cardData.address,
      cardData.city,
      cardData.country,
    ]
      .map((p) => (p || "").trim())
      .filter(Boolean);
    const location = locationParts.join(", ");

    // Structured contact rows — one logical module per field so the class
    // template can lay them out as its own row/column instead of one giant
    // mashed-together blob of text.
    const textModulesData = [
      email && { id: "email", header: "EMAIL", body: email },
      phone && { id: "phone", header: "PHONE", body: phone },
      website && { id: "website", header: "WEBSITE", body: website },
      location && { id: "location", header: "LOCATION", body: location },
    ].filter(Boolean);

    // Clickable action links shown under the card header on Android.
    const linkUris = [
      email && {
        uri: `mailto:${email}`,
        description: "Email",
        id: "link_email",
      },
      phone && {
        uri: `tel:${phone.replace(/[^+\d]/g, "")}`,
        description: "Call",
        id: "link_phone",
      },
      website && {
        uri: /^https?:\/\//i.test(website) ? website : `https://${website}`,
        description: "Website",
        id: "link_website",
      },
      cardData.publicCardUrl && {
        uri: cardData.publicCardUrl,
        description: "View full card",
        id: "link_card",
      },
    ].filter(Boolean);

    const genericObject = {
      id: objectId,
      classId: classId,
      state: "ACTIVE",
      // Company brand sits at the very top of the pass, next to the logo.
      cardTitle: {
        defaultValue: {
          language: "en-US",
          value: cardData.companyName || "Business Card",
        },
      },
      // Job title goes just above the big name so it reads like a
      // real business card: "Designer → Saad Khan".
      subheader: {
        defaultValue: {
          language: "en-US",
          value: cardData.jobTitle || "",
        },
      },
      // Primary, largest text on the card.
      header: {
        defaultValue: {
          language: "en-US",
          value: cardData.fullName || "Professional",
        },
      },
      textModulesData,
      linksModuleData: linkUris.length ? { uris: linkUris } : undefined,
      barcode: {
        type: "QR_CODE",
        value: cardData.publicCardUrl || "https://example.com",
        alternateText: "Scan to view full card",
      },
      hexBackgroundColor: formatHexColor(cardData.themeColor),
    };

    // Logo slot — the small circular image shown with the card header.
    if (logoUrl) {
      genericObject.logo = {
        sourceUri: { uri: logoUrl },
        contentDescription: {
          defaultValue: { language: "en-US", value: "Profile Logo" },
        },
      };
    }

    // Hero slot — the large banner strip. Prefer the user's cover banner so
    // the pass matches the live card preview; fall back to the avatar only
    // when no banner is available.
    const heroSourceUri = bannerUrl || logoUrl;
    if (heroSourceUri) {
      genericObject.heroImage = {
        sourceUri: { uri: heroSourceUri },
        contentDescription: {
          defaultValue: {
            language: "en-US",
            value: bannerUrl ? "Cover Banner" : "Profile Picture",
          },
        },
      };
    }

    try {
      await makeApiRequest("/genericObject", "POST", genericObject);
      return objectId;
    } catch (error) {
      if (error.code === 409 || error.response?.status === 409) {
        await makeApiRequest(
          `/genericObject/${objectId}`,
          "PUT",
          genericObject,
        );
        return objectId;
      }
      throw error;
    }
  },

  generateSaveUrl(objectId) {
    if (!credentials)
      throw new Error("Credentials mismatch for token signing.");

    const classId = `${ISSUER_ID}.business_card_class_v2`;
    const origin =
      env.CLIENT_ORIGIN ||
      process.env.FRONTEND_URL ||
      process.env.NEXT_PUBLIC_FRONTEND_URL ||
      "http://localhost:3000";
    const claims = {
      iss: credentials.client_email,
      aud: "google",
      origins: [origin],
      typ: "savetowallet",
      payload: {
        genericObjects: [{ id: objectId, classId: classId }],
      },
    };

    return jwt.sign(claims, credentials.private_key, { algorithm: "RS256" });
  },
};

export default walletService;
