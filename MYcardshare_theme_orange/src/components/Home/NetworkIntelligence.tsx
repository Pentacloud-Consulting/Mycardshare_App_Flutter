"use client";

import React, { useState } from "react";
import { motion } from "framer-motion";
import { Globe, Check, ArrowRight, Wifi } from "lucide-react";

export default function NetworkIntelligence() {
  const [connected, setConnected] = useState(false);

  return (
    <section className="relative w-full bg-[#FAF6F2] pt-6 sm:pt-8 lg:pt-10 pb-8 sm:pb-10 lg:pb-12 overflow-hidden border-b border-[#EFE6DD]">
      {/* Background soft ambient glow */}
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[400px] bg-[#D4642C]/5 rounded-full blur-[140px] pointer-events-none" />

      <div className="relative max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 z-10">
        
        {/* Main Clean Card Container */}
        <div className="relative bg-white rounded-[32px] sm:rounded-[40px] border border-[#EFE6DD] shadow-[0_20px_50px_rgba(212,100,44,0.05),0_2px_12px_rgba(0,0,0,0.02)] p-7 sm:p-10 lg:p-14 overflow-hidden">
          
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-10 lg:gap-14 items-center">
            
            {/* ================= LEFT COLUMN: CLEAN COPY & BULLETS ================= */}
            <div className="lg:col-span-6 flex flex-col items-start space-y-5">
              
              {/* Top Pill Badge */}
              <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full text-xs font-semibold uppercase tracking-wider bg-[#F6E3D8] text-[#B85222] border border-[#D4642C]/20">
                <span className="w-1.5 h-1.5 rounded-full bg-[#D4642C]" />
                <span>NETWORK INTELLIGENCE</span>
              </div>

              {/* Display Headline */}
              <h2 className="text-3xl sm:text-4xl lg:text-[42px] font-black tracking-tight text-[#18181B] font-['Space_Grotesk'] leading-[1.1] uppercase">
                BUILD YOUR NETWORK <br />
                <span className="text-[#D4642C]">SEAMLESSLY</span>
              </h2>

              {/* Subtitle */}
              <p className="text-sm sm:text-base text-[#7A6A5F] leading-relaxed font-normal max-w-lg">
                Instantly capture leads when someone views your card. Route contact info directly into your CRM or email without requiring any app downloads from your client.
              </p>

              {/* 3 Clean Simple Bullets */}
              <div className="space-y-3 pt-1 w-full max-w-md">
                {[
                  "Two-way frictionless contact exchange",
                  "Automated CRM syncing (HubSpot, Salesforce)",
                  "Real-time analytics and geo-reach tracking",
                ].map((item, idx) => (
                  <div key={idx} className="flex items-center gap-3 text-xs sm:text-sm font-medium text-[#2A1E17]">
                    <div className="w-5 h-5 rounded-full bg-[#F6E3D8] text-[#D4642C] flex items-center justify-center shrink-0">
                      <Check className="w-3 h-3 stroke-[2.5]" />
                    </div>
                    <span>{item}</span>
                  </div>
                ))}
              </div>

              {/* Clean Single Button */}
              <div className="pt-3">
                <a
                  href="#how-it-works"
                  className="group inline-flex items-center gap-2 px-6 py-3.5 rounded-full bg-white hover:bg-[#FAF6F2] text-[#18181B] font-bold text-xs sm:text-sm uppercase tracking-wider border border-[#E4D7CC] hover:border-[#D4642C]/40 shadow-xs transition-all duration-200 cursor-pointer"
                >
                  <span>Learn More About Us</span>
                  <ArrowRight className="w-4 h-4 text-[#D4642C] group-hover:translate-x-0.5 transition-transform" />
                </a>
              </div>

            </div>

            {/* ================= RIGHT COLUMN: SINGLE CLEAN DIGITAL PROFILE CARD ================= */}
            <div className="lg:col-span-6 relative flex items-center justify-center py-4">
              
              {/* Soft Ambient Radial Behind the Card */}
              <div className="absolute w-72 h-72 rounded-full bg-[#D4642C]/8 blur-[60px] pointer-events-none" />

              {/* The Clean Floating Card */}
              <motion.div
                whileHover={{ y: -4 }}
                transition={{ duration: 0.25 }}
                className="relative z-10 w-full max-w-[310px] bg-white rounded-3xl p-5 sm:p-6 border border-[#EFE6DD] shadow-[0_20px_45px_rgba(212,100,44,0.08),0_4px_16px_rgba(0,0,0,0.02)]"
              >
                {/* Card Header: Name + Globe */}
                <div className="flex items-start justify-between mb-4">
                  <div>
                    <h3 className="text-lg font-bold text-[#18181B] font-['Space_Grotesk'] leading-tight">
                      Sophie Moore
                    </h3>
                    <p className="text-[10px] font-bold font-mono tracking-wider text-[#D4642C] uppercase mt-0.5">
                      PRODUCT DESIGNER
                    </p>
                  </div>

                  <div className="w-8 h-8 rounded-full bg-[#FAF6F2] border border-[#EFE6DD] flex items-center justify-center text-[#7A6A5F]">
                    <Globe className="w-4 h-4" />
                  </div>
                </div>

                {/* Portrait Image */}
                <div className="relative w-full aspect-[4/3] rounded-2xl overflow-hidden bg-[#FAF6F2] mb-4 shadow-inner">
                  <img
                    src="https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=600&auto=format&fit=crop"
                    alt="Sophie Moore"
                    className="w-full h-full object-cover object-top"
                  />
                  {/* Subtle NFC Tag */}
                  <div className="absolute top-2.5 right-2.5 px-2 py-0.5 rounded-md bg-black/40 backdrop-blur-xs text-white text-[9px] font-mono flex items-center gap-1 border border-white/15">
                    <Wifi className="w-2.5 h-2.5 rotate-90 text-[#FFA370]" />
                    <span>NFC</span>
                  </div>
                </div>

                {/* Verified Tag */}
                <div className="flex items-center justify-center gap-1.5 mb-3.5 text-[10px] font-mono tracking-widest text-[#7A6A5F] uppercase font-semibold">
                  <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse" />
                  <span>VERIFIED DIGITAL PROFILE</span>
                </div>

                {/* Single Clean Button */}
                <button
                  type="button"
                  onClick={() => setConnected(!connected)}
                  className="w-full py-3 rounded-full bg-[#D4642C] hover:bg-[#B85222] text-white font-bold text-xs tracking-wider uppercase transition-all duration-200 shadow-[0_6px_18px_rgba(212,100,44,0.25)] flex items-center justify-center gap-2 cursor-pointer"
                >
                  {connected ? (
                    <>
                      <Check className="w-3.5 h-3.5 text-white" />
                      <span>Contact Saved</span>
                    </>
                  ) : (
                    <span>Connect with Sophie</span>
                  )}
                </button>

              </motion.div>

            </div>

          </div>

        </div>

      </div>
    </section>
  );
}
