"use client";

import React, { useRef, useEffect } from "react";

export default function MarketingVideo() {
  const videoRef = useRef<HTMLVideoElement>(null);

  useEffect(() => {
    if (videoRef.current) {
      videoRef.current.play().catch(() => {});
    }
  }, []);

  return (
    <section className="relative w-full -mt-8 sm:-mt-12 lg:-mt-16 z-20">
      
      {/* ================= SPLIT BACKGROUND (DARK ON TOP, LIGHT ON BOTTOM) ================= */}
      {/* 
        Top half is Dark Theme (#0D0B0A) with curved top corners and no dots.
        Bottom half is Light Theme (#FAF6F2 Warm Cream) starting at the midpoint of the video showcase card.
      */}
      <div className="absolute inset-0 pointer-events-none flex flex-col">
        {/* Top Dark Background: covers Header + top 50% of Video */}
        <div className="relative w-full flex-1 bg-[#0D0B0A] text-white rounded-t-[36px] sm:rounded-t-[48px] lg:rounded-t-[64px] border-t border-white/15 shadow-[0_-25px_60px_rgba(0,0,0,0.6)] overflow-hidden">
          {/* Top Ambient Glow Accent in Theme Matte Orange (#D4642C) */}
          <div className="absolute top-0 left-1/2 -translate-x-1/2 w-3/4 max-w-2xl h-[2px] bg-gradient-to-r from-transparent via-[#D4642C]/60 to-transparent" />

          {/* Smooth Ambient Glows (NO DOTS PATTERN) */}
          <div className="absolute top-1/4 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[700px] h-[450px] bg-[#D4642C]/18 rounded-full blur-[140px]" />
          <div className="absolute top-10 right-10 w-[450px] h-[350px] bg-[#D4642C]/10 rounded-full blur-[120px]" />
        </div>

        {/* Bottom Light Theme Background: starts at half video and flows down */}
        <div className="w-full h-[240px] sm:h-[340px] lg:h-[480px] bg-[#FAF6F2] relative border-b border-neutral-200/40">
          {/* Subtle Warm Tone Reflection on the Light Surface */}
          <div className="absolute top-0 left-1/2 -translate-x-1/2 w-3/4 max-w-3xl h-[120px] bg-[#D4642C]/5 rounded-full blur-[80px]" />
        </div>
      </div>

      {/* ================= FOREGROUND CONTENT ================= */}
      <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-16 sm:pt-24 lg:pt-28 pb-16 sm:pb-24 lg:pb-28 z-10">
        
        {/* ================= TOP HEADER AREA ================= */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 lg:gap-12 items-end mb-12 sm:mb-16">
          
          {/* Left Column: Title & Badge */}
          <div className="lg:col-span-7 space-y-4">
            {/* Main Headline with Theme Orange Highlight */}
            <h2 className="text-3xl sm:text-5xl lg:text-6xl font-black tracking-tight text-white uppercase leading-[1.08]">
              SEE HOW IT <br className="hidden sm:inline" />
              <span className="bg-gradient-to-r from-white via-neutral-100 to-[#FFA370] bg-clip-text text-transparent">
                WORKS IN{" "}
              </span>
              <span className="text-[#D4642C]">
                ACTION
              </span>
            </h2>

            {/* Small Established / Platform Status Tag */}
            <div className="flex items-center gap-3 pt-1">
              <span className="text-[11px] font-semibold text-neutral-500 uppercase tracking-widest">
                Platform
              </span>
              <span className="px-2.5 py-0.5 rounded-md bg-[#D4642C]/15 border border-[#D4642C]/30 text-xs font-bold text-[#FFA370]">
                v2.6 Live
              </span>
            </div>
          </div>

          {/* Right Column: Description + Metrics Row */}
          <div className="lg:col-span-5 flex flex-col justify-between space-y-6">
            <p className="text-sm sm:text-base text-neutral-400 font-normal leading-relaxed max-w-md">
              A frictionless digital card experience natively embedded in modern networking workflows.
            </p>

            {/* Metrics Row */}
            <div className="grid grid-cols-3 gap-4 pt-4 border-t border-white/10">
              <div>
                <div className="text-2xl sm:text-3xl font-black text-white tracking-tight">
                  +90%
                </div>
                <div className="text-[10px] sm:text-xs font-bold uppercase tracking-wider text-neutral-500 mt-1">
                  Faster Access
                </div>
              </div>

              <div>
                <div className="text-2xl sm:text-3xl font-black text-[#FFA370] tracking-tight">
                  100%
                </div>
                <div className="text-[10px] sm:text-xs font-bold uppercase tracking-wider text-neutral-500 mt-1">
                  Compatibility
                </div>
              </div>

              <div>
                <div className="text-2xl sm:text-3xl font-black text-white tracking-tight">
                  50K+
                </div>
                <div className="text-[10px] sm:text-xs font-bold uppercase tracking-wider text-neutral-500 mt-1">
                  Cards Shared
                </div>
              </div>
            </div>
          </div>

        </div>

        {/* ================= VIDEO SHOWCASE CONTAINER (LOOPING MUTED VIDEO) ================= */}
        <div className="relative w-full rounded-[28px] sm:rounded-[36px] lg:rounded-[44px] overflow-hidden border border-white/15 shadow-[0_25px_70px_rgba(0,0,0,0.6)] group">
          
          <div className="relative w-full aspect-[16/9] min-h-[340px] sm:min-h-[460px] lg:min-h-[580px] bg-gradient-to-tr from-[#141110] via-[#1F1916] to-[#2B201B]">
            
            {/* Native Looping HTML5 Video */}
            <video
              ref={videoRef}
              src="/video/MyCardShare%20video.mp4"
              autoPlay
              loop
              muted
              playsInline
              preload="auto"
              className="absolute inset-0 w-full h-full object-cover object-center"
            />

            {/* Dark Cinematic Vignette & Ambient Warm Orange Gradient Overlays */}
            <div className="absolute inset-0 bg-gradient-to-t from-black/85 via-transparent to-black/20 pointer-events-none" />
            <div className="absolute inset-0 bg-gradient-to-tr from-[#D4642C]/10 via-transparent to-black/30 pointer-events-none" />

            {/* Bottom Bar Info on Video */}
            <div className="absolute bottom-4 sm:bottom-6 inset-x-4 sm:inset-x-8 flex items-center justify-between text-xs sm:text-sm text-neutral-300 z-10 pointer-events-none">
              <div className="flex items-center gap-2">
                <span className="font-semibold text-white drop-shadow-md">
                  Watch how top teams share & connect in 3 seconds
                </span>
              </div>
              <div className="hidden sm:flex items-center gap-4 text-neutral-300 drop-shadow-md">
                <span>NFC Tap</span>
                <span>•</span>
                <span>Instant QR</span>
                <span>•</span>
                <span>CRM Auto-Sync</span>
              </div>
            </div>

          </div>

        </div>

      </div>
    </section>
  );
}
