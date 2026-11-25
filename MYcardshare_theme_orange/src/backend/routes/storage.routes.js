import express from "express";
const router = express.Router();
import multer from "multer";
import { admin } from "../config/firebase";

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 15 * 1024 * 1024 },
});

const bucket = admin.storage().bucket();

async function uploadToGCS(fileBuffer, fileName, folder = "documents") {
  const blob = bucket.file(`${folder}/${Date.now()}_${fileName}`);
  const blobStream = blob.createWriteStream({
    resumable: false,
    metadata: { contentType: "auto" },
  });

  return new Promise((resolve, reject) => {
    blobStream.on("error", (err) => reject(err));
    blobStream.on("finish", () => {
      const publicUrl = `https://storage.googleapis.com/${bucket.name}/${blob.name}`;
      resolve(publicUrl);
    });
    blobStream.end(fileBuffer);
  });
}

router.post("/document", upload.single("file"), async (req, res) => {
  try {
    if (!req.file)
      return res.status(400).json({ success: false, error: "No file" });
    const url = await uploadToGCS(
      req.file.buffer,
      req.file.originalname,
      "documents",
    );
    res.json({ success: true, url });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

router.post("/profile-image", async (req, res) => {
  try {
    const { imageBase64, type, userId } = req.body;
    if (!imageBase64 || !type || !userId)
      return res.status(400).json({ success: false, error: "Missing fields" });

    const matches = imageBase64.match(/^data:image\/([a-zA-Z+]+);base64,(.+)$/);
    if (!matches)
      return res.status(400).json({ success: false, error: "Invalid format" });

    const buffer = Buffer.from(matches[2], "base64");
    const fileName = `${type}/${userId}_${Date.now()}.${matches[1]}`;
    const blob = bucket.file(fileName);

    await blob.save(buffer, {
      metadata: { contentType: `image/${matches[1]}` },
    });
    const url = `https://storage.googleapis.com/${bucket.name}/${fileName}`;
    res.json({ success: true, url });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

export default router;
