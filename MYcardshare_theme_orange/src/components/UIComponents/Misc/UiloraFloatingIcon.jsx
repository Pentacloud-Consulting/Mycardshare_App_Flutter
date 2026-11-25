"use client";

import React from "react";
import { motion } from "framer-motion";

export const UiloraFloatingIcon = ({
  icon: Icon,
  title,
  subtitle,
  color = "#6366f1",
  delay = 0,
  className = "",
}) => {
  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.8 }}
      animate={{
        opacity: 1,
        scale: 1,
        y: [0, -10, 0],
      }}
      transition={{
        delay,
        opacity: { duration: 0.5 },
        scale: { duration: 0.5 },
        y: {
          repeat: Infinity,
          duration: 4,
          ease: "easeInOut",
          delay: delay * 0.5,
        },
      }}
      whileHover={{ scale: 1.08, y: -8, boxShadow: "0 20px 40px rgba(212,100,44,0.18), inset 0 0 0 1px rgba(255,255,255,0.9)" }}
      className={`absolute z-30 flex items-center gap-2 sm:gap-3 px-2.5 sm:px-4 py-1.5 sm:py-2.5 rounded-full shadow-2xl cursor-pointer group border border-stone-200/80 hover:border-[#D4642C]/50 transition-colors duration-300 ${className}`}
      style={{
        background: "rgba(255, 255, 255, 0.85)",
        backdropFilter: "blur(16px)",
        boxShadow: `0 10px 30px rgba(0,0,0,0.06), inset 0 0 0 1px rgba(255,255,255,0.7)`,
      }}
    >
      <div
        className="relative w-6 h-6 sm:w-8 sm:h-8 rounded-full flex items-center justify-center shrink-0 overflow-hidden group-hover:rotate-12 group-hover:scale-110 transition-all duration-300"
        style={{
          background: `${color}15`,
          border: `1px solid ${color}40`,
        }}
      >
        <div
          className="absolute inset-0 rounded-full opacity-20"
          style={{ background: color }}
        />
        <Icon
          style={{ color, filter: `drop-shadow(0 0 4px ${color})` }}
          className="relative z-10 w-3 h-3 sm:w-4 sm:h-4"
        />
      </div>

      <div className="flex flex-col">
        <span className="text-[9px] sm:text-[12px] font-black text-slate-800 tracking-tight leading-none mb-0.5">
          {title}
        </span>
        <span
          className="text-[6.5px] sm:text-[8px] font-bold uppercase tracking-widest leading-none"
          style={{ color: `${color}cc` }}
        >
          {subtitle}
        </span>
      </div>
    </motion.div>
  );
};
