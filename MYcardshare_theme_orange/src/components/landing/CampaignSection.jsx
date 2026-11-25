"use client";

import { motion } from "framer-motion";
import { Calendar, Users, BarChart, Plus } from "lucide-react";
import Link from "next/link";
import { UiloraBrandButton } from "@/components/UIComponents/Button/tsx/UiloraModernButtons";

export default function CampaignSection() {
  return (
    <section className="py-20 md:py-28 bg-[#FAF6F2]">
      <div className="max-w-7xl mx-auto px-6">
        {/* Main Card Container */}
        <div className="bg-white border border-[#EFE8E1] rounded-[36px] p-8 sm:p-12 md:p-16 relative overflow-hidden shadow-[0_15px_45px_rgba(212,100,44,0.06)]">
          {/* Subtle warm glow */}
          <div className="absolute top-0 right-0 w-[500px] h-[500px] bg-[#D4642C]/8 blur-[100px] pointer-events-none" />

          <div className="grid lg:grid-cols-2 gap-10 md:gap-14 items-center relative z-10">
            {/* Left Side: Content */}
            <div>
              <div className="w-12 h-12 bg-[#FAF6F2] text-[#D4642C] rounded-2xl flex items-center justify-center mb-6 border border-[#EFE8E1] shadow-xs">
                <Calendar size={24} />
              </div>

              <h2
                className="text-3xl sm:text-4xl md:text-5xl font-black text-[#18181B] mb-5 leading-[1.12] uppercase tracking-tight"
                style={{
                  fontFamily: "var(--font-display)",
                }}
              >
                Every Event is
                <br />
                <span className="text-[#D4642C]">Its Own Campaign</span>
              </h2>

              <p className="text-base sm:text-lg text-stone-500 mb-8 leading-relaxed font-normal">
                Create unique links and dynamic QR codes tailored for specific
                events, summits, or executive meetings. Track real-time
                performance, scan attribution, and conversion rates
                independently.
              </p>

              <Link href="/portal">
                <UiloraBrandButton className="px-8 py-3.5 text-sm font-bold normal-case">
                  Launch a Campaign
                </UiloraBrandButton>
              </Link>
            </div>

            {/* Right Side: Campaign Cards */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              {[
                {
                  title: "GITEX Global 2026",
                  scans: 642,
                  conv: "18.4%",
                  color: "border-l-[#D4642C]",
                },
                {
                  title: "Q3 Executive Summit",
                  scans: 285,
                  conv: "26.1%",
                  color: "border-l-[#E87A43]",
                },
                {
                  title: "TechCrunch Disrupt",
                  scans: 1120,
                  conv: "14.2%",
                  color: "border-l-[#F59E0B]",
                },
              ].map((camp, i) => (
                <motion.div
                  key={i}
                  initial={{ opacity: 0, y: 15 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  transition={{ delay: i * 0.08 }}
                  viewport={{ once: true }}
                  className={`bg-[#FAF6F2] border border-[#EFE8E1] border-l-4 ${camp.color} p-5 rounded-2xl shadow-xs`}
                >
                  <div className="text-stone-400 font-bold text-[10px] uppercase tracking-widest mb-1">
                    Event Campaign
                  </div>

                  <div className="font-bold text-[#18181B] text-base mb-4">
                    {camp.title}
                  </div>

                  <div className="flex justify-between items-end">
                    <div>
                      <div className="flex items-center gap-1 text-stone-500 text-xs font-bold tracking-wider mb-0.5">
                        <Users size={12} className="text-[#D4642C]" /> Scans
                      </div>
                      <div
                        className="text-2xl font-black text-[#18181B]"
                        style={{ fontFamily: "var(--font-display)" }}
                      >
                        {camp.scans}
                      </div>
                    </div>

                    <div>
                      <div className="flex items-center gap-1 text-stone-500 text-xs font-bold tracking-wider mb-0.5">
                        <BarChart size={12} className="text-[#D4642C]" /> Conv.
                      </div>
                      <div className="text-base font-bold text-[#D4642C]">
                        {camp.conv}
                      </div>
                    </div>
                  </div>
                </motion.div>
              ))}

              {/* Add New Campaign Card */}
              <motion.div
                initial={{ opacity: 0, y: 15 }}
                whileInView={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.25 }}
                viewport={{ once: true }}
                className="bg-white border-2 border-dashed border-[#D4642C]/30 hover:border-[#D4642C] rounded-2xl p-5 flex flex-col items-center justify-center text-center cursor-pointer transition-colors group shadow-xs"
              >
                <div className="w-10 h-10 rounded-full bg-[#FAF6F2] border border-[#EFE8E1] flex items-center justify-center text-[#D4642C] mb-2 group-hover:scale-110 transition-transform">
                  <Plus size={18} />
                </div>
                <div className="text-xs font-bold uppercase tracking-wider text-[#18181B]">
                  New Campaign
                </div>
                <div className="text-[11px] text-stone-400 mt-0.5">
                  Generate Custom Event QR
                </div>
              </motion.div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
