import jwt from "jsonwebtoken";
import fs from "fs";
import path from "path";

const lib = {
  createSamsungCdata(cardData) {
    const now = Math.floor(Date.now() / 1000);
    return {
      card: {
        type: "ticket",
        subType: "others",
        data: [
          {
            refId: cardData.userId || `user_${Date.now()}`,
            createdAt: now * 1000,
            updatedAt: now * 1000,
            language: "en",
            attributes: {
              title: cardData.fullName || "Business Card",
              subtitle: cardData.jobTitle || "",
              providerName: cardData.companyName || "Pentacloud",
              classification: "membership",
            },
            barcode: {
              type: "QR",
              value: cardData.publicCardUrl || "",
              ptFormat: "qrcodeSerial",
            },
          },
        ],
      },
    };
  },

  generateSamsungWalletUrl(cdata) {
    const partnerId = process.env.SAMSUNG_PARTNER_ID;
    const cardId = process.env.SAMSUNG_CARD_ID;
    const keyPath =
      process.env.SAMSUNG_PRIVATE_KEY_PATH ||
      path.resolve(__dirname, "../samsung-private-key.pem");

    if (!fs.existsSync(keyPath)) throw new Error("Samsung key missing");
    const privateKey = fs.readFileSync(keyPath, "utf8");

    const now = Math.floor(Date.now() / 1000);
    const token = jwt.sign(
      {
        iat: now,
        exp: now + 30,
        partnerId,
        cdata,
      },
      privateKey,
      { algorithm: "RS256" },
    );

    return `https://a.swallet.link/atw/v3/${cardId}#Clip?cdata=${encodeURIComponent(token)}`;
  },
};

export default lib;
