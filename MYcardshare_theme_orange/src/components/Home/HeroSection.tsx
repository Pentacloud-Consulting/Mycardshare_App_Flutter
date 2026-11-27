"use client";

import React from "react";
import Image from "next/image";
import Link from "next/link";
import { triggerAppStoreModal } from "@/components/Home/AppStoreModal";
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
                {/* Apple App Store (Triggers Launching Soon Modal) */}
                <button
                  type="button"
                  onClick={triggerAppStoreModal}
                  className="inline-flex items-center gap-1.5 px-3.5 py-2 bg-[#120F1D] hover:bg-black text-white rounded-full shadow-sm transition-all duration-200 hover:-translate-y-0.5 active:translate-y-0 cursor-pointer"
                >
                  <svg className="w-3.5 h-3.5 fill-white shrink-0" viewBox="0 0 384 512" fill="currentColor">
                    <path d="M318.7 268.7c-.2-36.7 16.4-64.4 50-84.8-18.8-26.9-47.2-41.7-84.7-44.6-35.5-2.8-74.3 20.7-88.5 20.7-15 0-49.4-19.7-76.4-19.7C63.3 141.2 4 184.8 4 273.5q0 39.3 14.4 81.2c12.8 36.7 59 126.7 107.2 125.2 25.2-.6 43-17.9 75.8-17.9 31.8 0 48.3 17.9 76.4 17.9 48.6-.7 90.4-82.5 102.6-119.3-65.2-30.7-61.7-90-61.7-91.9zm-56.6-164.2c27.3-32.4 24.8-61.9 24-72.5-24.1 1.4-52 16.4-67.9 34.9-17.5 19.8-27.8 44.3-25.6 71.9 26.1 2 49.9-11.4 69.5-34.3z" />
                  </svg>
                  <span className="text-xs font-semibold">App Store</span>
                </button>

                {/* Google Play */}
                <a
                  href="https://play.google.com/store/apps/details?id=com_pentacloud.mycarshare"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex items-center gap-1.5 px-3.5 py-2 bg-[#120F1D] hover:bg-black text-white rounded-full shadow-sm transition-all duration-200 hover:-translate-y-0.5 active:translate-y-0"
                >
                  <svg className="w-3.5 h-3.5 fill-white shrink-0" viewBox="0 0 512 512" fill="currentColor">
                    <path d="M325.3 234.3L104.6 13l280.8 161.2-60.1 60.1zM47 0C34 6.8 25.3 19.2 25.3 35.3v441.3c0 16.1 8.7 28.5 21.7 35.3l256.6-256L47 0zm425.2 225.6l-58.9-34.1-65.7 64.5 65.7 64.5 60.1-34.1c18-14.3 18-46.5-1.2-60.8zM104.6 499l280.8-161.2-60.1-60.1L104.6 499z" />
                  </svg>
                  <span className="text-xs font-semibold">Google Play</span>
                </a>
              </div>
            </div>

          </div>

        </div>

      </div>
    </section>
  );
}
