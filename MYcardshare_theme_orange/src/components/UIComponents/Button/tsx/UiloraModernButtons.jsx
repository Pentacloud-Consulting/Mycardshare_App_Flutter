"use client";

import React, { useRef, useState } from "react";
import {
  motion,
  AnimatePresence,
  useSpring,
  useMotionValue,
} from "framer-motion";
import { Star, Zap, ArrowRight, ShieldCheck, Command } from "lucide-react";
import { clsx } from "clsx";
import { twMerge } from "tailwind-merge";

function cn(...inputs) {
  return twMerge(clsx(inputs));
}

// 1. Optimized Spotlight Button (Original)
const SpotlightButton = ({ children, className = "" }) => {
  const divRef = useRef(null);
  const position = { x: 0, y: 0 };

  const handleMouseMove = (e) => {
    if (!divRef.current) return;
    const div = divRef.current;
    const rect = div.getBoundingClientRect();
    position.x = e.clientX - rect.left;
    position.y = e.clientY - rect.top;
    div.style.setProperty("--x", `${position.x}px`);
    div.style.setProperty("--y", `${position.y}px`);
    div.style.setProperty("--opacity", "1");
  };

  const handleMouseLeave = () => {
    if (!divRef.current) return;
    divRef.current.style.setProperty("--opacity", "0");
  };

  return (
    <button
      ref={divRef}
      onMouseMove={handleMouseMove}
      onMouseLeave={handleMouseLeave}
      className={cn(
        "relative overflow-hidden rounded-xl bg-slate-950 px-8 py-4 text-slate-300 transition-colors border border-slate-800",
        className,
      )}
    >
      <div
        className="pointer-events-none absolute -inset-px opacity-0 transition-opacity duration-300"
        style={{
          opacity: "var(--opacity, 0)",
          background: `radial-gradient(600px circle at var(--x) var(--y), rgba(255,255,255,0.1), transparent 40%)`,
        }}
      />
      <div className="relative z-10 flex items-center gap-2">{children}</div>
    </button>
  );
};

// 2. Border Beam Button (Original)
const BorderBeamButton = ({ text }) => {
  return (
    <button className="relative inline-flex h-14 overflow-hidden rounded-full p-[1px] focus:outline-none">
      <span className="absolute inset-[-1000%] animate-[spin_2s_linear_infinite] bg-[conic-gradient(from_90deg_at_50%_50%,#E2CBFF_0%,#393BB2_50%,#E2CBFF_100%)]" />
      <span className="inline-flex h-full w-full cursor-pointer items-center justify-center rounded-full bg-slate-950 px-8 py-1 text-sm font-medium text-white backdrop-blur-3xl">
        {text}
      </span>
    </button>
  );
};

// 3. Shimmering Button (Original)
const ShimmeringButton = ({ text }) => {
  return (
    <button className="inline-flex h-14 animate-shimmer items-center justify-center rounded-xl border border-slate-800 bg-[linear-gradient(110deg,#000103,45%,#1e2631,55%,#000103)] bg-[length:200%_100%] px-10 font-medium text-slate-400 transition-colors focus:outline-none">
      {text}
    </button>
  );
};

// 4. Cosmic Glow Button (Original)
const CosmicGlowButton = ({ text }) => {
  return (
    <button className="relative inline-flex h-14 overflow-hidden rounded-full p-[2px] focus:outline-none group">
      <span className="absolute inset-[-1000%] animate-[spin_3s_linear_infinite] bg-[conic-gradient(from_90deg_at_50%_50%,#E2CBFF_0%,#393BB2_50%,#E2CBFF_100%)]" />
      <span className="inline-flex h-full w-full cursor-pointer items-center justify-center rounded-full bg-slate-950 px-8 py-1 text-sm font-medium text-white backdrop-blur-3xl group-hover:bg-slate-950/80 transition-colors">
        <Zap size={16} className="mr-2 text-purple-400" /> {text}
      </span>
    </button>
  );
};

