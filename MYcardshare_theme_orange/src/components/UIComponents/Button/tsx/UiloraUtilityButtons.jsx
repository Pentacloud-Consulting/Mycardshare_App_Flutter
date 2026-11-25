"use client";

import React from "react";
import { Command } from "lucide-react";

// --- 1. THE COPY BUTTON ---
const CopyButton = ({ text }) => {
  return (
    <button className="flex items-center gap-2 bg-neutral-100 hover:bg-white text-black px-4 py-2 rounded-md font-medium text-sm transition-all active:scale-95 group">
      <span>{text}</span>
      <div className="h-4 w-[1px] bg-neutral-300 mx-1" />
      <div className="text-neutral-500 group-hover:text-black">
        <Command size={14} />
      </div>
    </button>
  );
};

// --- 2. THE NEON UNDERGLOW ---
const NeonUnderglowButton = ({ text }) => {
  return (
    <button className="group relative px-6 py-3 text-sm font-semibold text-white bg-neutral-800 rounded-full overflow-hidden">
      <div className="absolute inset-x-0 h-[2px] bottom-0 bg-gradient-to-r from-transparent via-rose-500 to-transparent w-3/4 mx-auto blur-sm group-hover:blur-md transition-all" />
      <div className="absolute inset-x-0 h-[1px] bottom-0 bg-gradient-to-r from-transparent via-rose-500 to-transparent w-3/4 mx-auto" />
      <span className="relative">{text}</span>
    </button>
  );
};

// Custom Feature as per user request: Liquid Animation Button
const LiquidButton = ({ text }) => {
  return (
    <button className="relative px-6 py-3 font-semibold text-white group overflow-hidden rounded-full">
      <div className="absolute inset-0 w-full h-full bg-blue-600 transition-all rounded-full group-hover:bg-blue-500" />
      <div className="absolute -bottom-10 left-1/2 -translate-x-1/2 w-32 h-32 bg-blue-400 rounded-[40%] animate-spin-slow opacity-50 group-hover:-translate-y-8 duration-700 transition-transform blur-xl" />
      <span className="relative z-10 block mix-blend-overlay font-bold uppercase tracking-widest text-[10px]">
        {text}
      </span>
    </button>
  );
};

export default function UiloraUtilityButtons() {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-12 place-items-center p-12 bg-black border border-white/5 rounded-3xl">
      <CopyButton text="npm install ui-lib" />
      <NeonUnderglowButton text="Neon Bottom" />
      <LiquidButton text="Liquid Flow" />
    </div>
  );
}
