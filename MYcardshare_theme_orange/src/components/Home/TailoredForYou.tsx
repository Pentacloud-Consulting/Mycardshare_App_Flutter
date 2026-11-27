"use client";

import React, { useState } from "react";
import { motion } from "framer-motion";
import {
  Smartphone,
  Building2,
  Check,
  ArrowRight,
  Wifi,
  Users,
  ShieldCheck,
  CheckCircle2,
  ExternalLink,
} from "lucide-react";

const ENTERPRISE_MEMBERS = [
  {
    initials: "SL",
    name: "Sarah Lin",
    role: "VP Enterprise",
    dept: "Global Sales",
    id: "MCS-8492",
  },
  {
    initials: "MV",
    name: "Marcus Vance",
    role: "AI Solutions Lead",
    dept: "Architecture",
    id: "MCS-8493",
  },
  {
    initials: "ER",
    name: "Elena Rostova",
    role: "Head of Growth",
    dept: "Marketing",
    id: "MCS-8494",
  },
];

export default function TailoredForYou() {
  const [selectedMemberIndex, setSelectedMemberIndex] = useState(0);

  return (
    <section className="relative w-full bg-[#FAF6F2] pt-12 sm:pt-16 pb-12 sm:pb-16 overflow-hidden border-b border-[#EFE6DD]">
      {/* Background ambient lighting */}
      <div className="absolute top-1/4 -right-40 w-96 h-96 bg-[#D4642C]/8 rounded-full blur-[130px] pointer-events-none" />
      <div className="absolute bottom-10 -left-40 w-96 h-96 bg-[#FFA370]/10 rounded-full blur-[120px] pointer-events-none" />

      <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 z-10">
        
        {/* ================= SECTION HEADER (CLEAN & CENTERED) ================= */}
        <div className="text-center max-w-3xl mx-auto mb-10 sm:mb-14">
          {/* Top Pill Badge */}
          <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full text-xs font-semibold uppercase tracking-wider bg-[#F6E3D8] text-[#B85222] border border-[#D4642C]/20 shadow-xs mb-3.5">
            <span className="w-1.5 h-1.5 rounded-full bg-[#D4642C] animate-pulse" />
            <span>TAILORED FOR YOU</span>
          </div>

          {/* Headline */}
          <h2 className="text-3xl sm:text-4xl lg:text-[46px] font-black tracking-tight text-[#18181B] font-['Space_Grotesk'] leading-[1.1] uppercase">
            BUILT FOR EVERYONE, <br />
            <span className="text-[#D4642C]">INDIVIDUALS & ENTERPRISES</span>
          </h2>

          {/* Subtitle */}
          <p className="mt-3.5 text-sm sm:text-base text-[#7A6A5F] max-w-xl mx-auto leading-relaxed font-normal">
            Whether you are an ambitious solo professional expanding your network or a global company outfitting thousands of employees with branded digital cards.
          </p>
        </div>

        {/* ================= 2 COMPARATIVE CARDS GRID (SIDE-BY-SIDE) ================= */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 lg:gap-8 max-w-6xl mx-auto items-stretch">
          
          {/* ════════════ CARD 1: FOR INDIVIDUALS ════════════ */}
          <div className="group relative bg-white rounded-[32px] p-7 sm:p-9 lg:p-10 border border-[#EFE6DD] shadow-[0_20px_60px_rgba(212,100,44,0.05),0_4px_20px_rgba(0,0,0,0.02)] flex flex-col justify-between overflow-hidden hover:border-[#D4642C]/40 hover:shadow-[0_25px_70px_rgba(212,100,44,0.12)] transition-all duration-300">
            {/* Ambient Top Glow */}
            <div className="absolute top-0 right-0 w-64 h-32 bg-[#D4642C]/6 rounded-full blur-[60px] pointer-events-none" />

            <div>
              {/* Top Bar: Icon + Category Badge */}
              <div className="flex items-center justify-between gap-3 mb-5">
                <div className="w-12 h-12 rounded-2xl bg-[#FFF5EE] border border-[#F5DDD0] flex items-center justify-center text-[#D4642C] group-hover:bg-[#D4642C] group-hover:text-white transition-all duration-300 shadow-xs">
                  <Smartphone className="w-6 h-6" />
                </div>
                <span className="px-3 py-1 rounded-full bg-[#FAF6F2] border border-[#EFE6DD] text-[11px] font-mono font-bold text-[#D4642C] uppercase tracking-wider">
                  SOLO & PROS
                </span>
              </div>

              {/* Title & Description */}
              <h3 className="text-2xl sm:text-3xl font-black text-[#18181B] font-['Space_Grotesk'] tracking-tight">
                For Individuals
              </h3>
              <p className="text-xs sm:text-sm text-[#7A6A5F] leading-relaxed font-normal mt-2">
                Leave a lasting impression with a modern digital business card. Share seamlessly via NFC tap, dynamic QR code, or 1-tap mobile wallet pass.
              </p>

              {/* ─────────────────────────────────────────────────────────────
                  CLEAN VISUAL MOCKUP: THE SOLO NFC PASS
              ───────────────────────────────────────────────────────────── */}
              <div className="my-6 p-4 sm:p-5 rounded-2xl bg-[#18181B] border border-white/10 text-white relative overflow-hidden shadow-lg">
                {/* Subtle Inner Glow */}
                <div className="absolute -top-10 -right-10 w-32 h-32 bg-[#D4642C]/20 rounded-full blur-2xl pointer-events-none" />

                {/* Profile Preview Row */}
                <div className="flex items-center justify-between relative z-10 mb-4">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-full bg-gradient-to-tr from-[#D4642C] to-[#FFA370] flex items-center justify-center font-bold text-sm text-white shadow-md">
                      AR
                    </div>
                    <div>
                      <div className="flex items-center gap-1.5">
                        <p className="text-sm font-bold text-white leading-tight">Alex Rivera</p>
                        <span className="w-1.5 h-1.5 rounded-full bg-emerald-400" />
                      </div>
                      <p className="text-[11px] font-mono text-[#FFA370] uppercase tracking-wide">Creative Director</p>
                    </div>
                  </div>

                  {/* Radiating NFC Tap Indicator */}
                  <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-white/5 border border-white/10 text-[10px] font-mono text-white/80">
                    <Wifi className="w-3.5 h-3.5 rotate-90 text-[#FFA370]" />
                    <span>NFC Tap</span>
                  </div>
                </div>

                {/* Supported Wallets Row */}
                <div className="pt-3 border-t border-white/10 flex items-center justify-between text-[11px] font-mono text-white/70">
                  <span className="flex items-center gap-1.5 text-emerald-400 font-semibold">
                    <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
                    Ready to Share
                  </span>

                  <div className="flex items-center gap-1.5">
                    <span className="px-2 py-0.5 rounded-md bg-white/10 text-white/90 text-[10px] font-semibold border border-white/10">
                      Apple Wallet
                    </span>
                    <span className="px-2 py-0.5 rounded-md bg-white/10 text-white/90 text-[10px] font-semibold border border-white/10">
                      Google Wallet
                    </span>
                  </div>
                </div>
              </div>

              {/* Feature Checklist */}
              <div className="space-y-3 pt-1">
                {[
                  "Fully customizable luxury digital identity profile",
                  "Apple, Google & Samsung Wallet 1-tap passes",
                  "Private contact vault with instant CSV lead export",
                  "Real-time tap analytics and engagement tracking",
                  "Direct WhatsApp, LinkedIn & calendar booking links",
                ].map((text, idx) => (
                  <div
                    key={idx}
                    className="flex items-center gap-3 text-xs sm:text-sm font-medium text-[#2A1E17]"
                  >
                    <div className="w-5 h-5 rounded-full bg-[#FFF5EE] text-[#D4642C] border border-[#F5DDD0] flex items-center justify-center shrink-0">
                      <Check className="w-3 h-3 stroke-[2.5]" />
                    </div>
                    <span>{text}</span>
                  </div>
                ))}
              </div>
            </div>

            {/* CTA Button */}
            <div className="pt-8">
              <a
                href="#cta"
                className="group/btn relative w-full inline-flex items-center justify-center gap-2 py-3.5 sm:py-4 rounded-full bg-[#D4642C] hover:bg-[#B85222] text-white font-bold text-xs sm:text-sm tracking-wide shadow-[0_10px_25px_rgba(212,100,44,0.3)] transition-all duration-300 hover:-translate-y-0.5 cursor-pointer overflow-hidden"
              >
                <div className="absolute inset-0 w-1/2 h-full bg-white/20 skew-x-12 -translate-x-full group-hover/btn:translate-x-[300%] transition-transform duration-1000 ease-in-out pointer-events-none" />
                <span>Create Your Personal Card</span>
                <ArrowRight className="w-4 h-4 group-hover/btn:translate-x-1 transition-transform" />
              </a>
            </div>

          </div>

          {/* ════════════ CARD 2: FOR ENTERPRISE & TEAMS ════════════ */}
          <div className="group relative bg-white rounded-[32px] p-7 sm:p-9 lg:p-10 border border-[#EFE6DD] shadow-[0_20px_60px_rgba(212,100,44,0.05),0_4px_20px_rgba(0,0,0,0.02)] flex flex-col justify-between overflow-hidden hover:border-[#D4642C]/40 hover:shadow-[0_25px_70px_rgba(212,100,44,0.12)] transition-all duration-300">
            {/* Ambient Top Glow */}
            <div className="absolute top-0 right-0 w-64 h-32 bg-[#D4642C]/6 rounded-full blur-[60px] pointer-events-none" />

            <div>
              {/* Top Bar: Icon + Category Badge */}
              <div className="flex items-center justify-between gap-3 mb-5">
                <div className="w-12 h-12 rounded-2xl bg-[#FFF5EE] border border-[#F5DDD0] flex items-center justify-center text-[#D4642C] group-hover:bg-[#D4642C] group-hover:text-white transition-all duration-300 shadow-xs">
                  <Building2 className="w-6 h-6" />
                </div>
                <span className="px-3 py-1 rounded-full bg-[#FAF6F2] border border-[#EFE6DD] text-[11px] font-mono font-bold text-[#D4642C] uppercase tracking-wider">
                  TEAM FLEETS
                </span>
              </div>

              {/* Title & Description */}
              <h3 className="text-2xl sm:text-3xl font-black text-[#18181B] font-['Space_Grotesk'] tracking-tight">
                For Enterprise & Teams
              </h3>
              <p className="text-xs sm:text-sm text-[#7A6A5F] leading-relaxed font-normal mt-2">
                Standardize your corporate identity across global offices. Centralize brand governance, automated employee provisioning, and aggregate CRM pipeline.
              </p>

              {/* ─────────────────────────────────────────────────────────────
                  CLEAN VISUAL MOCKUP: THE ENTERPRISE FLEET SELECTOR
              ───────────────────────────────────────────────────────────── */}
              <div className="my-6 p-4 sm:p-5 rounded-2xl bg-[#18181B] border border-white/10 text-white relative overflow-hidden shadow-lg">
                {/* Subtle Inner Glow */}
                <div className="absolute -top-10 -right-10 w-32 h-32 bg-[#D4642C]/20 rounded-full blur-2xl pointer-events-none" />

                {/* Active Member Display */}
                <div className="flex items-center justify-between relative z-10 mb-4">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-full bg-gradient-to-tr from-[#D4642C] to-[#FFA370] flex items-center justify-center font-bold text-sm text-white shadow-md">
                      {ENTERPRISE_MEMBERS[selectedMemberIndex].initials}
                    </div>
                    <div>
                      <div className="flex items-center gap-1.5">
                        <p className="text-sm font-bold text-white leading-tight">
                          {ENTERPRISE_MEMBERS[selectedMemberIndex].name}
                        </p>
                        <span className="px-1.5 py-0.2 rounded bg-white/10 text-[9px] font-mono text-white/70">
                          {ENTERPRISE_MEMBERS[selectedMemberIndex].id}
                        </span>
                      </div>
                      <p className="text-[11px] font-mono text-[#FFA370] uppercase tracking-wide">
                        {ENTERPRISE_MEMBERS[selectedMemberIndex].role}
                      </p>
                    </div>
                  </div>

                  {/* Team Fleet Badge */}
                  <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-white/5 border border-white/10 text-[10px] font-mono text-white/80">
                    <Users className="w-3.5 h-3.5 text-[#FFA370]" />
                    <span>2,450+ Cards</span>
                  </div>
                </div>

                {/* Team Roster Quick Tabs + CRM Sync Status */}
                <div className="pt-3 border-t border-white/10 flex items-center justify-between text-[11px] font-mono text-white/70">
                  <span className="flex items-center gap-1.5 text-emerald-400 font-semibold">
                    <CheckCircle2 className="w-3.5 h-3.5 text-emerald-400" />
                    CRM Auto-Synced
                  </span>

                  {/* Interactive Fleet Switcher */}
                  <div className="flex items-center gap-1">
                    {ENTERPRISE_MEMBERS.map((m, idx) => (
                      <button
                        key={m.id}
                        type="button"
                        onClick={() => setSelectedMemberIndex(idx)}
                        className={`px-2 py-0.5 rounded-md transition-all cursor-pointer text-[10px] font-semibold ${
                          selectedMemberIndex === idx
                            ? "bg-[#D4642C] text-white shadow-xs"
                            : "bg-white/10 hover:bg-white/20 text-white/80"
                        }`}
                      >
                        {m.name.split(" ")[0]}
                      </button>
                    ))}
                  </div>
                </div>
              </div>

              {/* Feature Checklist */}
              <div className="space-y-3 pt-1">
                {[
                  "Centralized workforce admin dashboard with role-based access",
                  "Automated employee onboarding via CSV or Workday / Okta",
                  "Direct two-way pipeline sync with HubSpot & Salesforce",
                  "Enterprise SSO (SAML / Azure AD) and SOC2-ready security",
                  "Custom corporate subdomain and brand lock governance",
                ].map((text, idx) => (
                  <div
                    key={idx}
                    className="flex items-center gap-3 text-xs sm:text-sm font-medium text-[#2A1E17]"
                  >
                    <div className="w-5 h-5 rounded-full bg-[#FFF5EE] text-[#D4642C] border border-[#F5DDD0] flex items-center justify-center shrink-0">
                      <Check className="w-3 h-3 stroke-[2.5]" />
                    </div>
                    <span>{text}</span>
                  </div>
                ))}
              </div>
            </div>

            {/* CTA Button */}
            <div className="pt-8">
              <a
                href="#contact"
                className="group/btn relative w-full inline-flex items-center justify-center gap-2 py-3.5 sm:py-4 rounded-full bg-[#18181B] hover:bg-[#27272A] text-white font-bold text-xs sm:text-sm tracking-wide shadow-md transition-all duration-300 hover:-translate-y-0.5 cursor-pointer"
              >
                <span>Request Enterprise Demo</span>
                <ArrowRight className="w-4 h-4 text-[#FFA370] group-hover/btn:translate-x-1 transition-transform" />
              </a>
            </div>

          </div>

        </div>

      </div>
    </section>
  );
}