export const UiloraBrandButton = ({
  children,
  variant = "primary",
  className = "",
  ...props
}) => {
  const [isHovered, setIsHovered] = useState(false);

  const variants = {
    primary:
      "bg-[#D4642C] hover:bg-[#BD5523] text-white shadow-[0_10px_25px_rgba(212,100,44,0.35)] border border-[#E87A43]/40 hover:-translate-y-0.5 hover:shadow-[0_16px_35px_rgba(212,100,44,0.45)] transition-all duration-300 transform",
    secondary:
      "bg-white text-stone-800 border border-stone-200 hover:bg-[#FAF6F2] hover:text-[#D4642C] hover:border-[#D4642C]/40 hover:shadow-md shadow-sm transition-all duration-300",
    outline:
      "bg-white/80 backdrop-blur-md text-stone-700 border border-stone-300 hover:bg-white hover:text-[#D4642C] hover:border-[#D4642C]/50 hover:shadow-[0_8px_25px_rgba(212,100,44,0.15)] shadow-sm transition-all duration-300",
  };

  return (
    <motion.button
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
      whileTap={{ scale: 0.98 }}
      className={cn(
        "relative inline-flex items-center justify-center gap-2 font-bold px-10 py-5 transition-all duration-300 overflow-hidden rounded-full uppercase tracking-[0.2em] text-[12px] shadow-2xl whitespace-nowrap",
        variants[variant],
        className,
      )}
      {...props}
    >

      <AnimatePresence>
        {isHovered && variant === "primary" && (
          <motion.div
            initial={{ left: "-100%", opacity: 0 }}
            animate={{ left: "100%", opacity: 0.5 }}
            transition={{
              duration: 0.8,
              ease: "easeInOut",
              repeat: Infinity,
              repeatDelay: 2,
            }}
            className="absolute inset-0 w-1/2 h-full bg-gradient-to-r from-transparent via-white/40 to-transparent skew-x-[-20deg] pointer-events-none"
          />
        )}
      </AnimatePresence>
      <div className="relative z-10 flex items-center gap-2">{children}</div>
    </motion.button>
  );
};

// 6. Magnetic Premium Interaction
const MagneticButton = ({ text }) => {
  const ref = useRef(null);
  const x = useMotionValue(0);
  const y = useMotionValue(0);

  const springConfig = { damping: 15, stiffness: 150 };
  const springX = useSpring(x, springConfig);
  const springY = useSpring(y, springConfig);

  const handleMouseMove = (e) => {
    const { clientX, clientY } = e;
    const rect = ref.current.getBoundingClientRect();
    const centerX = rect.left + rect.width / 2;
    const centerY = rect.top + rect.height / 2;
    x.set(clientX - centerX);
    y.set(clientY - centerY);
  };

  const handleMouseLeave = () => {
    x.set(0);
    y.set(0);
  };

  return (
    <motion.button
      ref={ref}
      onMouseMove={handleMouseMove}
      onMouseLeave={handleMouseLeave}
      style={{ x: springX, y: springY }}
      className="px-10 py-4 bg-zinc-900 border border-zinc-800 text-white rounded-xl shadow-2xl relative group hover:border-zinc-500 transition-colors"
    >
      <span className="relative z-10 font-bold text-[10px] uppercase tracking-widest">
        {text}
      </span>
      <div className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity bg-[radial-gradient(circle_at_center,rgba(255,255,255,0.1)_0%,transparent_100%)] pointer-events-none" />
    </motion.button>
  );
};

// 7. Glassmorphism Premium
const GlassButton = ({ text }) => (
  <button className="group relative px-10 py-4 bg-white/5 backdrop-blur-xl border border-white/10 text-white font-medium rounded-2xl hover:bg-white/10 hover:border-white/25 transition-all duration-500 shadow-xl overflow-hidden">
    <div className="absolute inset-0 bg-gradient-to-tr from-indigo-500/10 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-700" />
    <span className="relative z-10 flex items-center gap-2 uppercase tracking-widest text-[10px]">
      {text}{" "}
      <ArrowRight
        size={14}
        className="group-hover:translate-x-1 transition-transform"
      />
    </span>
  </button>
);

