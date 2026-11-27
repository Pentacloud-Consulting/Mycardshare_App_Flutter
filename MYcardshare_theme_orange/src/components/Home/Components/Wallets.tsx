"use client";

import React from "react";
import { ParallaxStrip } from "@/components/ContentBlocks/Pagination/tsx/ParallaxStrip";

export default function Wallets() {
  return (
    <section className="relative w-full bg-[#FAF6F2] py-16 sm:py-20 lg:py-24 overflow-hidden border-b border-[#EFE6DD]">
      {/* Subtle ambient warm lighting accents */}
      <div className="absolute top-1/4 -right-32 w-80 h-80 bg-[#D4642C]/8 rounded-full blur-[120px] pointer-events-none" />
      <div className="absolute bottom-10 -left-32 w-80 h-80 bg-[#D4642C]/6 rounded-full blur-[100px] pointer-events-none" />

      <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 z-10">
        
        {/* ================= SECTION HEADER ================= */}
        <div className="text-center max-w-2xl mx-auto mb-10 sm:mb-12">
          {/* Top Pill Badge */}
          <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full text-xs font-semibold uppercase tracking-wider bg-[#F6E3D8] text-[#B85222] border border-[#D4642C]/20 mb-3.5">
            <span className="w-1.5 h-1.5 rounded-full bg-[#D4642C] animate-pulse" />
            <span>NATIVE DIGITAL WALLET PASSES</span>
          </div>

          {/* Headline */}
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold font-['Space_Grotesk'] text-[#2A1E17] tracking-tight leading-[1.14]">
            Instant Access in <span className="text-[#D4642C]">Every Native Wallet</span>
          </h2>

          {/* Subtitle */}
          <p className="mt-3.5 text-base sm:text-lg text-[#7A6A5F] font-normal leading-relaxed">
            Store your verified digital identity directly into Google Wallet, Apple Wallet, and Samsung Wallet. Live updates, offline QR display, and instant push notifications.
          </p>
        </div>

        {/* ================= PARALLAX STRIP SHOWCASE (ORANGE THEME - 3 WALLETS) ================= */}
        <ParallaxStrip totalPages={3} />

      </div>
    </section>
  );
}

export { ParallaxStrip };
