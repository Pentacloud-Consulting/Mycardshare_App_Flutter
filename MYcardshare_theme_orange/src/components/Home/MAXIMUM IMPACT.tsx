"use client";

import React, { useState } from "react";
import Link from "next/link";
import {
  ArrowRight,
  QrCode,
  RefreshCw,
  ShieldCheck,
  BarChart3,
  Bot,
  Network,
  CheckCircle2,
  Lock,
  Globe,
  Radio,
  Sparkles,
  ScanLine,
  Phone,
  Mail
} from "lucide-react";

export default function MaximumImpact() {
  return (
    <section className="relative w-full bg-[#FAF6F2] -mt-6 sm:-mt-10 lg:-mt-14 z-20">
      {/* Dark Bento Sheet with Large Curved Top Corners */}
      <div className="relative w-full bg-[#0D0B0A] text-white rounded-t-[36px] sm:rounded-t-[48px] lg:rounded-t-[64px] py-16 sm:py-24 lg:py-28 overflow-hidden border-t border-white/10 shadow-[0_-25px_60px_rgba(0,0,0,0.3)]">
        
        {/* Subtle Top Ambient Glow Accent in Theme Matte Orange */}
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-3/4 max-w-2xl h-[2px] bg-gradient-to-r from-transparent via-[#D4642C]/40 to-transparent pointer-events-none" />

        {/* Ambient Warm Orange Glows (Theme #D4642C) */}
        <div className="absolute top-1/4 -left-40 w-[500px] h-[500px] bg-[#D4642C]/20 rounded-full blur-[140px] pointer-events-none" />
        <div className="absolute bottom-10 right-0 w-[600px] h-[600px] bg-[#D4642C]/18 rounded-full blur-[160px] pointer-events-none" />
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[700px] h-[700px] bg-[#D4642C]/10 rounded-full blur-[180px] pointer-events-none" />

        {/* Grid Pattern Background */}
        <div className="absolute inset-0 bg-[radial-gradient(#262220_1px,transparent_1px)] [background-size:24px_24px] opacity-40 pointer-events-none" />

        <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 z-10">
          
          {/* Section Header */}
          <div className="text-center max-w-3xl mx-auto mb-14 sm:mb-20">
            <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-white/5 border border-white/10 text-xs sm:text-sm font-bold tracking-widest uppercase text-neutral-300 mb-4 backdrop-blur-md">
              <span className="w-2 h-2 rounded-full bg-[#D4642C] animate-ping" />
              ENGINEERED FOR
            </div>

            <h2 className="text-4xl sm:text-5xl md:text-6xl font-black tracking-tight text-white uppercase leading-[1.1]">
              MAXIMUM{" "}
              <span className="bg-gradient-to-r from-[#D4642C] via-[#F18F58] to-[#FFA370] bg-clip-text text-transparent">
                IMPACT
              </span>
            </h2>

            <p className="mt-4 sm:mt-5 text-base sm:text-lg text-neutral-400 font-normal leading-relaxed">
              We don’t just build digital cards. We engineer professional ecosystems designed to multiply your growth and secure your network.
            </p>
          </div>

          {/* ==================== BENTO GRID SHOWCASE ==================== */}
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-stretch">
            
            {/* ================= CARD 1: ANALYTICS (Top Left - Spans 7 cols) ================= */}
            <div className="lg:col-span-7 relative group rounded-3xl p-6 sm:p-8 bg-gradient-to-b from-[#1C1816] to-[#141110] border border-white/10 shadow-[0_20px_50px_rgba(0,0,0,0.5)] overflow-hidden flex flex-col justify-between transition-all duration-300 hover:border-[#D4642C]/40">
              {/* Card Background Ambient Glow */}
              <div className="absolute -bottom-10 -right-10 w-72 h-72 bg-[#D4642C]/25 rounded-full blur-[80px] pointer-events-none group-hover:bg-[#D4642C]/35 transition-all duration-500" />

              <div>
                <div className="flex items-center justify-between mb-4">
                  <span className="text-xs font-bold text-neutral-500 tracking-wider">04</span>
                  <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#D4642C]/10 border border-[#D4642C]/30 text-[11px] font-semibold text-[#F18F58]">
                    <span className="w-1.5 h-1.5 rounded-full bg-[#D4642C] animate-pulse" />
                    REAL-TIME
                  </div>
                </div>

                <div className="max-w-md">
                  <h3 className="text-2xl sm:text-3xl font-bold text-white tracking-tight flex items-center gap-2.5">
                    <BarChart3 className="w-6 h-6 text-[#D4642C]" />
                    Analytics
                  </h3>
                  <p className="mt-2 text-sm text-neutral-400 leading-relaxed">
                    Track engagement, total scans, and conversion rates in a real-time command center.
                  </p>
                </div>
              </div>

              {/* Dashboard Visuals: ANIMATED WATER FLOW WAVE + BARS */}
              <div className="mt-8 pt-6 border-t border-white/5 grid grid-cols-1 sm:grid-cols-2 gap-4">
                
                {/* Est. Total Reach Bar Chart with Dynamic Equalizer Wave (Like Image 3) */}
                <div className="p-4 rounded-2xl bg-black/40 border border-white/5 backdrop-blur-sm">
                  <div className="flex items-center justify-between text-xs text-neutral-400 mb-3">
                    <span className="font-medium text-white">Est. Total Reach</span>
                    <span className="text-[10px] text-neutral-500">Last 30 Days</span>
                  </div>
                  
                  {/* Visual Bar Graph (All Bars in Matte Orange Theme with Dynamic Equalizer Wave) */}
                  <div className="h-24 flex items-end gap-2 pt-2 px-1">
                    {[
                      { h: 26, peak: false },
                      { h: 22, peak: false },
                      { h: 32, peak: false },
                      { h: 54, peak: false },
                      { h: 76, peak: true },
                      { h: 96, peak: true },
                      { h: 90, peak: true },
                      { h: 80, peak: false },
                    ].map((bar, i) => (
                      <div key={i} className="flex-1 flex flex-col items-center h-full justify-end">
                        <div
                          className={`w-full rounded-t-md origin-bottom transition-all duration-300 bg-gradient-to-t from-[#B84E1D] via-[#D4642C] to-[#FFA370] ${
                            bar.peak
                              ? "shadow-[0_0_18px_rgba(212,100,44,0.7)] brightness-110"
                              : "shadow-[0_0_10px_rgba(212,100,44,0.35)] opacity-85 hover:opacity-100"
                          }`}
                          style={{
                            height: `${bar.h}px`,
                            animation: `reachBarBounce 1.8s ease-in-out infinite`,
                            animationDelay: `${i * 0.18}s`,
                          }}
                        />
                      </div>
                    ))}
                  </div>

                  <div className="mt-3 flex items-center justify-between text-[11px] text-neutral-400">
                    <span>Growth</span>
                    <span className="text-emerald-400 font-semibold">+138.4%</span>
                  </div>
                </div>

                {/* Scans & Conversion with Fluid Water Flowing Wave Animation (100% Aligned) */}
                <div className="p-4 rounded-2xl bg-black/40 border border-white/5 backdrop-blur-sm flex flex-col justify-between overflow-hidden">
                  <div className="flex items-center justify-between text-xs text-neutral-400 mb-2">
                    <span className="font-medium text-white">Scans & Conversion</span>
                    <span className="text-xs font-bold text-[#FFA370]">94.2%</span>
                  </div>

                  {/* SVG Water Flow Line Animation - Unified Single Precise Path */}
                  <div className="h-20 w-full relative">
                    <svg className="w-full h-full overflow-visible" viewBox="0 0 160 50">
                      <defs>
                        <linearGradient id="waterGrad" x1="0" y1="0" x2="0" y2="1">
                          <stop offset="0%" stopColor="#D4642C" stopOpacity="0.45" />
                          <stop offset="100%" stopColor="#D4642C" stopOpacity="0.0" />
                        </linearGradient>
                      </defs>

                      {/* Fluid Background Wave Fill (Perfect match to curve) */}
                      <path
                        d="M 0,38 C 32,36 54,26 84,26 C 110,26 122,10 135,10 C 146,10 152,14 160,18 L 160,50 L 0,50 Z"
                        fill="url(#waterGrad)"
                        opacity="0.8"
                      />

                      {/* Solid Base Curve Line */}
                      <path
                        d="M 0,38 C 32,36 54,26 84,26 C 110,26 122,10 135,10 C 146,10 152,14 160,18"
                        fill="none"
                        stroke="#D4642C"
                        strokeWidth="2.5"
                        strokeLinecap="round"
                        opacity="0.6"
                      />

                      {/* Flowing Water Energy Pulse (Follows the EXACT same path) */}
                      <path
                        d="M 0,38 C 32,36 54,26 84,26 C 110,26 122,10 135,10 C 146,10 152,14 160,18"
                        fill="none"
                        stroke="#FFA370"
                        strokeWidth="2.5"
                        strokeLinecap="round"
                        className="animate-water-wave-fast"
                      />

                      {/* Pulsing Peak Node (Exact Apex at 135, 10) */}
                      <circle cx="135" cy="10" r="4.5" fill="#FFFFFF" className="animate-pulse" />
                      <circle cx="135" cy="10" r="9" fill="#FFA370" opacity="0.4" />
                    </svg>
                  </div>

                  {/* Team Tags */}
                  <div className="grid grid-cols-2 gap-1.5 pt-2 text-[10px] text-neutral-400">
                    <div className="flex items-center gap-1.5">
                      <span className="w-2 h-2 rounded-xs bg-[#D4642C]" />
                      <span>23 Growth Teams</span>
                    </div>
                    <div className="flex items-center gap-1.5">
                      <span className="w-2 h-2 rounded-xs bg-neutral-600" />
                      <span>18 Field Sales</span>
                    </div>
                  </div>
                </div>

              </div>

              {/* Bottom Row Action */}
              <div className="mt-6 flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <div className="h-2 w-24 sm:w-36 rounded-full bg-neutral-800 overflow-hidden flex">
                    <div className="h-full w-2/3 bg-[#D4642C]" />
                    <div className="h-full w-1/3 bg-neutral-700" />
                  </div>
                  <span className="text-[11px] text-neutral-400">8.4k Live Scans</span>
                </div>

                <Link
                  href="#analytics"
                  className="inline-flex items-center gap-2 px-5 py-2.5 rounded-full bg-[#D4642C] hover:bg-[#BF5422] text-white text-xs font-bold tracking-wide shadow-[0_4px_16px_rgba(212,100,44,0.4)] transition-all duration-200 hover:-translate-y-0.5"
                >
                  <span>Get Started</span>
                  <ArrowRight className="w-3.5 h-3.5" />
                </Link>
              </div>
            </div>

            {/* ================= CARD 2: CRM SYNC (Top Right - Spans 5 cols) ================= */}
            <div className="lg:col-span-5 relative group rounded-3xl p-6 sm:p-8 bg-gradient-to-b from-[#1C1816] to-[#141110] border border-white/10 shadow-[0_20px_50px_rgba(0,0,0,0.5)] overflow-hidden flex flex-col justify-between transition-all duration-300 hover:border-[#D4642C]/40">
              <div className="absolute top-1/2 right-0 w-60 h-60 bg-[#D4642C]/20 rounded-full blur-[70px] pointer-events-none" />

              <div>
                <div className="flex items-center justify-between mb-4">
                  <span className="text-xs font-bold text-neutral-500 tracking-wider">02</span>
                  <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#D4642C]/10 border border-[#D4642C]/30 text-[11px] font-semibold text-[#F18F58]">
                    <span className="w-1.5 h-1.5 rounded-full bg-[#D4642C]" />
                    AUTOMATED
                  </div>
                </div>

                <h3 className="text-2xl sm:text-3xl font-bold text-white tracking-tight flex items-center gap-2.5">
                  <RefreshCw className="w-6 h-6 text-[#D4642C]" />
                  CRM Sync
                </h3>
                <p className="mt-2 text-sm text-neutral-400 leading-relaxed">
                  Automatically route leads to Salesforce & HubSpot without manual data entry.
                </p>
              </div>

              {/* Flowing Water Wave Cards + Dynamic Equalizer Lead Val Bars (Image 2) */}
              <div className="relative mt-8 min-h-[190px] flex items-center justify-center">
                
                {/* Back Card (MRR) with Flowing Wave */}
                <div className="absolute top-0 right-4 sm:right-6 w-44 p-3.5 rounded-2xl bg-[#211C19]/90 border border-white/10 shadow-xl backdrop-blur-md transition-transform duration-300 group-hover:translate-x-1 group-hover:-translate-y-1">
                  <div className="text-[10px] text-neutral-400 uppercase tracking-wider font-semibold">
                    HubSpot Synced
                  </div>
                  <div className="text-lg font-black text-white mt-1">$65,500</div>
                  <div className="h-6 w-full mt-2 overflow-hidden">
                    <svg className="w-full h-full" viewBox="0 0 100 20">
                      <path
                        d="M0 15 Q 30 5, 50 12 T 100 4"
                        fill="none"
                        stroke="#D4642C"
                        strokeWidth="2"
                        className="animate-water-wave"
                      />
                    </svg>
                  </div>
                </div>

                {/* Front Large Card (ARR Pipeline) with Flowing Wave */}
                <div className="absolute bottom-0 left-2 sm:left-4 w-52 p-4 rounded-2xl bg-[#191513]/95 border border-[#D4642C]/40 shadow-2xl backdrop-blur-md z-10 transition-transform duration-300 group-hover:-translate-y-1">
                  <div className="flex items-center justify-between">
                    <span className="text-[10px] text-neutral-400 uppercase font-semibold">Salesforce ARR</span>
                    <span className="text-[10px] font-bold text-emerald-400">+7% in Q1</span>
                  </div>
                  <div className="text-2xl font-black text-white mt-1">$458,000</div>
                  <div className="h-8 w-full mt-2 overflow-hidden">
                    <svg className="w-full h-full" viewBox="0 0 120 25">
                      <path
                        d="M0 20 Q 25 18, 45 8 T 85 14 T 120 3"
                        fill="none"
                        stroke="#FFA370"
                        strokeWidth="2.5"
                        className="animate-water-wave-fast"
                      />
                    </svg>
                  </div>
                </div>

                {/* Small Metric Pill Card (Lead Val.) with Dynamic Glowing Equalizer Bars (Like Image 2) */}
                <div className="absolute bottom-2 right-1 sm:right-3 w-32 p-3 rounded-2xl bg-[#14100E]/95 border border-[#D4642C]/40 shadow-xl backdrop-blur-md z-20">
                  <div className="flex items-center justify-between text-[10px] text-neutral-400">
                    <span>Lead Val.</span>
                    <span className="text-[9px] font-bold text-emerald-400">+18.2%</span>
                  </div>
                  <div className="text-base font-bold text-white tracking-tight mt-0.5">$21.60</div>
                  
                  {/* Equalizer Bars: dynamically changing heights in looping wave */}
                  <div className="h-7 flex items-end gap-1.5 mt-2">
                    {[
                      { h: 10, peak: false },
                      { h: 16, peak: false },
                      { h: 24, peak: true },
                      { h: 20, peak: true },
                      { h: 26, peak: true },
                      { h: 14, peak: false },
                    ].map((bar, idx) => (
                      <div key={idx} className="flex-1 flex flex-col items-center h-full justify-end">
                        <div
                          className={`w-full rounded-t-sm origin-bottom bg-gradient-to-t from-[#B84E1D] via-[#D4642C] to-[#FFA370] ${
                            bar.peak
                              ? "shadow-[0_0_12px_rgba(212,100,44,0.8)] brightness-110"
                              : "shadow-[0_0_6px_rgba(212,100,44,0.4)] opacity-90"
                          }`}
                          style={{
                            height: `${bar.h}px`,
                            animation: `reachBarBounce 1.5s ease-in-out infinite`,
                            animationDelay: `${idx * 0.16}s`,
                          }}
                        />
                      </div>
                    ))}
                  </div>
                </div>

              </div>
            </div>

            {/* ================= CARD 3: SMART NETWORKING (Unique Network Effect - Image 3) ================= */}
            <div className="lg:col-span-4 relative group rounded-3xl p-6 sm:p-8 bg-gradient-to-b from-[#1C1816] to-[#141110] border border-white/10 shadow-[0_20px_50px_rgba(0,0,0,0.5)] overflow-hidden flex flex-col justify-between transition-all duration-300 hover:border-[#D4642C]/40">
              <div>
                <div className="flex items-center justify-between mb-4">
                  <span className="text-xs font-bold text-neutral-500 tracking-wider">06</span>
                  <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#D4642C]/10 border border-[#D4642C]/30 text-[11px] font-semibold text-[#F18F58]">
                    <span className="w-1.5 h-1.5 rounded-full bg-[#D4642C]" />
                    ECOSYSTEM
                  </div>
                </div>

                <h3 className="text-2xl font-bold text-white tracking-tight flex items-center gap-2.5">
                  <Network className="w-6 h-6 text-[#D4642C]" />
                  Smart Networking
                </h3>
                <p className="mt-2 text-sm text-neutral-400 leading-relaxed">
                  Transform single interactions into powerful, interconnected business ecosystems.
                </p>
              </div>

              {/* Unique Interactive Network Animation (Sonar radar rings, laser connection pulses, active badge) */}
              <div className="relative mt-8 p-4 rounded-2xl bg-black/50 border border-white/5 backdrop-blur-sm min-h-[160px] flex items-center justify-center overflow-hidden">
                
                {/* Floating Live Interaction Ping Badge */}
                <div className="absolute top-2 right-2 inline-flex items-center gap-1.5 px-2 py-0.5 rounded-full bg-[#D4642C]/15 border border-[#D4642C]/40 text-[9px] font-semibold text-[#FFA370] animate-pulse z-20">
                  <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-ping" />
                  <span>Lead Connected</span>
                </div>

                {/* Network Nodes Cluster with Direct Responsive Connection Lines */}
                <div className="relative w-full max-w-sm flex items-center justify-between z-10 pt-2 px-1 sm:px-3">
                  
                  {/* User 1: Jenny */}
                  <div className="relative flex flex-col items-center">
                    <div className="w-11 h-11 rounded-full bg-gradient-to-tr from-[#D4642C] to-[#F18F58] p-0.5 shadow-md">
                      <div className="w-full h-full rounded-full bg-[#1A1614] flex items-center justify-center text-xs font-bold text-white">
                        JN
                      </div>
                    </div>
                    <span className="mt-1.5 text-[10px] font-semibold text-neutral-300 bg-black/80 px-2 py-0.5 rounded-full border border-white/10 whitespace-nowrap">
                      Jenny
                    </span>
                  </div>

                  {/* Laser Connector Line 1 (Jenny -> Lexie) */}
                  <div className="flex-1 h-[2px] mx-1.5 sm:mx-2 relative bg-[#D4642C]/30 -translate-y-2 overflow-hidden rounded-full">
                    <div
                      className="absolute inset-0 bg-gradient-to-r from-transparent via-[#FFA370] to-transparent"
                      style={{
                        animation: "shimmerSweep 2.2s cubic-bezier(0.4, 0, 0.6, 1) infinite",
                      }}
                    />
                  </div>

                  {/* Central Key Executive: Lexie with expanding sonar radar rings */}
                  <div className="relative flex flex-col items-center -translate-y-2">
                    <div className="relative w-14 h-14 flex items-center justify-center">
                      {/* Perfectly Centered Sonar Ring 1 */}
                      <div className="absolute inset-0 rounded-full border-2 border-[#D4642C] animate-sonar pointer-events-none" />
                      {/* Perfectly Centered Sonar Ring 2 */}
                      <div className="absolute inset-0 rounded-full border border-[#FFA370] animate-sonar pointer-events-none" style={{ animationDelay: '1.4s' }} />

                      <div className="relative w-14 h-14 rounded-full bg-gradient-to-tr from-[#D4642C] to-[#FFA370] p-1 shadow-[0_0_24px_rgba(212,100,44,0.7)] z-10">
                        <div className="w-full h-full rounded-full bg-[#1A1614] flex items-center justify-center text-sm font-extrabold text-[#FFA370]">
                          LX
                        </div>
                      </div>
                    </div>
                    <span className="mt-1.5 text-[11px] font-bold text-white bg-[#D4642C] px-2.5 py-0.5 rounded-full shadow-md z-10 whitespace-nowrap">
                      Lexie • CEO
                    </span>
                  </div>

                  {/* Laser Connector Line 2 (Lexie -> Marcus) */}
                  <div className="flex-1 h-[2px] mx-1.5 sm:mx-2 relative bg-[#D4642C]/30 -translate-y-2 overflow-hidden rounded-full">
                    <div
                      className="absolute inset-0 bg-gradient-to-r from-transparent via-[#FFA370] to-transparent"
                      style={{
                        animation: "shimmerSweep 2.2s cubic-bezier(0.4, 0, 0.6, 1) infinite",
                        animationDelay: "1.1s",
                      }}
                    />
                  </div>

                  {/* User 3: Marcus */}
                  <div className="relative flex flex-col items-center">
                    <div className="w-11 h-11 rounded-full bg-gradient-to-tr from-[#D4642C] to-[#F18F58] p-0.5 shadow-md">
                      <div className="w-full h-full rounded-full bg-[#1A1614] flex items-center justify-center text-xs font-bold text-white">
                        MC
                      </div>
                    </div>
                    <span className="mt-1.5 text-[10px] font-semibold text-neutral-300 bg-black/80 px-2 py-0.5 rounded-full border border-white/10 whitespace-nowrap">
                      Marcus
                    </span>
                  </div>

                </div>

              </div>

              <div className="mt-6 flex items-center justify-between">
                <span className="text-xs text-neutral-400">3,400+ Interconnected Leads</span>
                <Link
                  href="#network"
                  className="text-xs font-semibold text-[#F18F58] hover:text-white flex items-center gap-1 transition-colors"
                >
                  Explore <ArrowRight className="w-3 h-3" />
                </Link>
              </div>
            </div>

            {/* ================= CARD 4 & 5: MIDDLE COLUMN (Spans 4 cols) ================= */}
            <div className="lg:col-span-4 flex flex-col gap-6">
              
              {/* CARD 4: DYNAMIC QR (Moving Dot Ping-Pong over Curved Arc - Image 4) */}
              <div className="relative group rounded-3xl p-6 bg-gradient-to-b from-[#1C1816] to-[#141110] border border-white/10 shadow-xl overflow-hidden flex flex-col justify-between transition-all duration-300 hover:border-[#D4642C]/40">
                <div className="flex items-center justify-between mb-3">
                  <span className="text-xs font-bold text-neutral-500">01</span>
                  <div className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-[#D4642C]/10 border border-[#D4642C]/30 text-[10px] font-semibold text-[#F18F58]">
                    <span className="w-1.5 h-1.5 rounded-full bg-[#D4642C]" />
                    LIVE UPDATES
                  </div>
                </div>

                <div>
                  <h4 className="text-xl font-bold text-white flex items-center gap-2">
                    <QrCode className="w-5 h-5 text-[#D4642C]" />
                    Dynamic QR
                  </h4>
                  <p className="mt-1.5 text-xs text-neutral-400 leading-relaxed">
                    Real-time updates ensure every shared profile stays current across all devices instantly.
                  </p>
                </div>

                {/* Global Scan Arcs with CONTINUOUS MOVING DOT (Left to Right to Left ping-pong) */}
                <div className="mt-4 p-3 rounded-2xl bg-black/40 border border-white/5 relative h-24 flex items-center justify-between px-4 overflow-hidden">
                  <div className="absolute inset-0 flex items-center justify-center opacity-20">
                    <Globe className="w-36 h-36 text-white" />
                  </div>
                  
                  {/* Location 1: London */}
                  <div className="relative z-10 flex flex-col items-center">
                    <div className="w-2.5 h-2.5 rounded-full bg-[#D4642C] shadow-[0_0_8px_#D4642C]" />
                    <span className="text-[10px] text-neutral-300 mt-1 font-semibold">London</span>
                  </div>

                  {/* SVG Dotted Curve with Smooth Traveling Dot */}
                  <div className="flex-1 h-12 relative px-2">
                    <svg className="w-full h-full overflow-visible" viewBox="0 0 100 30">
                      {/* Dotted Arch Path */}
                      <path
                        id="flightArc"
                        d="M 5,25 Q 50,2 95,25"
                        fill="none"
                        stroke="#D4642C"
                        strokeWidth="2"
                        strokeDasharray="3 3"
                        opacity="0.7"
                      />

                      {/* Moving Glowing Dot (Ping-Pong Loop: Left -> Right -> Left) */}
                      <circle r="4" fill="#FFA370" className="shadow-lg">
                        <animateMotion
                          path="M 5,25 Q 50,2 95,25"
                          dur="3s"
                          repeatCount="indefinite"
                          keyPoints="0;1;0"
                          keyTimes="0;0.5;1"
                          calcMode="spline"
                          keySplines="0.45 0 0.55 1; 0.45 0 0.55 1"
                        />
                      </circle>
                      
                      {/* Soft Halo around Moving Dot */}
                      <circle r="8" fill="#D4642C" opacity="0.35">
                        <animateMotion
                          path="M 5,25 Q 50,2 95,25"
                          dur="3s"
                          repeatCount="indefinite"
                          keyPoints="0;1;0"
                          keyTimes="0;0.5;1"
                          calcMode="spline"
                          keySplines="0.45 0 0.55 1; 0.45 0 0.55 1"
                        />
                      </circle>
                    </svg>
                  </div>

                  {/* Location 2: Tokyo */}
                  <div className="relative z-10 flex flex-col items-center">
                    <div className="w-2.5 h-2.5 rounded-full bg-[#FFA370] shadow-[0_0_8px_#FFA370]" />
                    <span className="text-[10px] text-neutral-300 mt-1 font-semibold">Tokyo</span>
                  </div>
                </div>
              </div>

              {/* CARD 5: AI CARD SCANNER (Animated Laser Viewfinder & OCR Extraction) */}
              <div className="relative group rounded-3xl p-6 bg-gradient-to-b from-[#1C1816] to-[#141110] border border-white/10 shadow-xl overflow-hidden flex flex-col justify-between transition-all duration-300 hover:border-[#D4642C]/40">
                <div className="flex items-center justify-between mb-3">
                  <span className="text-xs font-bold text-neutral-500">05</span>
                  <div className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-[#D4642C]/10 border border-[#D4642C]/30 text-[10px] font-semibold text-[#F18F58]">
                    <span className="w-1.5 h-1.5 rounded-full bg-[#D4642C] animate-pulse" />
                    AI SCANNER
                  </div>
                </div>

                <div>
                  <h4 className="text-xl font-bold text-white flex items-center gap-2">
                    <ScanLine className="w-5 h-5 text-[#D4642C]" />
                    AI Card Scanner
                  </h4>
                  <p className="mt-1.5 text-xs text-neutral-400 leading-relaxed">
                    Instantly turn physical paper business cards into verified digital contacts with 99.8% OCR accuracy.
                  </p>
                </div>

                {/* Animated Scanner Viewfinder Box */}
                <div className="mt-4 p-2.5 rounded-2xl bg-black/60 border border-white/5 relative overflow-hidden">
                  {/* Scanning Laser Beam (Moves smoothly down and up) */}
                  <div className="absolute inset-x-0 h-[2px] bg-gradient-to-r from-transparent via-[#D4642C] to-transparent shadow-[0_0_12px_#D4642C] z-20 pointer-events-none animate-scan-beam" />
                  
                  {/* Viewfinder Reticle Corners */}
                  <div className="absolute top-1.5 left-1.5 w-3 h-3 border-t-2 border-l-2 border-[#D4642C] pointer-events-none z-20" />
                  <div className="absolute top-1.5 right-1.5 w-3 h-3 border-t-2 border-r-2 border-[#D4642C] pointer-events-none z-20" />
                  <div className="absolute bottom-1.5 left-1.5 w-3 h-3 border-b-2 border-l-2 border-[#D4642C] pointer-events-none z-20" />
                  <div className="absolute bottom-1.5 right-1.5 w-3 h-3 border-b-2 border-r-2 border-[#D4642C] pointer-events-none z-20" />

                  {/* Scanned Card Preview Mockup */}
                  <div className="p-3.5 rounded-xl bg-gradient-to-b from-[#241F1C] to-[#1A1614] border border-[#D4642C]/25 relative z-10 space-y-3 shadow-lg">
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-2.5">
                        <div className="w-8 h-8 rounded-full bg-gradient-to-br from-[#D4642C] via-[#E2763E] to-[#F18F58] text-white flex items-center justify-center text-xs font-bold shadow-md shadow-[#D4642C]/20 ring-1 ring-white/20">
                          AR
                        </div>
                        <div>
                          <div className="text-xs font-bold text-white tracking-tight flex items-center gap-1.5">
                            <span>Alex Rivers</span>
                            <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 shadow-[0_0_6px_#34D399]" />
                          </div>
                          <div className="text-[11px] text-neutral-400 font-medium">Founder &amp; CEO</div>
                        </div>
                      </div>
                      <span className="px-2 py-0.5 rounded-full text-[10px] font-semibold tracking-wide bg-emerald-500/15 text-emerald-400 border border-emerald-500/30 flex items-center gap-1">
                        <span className="w-1 h-1 rounded-full bg-emerald-400" />
                        99.8% OCR
                      </span>
                    </div>

                    {/* Detected Data Fields */}
                    <div className="grid grid-cols-2 gap-2 pt-0.5">
                      <div className="px-2.5 py-1.5 rounded-lg bg-black/50 text-neutral-200 border border-white/5 flex items-center gap-2">
                        <Phone className="w-3.5 h-3.5 text-[#D4642C] shrink-0" />
                        <span className="text-[11px] font-medium tracking-tight truncate">+1 (555) 0192</span>
                      </div>
                      <div className="px-2.5 py-1.5 rounded-lg bg-black/50 text-neutral-200 border border-white/5 flex items-center gap-2">
                        <Mail className="w-3.5 h-3.5 text-[#D4642C] shrink-0" />
                        <span className="text-[11px] font-medium tracking-tight truncate">alex@corp.io</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

            </div>

            {/* ================= CARD 6: SECURE (Animated Vault Activity - Image 5) ================= */}
            <div className="lg:col-span-4 relative group rounded-3xl p-6 sm:p-8 bg-gradient-to-b from-[#1C1816] to-[#141110] border border-white/10 shadow-[0_20px_50px_rgba(0,0,0,0.5)] overflow-hidden flex flex-col justify-between transition-all duration-300 hover:border-[#D4642C]/40">
              <div>
                <div className="flex items-center justify-between mb-4">
                  <span className="text-xs font-bold text-neutral-500 tracking-wider">03</span>
                  <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#D4642C]/10 border border-[#D4642C]/30 text-[11px] font-semibold text-[#F18F58]">
                    <span className="w-1.5 h-1.5 rounded-full bg-[#D4642C]" />
                    ENCRYPTED
                  </div>
                </div>

                <h3 className="text-2xl font-bold text-white tracking-tight flex items-center gap-2.5">
                  <ShieldCheck className="w-6 h-6 text-[#D4642C]" />
                  Secure
                </h3>
                <p className="mt-2 text-sm text-neutral-400 leading-relaxed">
                  Bank-level encryption protecting your entire digital identity and contact vault.
                </p>
              </div>

              {/* Animated Vault Activity with Sweeping Shimmer Light Beams */}
              <div className="mt-6 p-4 rounded-2xl bg-black/40 border border-white/5 backdrop-blur-sm space-y-3.5">
                <div className="text-xs font-semibold text-neutral-400 flex items-center justify-between">
                  <span>Vault Activity</span>
                  <span className="text-[10px] text-emerald-400 font-mono flex items-center gap-1">
                    <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-ping" />
                    AES-256 LIVE
                  </span>
                </div>

                {/* User 1: Liam Smith with continuous sweeping scanner shimmer */}
                <div className="space-y-1">
                  <div className="flex justify-between text-[11px] text-neutral-300">
                    <span>Liam Smith</span>
                    <span className="text-[#F18F58] font-mono">100% Secure</span>
                  </div>
                  <div className="h-2 w-full bg-neutral-800 rounded-full overflow-hidden relative">
                    <div className="h-full bg-gradient-to-r from-[#D4642C] to-[#FFA370] w-full" />
                    {/* Sweeping Shimmer Scanner Light */}
                    <div className="absolute inset-0 w-1/3 bg-gradient-to-r from-transparent via-white/50 to-transparent animate-shimmer-sweep" />
                  </div>
                </div>

                {/* User 2: Emma Williams with live scanner beam */}
                <div className="space-y-1">
                  <div className="flex justify-between text-[11px] text-neutral-300">
                    <span>Emma Williams</span>
                    <span className="text-neutral-400 font-mono">Protected</span>
                  </div>
                  <div className="h-2 w-full bg-neutral-800 rounded-full overflow-hidden relative">
                    <div className="h-full bg-neutral-600 w-3/4" />
                    {/* Sweeping Shimmer Scanner Light */}
                    <div className="absolute inset-0 w-1/3 bg-gradient-to-r from-transparent via-white/40 to-transparent animate-shimmer-sweep" style={{ animationDelay: '1.2s' }} />
                  </div>
                </div>

                {/* Security Audit Records */}
                <div className="pt-2 border-t border-white/5 space-y-1.5">
                  <div className="flex items-center justify-between text-[10px] text-neutral-400">
                    <div className="flex items-center gap-1.5">
                      <Lock className="w-3.5 h-3.5 text-[#D4642C]" />
                      <span>Anna Peterson</span>
                    </div>
                    <span className="text-emerald-400 font-semibold flex items-center gap-1">
                      <CheckCircle2 className="w-3 h-3 text-emerald-400" />
                      Verified
                    </span>
                  </div>
                </div>
              </div>

              <div className="mt-6 flex items-center justify-between">
                <div className="flex items-center gap-2 text-xs text-neutral-400">
                  <CheckCircle2 className="w-4 h-4 text-emerald-500" />
                  <span>SOC 2 Type II Certified</span>
                </div>
              </div>
            </div>

          </div>
        </div>

      </div>
    </section>
  );
}
