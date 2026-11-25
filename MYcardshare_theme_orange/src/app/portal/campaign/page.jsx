"use client";

import { motion } from "framer-motion";
import { Megaphone, Sparkles } from "lucide-react";

export default function CampaignPage() {
  return (
    <div className="space-y-8">
      <div>
        <h1
          className="text-2xl font-black tracking-tight text-[#0F172A]"
          style={{ fontFamily: "var(--font-display)" }}
        >
          Campaigns
        </h1>
        <p className="text-sm mt-1" style={{ color: "var(--color-muted)" }}>
          Manage and launch marketing campaigns
        </p>
      </div>

      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="flex flex-col items-center justify-center py-24 rounded-3xl"
        style={{
          background: "rgba(255,255,255,0.02)",
          border: "1px solid rgba(255,255,255,0.06)",
        }}
      >
        <div
          className="w-20 h-20 rounded-3xl flex items-center justify-center mb-6"
          style={{
            background: "rgba(99,102,241,0.1)",
            border: "1px solid rgba(99,102,241,0.2)",
          }}
        >
          <Megaphone size={36} className="text-indigo-400" />
        </div>
        <h2 className="text-xl font-black text-white mb-2 tracking-tight">
          Coming Soon
        </h2>
        <p className="text-sm text-slate-400 text-center max-w-md leading-relaxed">
          Campaign management tools are being built. You&apos;ll be able to
          create, schedule, and track marketing campaigns from here.
        </p>
        <div className="flex items-center gap-2 mt-6 text-[10px] font-bold uppercase tracking-[0.2em] text-indigo-400/60">
          <Sparkles size={12} />
          Under Development
        </div>
      </motion.div>
    </div>
  );
}
