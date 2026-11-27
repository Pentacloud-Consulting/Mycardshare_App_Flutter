'use client';

import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { cn } from '@/lib/utils';

// ================= WALLET ICONS =================
const GoogleWalletIcon: React.FC<{ className?: string }> = ({ className = "w-6 h-6" }) => (
  <svg viewBox="0 0 24 24" className={className} fill="none">
    {/* Google 4-color stylized emblem inside a circular emblem */}
    <path
      d="M21.35 11.1H12v3.16h5.36c-.23 1.25-.94 2.31-2 3.02v2.51h3.24c1.89-1.74 2.98-4.3 2.98-7.39 0-.44-.04-.88-.23-1.3z"
      fill="#4285F4"
    />
    <path
      d="M12 21c2.43 0 4.47-.8 5.96-2.18l-3.24-2.51c-.81.54-1.84.86-2.72.86-2.34 0-4.33-1.58-5.04-3.71H3.6v2.59C5.08 18.99 8.28 21 12 21z"
      fill="#34A853"
    />
    <path
      d="M6.96 13.46c-.18-.54-.28-1.12-.28-1.71 0-.59.1-1.17.28-1.71V7.45H3.6A9.97 9.97 0 002.5 12c0 1.61.39 3.14 1.1 4.49l3.36-2.61v-.42z"
      fill="#FBBC05"
    />
    <path
      d="M12 6.58c1.32 0 2.51.45 3.44 1.35l2.58-2.58C16.46 3.9 14.43 3 12 3 8.28 3 5.08 5.01 3.6 7.95l3.36 2.61c.71-2.13 2.7-3.98 5.04-3.98z"
      fill="#EA4335"
    />
  </svg>
);

const AppleWalletIcon: React.FC<{ className?: string }> = ({ className = "w-6 h-6" }) => (
  <svg viewBox="0 0 24 24" className={className} fill="currentColor">
    <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M15.97 6.37c.62-.75 1.04-1.8 1.01-2.85-.92.04-2.04.62-2.67 1.36-.56.65-.99 1.7-.93 2.73 1.03.08 2.01-.54 2.59-1.24z" />
  </svg>
);

const SamsungWalletIcon: React.FC<{ className?: string }> = ({ className = "w-6 h-6" }) => (
  <svg viewBox="0 0 24 24" className={className} fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <rect x="2" y="5" width="20" height="14" rx="3.5" />
    <path d="M2 10h20" />
    <path d="M6 15h4" />
    <circle cx="17" cy="15" r="1.5" fill="currentColor" />
  </svg>
);

