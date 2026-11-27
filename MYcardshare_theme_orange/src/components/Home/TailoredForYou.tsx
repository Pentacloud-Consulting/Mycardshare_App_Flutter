"use client";

import React, { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  Smartphone,
  Building2,
  Check,
  ArrowRight,
  Sparkles,
  Users,
  ShieldCheck,
  Zap,
  Wifi,
  QrCode,
  Layers,
  Database,
  CheckCircle2,
} from "lucide-react";

type FilterMode = "all" | "individual" | "enterprise";

const ENTERPRISE_MEMBERS = [
  {
    initials: "SL",
    name: "Sarah Lin",
    role: "VP Enterprise",
    id: "MCS-8492",
    tag: "Sarah",
  },
  {
    initials: "MV",
    name: "Marcus Vance",
    role: "Lead AI Architect",
    id: "MCS-8493",
    tag: "Marcus",
  },
  {
    initials: "ER",
    name: "Elena Rostova",
    role: "Head of Growth",
    id: "MCS-8494",
    tag: "Elena",
  },
];

export default function TailoredForYou() {
  const [filter, setFilter] = useState<FilterMode>("all");
  const [activeWalletTab, setActiveWalletTab] = useState<"apple" | "google" | "qr">("apple");
  const [selectedMemberIndex, setSelectedMemberIndex] = useState(0);

  return (
    <section className="relative w-full bg-[#FAF6F2] pt-10 sm:pt-12 lg:pt-14 pb-8 sm:pb-10 lg:pb-12 overflow-hidden border-b border-[#EFE6DD]">
      {/* Background ambient lighting */}
      <div className="absolute top-1/4 -right-40 w-96 h-96 bg-[#D4642C]/8 rounded-full blur-[130px] pointer-events-none" />
      <div className="absolute bottom-10 -left-40 w-96 h-96 bg-[#FFA370]/10 rounded-full blur-[120px] pointer-events-none" />

      <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 z-10">
        
        {/* ================= SECTION HEADER ================= */}
        <div className="text-center max-w-3xl mx-auto mb-8 sm:mb-10">
          {/* Top Pill Badge */}
          <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full text-xs font-semibold uppercase tracking-wider bg-[#F6E3D8] text-[#B85222] border border-[#D4642C]/20 shadow-xs mb-3.5">
            <span className="w-1.5 h-1.5 rounded-full bg-[#D4642C] animate-pulse" />
            <span>TAILORED FOR YOU</span>
          </div>

          {/* Headline */}
          <h2 className="text-3xl sm:text-4xl lg:text-[46px] font-black tracking-tight text-[#18181B] font-['Space_Grotesk'] leading-[1.08] uppercase">
            BUILT FOR EVERYONE, <br />
            <span className="text-[#D4642C]">INDIVIDUALS & ENTERPRISES</span>
          </h2>

          {/* Subtitle */}
          <p className="mt-3.5 text-sm sm:text-base text-[#7A6A5F] max-w-xl mx-auto leading-relaxed font-normal">
            Whether you are an ambitious solo creator expanding your network or a global company outfitting 5,000 employees with branded digital cards.
          </p>

          {/* ================= INTERACTIVE VIEW SWITCHER (CLEAN ANIMATION) ================= */}
          <div className="mt-6 inline-flex items-center p-1.5 rounded-full bg-white border border-[#EFE6DD] shadow-xs">
            {(
              [
                { id: "all", label: "Side-by-Side View" },
                { id: "individual", label: "For Individuals" },
                { id: "enterprise", label: "For Enterprise" },
              ] as const
            ).map((tab) => {
              const isActive = filter === tab.id;
              return (
                <button
                  key={tab.id}
                  onClick={() => setFilter(tab.id)}
                  className={`relative px-4 sm:px-5 py-2 rounded-full text-xs sm:text-sm font-semibold transition-colors duration-200 cursor-pointer ${
                    isActive ? "text-white" : "text-[#7A6A5F] hover:text-[#18181B]"
                  }`}
                >
                  {isActive && (
                    <motion.div
                      layoutId="activeFilterPill"
                      className="absolute inset-0 rounded-full bg-[#D4642C] shadow-sm"
                      transition={{ type: "spring", stiffness: 400, damping: 30 }}
                    />
                  )}
                  <span className="relative z-10">{tab.label}</span>
                </button>
              );
            })}
          </div>
        </div>

        {/* ================= 2 COMPARATIVE CARDS GRID WITH CLEAN ANIMATION UI ================= */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 lg:gap-10 max-w-6xl mx-auto items-stretch">
          
          {/* ════════════ CARD 1: FOR INDIVIDUALS ════════════ */}
          <AnimatePresence mode="popLayout">
            {(filter === "all" || filter === "individual") && (
              <motion.div
                layout
                initial={{ opacity: 0, scale: 0.96 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0.96 }}
                transition={{ duration: 0.3 }}
                whileHover={{ y: -6 }}
                className="group relative bg-white rounded-[28px] sm:rounded-[36px] p-7 sm:p-9 lg:p-10 border border-[#EFE6DD] shadow-[0_20px_60px_rgba(212,100,44,0.06),0_4px_20px_rgba(0,0,0,0.02)] flex flex-col justify-between overflow-hidden hover:border-[#D4642C]/40 hover:shadow-[0_25px_70px_rgba(212,100,44,0.12)] transition-all duration-300"
              >
                {/* Ambient Top Glow */}
                <div className="absolute top-0 right-0 w-64 h-32 bg-[#D4642C]/8 rounded-full blur-[60px] pointer-events-none" />

                <div>
                  {/* Top Bar: Icon + Badge */}
                  <div className="flex items-center justify-between gap-3 mb-5">
                    <div className="w-12 h-12 rounded-2xl bg-[#FAF6F2] border border-[#EFE6DD] flex items-center justify-center text-[#D4642C] group-hover:bg-[#D4642C] group-hover:text-white transition-all duration-300 shadow-xs">
                      <Smartphone className="w-6 h-6" />
                    </div>
                    <span className="px-3 py-1 rounded-full bg-[#FAF6F2] border border-[#EFE6DD] text-[10px] font-mono font-bold text-[#D4642C] uppercase tracking-wider">
                      SOLO & PROS
                    </span>
                  </div>

                  {/* Title & Description */}
                  <h3 className="text-2xl sm:text-3xl font-black text-[#18181B] font-['Space_Grotesk'] tracking-tight">
                    For Individuals
                  </h3>
                  <p className="text-xs sm:text-sm text-[#7A6A5F] leading-relaxed font-normal mt-2">
                    Leave a lasting impression with a modern digital business card. Share via NFC tap, dynamic QR code, or digital wallet pass.
                  </p>

                  {/* ─────────────────────────────────────────────────────────────
                      CLEAN ANIMATED INTERACTIVE MOCKUP: THE SOLO NFC PASS
                  ───────────────────────────────────────────────────────────── */}
                  <div className="my-6 p-4 rounded-2xl bg-[#1A120D] border border-white/10 text-white relative overflow-hidden shadow-inner">
                    {/* Background Subtle Gradient & Shimmer Line */}
                    <div className="absolute -inset-full bg-gradient-to-r from-transparent via-white/5 to-transparent skew-x-12 animate-[shimmer_5s_infinite]" />

                    {/* Mini Card Header */}
                    <div className="flex items-center justify-between relative z-10 mb-3">
                      <div className="flex items-center gap-2.5">
                        <div className="w-8 h-8 rounded-full bg-gradient-to-tr from-[#D4642C] to-[#FFA370] flex items-center justify-center font-bold text-xs text-white shadow-xs">
                          AR
                        </div>
                        <div>
                          <p className="text-xs font-bold text-white leading-tight">Alex Rivera</p>
                          <p className="text-[10px] font-mono text-[#FFA370] uppercase">Creative Director</p>
                        </div>
                      </div>

                      {/* Animated Radiating NFC Wave Rings */}
                      <div className="relative flex items-center justify-center w-7 h-7">
                        <span className="absolute w-6 h-6 rounded-full bg-[#D4642C]/40 animate-ping opacity-60" />
                        <span className="absolute w-4 h-4 rounded-full bg-[#D4642C]/70" />
                        <Wifi className="w-3.5 h-3.5 rotate-90 text-white relative z-10" />
                      </div>
                    </div>

                    {/* Interactive 3-way Sharing Selector */}
                    <div className="pt-2 border-t border-white/10 flex items-center justify-between text-[10px] font-mono text-white/70">
                      <span className="flex items-center gap-1">
                        <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse" />
                        Ready to Share
                      </span>

                      {/* Clean 3 interactive chips */}
                      <div className="flex items-center gap-1">
                        <button
                          type="button"
                          onClick={() => setActiveWalletTab("apple")}
                          className={`px-2 py-0.5 rounded-md transition-all cursor-pointer ${
                            activeWalletTab === "apple"
                              ? "bg-[#D4642C] text-white font-bold"
                              : "bg-white/10 hover:bg-white/20 text-white/80"
                          }`}
                        >
                          Apple
                        </button>
                        <button
                          type="button"
                          onClick={() => setActiveWalletTab("google")}
                          className={`px-2 py-0.5 rounded-md transition-all cursor-pointer ${
                            activeWalletTab === "google"
                              ? "bg-[#D4642C] text-white font-bold"
                              : "bg-white/10 hover:bg-white/20 text-white/80"
                          }`}
                        >
                          Google
                        </button>
                        <button
                          type="button"
                          onClick={() => setActiveWalletTab("qr")}
                          className={`px-2 py-0.5 rounded-md transition-all cursor-pointer ${
                            activeWalletTab === "qr"
                              ? "bg-[#D4642C] text-white font-bold"
                              : "bg-white/10 hover:bg-white/20 text-white/80"
                          }`}
                        >
                          QR Pass
                        </button>
                      </div>
                    </div>
                  </div>

                  {/* 4 Interactive Bullet Points */}
                  <div className="space-y-3 pt-2">
                    {[
                      { text: "Fully customizable luxury identity profile", badge: "Live Profile" },
                      { text: "Apple, Google & Samsung Wallet 1-tap passes", badge: "3 Wallets" },
                      { text: "Contact vault with CSV export and lead notes", badge: "Auto-Vault" },
                      { text: "Real-time view analytics and geo-tracking", badge: "Instant GPS" },
                    ].map((bullet, idx) => (
                      <motion.div
                        key={idx}
                        whileHover={{ x: 4 }}
                        className="group/item flex items-center justify-between gap-3 p-2 rounded-xl hover:bg-[#FAF6F2] transition-colors cursor-default"
                      >
                        <div className="flex items-center gap-3 text-xs sm:text-sm font-medium text-[#2A1E17]">
                          <div className="w-5 h-5 rounded-full bg-[#FAF6F2] group-hover/item:bg-[#D4642C] group-hover/item:text-white border border-[#D4642C]/30 flex items-center justify-center shrink-0 text-[#D4642C] transition-colors">
                            <Check className="w-3 h-3 stroke-[2.5]" />
                          </div>
                          <span>{bullet.text}</span>
                        </div>
                        <span className="opacity-0 group-hover/item:opacity-100 transition-opacity text-[10px] font-mono text-[#D4642C] font-bold">
                          {bullet.badge}
                        </span>
                      </motion.div>
                    ))}
                  </div>
                </div>

                {/* CTA Button: Solid Matte Orange with Hover Sweep */}
                <div className="pt-6">
                  <a
                    href="#cta"
                    className="group/btn relative w-full inline-flex items-center justify-center gap-2 py-3.5 sm:py-4 rounded-full bg-[#D4642C] hover:bg-[#B85222] text-white font-bold text-xs sm:text-sm tracking-wide shadow-[0_10px_25px_rgba(212,100,44,0.35)] transition-all duration-300 hover:-translate-y-0.5 cursor-pointer overflow-hidden"
                  >
                    <div className="absolute inset-0 w-1/2 h-full bg-white/20 skew-x-12 -translate-x-full group-hover/btn:translate-x-[300%] transition-transform duration-1000 ease-in-out pointer-events-none" />
                    <span>Create Your Personal Card</span>
                    <ArrowRight className="w-4 h-4 group-hover/btn:translate-x-1 transition-transform" />
                  </a>
                </div>

              </motion.div>
            )}
          </AnimatePresence>

          {/* ════════════ CARD 2: FOR ENTERPRISE & TEAMS ════════════ */}
          <AnimatePresence mode="popLayout">
            {(filter === "all" || filter === "enterprise") && (
              <motion.div
                layout
                initial={{ opacity: 0, scale: 0.96 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0.96 }}
                transition={{ duration: 0.3 }}
                whileHover={{ y: -6 }}
                className="group relative bg-white rounded-[28px] sm:rounded-[36px] p-7 sm:p-9 lg:p-10 border border-[#EFE6DD] shadow-[0_20px_60px_rgba(212,100,44,0.06),0_4px_20px_rgba(0,0,0,0.02)] flex flex-col justify-between overflow-hidden hover:border-[#D4642C]/40 hover:shadow-[0_25px_70px_rgba(212,100,44,0.12)] transition-all duration-300"
              >
                {/* Ambient Top Glow */}
                <div className="absolute top-0 right-0 w-64 h-32 bg-[#D4642C]/8 rounded-full blur-[60px] pointer-events-none" />

                <div>
                  {/* Top Bar: Icon + Badge */}
                  <div className="flex items-center justify-between gap-3 mb-5">
                    <div className="w-12 h-12 rounded-2xl bg-[#FAF6F2] border border-[#EFE6DD] flex items-center justify-center text-[#D4642C] group-hover:bg-[#D4642C] group-hover:text-white transition-all duration-300 shadow-xs">
                      <Building2 className="w-6 h-6" />
                    </div>
                    <span className="px-3 py-1 rounded-full bg-[#FAF6F2] border border-[#EFE6DD] text-[10px] font-mono font-bold text-[#D4642C] uppercase tracking-wider">
                      TEAM FLEETS
                    </span>
                  </div>

                  {/* Title & Description */}
                  <h3 className="text-2xl sm:text-3xl font-black text-[#18181B] font-['Space_Grotesk'] tracking-tight">
                    For Enterprise & Teams
                  </h3>
                  <p className="text-xs sm:text-sm text-[#7A6A5F] leading-relaxed font-normal mt-2">
                    Standardize your corporate identity at scale. Centralize brand governance, employee offboarding, and aggregate CRM pipeline.
                  </p>

                  {/* ─────────────────────────────────────────────────────────────
                      CLEAN ANIMATED INTERACTIVE MOCKUP: THE ENTERPRISE FLEET SELECTOR
                  ───────────────────────────────────────────────────────────── */}
                  <div className="my-6 p-4 rounded-2xl bg-[#1A120D] border border-white/10 text-white relative overflow-hidden shadow-inner">
                    {/* Background Subtle Gradient & Shimmer Line */}
                    <div className="absolute -inset-full bg-gradient-to-r from-transparent via-white/5 to-transparent skew-x-12 animate-[shimmer_5s_infinite]" />

                    {/* Active Selected Team Pass Header */}
                    <motion.div
                      key={ENTERPRISE_MEMBERS[selectedMemberIndex].id}
                      initial={{ opacity: 0, y: 6 }}
                      animate={{ opacity: 1, y: 0 }}
                      transition={{ duration: 0.2 }}
                      className="flex items-center justify-between relative z-10 mb-3"
                    >
                      <div className="flex items-center gap-2.5">
                        <div className="w-8 h-8 rounded-full bg-gradient-to-tr from-[#D4642C] to-[#FFA370] flex items-center justify-center font-bold text-xs text-white shadow-xs">
                          {ENTERPRISE_MEMBERS[selectedMemberIndex].initials}
                        </div>
                        <div>
                          <p className="text-xs font-bold text-white leading-tight">
                            {ENTERPRISE_MEMBERS[selectedMemberIndex].name}
                          </p>
                          <p className="text-[10px] font-mono text-[#FFA370] uppercase">
                            {ENTERPRISE_MEMBERS[selectedMemberIndex].role}
                          </p>
                        </div>
                      </div>

                      <div className="flex items-center gap-2">
                        <span className="px-2 py-0.5 rounded-md bg-white/10 text-[9px] font-mono text-white/80 border border-white/10">
                          {ENTERPRISE_MEMBERS[selectedMemberIndex].id}
                        </span>
                        <div className="relative flex items-center justify-center w-7 h-7">
                          <span className="absolute w-6 h-6 rounded-full bg-[#D4642C]/40 animate-ping opacity-60" />
                          <span className="absolute w-4 h-4 rounded-full bg-[#D4642C]/70" />
                          <Building2 className="w-3.5 h-3.5 text-white relative z-10" />
                        </div>
                      </div>
                    </motion.div>

                    {/* Interactive Fleet Selector Bar */}
                    <div className="pt-2 border-t border-white/10 flex items-center justify-between text-[10px] font-mono text-white/70">
                      <span className="flex items-center gap-1 text-emerald-400 font-semibold">
                        <CheckCircle2 className="w-3 h-3 text-emerald-400" />
                        CRM Synced
                      </span>

                      {/* 3 Interactive Member Buttons + Fleet Counter */}
                      <div className="flex items-center gap-1">
                        {ENTERPRISE_MEMBERS.map((m, idx) => (
                          <button
                            key={m.id}
                            type="button"
                            onClick={() => setSelectedMemberIndex(idx)}
                            className={`px-2 py-0.5 rounded-md transition-all cursor-pointer ${
                              selectedMemberIndex === idx
                                ? "bg-[#D4642C] text-white font-bold shadow-xs"
                                : "bg-white/10 hover:bg-white/20 text-white/80"
                            }`}
                          >
                            {m.tag}
                          </button>
                        ))}
                        <span className="px-1.5 py-0.5 text-[9px] text-[#FFA370] font-bold">
                          +2,450
                        </span>
                      </div>
                    </div>
                  </div>

                  {/* 4 Interactive Bullet Points */}
                  <div className="space-y-3 pt-2">
                    {[
                      { text: "Centralized workforce admin dashboard", badge: "Admin Control" },
                      { text: "Automated bulk employee invitation codes", badge: "Bulk CSV" },
                      { text: "Direct pipeline sync to HubSpot & Salesforce", badge: "CRM Sync" },
                      { text: "Corporate domain masking and custom subdomains", badge: "SSO / Domain" },
                    ].map((bullet, idx) => (
                      <motion.div
                        key={idx}
                        whileHover={{ x: 4 }}
                        className="group/item flex items-center justify-between gap-3 p-2 rounded-xl hover:bg-[#FAF6F2] transition-colors cursor-default"
                      >
                        <div className="flex items-center gap-3 text-xs sm:text-sm font-medium text-[#2A1E17]">
                          <div className="w-5 h-5 rounded-full bg-[#FAF6F2] group-hover/item:bg-[#D4642C] group-hover/item:text-white border border-[#D4642C]/30 flex items-center justify-center shrink-0 text-[#D4642C] transition-colors">
                            <Check className="w-3 h-3 stroke-[2.5]" />
                          </div>
                          <span>{bullet.text}</span>
                        </div>
                        <span className="opacity-0 group-hover/item:opacity-100 transition-opacity text-[10px] font-mono text-[#D4642C] font-bold">
                          {bullet.badge}
                        </span>
                      </motion.div>
                    ))}
                  </div>
                </div>

                {/* CTA Button: Outline / Glass Pill with Glow */}
                <div className="pt-6">
                  <a
                    href="#contact"
                    className="group/btn relative w-full inline-flex items-center justify-center gap-2 py-3.5 sm:py-4 rounded-full bg-white hover:bg-[#FAF6F2] text-[#18181B] hover:text-[#D4642C] font-bold text-xs sm:text-sm tracking-wide border border-[#E4D7CC] hover:border-[#D4642C]/40 shadow-xs hover:shadow-[0_8px_20px_rgba(212,100,44,0.1)] transition-all duration-300 hover:-translate-y-0.5 cursor-pointer"
                  >
                    <span>Explore Enterprise Solutions</span>
                    <ArrowRight className="w-4 h-4 text-[#D4642C] group-hover/btn:translate-x-1 transition-transform" />
                  </a>
                </div>

              </motion.div>
            )}
          </AnimatePresence>

        </div>

      </div>
    </section>
  );
}
