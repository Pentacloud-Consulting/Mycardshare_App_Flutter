"use client";

import { motion } from "framer-motion";
import { Smartphone, Building2, CheckCircle2 } from "lucide-react";
import Link from "next/link";
import { UiloraBrandButton } from "../UIComponents/Button/tsx/UiloraModernButtons";

export default function AudienceSplit() {
  return (
    <section className="py-20 md:py-28 bg-[#FAF6F2] relative overflow-hidden">
      <div className="max-w-7xl mx-auto px-6 relative z-10">
        {/* Header */}
        <div className="text-center mb-14 sm:mb-18">
          <div className="inline-flex items-center gap-2 px-3.5 py-1 rounded-full text-xs font-bold uppercase tracking-widest mb-4 bg-white border border-[#EFE8E1] text-[#D4642C]">
            Tailored For You
          </div>

          <motion.h2
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            className="text-3xl sm:text-4xl md:text-5xl font-black text-[#18181B] tracking-tight leading-tight uppercase"
            style={{
              fontFamily: "var(--font-display)",
            }}
          >
            Built for Everyone,
            <br />
            <span className="text-[#D4642C]">Individuals & Enterprises</span>
          </motion.h2>
        </div>

        {/* Two Column Layout */}
        <div className="grid md:grid-cols-2 gap-8 lg:gap-10">
          {/* Card 1: Individuals */}
          <motion.div
            initial={{ opacity: 0, y: 25 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            whileHover={{ y: -6 }}
            className="p-8 sm:p-10 rounded-[30px] border border-[#EFE8E1] bg-white relative overflow-hidden group shadow-[0_10px_35px_rgba(212,100,44,0.05)] transition-all duration-300"
          >
            <div className="absolute top-0 right-0 w-44 h-44 bg-[#D4642C]/5 blur-3xl pointer-events-none" />

            <div className="relative z-10">
              <div className="w-12 h-12 bg-[#FAF6F2] text-[#D4642C] rounded-2xl border border-[#EFE8E1] flex items-center justify-center mb-6 shadow-xs">
                <Smartphone size={24} />
              </div>

              <h3
                className="text-2xl font-black text-[#18181B] mb-3"
                style={{ fontFamily: "var(--font-display)" }}
              >
                For Individuals
              </h3>

              <p className="text-stone-500 mb-8 text-base leading-relaxed font-normal">
                Leave a lasting impression with a modern digital business card.
                Share via NFC tap, dynamic QR code, or digital wallet pass.
              </p>

              <ul className="space-y-3.5 mb-10">
                {[
                  "Fully customizable luxury identity profile",
                  "Apple, Google & Samsung Wallet 1-tap passes",
                  "Contact vault with CSV export and lead notes",
                  "Real-time view analytics and geo-tracking",
                ].map((it) => (
                  <li key={it} className="flex items-center gap-3 text-stone-800">
                    <CheckCircle2 size={18} className="text-[#D4642C] shrink-0" />
                    <span className="font-semibold text-sm sm:text-base">{it}</span>
                  </li>
                ))}
              </ul>

              <Link href="/signup" className="block w-full">
                <UiloraBrandButton className="w-full py-3.5 normal-case font-bold text-sm">
                  Create Your Personal Card
                </UiloraBrandButton>
              </Link>
            </div>
          </motion.div>

          {/* Card 2: Enterprises */}
          <motion.div
            initial={{ opacity: 0, y: 25 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.1 }}
            whileHover={{ y: -6 }}
            className="p-8 sm:p-10 rounded-[30px] border border-[#EFE8E1] bg-white relative overflow-hidden group shadow-[0_10px_35px_rgba(212,100,44,0.05)] transition-all duration-300"
          >
            <div className="absolute top-0 right-0 w-44 h-44 bg-[#E87A43]/5 blur-3xl pointer-events-none" />

            <div className="relative z-10">
              <div className="w-12 h-12 bg-[#FAF6F2] text-[#E87A43] rounded-2xl border border-[#EFE8E1] flex items-center justify-center mb-6 shadow-xs">
                <Building2 size={24} />
              </div>

              <h3
                className="text-2xl font-black text-[#18181B] mb-3"
                style={{ fontFamily: "var(--font-display)" }}
              >
                For Enterprise & Teams
              </h3>

              <p className="text-stone-500 mb-8 text-base leading-relaxed font-normal">
                Standardize your corporate identity at scale. Centralize brand
                governance, employee offboarding, and aggregate CRM pipeline.
              </p>

              <ul className="space-y-3.5 mb-10">
                {[
                  "Centralized workforce admin dashboard",
                  "Automated bulk employee invitation codes",
                  "Direct pipeline sync to HubSpot & Salesforce",
                  "Corporate domain masking and custom subdomains",
                ].map((it) => (
                  <li key={it} className="flex items-center gap-3 text-stone-800">
                    <CheckCircle2 size={18} className="text-[#D4642C] shrink-0" />
                    <span className="font-semibold text-sm sm:text-base">{it}</span>
                  </li>
                ))}
              </ul>

              <Link href="/enterprise" className="block w-full">
                <UiloraBrandButton
                  variant="outline"
                  className="w-full py-3.5 normal-case font-bold text-sm"
                >
                  Explore Enterprise Solutions
                </UiloraBrandButton>
              </Link>
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  );
}