// 8. Minimal Link
const MinimalLink = ({ text }) => (
  <button className="group relative px-4 py-2 text-zinc-400 hover:text-white transition-colors duration-500 font-medium">
    <span className="text-[10px] uppercase tracking-widest">{text}</span>
    <div className="absolute bottom-0 left-1/2 -translate-x-1/2 w-0 h-[2px] bg-indigo-500 group-hover:w-full transition-all duration-500" />
  </button>
);

// 9. Ghost Glow Button
const GhostGlowButton = ({ text }) => (
  <button className="relative px-10 py-4 bg-transparent border border-white/10 text-white rounded-full overflow-hidden group transition-colors hover:bg-white/5">
    <div className="absolute inset-0 bg-gradient-to-r from-indigo-500/20 via-purple-500/20 to-pink-500/20 opacity-0 group-hover:opacity-100 transition-opacity blur-md" />
    <span className="relative z-10 text-[10px] uppercase tracking-widest font-semibold">
      {text}
    </span>
  </button>
);

// 10. Nebula Glow Button
const NebulaButton = ({ text }) => (
  <button className="relative group px-10 py-4 rounded-full font-bold text-white overflow-hidden shadow-[0_0_40px_-10px_rgba(168,85,247,0.5)]">
    <div className="absolute inset-0 bg-slate-950 z-0" />
    <div className="absolute inset-0 opacity-0 group-hover:opacity-100 blur-xl transition-opacity animate-[spin_4s_linear_infinite] bg-[conic-gradient(from_0deg,transparent_0_340deg,rgba(168,85,247,1)_360deg)] z-0" />
    <div className="absolute inset-[1px] rounded-full bg-slate-950 z-10" />
    <div className="absolute inset-0 bg-gradient-to-r from-purple-500/10 to-pink-500/10 z-10" />
    <span className="relative z-20 text-[10px] uppercase tracking-widest">
      {text}
    </span>
  </button>
);

// 11. Aurora Shift Button
const AuroraButton = ({ text }) => (
  <button className="relative px-10 py-4 rounded-full bg-slate-950 text-white font-semibold border border-white/10 overflow-hidden group">
    <div className="absolute inset-0 bg-gradient-to-r from-cyan-500 via-indigo-500 to-purple-500 opacity-20 group-hover:opacity-40 transition-opacity" />
    <div className="absolute -inset-1 opacity-0 group-hover:opacity-100 blur-2xl bg-gradient-to-r from-cyan-500 via-indigo-500 to-purple-500 transition-opacity duration-1000 group-hover:animate-pulse" />
    <div className="absolute inset-[1px] bg-slate-950 rounded-full" />
    <span className="relative z-10 text-[10px] uppercase tracking-widest">
      {text}
    </span>
  </button>
);

// 12. Starlight Button
const StarlightButton = ({ text }) => (
  <button className="relative px-10 py-4 rounded-xl bg-slate-900 border border-slate-700 text-slate-300 font-bold overflow-hidden group hover:border-slate-500 transition-colors shadow-2xl">
    <div className="absolute top-0 left-1/2 -translate-x-1/2 w-1/2 h-1 bg-gradient-to-r from-transparent via-indigo-400 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500 blur-sm" />
    <div className="absolute top-0 left-1/2 -translate-x-1/2 w-1/4 h-px bg-gradient-to-r from-transparent via-white to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500" />
    <span className="relative z-10 text-[10px] uppercase tracking-widest">
      {text}
    </span>
  </button>
);