// ================= ORANGE THEMED TOPOGRAPHIC WAVES (REPLACING BLUE WITH ORANGE) =================
const OrangeWaveVisual: React.FC<{ variant?: number }> = ({ variant = 0 }) => {
  // Variations in wave frequency / height for different wallet passes
  const waveSets = [
    // Variant 0: Google Wallet Flow
    [
      "M-100,60 C200,120 500,10 800,140 1100,280 1400,90 1600,130",
      "M-100,90 C220,150 520,30 820,170 1120,310 1420,120 1600,160",
      "M-100,120 C240,180 540,50 840,200 1140,340 1440,150 1600,190",
      "M-100,150 C260,210 560,70 860,230 1160,370 1460,180 1600,220",
      "M-100,180 C280,240 580,90 880,260 1180,400 1480,210 1600,250",
      "M-100,210 C300,270 600,110 900,290 1200,430 1500,240 1600,280",
      "M-100,240 C320,300 620,130 920,320 1220,460 1520,270 1600,310",
      "M-100,270 C340,330 640,150 940,350 1240,490 1540,300 1600,340",
      "M-100,300 C360,360 660,170 960,380 1260,520 1560,330 1600,370",
      "M-100,330 C380,390 680,190 980,410 1280,550 1580,360 1600,400",
    ],
    // Variant 1: Apple Wallet Flow
    [
      "M-100,40 C180,140 480,-10 780,110 1080,250 1380,70 1600,100",
      "M-100,70 C200,170 500,10 800,140 1100,280 1400,100 1600,130",
      "M-100,100 C220,200 520,30 820,170 1120,310 1420,130 1600,160",
      "M-100,130 C240,230 540,50 840,200 1140,340 1440,160 1600,190",
      "M-100,160 C260,260 560,70 860,230 1160,370 1460,190 1600,220",
      "M-100,190 C280,290 580,90 880,260 1180,400 1480,220 1600,250",
      "M-100,220 C300,320 600,110 900,290 1200,430 1500,250 1600,280",
      "M-100,250 C320,350 620,130 920,320 1220,460 1520,280 1600,310",
      "M-100,280 C340,380 640,150 940,350 1240,490 1540,310 1600,340",
      "M-100,310 C360,410 660,170 960,380 1260,520 1560,340 1600,370",
    ],
    // Variant 2: Samsung Wallet Flow
    [
      "M-100,80 C220,100 520,40 820,160 1120,290 1420,110 1600,150",
      "M-100,110 C240,130 540,60 840,190 1140,320 1440,140 1600,180",
      "M-100,140 C260,160 560,80 860,220 1160,350 1460,170 1600,210",
      "M-100,170 C280,190 580,100 880,250 1180,380 1480,200 1600,240",
      "M-100,200 C300,220 600,120 900,280 1200,410 1500,230 1600,270",
      "M-100,230 C320,250 620,140 920,310 1220,440 1520,260 1600,300",
      "M-100,260 C340,280 640,160 940,340 1240,470 1540,290 1600,330",
      "M-100,290 C360,310 660,180 960,370 1260,500 1560,320 1600,360",
      "M-100,320 C380,340 680,200 980,400 1280,530 1580,350 1600,390",
      "M-100,350 C400,370 700,220 1000,430 1300,560 1600,380 1600,420",
    ],
  ];

  const currentWaves = waveSets[variant % waveSets.length];

  return (
    <div className="absolute inset-0 w-full h-full bg-[#1A0E08] overflow-hidden">
      {/* Deep warm glowing orange background mesh */}
      <div className="absolute inset-0 bg-gradient-to-br from-[#120804] via-[#221006] to-[#0A0402]" />
      
      {/* Central radiating ember glow */}
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[700px] h-[350px] bg-[#D4642C]/28 rounded-full blur-[110px] pointer-events-none" />
      <div className="absolute top-10 right-20 w-[400px] h-[250px] bg-[#FFA370]/15 rounded-full blur-[90px] pointer-events-none" />

      {/* Topographic 3D Orange Waves SVG */}
      <svg
        viewBox="0 0 1500 450"
        preserveAspectRatio="xMidYMid slice"
        className="absolute inset-0 w-full h-full opacity-90"
      >
        <defs>
          <linearGradient id={`orangeWaveGrad-${variant}`} x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stopColor="#FFA370" stopOpacity="0.9" />
            <stop offset="45%" stopColor="#D4642C" stopOpacity="0.75" />
            <stop offset="85%" stopColor="#8A3410" stopOpacity="0.4" />
            <stop offset="100%" stopColor="#3D1504" stopOpacity="0.1" />
          </linearGradient>

          <linearGradient id={`waveShadow-${variant}`} x1="0%" y1="0%" x2="0%" y2="100%">
            <stop offset="0%" stopColor="#D4642C" stopOpacity="0.18" />
            <stop offset="100%" stopColor="#0D0603" stopOpacity="0.7" />
          </linearGradient>
        </defs>

        {/* Shaded topographic wave bands */}
        {currentWaves.map((d, idx) => (
          <path
            key={`band-${idx}`}
            d={`${d} L1600,500 L-100,500 Z`}
            fill={`url(#waveShadow-${variant})`}
            opacity={0.06 + idx * 0.015}
          />
        ))}

        {/* Glowing Orange Contour Lines */}
        {currentWaves.map((d, idx) => {
          const isKeyStroke = idx % 2 === 0;
          return (
            <path
              key={`line-${idx}`}
              d={d}
              fill="none"
              stroke={`url(#orangeWaveGrad-${variant})`}
              strokeWidth={isKeyStroke ? 2.4 : 1.5}
              strokeOpacity={isKeyStroke ? 0.75 : 0.45}
              strokeLinecap="round"
            />
          );
        })}
      </svg>

      {/* Subtle top/bottom edge vignette */}
      <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-black/30 pointer-events-none" />
      <div className="absolute inset-0 bg-radial from-transparent via-transparent to-black/50 pointer-events-none" />
    </div>
  );
};

// ================= 3 WALLET SPECIFICATIONS =================
interface WalletItem {
  id: string;
  name: string;
  edition: string;
  badge: string;
  tagline: string;
  headline: string;
  icon: React.ReactNode;
}

const WALLETS: WalletItem[] = [
  {
    id: "google",
    name: "Google Wallet",
    edition: "001",
    badge: "GOOGLE WALLET READY",
    tagline: "PASS EDITION 001 • GOOGLE WALLET",
    headline: "DIGITAL WALLET PASS",
    icon: <GoogleWalletIcon className="w-5 h-5 sm:w-6 sm:h-6" />,
  },
  {
    id: "apple",
    name: "Apple Wallet",
    edition: "002",
    badge: "APPLE WALLET COMPATIBLE",
    tagline: "PASS EDITION 002 • APPLE WALLET",
    headline: "DIGITAL WALLET PASS",
    icon: <AppleWalletIcon className="w-5 h-5 sm:w-6 sm:h-6 text-white" />,
  },
  {
    id: "samsung",
    name: "Samsung Wallet",
    edition: "003",
    badge: "SAMSUNG WALLET SUPPORTED",
    tagline: "PASS EDITION 003 • SAMSUNG WALLET",
    headline: "DIGITAL WALLET PASS",
    icon: <SamsungWalletIcon className="w-5 h-5 sm:w-6 sm:h-6 text-[#FFA370]" />,
  },
];

export interface ParallaxStripProps {
  totalPages?: number;
  className?: string;
}

export const ParallaxStrip: React.FC<ParallaxStripProps> = ({
  className
}) => {
  // 3 buttons: 1 = Google Wallet, 2 = Apple Wallet, 3 = Samsung Wallet
  const [page, setPage] = useState(1);

  return (
    <div className="w-full flex items-center justify-center px-4">
      <div className={cn("w-full max-w-5xl mx-auto flex flex-col items-center", className)}>
        
        {/* ================= MAIN BOX (ORANGE THEME WAVES) ================= */}
        <div className="relative w-full h-72 sm:h-80 md:h-96 overflow-hidden rounded-2xl bg-[#140B06] border border-[#D4642C]/30 shadow-[0_20px_60px_rgba(212,100,44,0.18),0_10px_30px_rgba(0,0,0,0.5)]">
          <motion.div
            className="flex h-full"
            animate={{ x: `-${(page - 1) * 100}%` }}
            transition={{ type: "spring", stiffness: 200, damping: 25 }}
          >
            {WALLETS.map((wallet, i) => (
              <div key={wallet.id} className="min-w-full h-full relative overflow-hidden flex items-center justify-center">
                
                {/* Parallax Moving Orange Waves Background */}
                <motion.div
                  className="w-[120%] h-[120%] absolute inset-0 -top-[10%] -left-[10%]"
                  animate={{ x: `${(page - 1 - i) * 15}%` }}
                  transition={{ type: "spring", stiffness: 100, damping: 25 }}
                >
                  <OrangeWaveVisual variant={i} />
                </motion.div>

                {/* Central Typography Display (Matching Image 1 & 2 Layout Exactly) */}
                <motion.div
                  initial={{ opacity: 0, y: 16 }}
                  animate={{ opacity: page === i + 1 ? 1 : 0, y: page === i + 1 ? 0 : 16 }}
                  transition={{ delay: 0.18 }}
                  className="relative z-10 text-center select-none px-6"
                >
                  {/* Main Title: DIGITAL WALLET PASS */}
                  <h3 className="text-3xl sm:text-5xl md:text-6xl font-black text-white uppercase tracking-tight font-['Space_Grotesk'] drop-shadow-[0_2px_12px_rgba(0,0,0,0.6)]">
                    {wallet.headline}
                  </h3>

                  {/* Subtitle in Theme Peach Mono: PASS EDITION 00X • WALLET NAME */}
                  <p className="text-[#FFA370] font-mono text-xs sm:text-sm md:text-base mt-2.5 tracking-[0.2em] uppercase font-semibold drop-shadow-sm">
                    {wallet.tagline}
                  </p>
                </motion.div>
              </div>
            ))}
          </motion.div>
        </div>

        {/* ================= 3 CIRCLE BUTTONS PAGINATION STRIP ================= */}
        {/* Only 3 buttons: Google Wallet, Apple Wallet, Samsung Wallet */}
        <div className="mt-4 flex flex-col items-center gap-1.5">
          <div className="flex items-center gap-3.5 sm:gap-4 p-2.5 sm:p-3 bg-[#1A110B]/95 backdrop-blur-md rounded-full border border-[#D4642C]/30 shadow-[0_12px_32px_rgba(0,0,0,0.4),0_0_20px_rgba(212,100,44,0.15)]">
            {WALLETS.map((wallet, i) => {
              const isActive = page === i + 1;
              return (
                <button
                  key={wallet.id}
                  type="button"
                  onClick={() => setPage(i + 1)}
                  className="relative group cursor-pointer focus:outline-none"
                  aria-label={`Select ${wallet.name}`}
                  title={wallet.name}
                >
                  {/* Circle Box Button */}
                  <motion.div
                    animate={{
                      scale: isActive ? 1.12 : 1,
                    }}
                    transition={{ type: "spring", stiffness: 300, damping: 20 }}
                    className={cn(
                      "w-12 h-12 sm:w-14 sm:h-14 rounded-full flex items-center justify-center transition-all duration-300 relative",
                      isActive
                        ? "bg-[#2A160C] text-white border-2 border-[#D4642C] shadow-[0_0_20px_rgba(212,100,44,0.55)]"
                        : "bg-[#180E08]/80 text-white/50 border border-white/10 hover:border-[#D4642C]/50 hover:text-white hover:bg-[#20120A]"
                    )}
                  >
                    {/* Glowing orange backdrop behind active circle icon */}
                    {isActive && (
                      <div className="absolute inset-0 rounded-full bg-[#D4642C]/20 blur-xs pointer-events-none" />
                    )}

                    {/* Icon */}
                    <div className="relative z-10 transition-transform duration-200 group-hover:scale-105">
                      {wallet.icon}
                    </div>
                  </motion.div>

                  {/* Active Glowing Ring Indicator */}
                  {isActive && (
                    <motion.div
                      layoutId="active-wallet-ring"
                      className="absolute -inset-1 rounded-full border-2 border-[#D4642C]/80 shadow-[0_0_12px_rgba(212,100,44,0.4)] pointer-events-none"
                      transition={{ type: "spring", stiffness: 350, damping: 25 }}
                    />
                  )}
                </button>
              );
            })}
          </div>

          {/* Active Wallet Label indicator */}
          <div className="flex items-center gap-2 text-xs sm:text-sm font-semibold tracking-wide text-[#A08F83]">
            <span>Active:</span>
            <span className="text-[#D4642C] font-bold font-['Space_Grotesk']">
              {WALLETS[page - 1].name}
            </span>
          </div>
        </div>

      </div>
    </div>
  );
};

export default ParallaxStrip;
