"use client";

import React from "react";
import Link from "next/link";
import { ArrowUpRight, ArrowRight, Clock, Calendar, Wifi, Scan, BarChart3, CheckCircle2, TrendingUp, Sparkles } from "lucide-react";

interface BlogPost {
  id: string;
  category: string;
  readTime: string;
  date: string;
  title: string;
  excerpt: string;
  author: {
    name: string;
    role: string;
    initials: string;
  };
  visualType: "card" | "scanner" | "analytics";
}

const BLOG_POSTS: BlogPost[] = [
  {
    id: "death-of-paper-cards",
    category: "Digital Identity",
    readTime: "4 min read",
    date: "Nov 24, 2026",
    title: "The Death of Paper Cards: Why Modern Teams Are Going 100% Digital",
    excerpt:
      "Paper business cards are static, costly, and easily lost. Discover how dynamic NFC chips and Apple Wallet passes keep contact details updated in real time.",
    author: {
      name: "Elena Rostova",
      role: "Head of Product",
      initials: "ER",
    },
    visualType: "card",
  },
  {
    id: "ai-card-scanner-advancements",
    category: "AI Technology",
    readTime: "5 min read",
    date: "Nov 19, 2026",
    title: "AI Card Scanner 2.0: Turn Loose Paper into Verified CRM Leads in 3s",
    excerpt:
      "How on-device neural computer vision extracts names, numbers, and job titles across 30+ languages with 99.8% accuracy and zero manual data entry.",
    author: {
      name: "Marcus Vance",
      role: "AI Architect",
      initials: "MV",
    },
    visualType: "scanner",
  },
  {
    id: "enterprise-digital-cards-scale",
    category: "Enterprise Guide",
    readTime: "6 min read",
    date: "Nov 12, 2026",
    title: "Enterprise Playbook: Deploying Branded Cards Across 5,000+ Employees",
    excerpt:
      "A complete blueprint for HR and marketing leaders: centralized admin controls, automated SSO directory sync, and compliance approval workflows.",
    author: {
      name: "Sarah Lin",
      role: "VP of Enterprise",
      initials: "SL",
    },
    visualType: "analytics",
  },
];

/* ------------------------------------------------------------------ */
/*  Card Cover Artwork (Clean, Modern, Branded Visuals)                */
/* ------------------------------------------------------------------ */

// Cover 1: Digital NFC Card Mockup
const CardCoverArt: React.FC = () => (
  <div className="relative w-full h-full bg-gradient-to-br from-[#FAF3EC] via-[#F6E6DA] to-[#EFD8C9] p-5 flex items-center justify-center overflow-hidden">
    {/* Concentric Decorative Rings */}
    <div className="absolute w-64 h-64 rounded-full border border-[#D4642C]/15 pointer-events-none" />
    <div className="absolute w-44 h-44 rounded-full border border-[#D4642C]/20 pointer-events-none" />

    {/* Floating Mini Digital Card */}
    <div className="relative w-48 h-28 bg-[#181513] rounded-xl p-3 border border-white/10 shadow-[0_12px_28px_rgba(0,0,0,0.18)] flex flex-col justify-between group-hover:scale-105 group-hover:-rotate-1 transition-transform duration-500">
      <div className="flex items-center justify-between">
        <span className="text-[9px] font-mono font-bold tracking-widest text-[#FFA370]">NFC SMART CARD</span>
        <Wifi className="w-3.5 h-3.5 rotate-90 text-[#FFA370]" />
      </div>
      <div className="flex items-center gap-2">
        <div className="w-7 h-7 rounded-md bg-[#D4642C] flex items-center justify-center text-white text-[10px] font-bold">
          AR
        </div>
        <div>
          <div className="text-[11px] font-bold text-white leading-tight">Alex Rivers</div>
          <div className="text-[9px] text-white/60">Product Director</div>
        </div>
      </div>
      <div className="flex items-center justify-between text-[8px] font-mono text-white/40 pt-1 border-t border-white/10">
        <span>mycard.id/alex</span>
        <span className="text-emerald-400">● LIVE</span>
      </div>
    </div>
  </div>
);