export default function UiloraModernButtons() {
  return (
    <div className="p-8 md:p-16 flex flex-col gap-12">
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 text-white">
        {/* Row 1: The Originals */}
        <div className="h-64 flex flex-col items-center justify-center p-12 rounded-3xl bg-zinc-900/50 border border-white/5 relative overflow-hidden group">
          <div className="absolute top-4 left-4 text-[10px] font-mono text-zinc-600 uppercase tracking-widest">
            Original / Spotlight
          </div>
          <SpotlightButton>
            <Star size={16} className="text-yellow-400 fill-yellow-400" />
            <span>Star on Github</span>
          </SpotlightButton>
        </div>

        <div className="h-64 flex flex-col items-center justify-center p-12 rounded-3xl bg-zinc-900/50 border border-white/5 relative overflow-hidden">
          <div className="absolute top-4 left-4 text-[10px] font-mono text-zinc-600 uppercase tracking-widest">
            Original / Border Beam
          </div>
          <BorderBeamButton text="Generate Magic" />
        </div>

        <div className="h-64 flex flex-col items-center justify-center p-12 rounded-3xl bg-zinc-900/50 border border-white/5 relative overflow-hidden">
          <div className="absolute top-4 left-4 text-[10px] font-mono text-zinc-600 uppercase tracking-widest">
            Original / Shimmer
          </div>
          <ShimmeringButton text="Premium Plan" />
        </div>

        {/* Row 2: Original 4 + Flagship */}
        <div className="h-64 flex flex-col items-center justify-center p-12 rounded-3xl bg-zinc-900/50 border border-white/5 relative overflow-hidden">
          <div className="absolute top-4 left-4 text-[10px] font-mono text-zinc-600 uppercase tracking-widest">
            Original / Cosmic
          </div>
          <CosmicGlowButton text="AI Action" />
        </div>

        <div className="h-64 flex flex-col items-center justify-center p-12 rounded-3xl bg-indigo-500/5 border border-indigo-500/20 relative overflow-hidden group shadow-2xl">
          <div className="absolute top-4 left-4 text-[10px] font-mono text-zinc-600 uppercase tracking-widest text-indigo-400 font-bold">
            Flagship / Uilora
          </div>
          <UiloraBrandButton>Get Started</UiloraBrandButton>
        </div>

        <div className="h-64 flex flex-col items-center justify-center p-12 rounded-3xl bg-zinc-900/50 border border-white/5 relative overflow-hidden">
          <div className="absolute top-4 left-4 text-[10px] font-mono text-zinc-600 uppercase tracking-widest">
            Modern / Interaction
          </div>
          <MagneticButton text="Magnetic Pull" />
        </div>

        {/* Row 3: Modern/Beam Styles */}
        <div className="h-64 flex flex-col items-center justify-center p-12 rounded-3xl bg-zinc-900/50 border border-white/5 relative overflow-hidden">
          <div className="absolute top-4 left-4 text-[10px] font-mono text-zinc-600 uppercase tracking-widest">
            Modern / Glass Pro
          </div>
          <GlassButton text="View Portfolio" />
        </div>

        <div className="h-64 flex flex-col items-center justify-center p-12 rounded-3xl bg-zinc-900/50 border border-white/5 relative overflow-hidden">
          <div className="absolute top-4 left-4 text-[10px] font-mono text-zinc-600 uppercase tracking-widest">
            Modern / Ghost Glow
          </div>
          <GhostGlowButton text="Stealth Access" />
        </div>

        <div className="h-64 flex flex-col items-center justify-center p-12 rounded-3xl bg-zinc-900/50 border border-white/5 relative overflow-hidden">
          <div className="absolute top-4 left-4 text-[10px] font-mono text-zinc-600 uppercase tracking-widest">
            Modern / Nebula
          </div>
          <NebulaButton text="Deep Space" />
        </div>

        {/* Row 4: Smooth/Cosmic Glares */}
        <div className="h-64 flex flex-col items-center justify-center p-12 rounded-3xl bg-zinc-900/50 border border-white/5 relative overflow-hidden">
          <div className="absolute top-4 left-4 text-[10px] font-mono text-zinc-600 uppercase tracking-widest">
            Modern / Minimal
          </div>
          <MinimalLink text="Read Case Study" />
        </div>

        <div className="h-64 flex flex-col items-center justify-center p-12 rounded-3xl bg-zinc-900/50 border border-white/5 relative overflow-hidden">
          <div className="absolute top-4 left-4 text-[10px] font-mono text-zinc-600 uppercase tracking-widest">
            Modern / Aurora
          </div>
          <AuroraButton text="Northern Lights" />
        </div>

        <div className="h-64 flex flex-col items-center justify-center p-12 rounded-3xl bg-zinc-900/50 border border-white/5 relative overflow-hidden">
          <div className="absolute top-4 left-4 text-[10px] font-mono text-zinc-600 uppercase tracking-widest">
            Modern / Starlight
          </div>
          <StarlightButton text="Initiate Sequence" />
        </div>
      </div>
    </div>
  );
}
