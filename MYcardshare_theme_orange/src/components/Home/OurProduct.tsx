"use client";

import React from "react";
import { CinematicSlice } from "@/components/ContentBlocks/Pagination/tsx/CinematicSlice";

export default function OurProduct() {
  return (
    <section className="relative w-full bg-[#FAF6F2] pt-10 sm:pt-12 lg:pt-14 pb-8 sm:pb-10 lg:pb-12 overflow-hidden border-b border-[#EFE6DD]">
      {/* Ambient background glows */}
      <div className="absolute top-1/3 left-1/2 -translate-x-1/2 w-[600px] h-[350px] bg-[#D4642C]/8 rounded-full blur-[140px] pointer-events-none" />

      <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 z-10">
        
        {/* ================= SECTION HEADER ================= */}
        <div className="text-center max-w-2xl mx-auto mb-6 sm:mb-8">
          {/* Top Pill Badge */}
          <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full text-xs font-semibold uppercase tracking-wider bg-[#F6E3D8] text-[#B85222] border border-[#D4642C]/20 mb-3.5">
            <span className="w-1.5 h-1.5 rounded-full bg-[#D4642C] animate-pulse" />
            <span>MYCARDSHARE SIGNATURE HARDWARE</span>
          </div>

          {/* Headline */}
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold font-['Space_Grotesk'] text-[#2A1E17] tracking-tight leading-[1.14]">
            Crafted for <span className="text-[#D4642C]">Visual Impact</span>
          </h2>

          {/* Subtitle */}
          <p className="mt-3.5 text-base sm:text-lg text-[#7A6A5F] font-normal leading-relaxed">
            Experience our bespoke MyCardShare collections — premium matte metal, sustainable eco-bamboo, frosted acrylic, and instant NFC tap interactions.
          </p>
        </div>

        {/* ================= CINEMATIC SLICE COMPONENT ================= */}
        <CinematicSlice totalPages={5} />

      </div>
    </section>
  );
}

export { CinematicSlice };
