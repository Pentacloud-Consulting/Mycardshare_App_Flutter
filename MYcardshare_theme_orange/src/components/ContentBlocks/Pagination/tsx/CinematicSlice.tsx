'use client';

import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ChevronRight, ChevronLeft, Wifi, QrCode, Sparkles, Shield, Leaf, Layers, Building2 } from 'lucide-react';
import { cn } from '@/lib/utils';

// ================= PRODUCT DEFINITIONS (BASED ON MYCARDSHARE) =================
interface ProductCardItem {
  id: string;
  number: string;
  collection: string;
  title: string;
  subtitle: string;
  badge: string;
  name: string;
  role: string;
  company: string;
  material: string;
  themeColor: string;
  accentColor: string;
  type: 'metal' | 'bamboo' | 'prism' | 'carbon' | 'fleet';
}

const PRODUCTS: ProductCardItem[] = [
  {
    id: "black-titanium",
    number: "001",
    collection: "METAL LUXE SERIES",
    title: "BLACK TITANIUM",
    subtitle: "Laser-engraved aerospace matte metal with ultra-fast NFC tap and dynamic verified QR.",
    badge: "FLAGSHIP HARDWARE",
    name: "ALEX RIVERS",
    role: "Chief Executive Officer",
    company: "MyCardShare Global",
    material: "Matte Black Titanium • 0.8mm",
    themeColor: "#D4642C",
    accentColor: "#FFA370",
    type: "metal",
  },
  {
    id: "eco-bamboo",
    number: "002",
    collection: "NATURE SERIES",
    title: "ECO BAMBOO",
    subtitle: "Sustainable hand-crafted hardwood embedded with a micro-NFC chip for zero-waste networking.",
    badge: "100% SUSTAINABLE",
    name: "ELENA ROSTOVA",
    role: "Head of Sustainability",
    company: "Terra Bio Ventures",
    material: "Natural Organic Hardwood",
    themeColor: "#C97A3E",
    accentColor: "#FBD38D",
    type: "bamboo",
  },
  {
    id: "frosted-prism",
    number: "003",
    collection: "DESIGNER SERIES",
    title: "FROSTED PRISM",
    subtitle: "Semi-translucent frosted glass finish with visible holographic NFC antenna array.",
    badge: "ULTRA-MINIMALIST",
    name: "MARCUS VANCE",
    role: "Lead Creative Architect",
    company: "Studio Delta",
    material: "Translucent Matte Acrylic",
    themeColor: "#E07A4B",
    accentColor: "#E2E8F0",
    type: "prism",
  },
  {
    id: "forged-carbon",
    number: "004",
    collection: "APEX EXECUTIVE",
    title: "FORGED CARBON",
    subtitle: "Aerospace composite carbon fiber engineered for executives who demand extreme durability.",
    badge: "EXECUTIVE TIER",
    name: "SOPHIA CHEN",
    role: "Managing Partner",
    company: "Apex Capital Partners",
    material: "Twill Carbon Fiber Matrix",
    themeColor: "#D4642C",
    accentColor: "#FFA370",
    type: "carbon",
  },
  {
    id: "enterprise-fleet",
    number: "005",
    collection: "TEAMS & ENTERPRISE",
    title: "ENTERPRISE FLEET",
    subtitle: "Centrally deployed corporate card packs with instant CRM sync and automatic team directory updates.",
    badge: "TEAM DEPLOYMENT",
    name: "SARAH & TEAM",
    role: "500+ Synced Profiles",
    company: "Global Enterprise Fleet",
    material: "Multi-Card Cloud Ecosystem",
    themeColor: "#E87A43",
    accentColor: "#FBD38D",
    type: "fleet",
  },
];

