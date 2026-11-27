"use client";

import React, { useState } from "react";
import { Play, X, Sparkles, CheckCircle2, ShieldCheck, Zap } from "lucide-react";

export default function MarketingVideo() {
  const [isPlaying, setIsPlaying] = useState(false);

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
        
        {/* ================= TOP HEADER AREA (IMAGE 1 LAYOUT + IMAGE 2 INFORMATION) ================= */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 lg:gap-12 items-end mb-12 sm:mb-16">
          
          {/* Left Column: Title & Badge */}
          <div className="lg:col-span-7 space-y-4">
            {/* Main Headline from Image 2 with Theme Orange Highlight */}
            <h2 className="text-3xl sm:text-5xl lg:text-6xl font-black tracking-tight text-white uppercase leading-[1.08]">
              SEE HOW IT <br className="hidden sm:inline" />
              <span className="bg-gradient-to-r from-white via-neutral-100 to-[#FFA370] bg-clip-text text-transparent">
                WORKS IN{" "}
              </span>
              <span className="text-[#D4642C]">
                ACTION
              </span>
            </h2>

            {/* Small Established / Platform Status Tag (Image 1 style) */}
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
            {/* Description from Image 2 */}
            <p className="text-sm sm:text-base text-neutral-400 font-normal leading-relaxed max-w-md">
              A frictionless digital card experience natively embedded in modern networking workflows.
            </p>

            {/* Metrics Row from Image 2 + Additional Live Stats */}
            <div className="grid grid-cols-3 gap-4 pt-4 border-t border-white/10">
              {/* Stat 1 */}
              <div>
                <div className="text-2xl sm:text-3xl font-black text-white tracking-tight">
                  +90%
                </div>
                <div className="text-[10px] sm:text-xs font-bold uppercase tracking-wider text-neutral-500 mt-1">
                  Faster Access
                </div>
              </div>

              {/* Stat 2 */}
              <div>
                <div className="text-2xl sm:text-3xl font-black text-[#FFA370] tracking-tight">
                  100%
                </div>
                <div className="text-[10px] sm:text-xs font-bold uppercase tracking-wider text-neutral-500 mt-1">
                  Compatibility
                </div>
              </div>

              {/* Stat 3 (Trusted Platform Scale) */}
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

        {/* ================= VIDEO SHOWCASE CONTAINER (IMAGE 1 DESIGN) ================= */}
        <div className="relative w-full rounded-[28px] sm:rounded-[36px] lg:rounded-[44px] overflow-hidden border border-white/15 shadow-[0_25px_70px_rgba(0,0,0,0.6)] group">
          
          {/* Video Thumbnail Background */}
          <div className="relative w-full aspect-[16/9] min-h-[340px] sm:min-h-[460px] lg:min-h-[580px] bg-gradient-to-tr from-[#141110] via-[#1F1916] to-[#2B201B]">
            
            {/* High quality business collaboration local background photo */}
            <img
              src="/images/marketing_video_thumb.jpg"
              alt="MyCardShare Platform Demo Showcase"
              loading="eager"
              className="absolute inset-0 w-full h-full object-cover object-center opacity-75 group-hover:scale-105 transition-transform duration-700 ease-out"
            />

            {/* Dark Cinematic Vignette & Ambient Warm Orange Gradient Overlays */}
            <div className="absolute inset-0 bg-gradient-to-t from-black/90 via-black/40 to-black/30 pointer-events-none" />
            <div className="absolute inset-0 bg-gradient-to-tr from-[#D4642C]/25 via-transparent to-black/40 pointer-events-none" />

            {/* Central Play Button with Pulsing Radar Rings (from Image 1) */}
            <div className="absolute inset-0 flex items-center justify-center z-20">
              <button
                type="button"
                onClick={() => setIsPlaying(true)}
                aria-label="Play Product Video"
                className="relative group/btn flex items-center justify-center cursor-pointer focus:outline-hidden"
              >
                {/* Radar Pulse Wave 1 */}
                <div className="absolute w-20 h-20 sm:w-28 sm:h-28 rounded-full border-2 border-[#D4642C] animate-sonar pointer-events-none" />
                
                {/* Radar Pulse Wave 2 */}
                <div className="absolute w-20 h-20 sm:w-28 sm:h-28 rounded-full border border-[#FFA370] animate-sonar pointer-events-none" style={{ animationDelay: '1.4s' }} />

                {/* Main Glowing Button Body */}
                <div className="relative w-16 h-16 sm:w-22 sm:h-22 rounded-full bg-gradient-to-tr from-[#D4642C] to-[#F18F58] text-white flex items-center justify-center shadow-[0_0_35px_rgba(212,100,44,0.7)] transition-all duration-300 group-hover/btn:scale-110 group-hover/btn:shadow-[0_0_50px_rgba(212,100,44,0.9)] active:scale-95">
                  <Play className="w-7 h-7 sm:w-9 sm:h-9 fill-white text-white ml-1 transition-transform group-hover/btn:scale-110" />
                </div>
              </button>
            </div>

            {/* Bottom Bar Info on Thumbnail */}
            <div className="absolute bottom-4 sm:bottom-6 inset-x-4 sm:inset-x-8 flex items-center justify-between text-xs sm:text-sm text-neutral-300 z-10">
              <div className="flex items-center gap-2">
                <span className="font-semibold text-white">Watch how top teams share & connect in 3 seconds</span>
              </div>
              <div className="hidden sm:flex items-center gap-4 text-neutral-400">
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

      {/* ================= INTERACTIVE VIDEO MODAL ================= */}
      {isPlaying && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/90 backdrop-blur-xl p-4 sm:p-6 animate-in fade-in duration-200">
          <div className="relative w-full max-w-5xl aspect-[16/9] bg-neutral-900 rounded-3xl overflow-hidden shadow-2xl border border-white/20">
            {/* Close Button */}
            <button
              onClick={() => setIsPlaying(false)}
              aria-label="Close video"
              className="absolute top-4 right-4 z-20 w-10 h-10 rounded-full bg-black/70 hover:bg-[#D4642C] text-white flex items-center justify-center transition-colors"
            >
              <X className="w-5 h-5" />
            </button>

            {/* Embedded Video Player */}
            <iframe
              className="w-full h-full"
              src="https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ?autoplay=1"
              title="MyCardShare Product Video"
              allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
              allowFullScreen
            />
          </div>
        </div>
      )}
    </section>
  );
}
