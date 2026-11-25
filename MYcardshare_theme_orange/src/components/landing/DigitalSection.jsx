"use client";

import { motion } from "framer-motion";
import { CheckCircle2 } from "lucide-react";

export default function DigitalSection() {
  return (
    <section className="py-20 md:py-28 relative overflow-hidden bg-white">
      {/* Background Glow */}
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[700px] h-[400px] bg-[#D4642C]/5 blur-[120px] pointer-events-none" />

      <div className="max-w-7xl mx-auto px-6 relative z-10">
        {/* Header */}
        <div className="text-center mb-16">
          <div className="inline-flex items-center gap-2 px-3.5 py-1 rounded-full text-xs font-bold uppercase tracking-widest mb-4 bg-[#FAF6F2] border border-[#EFE8E1] text-[#D4642C]">
            Universal Compatibility
          </div>

          <motion.h2
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            className="text-3xl sm:text-4xl md:text-5xl font-black text-[#18181B] mb-5 tracking-tight"
            style={{ fontFamily: "var(--font-display)" }}
          >
            Nothing Physical.{" "}
            <span className="text-[#D4642C]">100% Digital.</span>
          </motion.h2>

          <motion.p
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="text-base sm:text-lg text-stone-500 max-w-2xl mx-auto leading-relaxed"
          >
            Available everywhere you go. Access your card instantly across our
            web portal, or add it with one click to Apple Wallet, Google Wallet,
            and Samsung Wallet.
          </motion.p>
        </div>

        {/* Wallet Cards Grid */}
        <div className="grid md:grid-cols-3 gap-6 sm:gap-8">
          {/* Apple Wallet */}
          <motion.div
            initial={{ opacity: 0, y: 25 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            whileHover={{ y: -8 }}
            className="bg-[#FAF6F2] border border-[#EFE8E1] rounded-[28px] p-7 sm:p-9 flex flex-col items-center text-center relative overflow-hidden group hover:border-[#D4642C]/40 hover:shadow-[0_15px_35px_rgba(212,100,44,0.08)] hover:bg-white transition-all duration-300 cursor-pointer"
          >
            <div className="w-16 h-16 bg-white rounded-2xl flex items-center justify-center mb-6 shadow-xs border border-[#EFE8E1]">
              <img
                src="https://upload.wikimedia.org/wikipedia/commons/f/fa/Apple_logo_black.svg"
                alt="Apple Wallet"
                className="w-8 h-auto opacity-85"
              />
            </div>

            <h3
              className="text-xl font-bold text-[#18181B] mb-3"
              style={{ fontFamily: "var(--font-display)" }}
            >
              Apple Wallet
            </h3>
            <p className="text-sm text-stone-500 mb-8 leading-relaxed font-normal">
              Add directly to your iPhone or Apple Watch for instant access from
              your lock screen via a quick double-click.
            </p>

            <div className="mt-auto w-full py-3 rounded-xl text-xs sm:text-sm font-bold bg-white border border-[#EFE8E1] text-stone-700 group-hover:bg-[#D4642C] group-hover:text-white group-hover:border-[#D4642C] transition-all duration-300 shadow-xs flex items-center justify-center gap-2">
              <CheckCircle2 size={16} />
              Native Integration
            </div>
          </motion.div>

          {/* Google Wallet */}
          <motion.div
            initial={{ opacity: 0, y: 25 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.1 }}
            whileHover={{ y: -8 }}
            className="bg-[#FAF6F2] border border-[#EFE8E1] rounded-[28px] p-7 sm:p-9 flex flex-col items-center text-center relative overflow-hidden group hover:border-[#D4642C]/40 hover:shadow-[0_15px_35px_rgba(212,100,44,0.08)] hover:bg-white transition-all duration-300 cursor-pointer"
          >
            <div className="w-16 h-16 bg-white rounded-2xl flex items-center justify-center mb-6 shadow-xs border border-[#EFE8E1] overflow-hidden p-3.5">
              <img
                src="/wallet-brands/google-g.svg"
                alt="Google Wallet"
                className="w-full h-full object-contain"
                loading="lazy"
                decoding="async"
              />
            </div>

            <h3
              className="text-xl font-bold text-[#18181B] mb-3"
              style={{ fontFamily: "var(--font-display)" }}
            >
              Google Wallet
            </h3>
            <p className="text-sm text-stone-500 mb-8 leading-relaxed font-normal">
              Seamless 1-tap pass integration with Google Wallet on Android, Wear
              OS, and smart devices.
            </p>

            <div className="mt-auto w-full py-3 rounded-xl text-xs sm:text-sm font-bold bg-white border border-[#EFE8E1] text-stone-700 group-hover:bg-[#D4642C] group-hover:text-white group-hover:border-[#D4642C] transition-all duration-300 shadow-xs flex items-center justify-center gap-2">
              <CheckCircle2 size={16} />
              Google Pay Ready
            </div>
          </motion.div>

          {/* Samsung Wallet */}
          <motion.div
            initial={{ opacity: 0, y: 25 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.2 }}
            whileHover={{ y: -8 }}
            className="bg-[#FAF6F2] border border-[#EFE8E1] rounded-[28px] p-7 sm:p-9 flex flex-col items-center text-center relative overflow-hidden group hover:border-[#D4642C]/40 hover:shadow-[0_15px_35px_rgba(212,100,44,0.08)] hover:bg-white transition-all duration-300 cursor-pointer"
          >
            <div className="w-16 h-16 bg-white rounded-2xl flex items-center justify-center mb-6 shadow-xs border border-[#EFE8E1] overflow-hidden p-3.5">
              <img
                src="/wallet-brands/samsung-symbol.svg"
                alt="Samsung Wallet"
                className="w-full h-full object-contain"
                loading="lazy"
                decoding="async"
              />
            </div>

            <h3
              className="text-xl font-bold text-[#18181B] mb-3"
              style={{ fontFamily: "var(--font-display)" }}
            >
              Samsung Wallet
            </h3>
            <p className="text-sm text-stone-500 mb-8 leading-relaxed font-normal">
              Built natively for Galaxy smartphones with quick swipe-up edge
              panel access anywhere.
            </p>

            <div className="mt-auto w-full py-3 rounded-xl text-xs sm:text-sm font-bold bg-white border border-[#EFE8E1] text-stone-700 group-hover:bg-[#D4642C] group-hover:text-white group-hover:border-[#D4642C] transition-all duration-300 shadow-xs flex items-center justify-center gap-2">
              <CheckCircle2 size={16} />
              Galaxy Optimized
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  );
}
