"use client";

import React from "react";
import Link from "next/link";
import { Sparkles, ArrowRight } from "lucide-react";

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
              
              {/* Apple App Store Button */}
              <Link
                href="#app-store"
                className="inline-flex items-center gap-2.5 px-4 sm:px-5 py-2.5 bg-black hover:bg-neutral-900 text-white rounded-xl border border-white/20 shadow-md transition-all duration-300 hover:scale-[1.03] active:scale-100 group"
              >
                {/* Crisp Apple Logo SVG */}
                <svg className="w-5 h-5 fill-white transition-transform duration-300 group-hover:scale-110" viewBox="0 0 170 170">
                  <path d="M150.37 130.25c-2.45 5.66-5.35 10.87-8.71 15.66-4.58 6.53-8.33 11.05-11.22 13.56-4.48 4.12-9.28 6.23-14.42 6.35-3.69 0-8.14-1.05-13.32-3.18-5.19-2.12-9.97-3.17-14.34-3.17-4.58 0-9.49 1.05-14.75 3.17-5.26 2.13-9.5 3.24-12.74 3.35-4.35.13-9.16-1.9-14.42-6.08-3.69-3.08-7.7-7.94-12.04-14.59-6.3-9.69-11.23-20.47-14.78-32.33-3.55-11.86-5.33-23.2-5.33-34.02 0-14.07 3.37-26.04 10.11-35.91 6.74-9.87 15.54-14.93 26.4-15.18 5.43 0 11.23 1.5 17.41 4.5 6.18 3 10.27 4.56 12.28 4.67 1.56 0 5.86-1.63 12.91-4.89 7.05-3.26 13.1-4.66 18.15-4.2 13.59.87 24.32 5.99 32.18 15.36-11.85 7.18-17.65 17.07-17.41 29.69.24 9.9 4.09 18.27 11.55 25.12 7.46 6.85 16.3 10.77 26.52 11.75-2.29 7.07-5.22 14.36-8.79 21.89zM119.22 31.84c0-7.72 2.76-14.93 8.28-21.63 5.52-6.7 12.39-10.74 20.61-12.13.22 1.3.33 2.39.33 3.26 0 7.72-2.88 15.04-8.64 21.96-5.76 6.92-12.82 10.87-21.18 11.85-.22-1.09-.34-2.19-.34-3.31z" />
                </svg>
                <div className="flex flex-col text-left">
                  <span className="text-[9px] uppercase font-semibold text-neutral-300 tracking-wider">
                    Download on the
                  </span>
                  <span className="text-xs sm:text-sm font-extrabold text-white tracking-tight -mt-0.5">
                    App Store
                  </span>
                </div>
              </Link>

              {/* Google Play Store Button */}
              <Link
                href="#play-store"
                className="inline-flex items-center gap-2.5 px-4 sm:px-5 py-2.5 bg-black hover:bg-neutral-900 text-white rounded-xl border border-white/20 shadow-md transition-all duration-300 hover:scale-[1.03] active:scale-100 group"
              >
                {/* Crisp Google Play Triangle SVG */}
                <svg className="w-4 h-4 fill-white transition-transform duration-300 group-hover:scale-110" viewBox="0 0 24 24">
                  <path d="M3.609 1.814L13.792 12 3.61 22.186a2.38 2.38 0 0 1-.61-.926V2.74c.14-.366.35-.688.61-.926zm11.24 11.24l2.185 2.184-11.787 6.8c-.378.219-.79.324-1.2.324l10.802-9.308zm0-2.108L4.047 1.638C4.457 1.638 4.87 1.743 5.25 1.96l11.784 6.8-2.185 2.186zm1.096 1.054l3.666 2.116c.866.5 1.389 1.408 1.389 2.408 0 1-.523 1.908-1.389 2.408l-3.666 2.116-2.457-2.457 2.457-2.457z" />
                </svg>
                <div className="flex flex-col text-left">
                  <span className="text-[9px] uppercase font-semibold text-neutral-300 tracking-wider">
                    Get it on
                  </span>
                  <span className="text-xs sm:text-sm font-extrabold text-white tracking-tight -mt-0.5">
                    Play Store
                  </span>
                </div>
              </Link>

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
