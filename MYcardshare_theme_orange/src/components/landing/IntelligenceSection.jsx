"use client";

import { motion } from "framer-motion";
import { Zap, CheckCircle2 } from "lucide-react";

const LEADS = [
  {
    initials: "JM",
    name: "James Mitchell",
    company: "Cushman & Wakefield",
    color: "bg-[#D4642C]",
    badge: "via NFC Tap — GITEX Summit",
  },
  {
    initials: "FA",
    name: "Fatima Al-Zahrawi",
    company: "Dubai Future District",
    color: "bg-[#E87A43]",
    badge: "via Dynamic QR Scan",
  },
  {
    initials: "MK",
    name: "Michael Kim",
    company: "TechNexus Global",
    color: "bg-stone-800",
    badge: "via Direct Digital Pass",
  },
  {
    initials: "PS",
    name: "Priya Sharma",
    company: "CBRE Middle East",
    color: "bg-[#F59E0B]",
    badge: "via Apple Wallet Share",
  },
];

export default function IntelligenceSection() {
  return (
    <section className="py-20 md:py-28 bg-white relative overflow-hidden">
      <div className="max-w-7xl mx-auto px-6 relative z-10">
        <div className="flex flex-col lg:flex-row gap-12 lg:gap-18 items-center">
          {/* Left Text Content */}
          <motion.div
            initial={{ opacity: 0, x: -30 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            className="flex-1"
          >
            <div className="inline-flex items-center gap-2 px-3.5 py-1 rounded-full mb-6 text-xs font-bold uppercase tracking-widest bg-[#FAF6F2] border border-[#EFE8E1] text-[#D4642C]">
              <Zap size={14} className="text-[#D4642C]" /> Real-time Intelligence
            </div>

            <h2
              className="text-3xl sm:text-4xl md:text-5xl font-black text-[#18181B] mb-6 leading-[1.12] tracking-tight"
              style={{ fontFamily: "var(--font-display)" }}
            >
              Leads Captured.
              <br />
              <span className="text-[#D4642C]">CRM Synced.</span>
              <br />
              <span>Instantly.</span>
            </h2>

            <p className="text-base sm:text-lg text-stone-500 mb-8 max-w-lg leading-relaxed font-normal">
              Transform every connection into actionable pipeline data. Our
              platform automatically syncs captured contact cards with your CRM,
              eliminating friction and manual spreadsheets.
            </p>

            <div className="space-y-6">
              <div className="flex gap-4">
                <div className="w-8 h-8 rounded-full bg-[#FAF6F2] flex items-center justify-center border border-[#EFE8E1] shrink-0 mt-0.5">
                  <CheckCircle2 size={16} className="text-[#D4642C]" />
                </div>
                <div>
                  <h4 className="text-[#18181B] font-bold text-base mb-1">
                    Instant Enterprise Lead Push
                  </h4>
                  <p className="text-stone-500 text-sm">
                    Direct two-way synchronization with Salesforce, HubSpot, and
                    Zoho CRM.
                  </p>
                </div>
              </div>

              <div className="flex gap-4">
                <div className="w-8 h-8 rounded-full bg-[#FAF6F2] flex items-center justify-center border border-[#EFE8E1] shrink-0 mt-0.5">
                  <CheckCircle2 size={16} className="text-[#D4642C]" />
                </div>
                <div>
                  <h4 className="text-[#18181B] font-bold text-base mb-1">
                    Contextual Source Attribution
                  </h4>
                  <p className="text-stone-500 text-sm">
                    Accurately determine which specific card, event, or team
                    member generated the opportunity.
                  </p>
                </div>
              </div>
            </div>
          </motion.div>

          {/* Right Live Lead Feed UI */}
          <motion.div
            initial={{ opacity: 0, scale: 0.96 }}
            whileInView={{ opacity: 1, scale: 1 }}
            viewport={{ once: true }}
            className="flex-1 w-full"
          >
            <div className="bg-[#FAF6F2] border border-[#EFE8E1] rounded-[32px] p-6 sm:p-8 shadow-[0_15px_45px_rgba(212,100,44,0.06)] relative">
              {/* Header */}
              <div className="flex justify-between items-center mb-6 pb-4 border-b border-[#EFE8E1] relative z-10">
                <h3
                  className="text-[#18181B] font-bold text-lg sm:text-xl"
                  style={{ fontFamily: "var(--font-display)" }}
                >
                  Live Pipeline Feed
                </h3>

                <div className="flex items-center gap-2 text-stone-500 text-xs font-semibold">
                  <motion.div
                    animate={{ opacity: [1, 0.3, 1] }}
                    transition={{ duration: 1.8, repeat: Infinity }}
                    className="w-2 h-2 rounded-full bg-emerald-500 shadow-[0_0_8px_rgba(16,185,129,0.8)]"
                  />
                  Live Syncing
                </div>
              </div>

              {/* Lead List */}
              <div className="space-y-3.5 relative z-10">
                {LEADS.map((lead, i) => (
                  <motion.div
                    key={i}
                    initial={{ opacity: 0, y: 10 }}
                    whileInView={{ opacity: 1, y: 0 }}
                    transition={{ delay: i * 0.1 }}
                    viewport={{ once: true }}
                    className="bg-white border border-[#EFE8E1] rounded-2xl p-4 flex flex-col sm:flex-row sm:items-center justify-between gap-3 shadow-xs"
                  >
                    <div className="flex items-center gap-3.5">
                      <div
                        className={`w-10 h-10 rounded-full ${lead.color} flex items-center justify-center text-white font-bold text-xs shrink-0 shadow-xs`}
                      >
                        {lead.initials}
                      </div>

                      <div>
                        <div className="text-[#18181B] font-bold text-sm">
                          {lead.name}
                        </div>
                        <div className="text-stone-500 text-xs">
                          {lead.company}
                        </div>
                      </div>
                    </div>

                    <div className="bg-[#FAF6F2] text-[#D4642C] px-3 py-1 rounded-full text-[11px] font-bold border border-[#EFE8E1] w-fit">
                      {lead.badge}
                    </div>
                  </motion.div>
                ))}
              </div>
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  );
}