// ================= REALISTIC 3D MYCARDSHARE PHYSICAL CARD VISUAL =================
const MyCardShareCardGraphic: React.FC<{ product: ProductCardItem }> = ({ product }) => {
  return (
    <div className="absolute inset-0 w-full h-full overflow-hidden flex items-center justify-center select-none">
      
      {/* Studio Lighting Background */}
      <div className="absolute inset-0 bg-[#0E0B09]">
        {/* Ambient Warm Radial Backlight */}
        <div
          className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[700px] h-[400px] rounded-full blur-[130px] opacity-40 pointer-events-none"
          style={{ backgroundColor: product.themeColor }}
        />
        <div className="absolute inset-0 bg-[radial-gradient(#261D18_1px,transparent_1px)] [background-size:20px_20px] opacity-40" />
      </div>

      {/* Floating Angled Digital Business Card (Center-Right composition) */}
      <div className="relative z-10 w-full h-full flex items-center justify-center sm:justify-end sm:pr-14 md:pr-20 pb-16 sm:pb-0">
        
        {/* Glow Behind the Card */}
        <div
          className="absolute w-[360px] sm:w-[420px] h-[220px] sm:h-[260px] rounded-[28px] blur-[50px] opacity-35"
          style={{ backgroundColor: product.themeColor }}
        />

        {/* ═══════════ THE CARD ═══════════ */}
        <div
          className={cn(
            "relative w-[310px] sm:w-[380px] md:w-[420px] h-[190px] sm:h-[230px] md:h-[250px] rounded-[22px] sm:rounded-[26px] p-5 sm:p-6 sm:px-7 flex flex-col justify-between transition-transform duration-500 shadow-[0_30px_70px_rgba(0,0,0,0.8),0_0_30px_rgba(212,100,44,0.15)] border",
            product.type === "metal" && "bg-gradient-to-br from-[#1C1816] via-[#14100E] to-[#0A0706] border-[#D4642C]/40 text-white",
            product.type === "bamboo" && "bg-gradient-to-br from-[#A66E38] via-[#8C5828] to-[#593414] border-[#FBD38D]/40 text-[#FAF6F2]",
            product.type === "prism" && "bg-white/10 backdrop-blur-xl border-white/30 text-white shadow-[inset_0_1px_1px_rgba(255,255,255,0.4)]",
            product.type === "carbon" && "bg-gradient-to-br from-[#1A1A1A] via-[#121212] to-[#050505] border-[#D4642C]/40 text-white",
            product.type === "fleet" && "bg-gradient-to-br from-[#241711] via-[#190F0B] to-[#0C0604] border-[#FFA370]/30 text-white"
          )}
        >
          {/* Carbon weave overlay if carbon */}
          {product.type === "carbon" && (
            <div className="absolute inset-0 rounded-[22px] sm:rounded-[26px] opacity-25 bg-[radial-gradient(#404040_1px,transparent_1px)] [background-size:6px_6px] pointer-events-none" />
          )}

          {/* Bamboo wood grain overlay if bamboo */}
          {product.type === "bamboo" && (
            <div className="absolute inset-0 rounded-[22px] sm:rounded-[26px] opacity-15 bg-[repeating-linear-gradient(45deg,transparent,transparent_8px,rgba(0,0,0,0.15)_8px,rgba(0,0,0,0.15)_16px)] pointer-events-none" />
          )}

          {/* Frosted prism holographic sheen */}
          {product.type === "prism" && (
            <div className="absolute inset-0 rounded-[22px] sm:rounded-[26px] opacity-30 bg-gradient-to-tr from-[#D4642C]/20 via-sky-400/20 to-purple-500/20 pointer-events-none" />
          )}

          {/* Card Top Row: Brand & NFC Indicator */}
          <div className="relative z-10 flex items-center justify-between">
            {/* MyCardShare Logo */}
            <div className="flex items-center gap-2">
              <div
                className="w-7 h-7 sm:w-8 sm:h-8 rounded-lg flex items-center justify-center font-black text-xs sm:text-sm text-white shadow-xs"
                style={{ backgroundColor: product.themeColor }}
              >
                M
              </div>
              <div className="flex flex-col">
                <span className="font-['Space_Grotesk'] font-black tracking-wider text-xs sm:text-sm leading-tight uppercase">
                  MyCardShare
                </span>
                <span className="text-[9px] font-mono tracking-widest text-white/60 uppercase">
                  {product.badge}
                </span>
              </div>
            </div>

            {/* NFC Wave Symbol */}
            <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-white/10 backdrop-blur-xs border border-white/15">
              <Wifi className="w-3.5 h-3.5 rotate-90 text-white" />
              <span className="text-[9px] font-mono font-bold tracking-wider uppercase text-white/90">
                NFC TAP
              </span>
            </div>
          </div>

          {/* Card Middle: Cardholder Name & Role */}
          <div className="relative z-10 my-auto py-2">
            <h4
              className="text-lg sm:text-2xl font-black tracking-tight uppercase leading-none font-['Space_Grotesk']"
              style={{ color: product.type === "bamboo" ? "#FFF6EE" : "#FFFFFF" }}
            >
              {product.name}
            </h4>
            <p className="text-xs sm:text-sm font-medium text-white/80 mt-1">
              {product.role}
            </p>
            <p className="text-[10px] sm:text-xs font-mono tracking-wider text-white/60 mt-0.5 uppercase">
              {product.company}
            </p>
          </div>

          {/* Card Bottom Row: Chip + Verified QR Code */}
          <div className="relative z-10 flex items-end justify-between pt-2 border-t border-white/10">
            {/* Chip / Security details */}
            <div className="flex items-center gap-2">
              {/* EMV Microchip Mockup */}
              <div className="w-8 h-6 sm:w-9 sm:h-7 rounded bg-gradient-to-br from-[#E2B774] to-[#B38743] border border-[#F4D08C]/50 flex flex-col justify-around p-0.5 shadow-xs">
                <div className="h-[1px] bg-black/30 w-full" />
                <div className="h-[1px] bg-black/30 w-full" />
              </div>
              <div className="text-[9px] font-mono text-white/60 hidden sm:block">
                <span>VERIFIED NFC PASS</span>
                <div className="text-white/40">ID: MCS-2026-{product.number}</div>
              </div>
            </div>

            {/* Dynamic QR Code Badge */}
            <div className="flex items-center gap-1.5 p-1.5 rounded-lg bg-white text-black shadow-md">
              <QrCode className="w-4 h-4 sm:w-5 sm:h-5 text-black" />
            </div>
          </div>

          {/* Light reflection sheen diagonally across the card */}
          <div className="absolute inset-0 rounded-[22px] sm:rounded-[26px] bg-gradient-to-tr from-transparent via-white/10 to-transparent pointer-events-none" />
        </div>
      </div>
    </div>
  );
};

