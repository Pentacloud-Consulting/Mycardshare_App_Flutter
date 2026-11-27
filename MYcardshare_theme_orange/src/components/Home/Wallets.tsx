"use client";

import React from "react";
import { ParallaxStrip } from "@/components/ContentBlocks/Pagination/tsx/ParallaxStrip";

export default function Wallets() {
  return (
    <section className="relative w-full bg-[#FAF6F2] pt-6 sm:pt-10 lg:pt-12 pb-6 sm:pb-8 lg:pb-10 overflow-hidden border-b border-[#EFE6DD]">
      {/* Subtle ambient warm lighting accents */}
      <div className="absolute top-1/4 -right-32 w-80 h-80 bg-[#D4642C]/8 rounded-full blur-[120px] pointer-events-none" />
      <div className="absolute bottom-10 -left-32 w-80 h-80 bg-[#D4642C]/6 rounded-full blur-[100px] pointer-events-none" />

      <div className="relative max-w-7xl mx-auto px-3.5 sm:px-6 lg:px-8 z-10">
        
        {/* ================= SECTION HEADER ================= */}
        <div className="text-center max-w-2xl mx-auto mb-4 sm:mb-8">
          {/* Top Pill Badge */}
          <div className="inline-flex items-center gap-1.5 sm:gap-2 px-2.5 sm:px-3.5 py-1 sm:py-1.5 rounded-full text-[10px] sm:text-xs font-semibold uppercase tracking-wider bg-[#F6E3D8] text-[#B85222] border border-[#D4642C]/20 mb-2.5 sm:mb-3.5">
            <span className="w-1.5 h-1.5 rounded-full bg-[#D4642C] animate-pulse" />
            <span>NATIVE DIGITAL WALLET PASSES</span>
          </div>

          {/* Headline */}
          <h2 className="text-2xl sm:text-4xl lg:text-5xl font-bold font-['Space_Grotesk'] text-[#2A1E17] tracking-tight leading-[1.14]">
            Instant Access in <span className="text-[#D4642C]">Every Native Wallet</span>
          </h2>

          {/* Subtitle */}
          <p className="mt-2.5 sm:mt-3.5 text-xs sm:text-base lg:text-lg text-[#7A6A5F] font-normal leading-relaxed">
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
