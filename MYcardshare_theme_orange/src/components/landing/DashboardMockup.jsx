"use client";

import { motion } from "framer-motion";

export default function DashboardMockup() {
  return (
    <section className="py-20 md:py-28 bg-white">
      <div className="max-w-7xl mx-auto px-6">
        {/* Header */}
        <div className="text-center mb-14 sm:mb-18">
          <motion.div
            initial={{ opacity: 0, y: 10 }}
            whileInView={{ opacity: 1, y: 0 }}
            className="inline-flex px-3.5 py-1 rounded-full mb-4 text-xs font-bold uppercase tracking-widest bg-[#FAF6F2] border border-[#EFE8E1] text-[#D4642C]"
          >
            Analytics & Command Center
          </motion.div>

          <motion.h2
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            className="text-3xl sm:text-4xl md:text-5xl font-black text-[#18181B] mb-4 tracking-tight leading-tight"
            style={{ fontFamily: "var(--font-display)" }}
          >
            A Dashboard That
            <br />
            <span className="text-[#D4642C]">Tells the Complete Story</span>
          </motion.h2>

          <motion.p
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="text-stone-500 max-w-2xl mx-auto text-base sm:text-lg leading-relaxed font-normal"
          >
            Not just superficial vanity metrics. Real commercial intelligence —
            who viewed, who scanned, which campaigns convert, and lead velocity.
          </motion.p>
        </div>

        {/* Dashboard Mockup Card */}
        <motion.div
          initial={{ opacity: 0, y: 35 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-80px" }}
          className="bg-white border border-[#EFE8E1] rounded-[32px] overflow-hidden shadow-[0_20px_60px_rgba(212,100,44,0.08)]"
        >
          {/* Window Header */}
          <div className="bg-[#FAF6F2] px-6 py-4 flex items-center justify-between border-b border-[#EFE8E1]">
            <div className="flex items-center gap-2">
              <div className="w-3 h-3 rounded-full bg-rose-400" />
              <div className="w-3 h-3 rounded-full bg-amber-400" />
              <div className="w-3 h-3 rounded-full bg-emerald-400" />
            </div>

            <div className="hidden md:flex gap-2">
              <div className="px-4 py-1.5 rounded-lg bg-[#D4642C] text-white text-xs font-bold shadow-xs">
                Overview
              </div>
              <div className="px-4 py-1.5 rounded-lg text-stone-600 text-xs font-semibold hover:text-[#D4642C] cursor-pointer">
                Leads
              </div>
              <div className="px-4 py-1.5 rounded-lg text-stone-600 text-xs font-semibold hover:text-[#D4642C] cursor-pointer">
                Campaigns
              </div>
              <div className="px-4 py-1.5 rounded-lg text-stone-600 text-xs font-semibold hover:text-[#D4642C] cursor-pointer">
                Team Rollout
              </div>
            </div>

            <div className="text-[11px] font-bold text-stone-400 uppercase tracking-widest hidden sm:block">
              Nexus v3 Live Feed
            </div>
          </div>

          {/* Dashboard Content */}
          <div className="p-6 md:p-10">
            {/* KPI Cards */}
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
              {[
                {
                  label: "Total Visitors",
                  val: "12,847",
                  diff: "+24%",
                },
                { label: "QR Scans", val: "3,214", diff: "+18%" },
                { label: "Leads Captured", val: "641", diff: "+31%" },
                { label: "Conv. Rate", val: "4.99%", diff: "+0.8%" },
              ].map((kpi, i) => (
                <div
                  key={i}
                  className="bg-[#FAF6F2] border border-[#EFE8E1] rounded-2xl p-4 sm:p-5"
                >
                  <div className="text-stone-500 text-xs font-bold mb-2 uppercase tracking-wide">
                    {kpi.label}
                  </div>
                  <div
                    className="text-[#18181B] text-2xl sm:text-3xl font-black mb-1 tracking-tight"
                    style={{ fontFamily: "var(--font-display)" }}
                  >
                    {kpi.val}
                  </div>
                  <div className="text-[#D4642C] text-xs font-bold tracking-wide">
                    ↑ {kpi.diff} vs last mo.
                  </div>
                </div>
              ))}
            </div>

            {/* Charts Grid */}
            <div className="grid md:grid-cols-3 gap-6 sm:gap-8">
              {/* Daily Bar Chart */}
              <div className="md:col-span-2 bg-[#FAF6F2] border border-[#EFE8E1] rounded-2xl p-5 sm:p-7">
                <div className="flex justify-between items-center mb-6">
                  <div className="text-[#18181B] text-sm font-bold uppercase tracking-wide">
                    Views & Lead Conversions — Daily
                  </div>
                  <div className="flex items-center gap-3 text-xs">
                    <span className="flex items-center gap-1.5 text-stone-500">
                      <span className="w-2.5 h-2.5 rounded-full bg-[#D4642C]/20" /> Views
                    </span>
                    <span className="flex items-center gap-1.5 text-[#D4642C] font-semibold">
                      <span className="w-2.5 h-2.5 rounded-full bg-[#D4642C]" /> Leads
                    </span>
                  </div>
                </div>

                <div className="flex items-end justify-between h-[150px] md:h-[200px] gap-1.5 md:gap-2.5">
                  {[40, 60, 50, 70, 90, 40, 30, 55, 75, 85, 95, 65, 45, 80].map(
                    (h1, i) => {
                      const h2 = [
                        20, 35, 25, 45, 60, 25, 15, 30, 45, 50, 65, 40, 30, 55,
                      ][i];
                      return (
                        <div
                          key={i}
                          className="flex-1 flex flex-col items-center justify-end h-full relative"
                        >
                          <motion.div
                            initial={{ height: 0 }}
                            whileInView={{ height: `${h1}%` }}
                            transition={{ duration: 0.8, delay: i * 0.04 }}
                            className="w-full bg-[#D4642C]/20 rounded-t-sm relative"
                          >
                            <motion.div
                              initial={{ height: 0 }}
                              whileInView={{ height: `${(h2 / h1) * 100}%` }}
                              transition={{
                                duration: 0.8,
                                delay: i * 0.04 + 0.15,
                              }}
                              className="w-full bg-[#D4642C] rounded-t-sm absolute bottom-0 left-0"
                            />
                          </motion.div>
                        </div>
                      );
                    },
                  )}
                </div>
              </div>

              {/* Traffic Sources */}
              <div className="bg-[#FAF6F2] border border-[#EFE8E1] rounded-2xl p-5 sm:p-7">
                <div className="text-[#18181B] text-sm font-bold mb-6 uppercase tracking-wide">
                  Channel Attribution
                </div>

                <div className="space-y-5">
                  {[
                    { name: "Dynamic QR Scan", val: "72%", col: "#D4642C" },
                    { name: "Direct Sovereign Link", val: "48%", col: "#E87A43" },
                    { name: "Apple & Google Wallet", val: "35%", col: "#F59E0B" },
                    { name: "WhatsApp & Message", val: "22%", col: "#10B981" },
                  ].map((s, i) => (
                    <div key={i}>
                      <div className="flex justify-between text-xs sm:text-sm mb-1.5">
                        <div className="flex items-center gap-2 text-stone-800 font-semibold">
                          <div
                            className="w-2 h-2 rounded-full"
                            style={{ background: s.col }}
                          />
                          {s.name}
                        </div>
                        <div className="text-stone-500 font-bold">{s.val}</div>
                      </div>

                      <div className="h-2 w-full bg-stone-200/60 rounded-full overflow-hidden">
                        <motion.div
                          initial={{ width: 0 }}
                          whileInView={{ width: s.val }}
                          transition={{ duration: 0.8, delay: 0.4 + i * 0.1 }}
                          className="h-full rounded-full"
                          style={{ background: s.col }}
                        />
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </motion.div>
      </div>
    </section>
  );
}
