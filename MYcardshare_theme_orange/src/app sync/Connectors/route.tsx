import { NextRequest, NextResponse } from "next/server";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import { connectDB } from "@/backend/config/db";
import { apiAdapter, AppError } from "@/backend/utils/api-adapter";
import { success, fail } from "@/backend/utils/apiResponse";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

/**
 * INDIVIDUAL CONNECTORS & CRM WEBHOOK SYNC (APP <-> WEB)
 * 
 * Supports:
 * - GET /api/sync/individual-connectors
 *   Lists user's active CRM integrations (HubSpot, Zapier, Webhook, Salesforce, Zoho).
 * - POST /api/sync/individual-connectors
 *   Configures webhook URL, API Key, or toggles auto-sync when a new lead is captured.
 */

export const GET = apiAdapter(async (request: NextRequest) => {
  const context = await resolveAuth(request);
  const uid = context.uid;
  const db = await connectDB();

  const user = await db.collection("users").findOne({ uid });
  const connectorDoc = await db.collection("user_connectors").findOne({ userId: uid });

  const connectors = {
    zapier: {
      id: "zapier",
      name: "Zapier",
      icon: "https://cdn.iconscout.com/icon/free/png-256/free-zapier-3629165-3030282.png",
      isEnabled: Boolean(connectorDoc?.zapierWebhookUrl),
      webhookUrl: connectorDoc?.zapierWebhookUrl || "",
      description: "Trigger automations across 5,000+ apps when a lead exchanges contact.",
      lastTriggeredAt: connectorDoc?.zapierLastTriggeredAt || null,
    },
    hubspot: {
      id: "hubspot",
      name: "HubSpot CRM",
      icon: "https://cdn.iconscout.com/icon/free/png-256/free-hubspot-3628859-3030018.png",
      isEnabled: Boolean(connectorDoc?.hubspotApiKey),
      apiKey: connectorDoc?.hubspotApiKey ? "••••••••" + connectorDoc.hubspotApiKey.slice(-4) : "",
      description: "Directly sync card leads as new Contacts in your HubSpot CRM pipeline.",
      lastTriggeredAt: connectorDoc?.hubspotLastTriggeredAt || null,
    },
    customWebhook: {
      id: "custom_webhook",
      name: "Custom Webhook",
      icon: "https://cdn-icons-png.flaticon.com/512/875/875567.png",
      isEnabled: Boolean(connectorDoc?.customWebhookUrl),
      webhookUrl: connectorDoc?.customWebhookUrl || "",
      secretKey: connectorDoc?.webhookSecret ? "••••••••" : "",
      description: "POST incoming lead JSON payload to your custom server endpoint.",
      lastTriggeredAt: connectorDoc?.customWebhookLastTriggeredAt || null,
    },
    googleSheets: {
      id: "google_sheets",
      name: "Google Sheets",
      icon: "https://cdn.iconscout.com/icon/free/png-256/free-google-sheets-logo-icon-download-in-svg-png-gif-file-formats--spreadsheet-excel-google-apps-pack-logos-icons-3312388.png",
      isEnabled: Boolean(connectorDoc?.googleSheetId),
      sheetId: connectorDoc?.googleSheetId || "",
      description: "Append captured contacts directly to a live spreadsheet.",
    },
  };

  return NextResponse.json(
    success({
      autoSyncNewLeads: connectorDoc?.autoSyncNewLeads ?? true,
      activeIntegrationsCount: Object.values(connectors).filter((c) => c.isEnabled).length,
      connectors,
    })
  );
});

export const POST = apiAdapter(async (request: NextRequest) => {
  const context = await resolveAuth(request);
  const uid = context.uid;

  const body = await request.json();
  const { connectorId, config = {}, autoSyncNewLeads } = body;

  const db = await connectDB();
  const updatePayload: any = {
    userId: uid,
    updatedAt: new Date(),
  };

  if (autoSyncNewLeads !== undefined) {
    updatePayload.autoSyncNewLeads = Boolean(autoSyncNewLeads);
  }

  if (connectorId === "zapier") {
    updatePayload.zapierWebhookUrl = config.webhookUrl || "";
  } else if (connectorId === "hubspot") {
    updatePayload.hubspotApiKey = config.apiKey || "";
  } else if (connectorId === "custom_webhook") {
    updatePayload.customWebhookUrl = config.webhookUrl || "";
    if (config.secretKey) updatePayload.webhookSecret = config.secretKey;
  } else if (connectorId === "google_sheets") {
    updatePayload.googleSheetId = config.sheetId || "";
  }

  await db.collection("user_connectors").updateOne(
    { userId: uid },
    { $set: updatePayload },
    { upsert: true }
  );

  return NextResponse.json(
    success({
      message: `Connector '${connectorId || "settings"}' saved successfully.`,
      updatedConfig: updatePayload,
    })
  );
});
