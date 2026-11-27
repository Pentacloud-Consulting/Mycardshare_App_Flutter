"use client";

import React, { useState, useEffect } from "react";
import { ArrowUpRight } from "lucide-react";

type TabKey = "overview" | "leads" | "campaigns";

interface StatItem {
  label: string;
  value: string;
  growth: string;
}

interface BarData {
  day: string;
  height: number; // percentage of chart height (solid full bar)
  views: number;
  leads: number;
}

const TAB_STATS: Record<TabKey, StatItem[]> = {
  overview: [
    { label: "TOTAL VISITORS", value: "12,847", growth: "+24% vs last mo." },
    { label: "QR SCANS", value: "3,214", growth: "+18% vs last mo." },
    { label: "LEADS CAPTURED", value: "641", growth: "+31% vs last mo." },
    { label: "CONV. RATE", value: "4.99%", growth: "+0.8% vs last mo." },
  ],
  leads: [
    { label: "TOTAL LEADS", value: "1,894", growth: "+36% vs last mo." },
    { label: "QUALIFIED LEADS", value: "742", growth: "+28% vs last mo." },
    { label: "SYNCED TO CRM", value: "618", growth: "+41% vs last mo." },
    { label: "RESPONSE RATE", value: "64.2%", growth: "+4.1% vs last mo." },
  ],
  campaigns: [
    { label: "ACTIVE CARDS", value: "348", growth: "+16% vs last mo." },
    { label: "TOP REGION", value: "North America", growth: "+52% share" },
    { label: "EVENT SCANS", value: "5,410", growth: "+63% vs last mo." },
    { label: "AVG. DWELL TIME", value: "2m 18s", growth: "+12% vs last mo." },
  ],
};

// 12 solid full bars (matching Image 2 heights without bottle split)
const BARS_DATA: BarData[] = [
  { day: "01", height: 50, views: 820, leads: 48 },
  { day: "02", height: 62, views: 980, leads: 62 },
  { day: "03", height: 48, views: 760, leads: 38 },
  { day: "04", height: 72, views: 1140, leads: 74 },
  { day: "05", height: 88, views: 1420, leads: 96 },
  { day: "06", height: 58, views: 910, leads: 52 },
  { day: "07", height: 46, views: 710, leads: 34 },
  { day: "08", height: 56, views: 880, leads: 56 },
  { day: "09", height: 70, views: 1180, leads: 82 },
  { day: "10", height: 84, views: 1360, leads: 92 },
  { day: "11", height: 64, views: 990, leads: 64 },
  { day: "12", height: 78, views: 1480, leads: 104 },
];

interface TrafficSourceItem {
  name: string;
  color: string;
  dotColor: string;
  // Sequence: Drained -> Fill Completely (100%) -> Settle to Target -> Decrease
  phases: number[];
}

const TRAFFIC_SOURCES: TrafficSourceItem[] = [
  { name: "QR Scan", color: "#D4642C", dotColor: "#D4642C", phases: [12, 100, 72, 38] },
  { name: "Direct Link", color: "#0EA5E9", dotColor: "#0EA5E9", phases: [8, 100, 48, 24] },
  { name: "Email Share", color: "#10B981", dotColor: "#10B981", phases: [6, 100, 35, 18] },
  { name: "WhatsApp", color: "#F59E0B", dotColor: "#F59E0B", phases: [4, 100, 22, 12] },
];

