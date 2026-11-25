import { NextResponse } from "next/server";
import fs from "fs";
import path from "path";

export const runtime = "nodejs";

export async function GET(request, { params }) {
  const { path: filePathArray } = await params;
  
  if (!filePathArray || filePathArray.length === 0) {
    return new NextResponse("Not Found", { status: 404 });
  }

  // Prevent directory traversal attacks
  const safePath = path.normalize(path.join(...filePathArray)).replace(/^(\.\.(\/|\\|$))+/, '');
  const fullPath = path.join(process.cwd(), "public", "uploads", safePath);

  if (!fs.existsSync(fullPath)) {
    return new NextResponse("Not Found", { status: 404 });
  }

  const ext = path.extname(fullPath).toLowerCase();
  let contentType = "application/octet-stream";
  if (ext === ".jpg" || ext === ".jpeg") contentType = "image/jpeg";
  else if (ext === ".png") contentType = "image/png";
  else if (ext === ".gif") contentType = "image/gif";
  else if (ext === ".webp") contentType = "image/webp";
  else if (ext === ".svg") contentType = "image/svg+xml";
  else if (ext === ".pdf") contentType = "application/pdf";
  else if (ext === ".doc") contentType = "application/msword";
  else if (ext === ".docx") contentType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document";

  try {
    const fileBuffer = await fs.promises.readFile(fullPath);
    
    return new NextResponse(fileBuffer, {
      headers: {
        "Content-Type": contentType,
        "Cache-Control": "public, max-age=86400, immutable",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, HEAD, OPTIONS",
        "Access-Control-Allow-Headers": "*",
      },
    });
  } catch (err) {
    return new NextResponse("Error reading file", { 
      status: 500,
      headers: { "Access-Control-Allow-Origin": "*" }
    });
  }
}
