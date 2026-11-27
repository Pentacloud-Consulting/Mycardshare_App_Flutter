"use client";

import React from "react";
import Link from "next/link";
import { Sparkles, ArrowRight } from "lucide-react";
import { triggerAppStoreModal } from "@/components/Home/AppStoreModal";

export default function CTA() {
  return (
    <section className="relative w-full bg-[#FAF6F2] pt-16 sm:pt-20 lg:pt-24 pb-12 sm:pb-16 lg:pb-20 overflow-visible">
      {/* Container with top headroom to allow the phone to poke above cleanly */}
      <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        {/* ================= MAIN COMPACT CTA BANNER CARD ================= */}
        <div className="relative rounded-[32px] sm:rounded-[44px] lg:rounded-[48px] bg-gradient-to-br from-[#D4642C] via-[#CE5E27] to-[#B84E1D] text-white shadow-[0_30px_90px_rgba(212,100,44,0.35),0_15px_35px_rgba(0,0,0,0.12)] border border-[#FFA370]/30 py-8 sm:py-10 lg:py-12 flex flex-col justify-center">
          
          {/* Subtle Concentric Circular Watermarks Behind Phone (Matching Image 1 Reference) */}
          <div className="absolute right-4 sm:right-16 lg:right-24 top-1/2 -translate-y-1/2 w-[320px] sm:w-[440px] lg:w-[500px] h-[320px] sm:h-[440px] lg:h-[500px] rounded-full bg-white/10 pointer-events-none" />
          <div className="absolute right-12 sm:right-28 lg:right-36 top-1/2 -translate-y-1/2 w-[200px] sm:w-[280px] lg:w-[340px] h-[200px] sm:h-[280px] lg:h-[340px] rounded-full bg-white/10 pointer-events-none" />

          {/* Ambient Warm Highlights */}
          <div className="absolute top-0 left-1/4 w-72 h-72 bg-white/15 rounded-full blur-[90px] pointer-events-none" />

          {/* ================= LEFT CONTENT COLUMN ================= */}
          <div className="relative z-10 px-6 sm:px-10 lg:pl-14 lg:pr-6 max-w-xl xl:max-w-2xl flex flex-col justify-center space-y-4 sm:space-y-5">
            
            {/* Headline with Serif Italic Accent (From Image 1 Design) */}
            <h2 className="text-2xl sm:text-4xl lg:text-[40px] xl:text-[44px] font-black tracking-tight text-white leading-[1.12]">
              MyCardShare,{" "}
              <span className="font-serif italic font-normal text-[#FFF2EB]">
                your partner
              </span>{" "}
              <br className="hidden sm:inline" />
              in modern networking.
            </h2>

            {/* Subtitle Description */}
            <p className="text-sm sm:text-base text-white/85 font-normal leading-relaxed max-w-lg">
              Create, customize, and share your digital identity in seconds. Tap to share via NFC, Dynamic QR, or Apple and Google Wallets—no app required for recipients.
            </p>

            {/* ================= DOWNLOAD BUTTONS (IMAGE 1 DESIGN) ================= */}
            <div className="flex flex-wrap items-center gap-3 pt-1">
              
              {/* Apple App Store Button (Triggers Launching Soon Modal) */}
              <button
                type="button"
                onClick={triggerAppStoreModal}
                className="inline-flex items-center gap-3 px-5 py-2.5 bg-black hover:bg-neutral-900 text-white rounded-full border border-white/20 shadow-md transition-all duration-300 hover:scale-[1.03] active:scale-100 group cursor-pointer"
              >
                {/* Crisp Apple Logo SVG */}
                <svg className="w-5 h-5 fill-white shrink-0 transition-transform duration-300 group-hover:scale-110" viewBox="0 0 384 512" fill="currentColor">
                  <path d="M318.7 268.7c-.2-36.7 16.4-64.4 50-84.8-18.8-26.9-47.2-41.7-84.7-44.6-35.5-2.8-74.3 20.7-88.5 20.7-15 0-49.4-19.7-76.4-19.7C63.3 141.2 4 184.8 4 273.5q0 39.3 14.4 81.2c12.8 36.7 59 126.7 107.2 125.2 25.2-.6 43-17.9 75.8-17.9 31.8 0 48.3 17.9 76.4 17.9 48.6-.7 90.4-82.5 102.6-119.3-65.2-30.7-61.7-90-61.7-91.9zm-56.6-164.2c27.3-32.4 24.8-61.9 24-72.5-24.1 1.4-52 16.4-67.9 34.9-17.5 19.8-27.8 44.3-25.6 71.9 26.1 2 49.9-11.4 69.5-34.3z" />
                </svg>
                <div className="flex flex-col text-left">
                  <span className="text-[9px] uppercase font-bold text-neutral-300 tracking-wider">
                    Download on the
                  </span>
                  <span className="text-xs sm:text-sm font-extrabold text-white tracking-tight -mt-0.5">
                    App Store
                  </span>
                </div>
              </button>

              {/* Google Play Store Button */}
              <a
                href="https://play.google.com/store/apps/details?id=com_pentacloud.mycarshare"
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center gap-3 px-5 py-2.5 bg-black hover:bg-neutral-900 text-white rounded-full border border-white/20 shadow-md transition-all duration-300 hover:scale-[1.03] active:scale-100 group"
              >
                {/* Crisp Google Play Triangle SVG */}
                <svg className="w-4 h-4 fill-white shrink-0 transition-transform duration-300 group-hover:scale-110" viewBox="0 0 512 512" fill="currentColor">
                  <path d="M325.3 234.3L104.6 13l280.8 161.2-60.1 60.1zM47 0C34 6.8 25.3 19.2 25.3 35.3v441.3c0 16.1 8.7 28.5 21.7 35.3l256.6-256L47 0zm425.2 225.6l-58.9-34.1-65.7 64.5 65.7 64.5 60.1-34.1c18-14.3 18-46.5-1.2-60.8zM104.6 499l280.8-161.2-60.1-60.1L104.6 499z" />
                </svg>
                <div className="flex flex-col text-left">
                  <span className="text-[9px] uppercase font-bold text-neutral-300 tracking-wider">
                    Get it on
                  </span>
                  <span className="text-xs sm:text-sm font-extrabold text-white tracking-tight -mt-0.5">
                    Play Store
                  </span>
                </div>
              </a>

            </div>

            {/* Micro Trust Proof */}
            <div className="pt-1 flex items-center gap-3 text-[11px] text-white/75">
              <span className="flex items-center gap-1.5 font-medium">
                <span className="w-1.5 h-1.5 rounded-full bg-emerald-400" />
                Free to start
              </span>
              <span>•</span>
              <span className="font-medium">iOS & Android Compatible</span>
              <span>•</span>
              <span className="font-medium">4.9 ★ Rating</span>
            </div>

          </div>

          {/* ================= RIGHT SIDE: FLOATING PHONE PROMINENTLY EXTENDING OUTSIDE THE BOX ================= */}
          {/* 
            Desktop View: Anchored flush to the bottom (bottom-0), with explicit width so it naturally 
            towers ~140px-160px ABOVE the top border of the card into the open section headroom.
          */}
          <div className="hidden lg:flex absolute right-6 xl:right-16 bottom-0 items-end justify-center pointer-events-none z-20">
            <img
              src="/images/CTA.png"
              alt="MyCardShare Mobile App Preview"
              className="w-[310px] xl:w-[350px] h-auto object-contain object-bottom drop-shadow-[0_30px_60px_rgba(0,0,0,0.55)] transition-transform duration-500 hover:scale-[1.02]"
            />
          </div>

          {/* Mobile & Tablet View: Clean Bottom Flush Placement with Overlap */}
          <div className="lg:hidden relative flex justify-center items-end mt-4 pt-4 px-4 z-20">
            <img
              src="/images/CTA.png"
              alt="MyCardShare Mobile App Preview"
              className="w-[260px] sm:w-[300px] h-auto object-contain object-bottom drop-shadow-[0_20px_40px_rgba(0,0,0,0.5)]"
            />
          </div>

        </div>

      </div>
    </section>
  );
}