// Cover 2: AI Card Scanner Reticle
const ScannerCoverArt: React.FC = () => (
  <div className="relative w-full h-full bg-gradient-to-br from-[#FDF5F0] via-[#F7ECE4] to-[#EEDBD0] p-5 flex items-center justify-center overflow-hidden">
    {/* Grid Backdrop */}
    <div className="absolute inset-0 bg-[radial-gradient(#D4642C_1px,transparent_1px)] [background-size:14px_14px] opacity-20 pointer-events-none" />

    {/* Simulated Scanner Viewfinder Card */}
    <div className="relative w-48 h-28 bg-white/90 backdrop-blur-xs rounded-xl p-3 border-2 border-dashed border-[#D4642C]/50 shadow-[0_12px_28px_rgba(212,100,44,0.12)] flex flex-col justify-between group-hover:scale-105 group-hover:rotate-1 transition-transform duration-500">
      {/* Corner Brackets */}
      <div className="absolute -top-1 -left-1 w-2.5 h-2.5 border-t-2 border-l-2 border-[#D4642C]" />
      <div className="absolute -top-1 -right-1 w-2.5 h-2.5 border-t-2 border-r-2 border-[#D4642C]" />
      <div className="absolute -bottom-1 -left-1 w-2.5 h-2.5 border-b-2 border-l-2 border-[#D4642C]" />
      <div className="absolute -bottom-1 -right-1 w-2.5 h-2.5 border-b-2 border-r-2 border-[#D4642C]" />

      <div className="flex items-center justify-between">
        <div className="flex items-center gap-1 text-[9px] font-mono font-bold text-[#D4642C]">
          <Scan className="w-3 h-3" />
          <span>AI OCR SCAN</span>
        </div>
        <span className="text-[8px] font-mono px-1.5 py-0.5 rounded bg-emerald-100 text-emerald-800 font-bold">
          99.8%
        </span>
      </div>

      {/* Laser Line */}
      <div className="w-full h-0.5 bg-gradient-to-r from-transparent via-[#D4642C] to-transparent shadow-[0_0_6px_#D4642C]" />

      <div className="space-y-0.5 text-[9px] font-mono text-[#2A1E17]">
        <div className="flex justify-between">
          <span className="text-[#7A6A5F]">NAME:</span>
          <span className="font-bold">Sophia Martinez</span>
        </div>
        <div className="flex justify-between">
          <span className="text-[#7A6A5F]">SYNC:</span>
          <span className="text-emerald-600 font-bold">Auto CRM ✓</span>
        </div>
      </div>
    </div>
  </div>
);

// Cover 3: Enterprise Analytics Graph
const AnalyticsCoverArt: React.FC = () => (
  <div className="relative w-full h-full bg-gradient-to-br from-[#FAF5F0] via-[#F4E9DF] to-[#E9D7C9] p-5 flex items-center justify-center overflow-hidden">
    {/* Floating Dashboard Card */}
    <div className="relative w-48 h-28 bg-[#181513] rounded-xl p-3 border border-white/10 shadow-[0_12px_28px_rgba(0,0,0,0.18)] flex flex-col justify-between group-hover:scale-105 group-hover:-rotate-1 transition-transform duration-500">
      <div className="flex items-center justify-between">
        <span className="text-[9px] font-mono font-bold text-[#FFA370]">FLEET ANALYTICS</span>
        <div className="flex items-center gap-0.5 text-[9px] font-bold text-emerald-400">
          <TrendingUp className="w-2.5 h-2.5" />
          <span>+142%</span>
        </div>
      </div>

      {/* Mini Spline Graph */}
      <div className="my-auto">
        <div className="text-sm font-bold font-['Space_Grotesk'] text-white">48,290 Views</div>
        <svg className="w-full h-8 overflow-visible mt-1" viewBox="0 0 100 24">
          <path
            d="M0 20 Q 20 18, 40 10 T 70 8 T 100 2"
            fill="none"
            stroke="#D4642C"
            strokeWidth="2.5"
            strokeLinecap="round"
          />
          <circle cx="100" cy="2" r="3" fill="#FFA370" />
        </svg>
      </div>

      <div className="flex items-center justify-between text-[8px] font-mono text-white/50 pt-1 border-t border-white/10">
        <span>450 Team Cards</span>
        <span className="text-emerald-400">100% Synced</span>
      </div>
    </div>
  </div>
);

/* ------------------------------------------------------------------ */
/*  Main Blog Section Component                                        */
/* ------------------------------------------------------------------ */

