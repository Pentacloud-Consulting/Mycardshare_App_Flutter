"use client";

import React from "react";
import Image from "next/image";
import Link from "next/link";
import { Zap, ArrowRight } from "lucide-react";

export default function HeroSection() {
  return (
    <section className="relative w-full min-h-screen lg:min-h-[56.25vw] flex flex-col justify-between bg-[#FAF6F2] pt-20 sm:pt-24 pb-8 select-none">
      
      {/* Background Image: 100% full width and bottom-aligned so the bottom is never cut off */}
      <div className="absolute inset-0 z-0 pointer-events-none">
        <Image
          src="/images/Hero_Section_16x9.png"
          alt="MyCardShare Showcase Background"
          fill
          priority
          quality={100}
          className="object-cover object-bottom"
        />
      </div>

      {/* Main Content Container (Fits 1 screen without scrolling) */}
      <div className="relative z-10 w-full max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex-1 flex flex-col justify-between">
        
        {/* Top Headline: Centered with Stepped Indent */}
        <div className="pt-2 sm:pt-4 w-full flex flex-col items-center justify-center">
          <h1 className="inline-block text-left text-3xl sm:text-5xl lg:text-[4rem] xl:text-[4.5rem] font-bold tracking-tight text-[#1E1730] leading-[1.05]">
            <span className="block">Welcome</span>
            <span className="block pl-6 sm:pl-12 lg:pl-20 mt-0.5">
              To <span className="text-[#D4642C]">MyCardShare</span>
            </span>
          </h1>
        </div>

        {/* 3-Column Layout */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-4 lg:gap-6 items-end pb-4 sm:pb-6">
          
          {/* ===================== LEFT SIDE (Shifted Up) ===================== */}
          <div className="lg:col-span-4 flex flex-col justify-between space-y-5 sm:space-y-7 order-2 lg:order-1 -translate-y-20 sm:-translate-y-28 lg:-translate-y-40 xl:-translate-y-48">
            
            {/* Floating Logo Badge */}
            <div className="w-16 h-16 sm:w-20 sm:h-20 lg:w-24 lg:h-24 rounded-2xl sm:rounded-3xl bg-white/95 backdrop-blur-md shadow-[0_10px_30px_rgba(0,0,0,0.06)] border border-[#EFE8E1] flex items-center justify-center animate-float-slow transition-transform hover:scale-105">
              <div className="w-10 h-10 sm:w-12 sm:h-12 rounded-xl sm:rounded-2xl bg-[#FAF6F2] border border-[#EBE3DB] flex items-center justify-center text-[#D4642C] shadow-xs">
                <Zap className="w-5 h-5 sm:w-6 sm:h-6 fill-[#D4642C]" />
              </div>
            </div>

            {/* Bottom-left Tagline */}
            <div className="space-y-2">
              <h3 className="text-lg sm:text-xl lg:text-2xl font-medium tracking-tight text-neutral-900 leading-snug max-w-xs">
                The ultimate networking hack is here.
              </h3>
              <Link
                href="#get-started"
                className="inline-flex items-center gap-1.5 text-xs sm:text-sm font-semibold text-[#D4642C] hover:text-[#BF5422] transition-colors group"
              >
                <span>Start sharing now</span>
                <ArrowRight className="w-3.5 h-3.5 transition-transform group-hover:translate-x-1" />
              </Link>
            </div>

          </div>

          {/* ===================== CENTER SPACER ===================== */}
          <div className="lg:col-span-4 min-h-[200px] sm:min-h-[260px] lg:min-h-[340px] flex items-center justify-center pointer-events-none order-1 lg:order-2">
            {/* Transparent spacer keeping the phone & hand in the background clearly visible */}
          </div>

          {/* ===================== RIGHT SIDE (Shifted Up) ===================== */}
          <div className="lg:col-span-4 flex flex-col justify-between space-y-5 sm:space-y-7 lg:items-start lg:pl-6 order-3 -translate-y-20 sm:-translate-y-28 lg:-translate-y-40 xl:-translate-y-48">
            
            {/* Floating Avatar Card */}
            <div className="w-16 h-16 sm:w-20 sm:h-20 lg:w-24 lg:h-24 rounded-2xl sm:rounded-3xl bg-white/95 backdrop-blur-md shadow-[0_10px_30px_rgba(0,0,0,0.06)] border border-[#EFE8E1] p-1.5 sm:p-2 flex items-center justify-center animate-float-reverse transition-transform hover:scale-105">
              <div className="relative w-full h-full rounded-xl sm:rounded-2xl overflow-hidden bg-[#FAF6F2] flex items-center justify-center border border-[#EBE3DB]">
                <svg className="w-10 h-10 text-[#D4642C]" viewBox="0 0 24 24" fill="currentColor">
                  <path fillRule="evenodd" d="M18.685 19.097A9.723 9.723 0 0 0 21.75 12c0-5.385-4.365-9.75-9.75-9.75S2.25 6.615 2.25 12a9.723 9.723 0 0 0 3.065 7.097A9.716 9.716 0 0 0 12 21.75a9.716 9.716 0 0 0 6.685-2.653Zm-12-1.583a7.525 7.525 0 0 1 10.63 0A8.25 8.25 0 1 1 6.685 17.514ZM12 6a3.75 3.75 0 1 0 0 7.5 3.75 3.75 0 0 0 0-7.5Z" clipRule="evenodd" />
                </svg>
              </div>
            </div>

            {/* Bottom-right Copy & Store Buttons */}
            <div className="space-y-3">
              <p className="text-xs sm:text-sm text-neutral-500 font-normal leading-relaxed max-w-[260px]">
                Bye bye paper clutter. See you later lost contacts. Adios missed professional opportunities.
              </p>

              {/* Store Download Buttons */}
              <div className="flex flex-wrap gap-2 pt-0.5">
                {/* Apple App Store */}
                <Link
                  href="#app-store"
                  className="inline-flex items-center gap-1.5 px-3.5 py-2 bg-[#120F1D] hover:bg-black text-white rounded-full shadow-sm transition-all duration-200 hover:-translate-y-0.5 active:translate-y-0"
                >
                  <svg className="w-3.5 h-3.5 fill-white" viewBox="0 0 170 170">
                    <path d="M150.37 130.25c-2.45 5.66-5.35 10.87-8.71 15.66-4.58 6.53-8.33 11.05-11.22 13.56-4.48 4.12-9.28 6.23-14.42 6.35-3.69 0-8.14-1.05-13.32-3.18-5.19-2.12-9.97-3.17-14.34-3.17-4.58 0-9.49 1.05-14.75 3.17-5.26 2.13-9.5 3.24-12.74 3.35-4.35.13-9.16-1.9-14.42-6.08-3.69-3.08-7.7-7.94-12.04-14.59-6.3-9.69-11.23-20.47-14.78-32.33-3.55-11.86-5.33-23.2-5.33-34.02 0-14.07 3.37-26.04 10.11-35.91 6.74-9.87 15.54-14.93 26.4-15.18 5.43 0 11.23 1.5 17.41 4.5 6.18 3 10.27 4.56 12.28 4.67 1.56 0 5.86-1.63 12.91-4.89 7.05-3.26 13.1-4.66 18.15-4.2 13.59.87 24.32 5.99 32.18 15.36-11.85 7.18-17.65 17.07-17.41 29.69.24 9.9 4.09 18.27 11.55 25.12 7.46 6.85 16.3 10.77 26.52 11.75-2.29 7.07-5.22 14.36-8.79 21.89zM119.22 31.84c0-7.72 2.76-14.93 8.28-21.63 5.52-6.7 12.39-10.74 20.61-12.13.22 1.3.33 2.39.33 3.26 0 7.72-2.88 15.04-8.64 21.96-5.76 6.92-12.82 10.87-21.18 11.85-.22-1.09-.34-2.19-.34-3.31z" />
                  </svg>
                  <span className="text-xs font-semibold">App Store</span>
                </Link>

                {/* Google Play */}
                <Link
                  href="#google-play"
                  className="inline-flex items-center gap-1.5 px-3.5 py-2 bg-[#120F1D] hover:bg-black text-white rounded-full shadow-sm transition-all duration-200 hover:-translate-y-0.5 active:translate-y-0"
                >
                  <svg className="w-3.5 h-3.5 fill-white" viewBox="0 0 24 24">
                    <path d="M3.609 1.814L13.792 12 3.61 22.186a2.38 2.38 0 0 1-.61-.926V2.74c.14-.366.35-.688.61-.926zm11.24 11.24l2.185 2.184-11.787 6.8c-.378.219-.79.324-1.2.324l10.802-9.308zm0-2.108L4.047 1.638C4.457 1.638 4.87 1.743 5.25 1.96l11.784 6.8-2.185 2.186zm1.096 1.054l3.666 2.116c.866.5 1.389 1.408 1.389 2.408 0 1-.523 1.908-1.389 2.408l-3.666 2.116-2.457-2.457 2.457-2.457z" />
                  </svg>
                  <span className="text-xs font-semibold">Google Play</span>
                </Link>
              </div>
            </div>

          </div>

        </div>

      </div>
    </section>
  );
}
