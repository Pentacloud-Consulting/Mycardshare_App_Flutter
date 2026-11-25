import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import storageService from "@/backend/services/storage.service";
import { success } from "@/backend/utils/apiResponse";

// Diagnostic endpoint — tells you at a glance whether uploads will go to
// GCS (and which bucket) or fall back to local /public/uploads. Hit it any
// time you need to debug the "GCS_UPLOAD_FAILED" class of errors.
//
//   GET /api/storage/status
//   → { gcs: { ready, bucket }, local: { enabled, folder }, mode, maxUploadMB }
export const runtime = "nodejs";
export const dynamic = "force-dynamic";

export const GET = apiAdapter(async () => {
  const status = await storageService.getStorageStatus();
  return NextResponse.json(success(status));
});