export default function BlogSection() {
  return (
    <section className="relative w-full bg-[#FAF6F2] pt-10 sm:pt-12 lg:pt-14 pb-8 sm:pb-10 lg:pb-12 overflow-hidden border-t border-[#EFE6DD]">
      {/* Background Ambient Accents */}
      <div className="absolute top-1/3 -left-48 w-96 h-96 rounded-full bg-[#F6E3D8]/60 blur-[130px] pointer-events-none" />
      <div className="absolute bottom-12 -right-48 w-96 h-96 rounded-full bg-[#D4642C]/5 blur-[120px] pointer-events-none" />

      <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        {/* ================= SECTION HEADER ================= */}
        <div className="flex flex-col sm:flex-row sm:items-end justify-between mb-8 sm:mb-10 gap-6">
          <div className="max-w-2xl">
            {/* Top Pill Badge */}
            <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full text-xs font-semibold uppercase tracking-wider bg-[#F6E3D8] text-[#B85222] border border-[#D4642C]/20 mb-3.5">
              <span className="w-1.5 h-1.5 rounded-full bg-[#D4642C] animate-pulse" />
              <span>LATEST FROM OUR BLOG</span>
            </div>

            {/* Display Headline */}
            <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold font-['Space_Grotesk'] text-[#2A1E17] tracking-tight leading-[1.14]">
              Insights for <span className="text-[#D4642C]">Modern Networking</span>
            </h2>

            {/* Subtitle */}
            <p className="mt-3.5 text-base sm:text-lg text-[#7A6A5F] font-normal leading-relaxed">
              Actionable guides, technology breakdowns, and proven strategies for digital business cards and enterprise connection.
            </p>
          </div>

          {/* Right Action Button */}
          <Link
            href="#blog"
            className="group inline-flex items-center gap-2 px-5 py-2.5 rounded-full bg-white text-sm font-semibold text-[#2A1E17] border border-[#EFE6DD] shadow-[0_4px_14px_rgba(110,60,30,0.06)] hover:border-[#D4642C]/40 hover:text-[#D4642C] transition-all duration-300 shrink-0"
          >
            <span>Explore all articles</span>
            <ArrowRight className="w-4 h-4 text-[#D4642C] transition-transform duration-300 group-hover:translate-x-1" />
          </Link>
        </div>

        {/* ================= 3 DISTINCT BLOG BOXES (GRID) ================= */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-7 lg:gap-8">
          {BLOG_POSTS.map((post) => (
            <article
              key={post.id}
              className="group relative bg-white rounded-[26px] sm:rounded-[30px] border border-[#EBE3D8] shadow-[0_6px_26px_rgba(110,60,30,0.05)] hover:shadow-[0_24px_50px_rgba(212,100,44,0.14)] hover:border-[#D4642C]/40 transition-all duration-300 flex flex-col overflow-hidden hover:-translate-y-2 cursor-pointer"
            >
              {/* Box Cover Header */}
              <div className="relative w-full aspect-[16/10] overflow-hidden border-b border-[#EFE8DF]">
                {post.visualType === "card" && <CardCoverArt />}
                {post.visualType === "scanner" && <ScannerCoverArt />}
                {post.visualType === "analytics" && <AnalyticsCoverArt />}

                {/* Floating Category Tag */}
                <div className="absolute top-4 left-4 z-10">
                  <span className="inline-block px-3 py-1 rounded-full text-[11px] font-bold uppercase tracking-wider bg-white/95 backdrop-blur-md text-[#D4642C] shadow-sm border border-white/60">
                    {post.category}
                  </span>
                </div>

                {/* Floating Reading Time Badge */}
                <div className="absolute top-4 right-4 z-10">
                  <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-medium bg-[#181513]/80 backdrop-blur-md text-white">
                    <Clock className="w-3 h-3 text-[#FFA370]" />
                    <span>{post.readTime}</span>
                  </span>
                </div>
              </div>

              {/* Box Content Body */}
              <div className="p-6 sm:p-7 flex-1 flex flex-col justify-between">
                <div>
                  {/* Publication Date */}
                  <div className="flex items-center gap-2 text-xs font-medium text-[#7A6A5F] mb-2.5">
                    <Calendar className="w-3.5 h-3.5 text-[#D4642C]" />
                    <span>{post.date}</span>
                    <span className="w-1 h-1 rounded-full bg-[#EFE6DD]" />
                    <span className="text-[#B85222] font-semibold">Featured Guide</span>
                  </div>

                  {/* Headline Title */}
                  <h3 className="text-xl sm:text-[22px] font-bold font-['Space_Grotesk'] text-[#2A1E17] group-hover:text-[#D4642C] transition-colors duration-200 leading-snug line-clamp-2">
                    {post.title}
                  </h3>

                  {/* Excerpt Summary */}
                  <p className="mt-3 text-sm text-[#7A6A5F] leading-relaxed line-clamp-3">
                    {post.excerpt}
                  </p>
                </div>

                {/* Bottom Box Footer (Author + Arrow Action) */}
                <div className="pt-5 mt-6 border-t border-[#EFE8DF] flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="w-9 h-9 rounded-full bg-[#F6E3D8] text-[#D4642C] font-bold text-xs flex items-center justify-center border border-[#D4642C]/25 shadow-xs">
                      {post.author.initials}
                    </div>
                    <div className="flex flex-col">
                      <span className="text-xs font-semibold text-[#2A1E17] leading-tight">
                        {post.author.name}
                      </span>
                      <span className="text-[11px] text-[#7A6A5F]">
                        {post.author.role}
                      </span>
                    </div>
                  </div>

                  {/* Circular Hover Button */}
                  <div className="w-9 h-9 rounded-full bg-[#FAF6F2] group-hover:bg-[#D4642C] text-[#2A1E17] group-hover:text-white flex items-center justify-center transition-all duration-300 shadow-xs group-hover:scale-105 border border-[#EFE8DF] group-hover:border-[#D4642C]">
                    <ArrowUpRight className="w-4 h-4 transition-transform duration-300 group-hover:translate-x-0.5 group-hover:-translate-y-0.5" />
                  </div>
                </div>
              </div>
            </article>
          ))}
        </div>

      </div>
    </section>
  );
}