export default function AnalyticsDashboard() {
  const [activeTab, setActiveTab] = useState<TabKey>("overview");
  const [hoveredBarIndex, setHoveredBarIndex] = useState<number | null>(null);

  // Auto filling completely (100%) and auto decreasing animation loop
  const [trafficPhase, setTrafficPhase] = useState<number>(0);

  useEffect(() => {
    const timer = setInterval(() => {
      setTrafficPhase((prev) => (prev + 1) % 4);
    }, 2400);
    return () => clearInterval(timer);
  }, []);

  const stats = TAB_STATS[activeTab];

  return (
    <section className="relative w-full z-10">
      
      {/* Dynamic Keyframes for smooth wave motion on bars */}
      <style>{`
        @keyframes barUndulateSlow {
          0%, 100% {
            transform: scaleY(0.93);
          }
          50% {
            transform: scaleY(1.07);
          }
        }
      `}</style>

      {/* ================= SPLIT BACKGROUND (DARK ON TOP, LIGHT ON BOTTOM) ================= */}
      {/* 
        Top half is Dark Theme (#0D0B0A) with curved top corners matching the video section.
        Bottom half is Light Theme (#FAF6F2 Warm Cream) starting at the midpoint of the dashboard window container.
      */}
      <div className="absolute inset-0 pointer-events-none flex flex-col">
        {/* Top Dark Background: covers Header + top ~52% of Dashboard Window */}
        <div className="relative w-full flex-1 bg-[#0D0B0A] text-white rounded-t-[36px] sm:rounded-t-[48px] lg:rounded-t-[64px] border-t border-white/15 shadow-[0_-25px_60px_rgba(0,0,0,0.6)] overflow-hidden">
          {/* Top Ambient Glow Accent in Theme Matte Orange */}
          <div className="absolute top-0 left-1/2 -translate-x-1/2 w-3/4 max-w-2xl h-[2px] bg-gradient-to-r from-transparent via-[#D4642C]/70 to-transparent" />

          {/* Smooth Ambient Glows */}
          <div className="absolute top-1/4 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[700px] h-[450px] bg-[#D4642C]/16 rounded-full blur-[140px]" />
          <div className="absolute top-10 right-10 w-[450px] h-[350px] bg-[#D4642C]/10 rounded-full blur-[120px]" />
        </div>

        {/* Bottom Light Theme Background: starts at midpoint of dashboard and flows down */}
        <div className="w-full h-[180px] sm:h-[240px] lg:h-[280px] bg-[#FAF6F2] relative border-b border-[#EFE6DD]">
          {/* Subtle Warm Tone Reflection on the Light Surface */}
          <div className="absolute top-0 left-1/2 -translate-x-1/2 w-3/4 max-w-3xl h-[120px] bg-[#D4642C]/5 rounded-full blur-[80px]" />
        </div>
      </div>

      {/* ================= FOREGROUND CONTENT ================= */}
      <div className="relative max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 pt-12 sm:pt-16 lg:pt-20 pb-8 sm:pb-10 lg:pb-12 z-10">
        
        {/* ================= SECTION HEADER ================= */}
        <div className="text-center max-w-2xl mx-auto mb-8 sm:mb-10">
          {/* Main Title */}
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold font-['Space_Grotesk'] text-white tracking-tight leading-[1.15]">
            A dashboard that <br className="hidden sm:inline" />
            tells the full story.
          </h2>

          {/* Subtitle */}
          <p className="mt-4 text-base sm:text-lg text-[#A08F83] font-normal leading-relaxed">
            Not just vanity metrics. Real intelligence — who viewed, who scanned, and which channel converts.
          </p>
        </div>

        {/* ================= MAIN DASHBOARD WINDOW CONTAINER (DARK MODERN THEME) ================= */}
        <div className="relative bg-[#161210]/95 backdrop-blur-md rounded-[28px] sm:rounded-[36px] lg:rounded-[40px] border border-white/12 shadow-[0_30px_90px_rgba(0,0,0,0.8),0_0_40px_rgba(212,100,44,0.08)] p-5 sm:p-7 lg:p-8">
          
          {/* Top Window Bar (3 Dots + Tab Switcher) */}
          <div className="flex items-center justify-between pb-6 border-b border-white/10 mb-6">
            {/* 3 Mac Style Window Dots */}
            <div className="flex items-center gap-2">
              <span className="w-3 h-3 rounded-full bg-[#FF5F56] shadow-xs" />
              <span className="w-3 h-3 rounded-full bg-[#FFBD2E] shadow-xs" />
              <span className="w-3 h-3 rounded-full bg-[#27C93F] shadow-xs" />
            </div>

            {/* Right Tabs */}
            <div className="flex items-center gap-1.5 sm:gap-2">
              {(["overview", "leads", "campaigns"] as TabKey[]).map((tab) => {
                const isActive = activeTab === tab;
                const label = tab.charAt(0).toUpperCase() + tab.slice(1);
                return (
                  <button
                    key={tab}
                    type="button"
                    onClick={() => setActiveTab(tab)}
                    className={`text-xs sm:text-sm font-semibold px-4 sm:px-5 py-2 rounded-full transition-all duration-200 cursor-pointer ${
                      isActive
                        ? "bg-[#D4642C] text-white shadow-sm"
                        : "text-neutral-400 hover:text-white hover:bg-white/5"
                    }`}
                  >
                    {label}
                  </button>
                );
              })}
            </div>
          </div>

          {/* ================= 4 STAT METRIC CARDS (DARK THEME) ================= */}
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-3.5 sm:gap-4 lg:gap-5 mb-6">
            {stats.map((stat, idx) => (
              <div
                key={idx}
                className="bg-[#1E1916] rounded-[20px] p-4 sm:p-5 border border-white/10 hover:border-[#D4642C]/40 hover:bg-[#251F1B] transition-all duration-300 group overflow-hidden"
              >
                <div className="text-[11px] sm:text-xs font-semibold tracking-wider text-[#A08F83] uppercase font-['Space_Grotesk'] truncate">
                  {stat.label}
                </div>
                <div
                  className={`font-bold text-white font-['Space_Grotesk'] tracking-tight mt-1 group-hover:text-[#FFA370] transition-colors whitespace-nowrap truncate leading-tight ${
                    stat.value.length > 9
                      ? "text-lg sm:text-xl lg:text-[23px]"
                      : stat.value.length > 6
                      ? "text-xl sm:text-2xl lg:text-[27px]"
                      : "text-2xl sm:text-3xl lg:text-[32px]"
                  }`}
                  title={stat.value}
                >
                  {stat.value}
                </div>
                <div className="text-xs font-semibold text-emerald-400 flex items-center gap-1 mt-1.5 whitespace-nowrap">
                  <span>↑</span>
                  <span>{stat.growth}</span>
                </div>
              </div>
            ))}
          </div>

          {/* ================= LOWER SPLIT PANELS (DARK THEME) ================= */}
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-5 sm:gap-6">
            
            {/* LEFT PANEL: Solid Full Daily Bar Chart (Dark Theme) */}
            <div className="lg:col-span-8 bg-[#1E1916] rounded-[24px] p-5 sm:p-6 border border-white/10 flex flex-col justify-between">
              
              {/* Header with Title & Legend */}
              <div className="flex flex-wrap items-center justify-between gap-3 mb-6">
                <span className="text-xs font-bold tracking-wider text-[#A08F83] uppercase font-['Space_Grotesk']">
                  VIEWS &amp; LEADS — DAILY
                </span>

                {/* Legend */}
                <div className="flex items-center gap-4 text-xs font-medium text-neutral-300">
                  <div className="flex items-center gap-1.5">
                    <span className="w-2.5 h-2.5 rounded-sm bg-[#D4642C] shadow-[0_0_8px_rgba(212,100,44,0.6)]" />
                    <span>Daily Activity (Live)</span>
                  </div>
                </div>
              </div>

              {/* 12 Solid Full Bar Columns with Slow Undulation */}
              <div className="relative h-56 sm:h-64 flex items-end justify-between gap-1.5 sm:gap-2.5 pt-8 pb-3 px-1">
                
                {/* Horizontal Baseline Guideline */}
                <div className="absolute inset-x-0 bottom-3 h-px bg-white/10" />
                <div className="absolute inset-x-0 top-1/2 h-px border-b border-dashed border-white/10" />

                {BARS_DATA.map((bar, i) => {
                  const isHovered = hoveredBarIndex === i;

                  return (
                    <div
                      key={bar.day}
                      className="relative flex-1 h-full flex flex-col justify-end items-center group cursor-pointer z-10"
                      onMouseEnter={() => setHoveredBarIndex(i)}
                      onMouseLeave={() => setHoveredBarIndex(null)}
                    >
                      {/* Floating Tooltip on Hover */}
                      {isHovered && (
                        <div className="absolute -top-10 z-30 bg-white text-[#161210] text-[11px] font-bold py-1 px-2.5 rounded-md shadow-xl pointer-events-none whitespace-nowrap animate-in fade-in zoom-in-95 duration-150">
                          Day {bar.day}: <span className="text-[#D4642C]">{bar.views} views</span> • {bar.leads} leads
                        </div>
                      )}

                      {/* Solid Full Bar (Glows softly in dark theme) */}
                      <div
                        className="w-full max-w-[28px] sm:max-w-[34px] bg-gradient-to-t from-[#B85222] via-[#D4642C] to-[#FFA370] rounded-t-xl shadow-[0_0_14px_rgba(212,100,44,0.35)] group-hover:brightness-125 transition-all duration-300"
                        style={{
                          height: `${bar.height}%`,
                          animation: `barUndulateSlow 3.8s ease-in-out infinite`,
                          animationDelay: `${i * 0.22}s`,
                          transformOrigin: "bottom",
                        }}
                      />
                    </div>
                  );
                })}
              </div>

              {/* Days of Month Micro-Labels */}
              <div className="flex items-center justify-between text-[10px] text-[#A08F83] font-mono font-medium px-2 pt-2 border-t border-white/10">
                <span>01</span>
                <span>03</span>
                <span>05</span>
                <span>07</span>
                <span>09</span>
                <span>11</span>
                <span>12</span>
              </div>
            </div>

            {/* RIGHT PANEL: Traffic Sources Progress List (Dark Theme) */}
            <div className="lg:col-span-4 bg-[#1E1916] rounded-[24px] p-5 sm:p-6 border border-white/10 flex flex-col justify-between">
              
              <div>
                {/* Header */}
                <div className="flex items-center justify-between mb-6">
                  <div className="text-xs font-bold tracking-wider text-[#A08F83] uppercase font-['Space_Grotesk']">
                    TRAFFIC SOURCES
                  </div>
                  <span className="text-[10px] font-mono text-emerald-400 bg-emerald-500/10 px-2 py-0.5 rounded-full border border-emerald-500/25 animate-pulse font-semibold">
                    ● Live Telemetry
                  </span>
                </div>

                {/* 4 Traffic Channel Progress Rows (Fills Completely 100% and Decreases) */}
                <div className="space-y-5">
                  {TRAFFIC_SOURCES.map((source) => {
                    const currentPct = source.phases[trafficPhase % source.phases.length];
                    return (
                      <div key={source.name} className="space-y-1.5 group">
                        {/* Label + Dot + Live Percentage */}
                        <div className="flex items-center justify-between text-xs sm:text-[13px] font-medium text-white">
                          <div className="flex items-center gap-2">
                            <span
                              className="w-2 h-2 rounded-full shrink-0 group-hover:scale-125 transition-transform"
                              style={{ backgroundColor: source.dotColor }}
                            />
                            <span className="font-semibold text-white/95">{source.name}</span>
                          </div>
                          <span className="text-white font-mono font-bold transition-all duration-700">
                            {currentPct}%
                          </span>
                        </div>

                        {/* Progress Track: Smoothly fills completely to 100% and decreases */}
                        <div className="w-full h-2 bg-white/10 rounded-full overflow-hidden p-0.5">
                          <div
                            className="h-full rounded-full transition-all duration-1000 ease-in-out group-hover:brightness-125 shadow-xs"
                            style={{
                              width: `${currentPct}%`,
                              backgroundColor: source.color,
                            }}
                          />
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>

              {/* Bottom Quick Insight Pill */}
              <div className="mt-6 pt-4 border-t border-white/10 flex items-center justify-between text-xs text-neutral-400">
                <span>Highest converter:</span>
                <span className="font-semibold text-[#FFA370] flex items-center gap-1">
                  QR Physical Taps
                  <ArrowUpRight className="w-3.5 h-3.5" />
                </span>
              </div>

            </div>

          </div>

        </div>

      </div>
    </section>
  );
}
