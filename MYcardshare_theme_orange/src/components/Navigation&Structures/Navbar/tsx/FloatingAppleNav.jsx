"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";

// ============================================================================
// MERGED: Floating Island + Apple Glass Dynamic Pill
// When closed, it's a floating black island. When hovered, it expands and
// reveals the Apple-style sliding glass active indicator inside!
// ============================================================================

export const FloatingAppleNav = ({ items = [], className = "" }) => {
  const [isOpen, setIsOpen] = useState(false);
  const [active, setActive] = useState(items[0]?.name);

  return (
    <nav
      onMouseEnter={() => setIsOpen(true)}
      onMouseLeave={() => setIsOpen(false)}
      className={`bg-zinc-950 text-white rounded-full transition-all duration-500 ease-[cubic-bezier(0.23,1,0.32,1)] overflow-hidden flex items-center justify-center border border-white/10 shadow-2xl ${
        isOpen ? "w-auto min-w-[360px] px-2 py-2 h-14" : "w-4 h-4 p-0"
      } ${className}`}
    >
      <AnimatePresence mode="wait">
        {isOpen ? (
          <motion.div
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 0.9 }}
            className="flex w-full items-center justify-between gap-1"
          >
            {items.map((item) => (
              <a
                key={item.name}
                href={item.href}
                onClick={(e) => {
                  e.preventDefault();
                  setActive(item.name);
                }}
                className={`relative px-4 py-1.5 text-sm font-medium transition-colors duration-300 w-full text-center rounded-full ${
                  active === item.name
                    ? "text-black"
                    : "text-zinc-400 hover:text-white"
                }`}
              >
                {active === item.name && (
                  <motion.div
                    layoutId="merged-glass-active"
                    className="absolute inset-0 bg-white shadow-[0_0_15px_rgba(255,255,255,0.4)] rounded-full"
                    transition={{ type: "spring", bounce: 0.3, duration: 0.6 }}
                  />
                )}
                <span className="relative z-10">{item.name}</span>
              </a>
            ))}
          </motion.div>
        ) : (
          <div className="w-2 h-2 bg-white rounded-full shadow-[0_0_10px_white]" />
        )}
      </AnimatePresence>
    </nav>
  );
};
