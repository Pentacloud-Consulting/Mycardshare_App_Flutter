"use client";

import { useState, useEffect, useCallback } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Plug, Zap, Save, Loader2, CheckCircle, AlertCircle, Info } from "lucide-react";
import { authFetch, parseFetchJson } from "@/lib/api";
import { useAuth } from "@/lib/auth-context";

function Toast({ message, type, onClose }) {
  useEffect(() => { const t = setTimeout(onClose, 4000); return () => clearTimeout(t); }, [onClose]);
  const color = type === "success" ? "#10d9a8" : "#ef4444";
  const Icon = type === "success" ? CheckCircle : AlertCircle;
  return (
    <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: 20 }}
      className="fixed bottom-6 right-6 z-[100] flex items-center gap-3 px-5 py-3.5 rounded-xl shadow-2xl"
      style={{ background: `${color}15`, border: `1px solid ${color}30` }}>
      <Icon size={16} style={{ color }} /><span className="text-sm font-semibold" style={{ color }}>{message}</span>
    </motion.div>
  );
}

export default function EnterpriseConnectorsPage() {
  const { refreshUserData } = useAuth();
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [webhookUrl, setWebhookUrl] = useState("");
  const [toast, setToast] = useState(null);

  const fetchData = useCallback(async () => {
    setLoading(true);
    try {
      const res = await authFetch("/api/enterprise/profile");
      const data = await parseFetchJson(res);
      if (data.success && data.data.zapierWebhookUrl) {
        setWebhookUrl(data.data.zapierWebhookUrl);
      }
    } catch (_) {}
    finally { setLoading(false); }
  }, []);

  useEffect(() => { fetchData(); }, [fetchData]);

  const handleSave = async () => {
    setSaving(true);
    try {
      const res = await authFetch("/api/enterprise/profile", {
        method: "PATCH", headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ zapierWebhookUrl: webhookUrl }),
      });
      const data = await parseFetchJson(res);
      if (data.success) {
        setToast({ message: "Webhook URL saved successfully", type: "success" });
        await refreshUserData?.();
      } else {
        setToast({ message: data.error || "Failed to save", type: "error" });
      }
    } catch (err) { setToast({ message: err?.message || "Network error", type: "error" }); }
    finally { setSaving(false); }
  };

  const inputClass = "w-full px-5 py-3.5 rounded-2xl text-sm sm:text-base font-bold bg-slate-50 border border-slate-200 text-slate-800 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-[#D4642C]/30 focus:border-[#D4642C] transition-all";

  return (
    <div className="max-w-7xl mx-auto space-y-6">
      <div className="flex items-center justify-between gap-4">
        <div>
          <h1
            className="text-2xl font-black tracking-tight text-slate-800"
            style={{ fontFamily: "var(--font-display)" }}
          >
            Connectors Objects
          </h1>
          <p className="text-sm mt-1 text-slate-500">
            Manage your external integrations and object mappings.
          </p>
        </div>
      </div>

      <div
        className="rounded-2xl p-8 flex flex-col items-center justify-center text-center min-h-[400px] bg-white border border-slate-200 shadow-sm"
      >
        <motion.div
          initial={{ scale: 0.9, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          transition={{ duration: 0.5 }}
          className="w-20 h-20 rounded-full flex items-center justify-center mb-6"
          style={{
            background: "rgba(212,100,44,0.12)",
            border: "1px solid rgba(212,100,44,0.25)",
          }}
        >
          <Plug size={32} className="text-[#D4642C]" />
        </motion.div>
        
        <h2 className="text-xl font-bold text-slate-800 mb-2">Connectors Engine Active</h2>
        <p className="text-sm text-slate-500 max-w-md mb-8">
          Your Zapier CRM integration is enabled. Any leads captured across your enterprise workforce will be automatically formatted and sent to your configured Webhook URL.
        </p>

        <div className="w-full max-w-xl text-left mt-8">
          <label className="text-[9px] font-black uppercase tracking-widest text-slate-500 block mb-2">Zapier Webhook URL</label>
          <input 
            type="text" 
            value={webhookUrl} 
            onChange={(e) => setWebhookUrl(e.target.value)} 
            className={inputClass} 
            placeholder="https://hooks.zapier.com/hooks/catch/..." 
          />
          <p className="text-[8px] text-slate-400 uppercase font-black tracking-widest leading-relaxed mt-2 mb-6">
            Paste your Zapier Catch Hook URL here to enable Salesforce integration.
          </p>
          
          <button onClick={handleSave} disabled={saving}
            className="w-full inline-flex items-center justify-center gap-2 px-8 py-4 rounded-2xl bg-[#D4642C] hover:bg-[#BD5523] text-white font-black text-xs uppercase tracking-[0.2em] shadow-xl shadow-[#D4642C]/20 hover:shadow-[#D4642C]/40 transition-all disabled:opacity-50 active:scale-95">
            {saving ? <Loader2 size={16} className="animate-spin" /> : <Save size={16} />} Save Webhook
          </button>
        </div>
      </div>

      <div className="bg-[#FFF7ED] border border-[#FED7AA] shadow-sm rounded-2xl p-6 md:p-8 mt-6">
        <div className="flex items-start gap-4">
          <div className="w-10 h-10 rounded-full bg-[#FFEDD5] flex items-center justify-center flex-shrink-0 mt-1">
            <Info size={20} className="text-[#D4642C]" />
          </div>
          <div>
            <h3 className="text-lg font-bold text-slate-800 mb-2">How to configure your Zapier Action</h3>
            <p className="text-sm text-slate-600 leading-relaxed mb-4">
              When a lead is created or edited in our system, we instantly send the form data along with two special fields to your Webhook URL:
            </p>
            <ul className="space-y-3 mb-6">
              <li className="flex items-center gap-3 text-sm text-slate-600">
                <span className="w-2 h-2 rounded-full bg-[#D4642C]"></span>
                <span><strong>leadId:</strong> A unique identifier for the lead.</span>
              </li>
              <li className="flex items-center gap-3 text-sm text-slate-600">
                <span className="w-2 h-2 rounded-full bg-[#D4642C]"></span>
                <span><strong>action:</strong> Will say either <code>"create"</code> or <code>"update"</code>.</span>
              </li>
            </ul>
            <div className="bg-white border border-slate-200 shadow-sm rounded-xl p-5">
              <h4 className="text-sm font-bold text-slate-800 mb-3 uppercase tracking-widest">Zapier Setup Steps:</h4>
              <ol className="list-decimal list-inside space-y-2 text-sm text-slate-600">
                <li>Create a Zap with the <strong>Webhooks by Zapier (Catch Hook)</strong> trigger.</li>
                <li>Add a <strong>Find Record</strong> action for your CRM (e.g. Salesforce).</li>
                <li>Configure it to search by the <code className="text-[#D4642C] font-bold">leadId</code>.</li>
                <li>Check the box that says <strong>"Create Salesforce Record if it doesn't exist yet."</strong></li>
                <li>Map the remaining fields (Name, Phone, etc.) and turn on your Zap!</li>
              </ol>
            </div>
          </div>
        </div>
      </div>

      <AnimatePresence>
        {toast && <Toast key="toast" {...toast} onClose={() => setToast(null)} />}
      </AnimatePresence>
    </div>
  );
}
