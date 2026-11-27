'use client';

import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { cn } from '@/lib/utils';
import {
  Wifi,
  QrCode,
  ShieldCheck,
  Lock,
  Clock,
  Phone,
  Mail,
  CheckCircle2
} from 'lucide-react';

// ================= WALLET ICONS =================
const GoogleWalletIcon: React.FC<{ className?: string }> = ({ className = "w-6 h-6" }) => (
  <svg viewBox="0 0 24 24" className={className} fill="none">
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

// ================= SHARP SVG QR CODE =================
const CardQRCode: React.FC<{ className?: string }> = ({ className = "w-20 h-20" }) => (
  <svg viewBox="0 0 100 100" className={cn("bg-white p-1.5 rounded-xl shadow-md shrink-0", className)}>
    {/* Finder Top-Left */}
    <rect x="10" y="10" width="28" height="28" fill="#1A110B" rx="4" />
    <rect x="16" y="16" width="16" height="16" fill="#FFFFFF" rx="2" />
    <rect x="20" y="20" width="8" height="8" fill="#D4642C" rx="1.5" />
    
    {/* Finder Top-Right */}
    <rect x="62" y="10" width="28" height="28" fill="#1A110B" rx="4" />
    <rect x="68" y="16" width="16" height="16" fill="#FFFFFF" rx="2" />
    <rect x="72" y="20" width="8" height="8" fill="#D4642C" rx="1.5" />
    
    {/* Finder Bottom-Left */}
    <rect x="10" y="62" width="28" height="28" fill="#1A110B" rx="4" />
    <rect x="16" y="68" width="16" height="16" fill="#FFFFFF" rx="2" />
    <rect x="20" y="72" width="8" height="8" fill="#D4642C" rx="1.5" />
    
    {/* QR Data modules */}
    <rect x="44" y="12" width="6" height="6" fill="#1A110B" />
    <rect x="52" y="18" width="6" height="6" fill="#1A110B" />
    <rect x="44" y="26" width="6" height="6" fill="#1A110B" />
    <rect x="12" y="44" width="6" height="6" fill="#1A110B" />
    <rect x="22" y="48" width="6" height="6" fill="#1A110B" />
    <rect x="32" y="44" width="6" height="6" fill="#1A110B" />
    <rect x="44" y="44" width="12" height="12" fill="#D4642C" rx="2" />
    <rect x="62" y="44" width="6" height="6" fill="#1A110B" />
    <rect x="74" y="48" width="6" height="6" fill="#1A110B" />
    <rect x="84" y="44" width="6" height="6" fill="#1A110B" />
    <rect x="44" y="62" width="6" height="6" fill="#1A110B" />
    <rect x="54" y="68" width="6" height="6" fill="#1A110B" />
    <rect x="44" y="78" width="6" height="6" fill="#1A110B" />
    <rect x="64" y="64" width="6" height="6" fill="#1A110B" />
    <rect x="74" y="72" width="6" height="6" fill="#1A110B" />
    <rect x="82" y="64" width="6" height="6" fill="#1A110B" />
    <rect x="68" y="82" width="6" height="6" fill="#1A110B" />
    <rect x="80" y="80" width="8" height="8" fill="#1A110B" />
  </svg>
);

// ================= ORANGE THEMED TOPOGRAPHIC WAVES =================
const OrangeWaveVisual: React.FC<{ variant?: number }> = ({ variant = 0 }) => {
  const waveSets = [
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
    <div className="absolute inset-0 w-full h-full bg-[#140A05] overflow-hidden pointer-events-none">
      <div className="absolute inset-0 bg-gradient-to-br from-[#120804] via-[#221006] to-[#0A0402]" />
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[700px] h-[350px] bg-[#D4642C]/24 rounded-full blur-[110px]" />
      <div className="absolute top-10 right-20 w-[400px] h-[250px] bg-[#FFA370]/12 rounded-full blur-[90px]" />

      <svg viewBox="0 0 1500 450" preserveAspectRatio="xMidYMid slice" className="absolute inset-0 w-full h-full opacity-80">
        <defs>
          <linearGradient id={`orangeWaveGrad-${variant}`} x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stopColor="#FFA370" stopOpacity="0.85" />
            <stop offset="45%" stopColor="#D4642C" stopOpacity="0.65" />
            <stop offset="85%" stopColor="#8A3410" stopOpacity="0.3" />
            <stop offset="100%" stopColor="#3D1504" stopOpacity="0.1" />
          </linearGradient>
          <linearGradient id={`waveShadow-${variant}`} x1="0%" y1="0%" x2="0%" y2="100%">
            <stop offset="0%" stopColor="#D4642C" stopOpacity="0.15" />
            <stop offset="100%" stopColor="#0D0603" stopOpacity="0.7" />
          </linearGradient>
        </defs>

        {currentWaves.map((d, idx) => (
          <path
            key={`band-${idx}`}
            d={`${d} L1600,500 L-100,500 Z`}
            fill={`url(#waveShadow-${variant})`}
            opacity={0.05 + idx * 0.012}
          />
        ))}

        {currentWaves.map((d, idx) => {
          const isKeyStroke = idx % 2 === 0;
          return (
            <path
              key={`line-${idx}`}
              d={d}
              fill="none"
              stroke={`url(#orangeWaveGrad-${variant})`}
              strokeWidth={isKeyStroke ? 2.2 : 1.4}
              strokeOpacity={isKeyStroke ? 0.7 : 0.4}
              strokeLinecap="round"
            />
          );
        })}
      </svg>
      <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-black/40" />
    </div>
  );
};

// ================= REAL CARD PASS 1: GOOGLE WALLET PASS =================
const GoogleWalletCardPass: React.FC = () => {
  return (
    <motion.div
      initial={{ opacity: 0, y: 18, scale: 0.96 }}
      animate={{ opacity: 1, y: 0, scale: 1 }}
      exit={{ opacity: 0, y: -18, scale: 0.96 }}
      transition={{ type: "spring", stiffness: 220, damping: 22 }}
      className="relative w-full max-w-[480px] sm:max-w-[500px] h-[255px] sm:h-[265px] mx-auto rounded-3xl bg-gradient-to-b from-[#1F1916]/95 via-[#181210]/98 to-[#100B09] border border-white/15 p-4 sm:p-5 shadow-[0_25px_60px_rgba(0,0,0,0.7),0_0_40px_rgba(212,100,44,0.18)] backdrop-blur-xl overflow-hidden flex flex-col justify-between group"
    >
      {/* Light sheen animation */}
      <div className="absolute -inset-full bg-gradient-to-r from-transparent via-white/5 to-transparent rotate-45 pointer-events-none group-hover:translate-x-full transition-transform duration-1000" />

      {/* Card Header (Google Wallet styling) */}
      <div className="flex items-center justify-between pb-3 border-b border-white/10">
        <div className="flex items-center gap-2.5">
          <div className="w-7 h-7 rounded-full bg-white/10 flex items-center justify-center p-1 shadow-xs">
            <GoogleWalletIcon className="w-full h-full" />
          </div>
          <div>
            <div className="text-[13px] font-bold text-white tracking-tight flex items-center gap-1.5">
              <span>Google Wallet</span>
              <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 shadow-[0_0_8px_#34D399]" />
            </div>
            <div className="text-[9px] text-neutral-400 uppercase tracking-widest font-semibold">Digital Business Pass</div>
          </div>
        </div>

        {/* Smart Tap / NFC Badge */}
        <div className="flex items-center gap-1.5 px-2 py-0.5 rounded-full bg-white/5 border border-white/10 text-[10px] font-semibold text-neutral-300">
          <Wifi className="w-3 h-3 text-[#D4642C] rotate-90" />
          <span>Smart Tap</span>
        </div>
      </div>

      {/* Main Body */}
      <div className="flex items-center justify-between gap-3">
        {/* Left: User Details */}
        <div className="flex-1 min-w-0">
          <div className="inline-flex items-center px-2 py-0.5 rounded-md bg-[#D4642C]/15 border border-[#D4642C]/30 text-[9px] font-bold text-[#FFA370] uppercase tracking-wider mb-1">
            <span>MYCARDSHARE PASS</span>
          </div>

          <h4 className="text-lg sm:text-xl font-black text-white tracking-tight truncate">
            Alex Rivers
          </h4>
          <p className="text-xs font-semibold text-[#FFA370] tracking-tight truncate">
            Founder &amp; Chief Executive Officer
          </p>
          <p className="text-[10px] text-neutral-400 truncate font-medium">
            Pentacloud Technologies • Dubai
          </p>

          {/* Quick Contact Chips */}
          <div className="mt-2 flex flex-wrap gap-1.5">
            <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-lg bg-black/40 border border-white/5 text-[10px] text-neutral-300">
              <Phone className="w-2.5 h-2.5 text-[#D4642C]" />
              <span>+1 (555) 0192</span>
            </span>
            <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-lg bg-black/40 border border-white/5 text-[10px] text-neutral-300">
              <Mail className="w-2.5 h-2.5 text-[#D4642C]" />
              <span>alex@rivers.co</span>
            </span>
          </div>
        </div>

        {/* Right: Dynamic QR Code */}
        <div className="flex flex-col items-center shrink-0">
          <CardQRCode className="w-18 h-18 sm:w-20 sm:h-20" />
          <span className="text-[8px] font-mono text-neutral-400 mt-1 uppercase tracking-wider">
            Scan to Sync
          </span>
        </div>
      </div>

      {/* Card Footer Bar */}
      <div className="pt-2 border-t border-white/10 flex items-center justify-between text-[10px] text-neutral-400">
        <div className="flex items-center gap-1.5">
          <span className="font-mono text-neutral-300 font-semibold text-[9px]">PASS #MCS-88294</span>
          <span>•</span>
          <span className="text-emerald-400 font-medium flex items-center gap-1 text-[9px]">
            <CheckCircle2 className="w-3 h-3 text-emerald-400" />
            Verified Active
          </span>
        </div>

        {/* Google 4-Color Strip accent */}
        <div className="flex items-center gap-0.5">
          <span className="w-2 h-1 rounded-full bg-[#4285F4]" />
          <span className="w-2 h-1 rounded-full bg-[#EA4335]" />
          <span className="w-2 h-1 rounded-full bg-[#FBBC05]" />
          <span className="w-2 h-1 rounded-full bg-[#34A853]" />
        </div>
      </div>
    </motion.div>
  );
};

// ================= REAL CARD PASS 2: APPLE WALLET PASS =================
const AppleWalletCardPass: React.FC = () => {
  return (
    <motion.div
      initial={{ opacity: 0, y: 18, scale: 0.96 }}
      animate={{ opacity: 1, y: 0, scale: 1 }}
      exit={{ opacity: 0, y: -18, scale: 0.96 }}
      transition={{ type: "spring", stiffness: 220, damping: 22 }}
      className="relative w-full max-w-[480px] sm:max-w-[500px] h-[255px] sm:h-[265px] mx-auto rounded-3xl bg-gradient-to-b from-[#211A16]/95 via-[#18120F]/98 to-[#0E0907] border border-[#D4642C]/30 p-4 sm:p-5 shadow-[0_25px_60px_rgba(0,0,0,0.7),0_0_40px_rgba(212,100,44,0.22)] backdrop-blur-xl overflow-hidden flex flex-col justify-between group"
    >
      {/* Apple Pass Top Cutout Notch Accent */}
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-28 h-1 bg-[#D4642C]/40 rounded-b-md" />

      {/* Card Header (Apple Wallet Pass styling) */}
      <div className="flex items-center justify-between pb-3 border-b border-white/10">
        <div className="flex items-center gap-2">
          <div className="w-7 h-7 rounded-lg bg-black/60 border border-white/10 flex items-center justify-center text-white">
            <AppleWalletIcon className="w-4 h-4 text-white" />
          </div>
          <div>
            <div className="text-xs font-bold text-white tracking-wide uppercase font-['Space_Grotesk']">
              Apple Wallet Pass
            </div>
            <div className="text-[9px] text-[#FFA370] font-mono tracking-wider font-semibold">
              MYCARDSHARE • OFFICIAL ID
            </div>
          </div>
        </div>

        {/* NFC Tap Wave Symbol */}
        <div className="flex items-center gap-1.5 px-2 py-0.5 rounded-full bg-[#D4642C]/15 border border-[#D4642C]/35 text-[10px] font-semibold text-[#FFA370]">
          <Wifi className="w-3 h-3 rotate-90" />
          <span>NFC Tap Ready</span>
        </div>
      </div>

      {/* Main Apple Pass Grid */}
      <div className="flex items-center justify-between gap-3">
        {/* Pass Info */}
        <div className="flex-1 min-w-0">
          <div className="text-[9px] font-bold text-neutral-400 uppercase tracking-widest font-mono">
            CARDHOLDER
          </div>
          <h4 className="text-lg sm:text-xl font-black text-white tracking-tight truncate mt-0.5">
            Alex Rivers
          </h4>
          <p className="text-xs font-semibold text-[#F18F58] tracking-tight truncate">
            VP of Global Partnerships
          </p>
          <p className="text-[10px] text-neutral-400 font-medium truncate">
            MyCardShare Global Network
          </p>

          {/* Apple Wallet Metadata Grid */}
          <div className="grid grid-cols-2 gap-2 mt-2 pt-2 border-t border-white/5">
            <div>
              <div className="text-[8px] text-neutral-400 uppercase font-mono font-semibold">PASS TYPE</div>
              <div className="text-[11px] font-bold text-white tracking-tight">Executive Elite</div>
            </div>
            <div>
              <div className="text-[8px] text-neutral-400 uppercase font-mono font-semibold">SECURITY</div>
              <div className="text-[11px] font-bold text-emerald-400 flex items-center gap-1">
                <ShieldCheck className="w-2.5 h-2.5 text-emerald-400" />
                FaceID / TouchID
              </div>
            </div>
          </div>
        </div>

        {/* Apple Wallet Aztec/QR Code */}
        <div className="flex flex-col items-center shrink-0">
          <CardQRCode className="w-18 h-18 sm:w-20 sm:h-20" />
          <span className="text-[8px] font-mono text-neutral-400 mt-1 uppercase tracking-wider">
            Instant Pass
          </span>
        </div>
      </div>

      {/* Apple Pass Bottom Perforated Divider */}
      <div className="pt-2 border-t border-dashed border-white/15 flex items-center justify-between text-[9px] text-neutral-400">
        <span className="font-mono text-neutral-300">PASS ID: PKP-2026-9482</span>
        <span className="text-[#FFA370] font-semibold flex items-center gap-1">
          Instant Offline Access
        </span>
      </div>
    </motion.div>
  );
};

// ================= REAL CARD PASS 3: SAMSUNG WALLET (COMING SOON) =================
const SamsungWalletCardPass: React.FC = () => {
  return (
    <motion.div
      initial={{ opacity: 0, y: 18, scale: 0.96 }}
      animate={{ opacity: 1, y: 0, scale: 1 }}
      exit={{ opacity: 0, y: -18, scale: 0.96 }}
      transition={{ type: "spring", stiffness: 220, damping: 22 }}
      className="relative w-full max-w-[480px] sm:max-w-[500px] h-[255px] sm:h-[265px] mx-auto rounded-3xl bg-gradient-to-b from-[#1C1410]/95 via-[#160E0A]/98 to-[#0E0805] border-2 border-dashed border-[#D4642C]/40 p-4 sm:p-5 shadow-[0_25px_60px_rgba(0,0,0,0.7),0_0_40px_rgba(212,100,44,0.15)] backdrop-blur-xl overflow-hidden flex flex-col justify-between text-center group"
    >
      {/* Blueprint Grid Ambient Overlay */}
      <div className="absolute inset-0 bg-[radial-gradient(#D4642C_1px,transparent_1px)] [background-size:16px_16px] opacity-15 pointer-events-none" />

      {/* Top Header */}
      <div className="flex items-center justify-between pb-2.5 border-b border-white/10 relative z-10">
        <div className="flex items-center gap-2">
          <div className="w-7 h-7 rounded-lg bg-[#D4642C]/15 border border-[#D4642C]/30 flex items-center justify-center text-[#FFA370]">
            <SamsungWalletIcon className="w-4 h-4 text-[#FFA370]" />
          </div>
          <span className="text-xs font-bold text-white tracking-wide uppercase font-['Space_Grotesk']">
            Samsung Wallet
          </span>
        </div>

        {/* COMING SOON BADGE */}
        <div className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-gradient-to-r from-[#D4642C] to-[#E2763E] text-white text-[9px] font-black uppercase tracking-widest shadow-[0_0_12px_rgba(212,100,44,0.6)] animate-pulse">
          <Clock className="w-3 h-3 text-white" />
          <span>COMING SOON</span>
        </div>
      </div>

      {/* Main Content Area */}
      <div className="py-1 relative z-10 flex flex-col items-center">
        <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-[#2D180E] to-[#1A0E08] border border-[#D4642C]/40 flex items-center justify-center text-[#FFA370] shadow-md mb-2">
          <Lock className="w-4 h-4 text-[#FFA370]" />
        </div>

        <h4 className="text-base sm:text-lg font-black text-white tracking-tight">
          Samsung Wallet Pass Integration
        </h4>
        <p className="mt-1 text-[11px] sm:text-xs text-neutral-300 max-w-sm leading-relaxed">
          Native digital pass architecture for Galaxy devices is currently in certification. One UI Quick-Access integration rolling out soon.
        </p>

        {/* Feature Highlights Pills (Without Sparkles icon) */}
        <div className="mt-2.5 flex flex-wrap items-center justify-center gap-1.5">
          <span className="px-2 py-0.5 rounded-md bg-black/50 border border-white/10 text-[10px] text-neutral-300 font-medium flex items-center gap-1">
            <ShieldCheck className="w-3 h-3 text-[#FFA370]" />
            Samsung Knox Protected
          </span>
          <span className="px-2 py-0.5 rounded-md bg-black/50 border border-white/10 text-[10px] text-neutral-300 font-medium flex items-center gap-1">
            <Wifi className="w-3 h-3 text-[#FFA370] rotate-90" />
            Quick Pay Bar Ready
          </span>
          <span className="px-2 py-0.5 rounded-md bg-black/50 border border-white/10 text-[10px] text-neutral-300 font-medium">
            Galaxy One UI 6.0+
          </span>
        </div>
      </div>

      {/* Card Footer Bar */}
      <div className="pt-2 border-t border-white/10 flex items-center justify-between text-[9px] text-neutral-400 relative z-10">
        <span className="font-mono text-neutral-400">STATUS: IN ACTIVE DEVELOPMENT</span>
        <span className="text-[#FFA370] font-semibold flex items-center gap-1">
          <Clock className="w-2.5 h-2.5 text-[#D4642C]" />
          Expected Q2 2025
        </span>
      </div>
    </motion.div>
  );
};

// ================= WALLET DATA CONFIG =================
interface WalletItem {
  id: string;
  name: string;
  edition: string;
  badge: string;
  tagline: string;
  headline: string;
  isComingSoon?: boolean;
  icon: React.ReactNode;
  cardComponent: React.ReactNode;
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
    cardComponent: <GoogleWalletCardPass />,
  },
  {
    id: "apple",
    name: "Apple Wallet",
    edition: "002",
    badge: "APPLE WALLET COMPATIBLE",
    tagline: "PASS EDITION 002 • APPLE WALLET",
    headline: "DIGITAL WALLET PASS",
    icon: <AppleWalletIcon className="w-5 h-5 sm:w-6 sm:h-6 text-white" />,
    cardComponent: <AppleWalletCardPass />,
  },
  {
    id: "samsung",
    name: "Samsung Wallet",
    edition: "003",
    badge: "SAMSUNG WALLET • COMING SOON",
    tagline: "PASS EDITION 003 • SAMSUNG WALLET (COMING SOON)",
    headline: "DIGITAL WALLET PASS",
    isComingSoon: true,
    icon: <SamsungWalletIcon className="w-5 h-5 sm:w-6 sm:h-6 text-[#FFA370]" />,
    cardComponent: <SamsungWalletCardPass />,
  },
];

export interface ParallaxStripProps {
  totalPages?: number;
  className?: string;
}

export const ParallaxStrip: React.FC<ParallaxStripProps> = ({ className }) => {
  // 1 = Google Wallet, 2 = Apple Wallet, 3 = Samsung Wallet
  const [page, setPage] = useState(1);

  return (
    <div className="w-full flex items-center justify-center px-4">
      <div className={cn("w-full max-w-5xl mx-auto flex flex-col items-center", className)}>
        
        {/* ================= MAIN DISPLAY BOX (LOCKED FIXED HEIGHT: NEVER SHIFTS) ================= */}
        <div className="relative w-full h-[360px] sm:h-[380px] md:h-[400px] overflow-hidden rounded-3xl bg-[#140B06] border border-[#D4642C]/30 shadow-[0_20px_60px_rgba(212,100,44,0.18),0_10px_30px_rgba(0,0,0,0.5)] flex items-center justify-center p-4 sm:p-6">
          
          {/* Topographic Background Waves */}
          <div className="absolute inset-0 overflow-hidden pointer-events-none">
            <OrangeWaveVisual variant={page - 1} />
          </div>

          {/* Floating Real Wallet Pass Card Container */}
          <div className="relative z-10 w-full flex items-center justify-center">
            <AnimatePresence mode="wait">
              <div key={WALLETS[page - 1].id} className="w-full flex justify-center">
                {WALLETS[page - 1].cardComponent}
              </div>
            </AnimatePresence>
          </div>

        </div>

        {/* ================= 3 CIRCLE BUTTONS PAGINATION STRIP ================= */}
        <div className="mt-5 flex flex-col items-center gap-2">
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
                  title={wallet.isComingSoon ? `${wallet.name} (Coming Soon)` : wallet.name}
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

                    {/* Small 'SOON' Pill badge on Samsung button */}
                    {wallet.isComingSoon && (
                      <span className="absolute -top-1.5 -right-1 px-1.5 py-0.2 rounded-full bg-gradient-to-r from-[#D4642C] to-[#E2763E] text-[8px] font-black text-white uppercase shadow-[0_0_8px_rgba(212,100,44,0.8)] border border-white/20">
                        SOON
                      </span>
                    )}
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
            {WALLETS[page - 1].isComingSoon && (
              <span className="px-2 py-0.5 rounded-full bg-[#D4642C]/15 border border-[#D4642C]/30 text-[10px] font-bold text-[#FFA370] uppercase">
                Coming Soon
              </span>
            )}
          </div>
        </div>

      </div>
    </div>
  );
};

export default ParallaxStrip;
