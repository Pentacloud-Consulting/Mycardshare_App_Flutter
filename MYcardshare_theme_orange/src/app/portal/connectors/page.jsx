"use client";

import { motion } from "framer-motion";
import { Plug, Zap } from "lucide-react";

export default function ConnectorsPage() {
  return (
    <div className="max-w-7xl mx-auto space-y-6">
      <div className="flex items-center justify-between gap-4">
        <div>
          <h1
            className="text-2xl font-black tracking-tight text-[#0F172A]"
            style={{ fontFamily: "var(--font-display)" }}
          >
            Connectors Objects
          </h1>
          <p className="text-sm mt-1" style={{ color: "var(--color-muted)" }}>
            Manage your external integrations and object mappings.
          </p>
        </div>
      </div>

      <div
        className="rounded-2xl p-8 flex flex-col items-center justify-center text-center min-h-[400px]"
        style={{
          background: "rgba(255,255,255,0.02)",
          border: "1px solid rgba(255,255,255,0.06)",
        }}
      >
        <motion.div
          initial={{ scale: 0.9, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          transition={{ duration: 0.5 }}
          className="w-20 h-20 rounded-full flex items-center justify-center mb-6"
          style={{
            background: "rgba(99,102,241,0.15)",
            border: "1px solid rgba(99,102,241,0.3)",
          }}
        >
          <Plug size={32} className="text-indigo-400" />
        </motion.div>
        
        <h2 className="text-xl font-bold text-white mb-2">Connectors Engine Active</h2>
        <p className="text-sm text-slate-400 max-w-md mb-8">
          Your Zapier CRM integration is enabled. Any leads captured across your enterprise workforce will be automatically formatted and sent to your configured Webhook URL.
        </p>

        <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-widest text-indigo-400 bg-indigo-500/10 px-4 py-2 rounded-lg border border-indigo-500/20">
          <Zap size={14} />
          Listening for Lead Events
        </div>
      </div>
    </div>
  );
}
