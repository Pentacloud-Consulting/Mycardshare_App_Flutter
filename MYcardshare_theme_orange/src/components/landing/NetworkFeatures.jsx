"use client";

import { motion } from "framer-motion";
import { CheckCircle2, Globe } from "lucide-react";
import Link from "next/link";
import { UiloraBrandButton } from "../UIComponents/Button/tsx/UiloraModernButtons";

export default function NetworkFeatures() {
  return (
    <section className="py-20 md:py-28 bg-[#FAF6F2] relative overflow-hidden">
      <div className="max-w-7xl mx-auto px-6">
        <div className="grid lg:grid-cols-2 gap-12 lg:gap-16 items-center">
          {/* Left Text Content */}
          <motion.div
            initial={{ opacity: 0, x: -30 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.7 }}
          >
            <div className="inline-flex items-center gap-2 px-3.5 py-1 rounded-full text-xs font-bold uppercase tracking-widest mb-4 bg-white border border-[#EFE8E1] text-[#D4642C]">
              Network Intelligence
            </div>

            <h2
              className="text-3xl sm:text-4xl lg:text-5xl font-black text-[#18181B] mb-5 uppercase leading-tight tracking-tight"
              style={{ fontFamily: "var(--font-display)" }}
            >
              Build your network
              <br />
              <span className="text-[#D4642C]">seamlessly</span>
            </h2>

            <p className="text-base sm:text-lg text-stone-600 mb-8 max-w-lg leading-relaxed">
              Instantly capture leads when someone views your card. Route
              contact info directly into your CRM or email without requiring any
              app downloads from your client.
            </p>

            {/* Features list */}
            <ul className="space-y-3.5 mb-10">
              {[
                "Two-way frictionless contact exchange",
                "Automated CRM syncing (HubSpot, Salesforce)",
                "Real-time analytics and geo-reach tracking",
              ].map((item) => (
                <li key={item} className="flex items-center gap-3 text-stone-800">
                  <CheckCircle2 size={20} className="text-[#D4642C] shrink-0" />
                  <span className="font-semibold text-sm sm:text-base">{item}</span>
                </li>
              ))}
            </ul>

            <Link href="/about">
              <UiloraBrandButton
                variant="outline"
                className="px-8 py-3 text-sm font-bold"
              >
                Learn More About Us
              </UiloraBrandButton>
            </Link>
          </motion.div>

          {/* Right Visuals Animation */}
          <motion.div
            initial={{ opacity: 0, scale: 0.95 }}
            whileInView={{ opacity: 1, scale: 1 }}
            viewport={{ once: true }}
            transition={{ duration: 0.8 }}
            className="relative min-h-[420px] md:min-h-[500px] flex items-center justify-center p-4 md:p-8"
          >
            {/* Background Connection Lines */}
            <svg
              className="absolute inset-0 w-full h-full opacity-30"
              viewBox="0 0 600 600"
            >
              <motion.path
                d="M300 300 L 100 100 M 300 300 L 500 150 M 300 300 L 80 450 M 300 300 L 520 500"
                stroke="#D4642C"
                strokeWidth="1.5"
                strokeDasharray="8 8"
                animate={{ strokeDashoffset: [100, 0] }}
                transition={{ duration: 12, repeat: Infinity, ease: "linear" }}
              />
            </svg>

            {/* Floating Network Nodes */}
            {[
              { t: "10%", l: "6%", bg: "bg-[#D4642C]", label: "SJ", text: "text-white" },
              { t: "18%", l: "86%", bg: "bg-white", label: "MC", d: 1, text: "text-[#D4642C]" },
              { t: "76%", l: "4%", bg: "bg-white", label: "AW", d: 2, text: "text-[#D4642C]" },
              { t: "82%", l: "88%", bg: "bg-[#E87A43]", label: "RK", d: 3, text: "text-white" },
            ].map((n, i) => (
              <motion.div
                key={i}
                animate={{ y: [0, -12, 0] }}
                transition={{
                  duration: 4,
                  repeat: Infinity,
                  delay: n.d || 0,
                  ease: "easeInOut",
                }}
                className={`absolute w-10 h-10 md:w-12 md:h-12 rounded-full ${n.bg} flex items-center justify-center ${n.text} font-bold text-xs md:text-sm shadow-md z-30 border border-[#EFE8E1]`}
                style={{ top: n.t, left: n.l }}
              >
                {n.label}
              </motion.div>
            ))}

            {/* Main Digital Card */}
            <motion.div
              whileHover={{ rotateY: 8, rotateX: -4 }}
              transition={{ type: "spring", stiffness: 100, damping: 30 }}
              className="relative z-20 w-[270px] md:w-[310px] rounded-[32px] p-6 bg-white border border-[#EFE8E1] shadow-[0_20px_50px_rgba(212,100,44,0.12)]"
              style={{ transformPerspective: 1200 }}
            >
              {/* Background glow inside card */}
              <div className="absolute top-0 right-0 w-36 h-36 bg-[#D4642C]/10 blur-[40px] rounded-full pointer-events-none" />

              <div className="relative z-10">
                {/* Top section */}
                <div className="flex justify-between items-start mb-6">
                  <div>
                    <h3
                      className="text-[#18181B] text-xl font-bold mb-0.5"
                      style={{ fontFamily: "var(--font-display)" }}
                    >
                      Sophie Moore
                    </h3>
                    <div className="text-[#D4642C] text-[10px] font-black uppercase tracking-widest">
                      Product Designer
                    </div>
                  </div>

                  <div className="w-10 h-10 bg-[#FAF6F2] border border-[#EFE8E1] rounded-full flex items-center justify-center shadow-xs">
                    <Globe size={18} className="text-[#D4642C]" />
                  </div>
                </div>

                {/* Profile image */}
                <div className="flex flex-col items-center mb-6">
                  <div className="w-32 h-32 md:w-36 md:h-36 rounded-[24px] overflow-hidden border border-[#EFE8E1] mb-3 shadow-md bg-stone-100 pointer-events-none">
                    <img
                      src="https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=2576&auto=format&fit=crop"
                      alt="Sophie Moore"
                      className="w-full h-full object-cover"
                    />
                  </div>

                  <div className="text-stone-400 text-[10px] uppercase font-bold tracking-widest">
                    Verified Digital Profile
                  </div>
                </div>

                <div className="py-2.5 rounded-xl bg-[#D4642C] text-white text-center font-bold text-xs uppercase tracking-wider shadow-xs">
                  Connect With Sophie
                </div>
              </div>
            </motion.div>
          </motion.div>
        </div>
      </div>
    </section>
  );
}