// ================= MAIN CINEMATIC SLICE COMPONENT =================
export interface CinematicSliceProps {
  totalPages?: number;
  className?: string;
}

export const CinematicSlice: React.FC<CinematicSliceProps> = ({
  totalPages = PRODUCTS.length,
  className
}) => {
  const [page, setPage] = useState(1);
  const [isPaused, setIsPaused] = useState(false);
  const activeProduct = PRODUCTS[(page - 1) % PRODUCTS.length];

  // Auto-advance slides every 7 seconds
  useEffect(() => {
    if (isPaused) return;

    const timer = setInterval(() => {
      setPage((prev) => (prev >= totalPages ? 1 : prev + 1));
    }, 7000);

    return () => clearInterval(timer);
  }, [totalPages, isPaused, page]);

  return (
    <div
      className="w-full flex items-center justify-center"
      onMouseEnter={() => setIsPaused(true)}
      onMouseLeave={() => setIsPaused(false)}
    >
      <div className={cn("w-full max-w-5xl mx-auto h-[480px] sm:h-[520px] relative flex items-center justify-center group", className)}>
        
        {/* Background with blur for depth in product brand glow */}
        <div
          className="absolute inset-0 overflow-hidden rounded-3xl opacity-30 blur-3xl scale-110 pointer-events-none transition-colors duration-700"
          style={{ backgroundColor: activeProduct.themeColor }}
        />

        {/* Main Slicing Image Frame */}
        <div className="relative w-full h-full rounded-3xl overflow-hidden bg-[#0D0B0A] shadow-2xl border border-white/12">
          <AnimatePresence mode="wait">
            <motion.div
              key={page}
              className="relative w-full h-full"
            >
              {/* 3 Slices Animation (Slicing the Realistic Card Showcase) */}
              {[0, 1, 2].map((i) => (
                <motion.div
                  key={i}
                  className="absolute inset-0 overflow-hidden"
                  style={{
                    clipPath: `inset(0 ${100 - (i + 1) * 33.33}% 0 ${i * 33.33}%)`
                  }}
                  initial={{ y: "100%" }}
                  animate={{ y: "0%" }}
                  exit={{ y: "-100%" }}
                  transition={{
                    duration: 0.8,
                    ease: [0.16, 1, 0.3, 1],
                    delay: i * 0.1
                  }}
                >
                  {/* Rich Rendered MyCardShare Physical Card Visual */}
                  <MyCardShareCardGraphic product={activeProduct} />

                  {/* Diagonal Metallic Sheen Sweep */}
                  <motion.div
                    initial={{ x: '-100%' }}
                    animate={{ x: '200%' }}
                    transition={{ duration: 1, delay: 0.5 + (i * 0.1) }}
                    className="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent skew-x-12 pointer-events-none"
                  />
                </motion.div>
              ))}

              {/* Text Content Overlay (Based on MyCardShare) */}
              <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0 }}
                transition={{ delay: 0.45, duration: 0.7 }}
                className="absolute bottom-8 left-6 sm:bottom-10 sm:left-10 z-20 pointer-events-none max-w-md sm:max-w-lg"
              >
                {/* Pill Tag */}
                <div className="flex items-center gap-2 mb-2 sm:mb-2.5">
                  <span className="px-2.5 py-0.5 rounded-full bg-[#D4642C] text-[10px] font-black uppercase tracking-widest text-white shadow-xs">
                    MYCARDSHARE
                  </span>
                  <span className="text-[#FFA370] font-mono text-[11px] sm:text-xs tracking-wider uppercase font-bold drop-shadow-sm">
                    {activeProduct.collection}
                  </span>
                </div>

                {/* Main Product Title */}
                <h2 className="text-3xl sm:text-5xl lg:text-6xl font-black text-white tracking-tighter drop-shadow-[0_2px_15px_rgba(0,0,0,0.8)] font-['Space_Grotesk'] leading-[1.05]">
                  {activeProduct.title}
                </h2>

                {/* Subtitle / Product Specs */}
                <p className="text-white/80 text-xs sm:text-sm mt-2 sm:mt-2.5 font-normal leading-relaxed drop-shadow-sm max-w-sm sm:max-w-md">
                  {activeProduct.subtitle}
                </p>
              </motion.div>
            </motion.div>
          </AnimatePresence>

          {/* Navigation Overlay (Chevrons) */}
          <div className="absolute inset-0 z-30 flex items-center justify-between px-4 sm:px-6 pointer-events-none">
            <button
              onClick={() => setPage((p) => Math.max(1, p - 1))}
              disabled={page === 1}
              aria-label="Previous product"
              className="pointer-events-auto w-11 h-11 sm:w-12 sm:h-12 rounded-full bg-black/60 backdrop-blur-md border border-white/15 flex items-center justify-center text-white hover:bg-[#D4642C] hover:border-[#D4642C] transition-all disabled:opacity-20 disabled:pointer-events-none cursor-pointer shadow-lg"
            >
              <ChevronLeft className="w-5 h-5" />
            </button>
            <button
              onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
              disabled={page === totalPages}
              aria-label="Next product"
              className="pointer-events-auto w-11 h-11 sm:w-12 sm:h-12 rounded-full bg-black/60 backdrop-blur-md border border-white/15 flex items-center justify-center text-white hover:bg-[#D4642C] hover:border-[#D4642C] transition-all disabled:opacity-20 disabled:pointer-events-none cursor-pointer shadow-lg"
            >
              <ChevronRight className="w-5 h-5" />
            </button>
          </div>

          {/* Dot Indicators */}
          <div className="absolute bottom-8 right-6 sm:bottom-10 sm:right-10 z-30 flex items-center gap-2">
            {Array.from({ length: totalPages }).map((_, i) => (
              <motion.button
                key={i}
                type="button"
                onClick={() => setPage(i + 1)}
                aria-label={`Go to product ${i + 1}`}
                animate={{
                  width: page === i + 1 ? 32 : 8,
                  backgroundColor: page === i + 1 ? "#D4642C" : "rgba(255,255,255,0.25)"
                }}
                className="h-2 rounded-full pointer-events-auto cursor-pointer transition-colors"
              />
            ))}
          </div>

        </div>
      </div>
    </div>
  );
};

export default CinematicSlice;
