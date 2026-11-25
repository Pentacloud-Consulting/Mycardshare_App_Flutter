import { connectDB } from "../config/db";
import { firestoreDb } from "../config/firebase";
import { ObjectId } from "mongodb";

const leadService = {
  async createLead(leadData) {
    const db = await connectDB();
    const collection = db.collection("leads");

    // Check for duplicate within the same company or agent
    if (leadData.mobile) {
      const duplicateQuery = leadData.companyId 
        ? { companyId: leadData.companyId, mobile: leadData.mobile }
        : { agentId: leadData.agentId, mobile: leadData.mobile };
      const duplicate = await collection.findOne(duplicateQuery);
      if (duplicate) {
        throw new Error("DUPLICATE_LEAD");
      }
    }

    const lead = {
      ...leadData,
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    const result = await collection.insertOne(lead);
    const leadIdStr = String(result.insertedId);

    // Dual-write to Firestore for instant mobile sync
    try {
      const firestorePayload = {
        id: leadIdStr,
        name: lead.fullName || lead.name || "",
        fullName: lead.fullName || lead.name || "",
        phone: lead.mobile || lead.phone || "",
        mobile: lead.mobile || lead.phone || "",
        email: lead.email || "",
        company: lead.company || "",
        companyId: lead.companyId || null,
        campaignId: lead.campaignId || "",
        notes: lead.notes || "",
        status: lead.status || "New",
        source: lead.source || "web_portal",
        targetUid: lead.agentId || lead.cardId || null,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      if (lead.agentId) {
        await firestoreDb
          .collection("users")
          .doc(lead.agentId)
          .collection("leads")
          .doc(leadIdStr)
          .set(firestorePayload, { merge: true });
      }

      if (lead.companyId) {
        await Promise.allSettled([
          firestoreDb
            .collection("enterprises")
            .doc(lead.companyId)
            .collection("leads")
            .doc(leadIdStr)
            .set(firestorePayload, { merge: true }),
          firestoreDb
            .collection("companies")
            .doc(lead.companyId)
            .collection("leads")
            .doc(leadIdStr)
            .set(firestorePayload, { merge: true }),
        ]);
      }
    } catch (fsErr) {
      console.warn("[lead.service] Firestore dual-write notice:", fsErr.message);
    }

    return result.insertedId;
  },

  async listLeads(query, userContext) {
    const leadsMap = new Map();

    // 1. Fetch from MongoDB
    try {
      const db = await connectDB();
      const collection = db.collection("leads");
      const mongoLeads = await collection.find(query).sort({ createdAt: -1 }).limit(500).toArray();
      for (const l of mongoLeads) {
        const idStr = l._id?.toString() || l.id;
        leadsMap.set(idStr, { ...l, _id: idStr, id: idStr });
      }
    } catch (mErr) {
      console.warn("[listLeads] MongoDB query error:", mErr.message);
    }

    // 2. Fetch from Firestore users/{uid}/leads (captured via mobile app or card)
    const uid = userContext?.uid;
    const companyId = userContext?.companyId;

    if (uid) {
      try {
        const userLeadsSnap = await firestoreDb
          .collection("users")
          .doc(uid)
          .collection("leads")
          .get();

        for (const doc of userLeadsSnap.docs) {
          if (!leadsMap.has(doc.id)) {
            const d = doc.data();
            leadsMap.set(doc.id, {
              _id: doc.id,
              id: doc.id,
              fullName: d.name || d.fullName || "Lead Contact",
              name: d.name || d.fullName || "Lead Contact",
              mobile: d.phone || d.mobile || "",
              phone: d.phone || d.mobile || "",
              email: d.email || "",
              company: d.company || "",
              companyId: d.companyId || companyId,
              campaignId: d.campaignId || "",
              notes: d.notes || "",
              status: d.status || "New",
              source: d.source || "mobile",
              createdAt: d.createdAt?.toDate?.() || (d.createdAt ? new Date(d.createdAt) : new Date()),
              updatedAt: d.updatedAt?.toDate?.() || (d.updatedAt ? new Date(d.updatedAt) : new Date()),
            });
          }
        }
      } catch (fsErr) {
        console.warn("[listLeads] Firestore user leads notice:", fsErr.message);
      }
    }

    // 3. Fetch from Firestore enterprises/{companyId}/leads if associated with a company
    if (companyId) {
      try {
        const entLeadsSnap = await firestoreDb
          .collection("enterprises")
          .doc(companyId)
          .collection("leads")
          .get();

        for (const doc of entLeadsSnap.docs) {
          if (!leadsMap.has(doc.id)) {
            const d = doc.data();
            // Filter: if employee, only show leads assigned or targeted to them
            if (userContext?.role === "employee" && d.targetUid && d.targetUid !== uid && d.employeeEmail !== userContext?.email) {
              continue;
            }
            leadsMap.set(doc.id, {
              _id: doc.id,
              id: doc.id,
              fullName: d.name || d.fullName || "Lead Contact",
              name: d.name || d.fullName || "Lead Contact",
              mobile: d.phone || d.mobile || "",
              phone: d.phone || d.mobile || "",
              email: d.email || "",
              company: d.company || "",
              companyId,
              campaignId: d.campaignId || "",
              notes: d.notes || "",
              status: d.status || "New",
              source: d.source || "mobile",
              createdAt: d.createdAt?.toDate?.() || (d.createdAt ? new Date(d.createdAt) : new Date()),
              updatedAt: d.updatedAt?.toDate?.() || (d.updatedAt ? new Date(d.updatedAt) : new Date()),
            });
          }
        }
      } catch (entErr) {
        console.warn("[listLeads] Firestore enterprise leads notice:", entErr.message);
      }
    }

    return Array.from(leadsMap.values()).sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
  },

  async updateLead(leadId, companyId, updates) {
    const db = await connectDB();
    const collection = db.collection("leads");

    const oid = new ObjectId(leadId);
    const existing = await collection.findOne({ _id: oid });

    if (!existing) {
      throw new Error("NOT_FOUND_OR_FORBIDDEN");
    }

    if (companyId && existing.companyId && existing.companyId !== companyId) {
      throw new Error("NOT_FOUND_OR_FORBIDDEN");
    }

    await collection.updateOne(
      { _id: oid },
      { $set: { ...updates, updatedAt: new Date() } },
    );
    return true;
  },

  async deleteLead(leadId, companyId) {
    const db = await connectDB();
    const collection = db.collection("leads");

    const oid = new ObjectId(leadId);
    const existing = await collection.findOne({ _id: oid });

    if (!existing) {
      throw new Error("NOT_FOUND_OR_FORBIDDEN");
    }

    if (companyId && existing.companyId && existing.companyId !== companyId) {
      throw new Error("NOT_FOUND_OR_FORBIDDEN");
    }

    await collection.deleteOne({ _id: oid });
    return true;
  },

  async logCrmWebhook(
    companyId,
    leadId,
    url,
    type,
    status,
    responseStatus,
    errorMessage,
  ) {
    const db = await connectDB();
    await db.collection("crmLogs").insertOne({
      companyId,
      leadId: leadId.toString(),
      webhookUrl: url,
      integrationType: type,
      status,
      responseStatus,
      errorMessage,
      createdAt: new Date(),
    });
  },

  async pushToCrm(url, type, secret, payload, companyId, leadId) {
    try {
      const headers = { "Content-Type": "application/json" };
      if (secret) headers["x-crm-secret"] = secret;

      const response = await fetch(url, {
        method: "POST",
        headers,
        body: JSON.stringify({ ...payload, integrationType: type }),
      });

      const responseStatus = response.status;
      const status = response.ok ? "success" : "failed";
      let errorMessage = null;
      if (!response.ok) {
        errorMessage = `HTTP ${responseStatus}: ${await response.text()}`;
      }

      await this.logCrmWebhook(
        companyId,
        leadId,
        url,
        type,
        status,
        responseStatus,
        errorMessage,
      );
      return status === "success";
    } catch (err) {
      console.error(`❌ CRM ${type} hook error:`, err.message);
      await this.logCrmWebhook(
        companyId,
        leadId,
        url,
        type,
        "failed",
        null,
        err.message,
      );
      return false;
    }
  },
};

export default leadService;
