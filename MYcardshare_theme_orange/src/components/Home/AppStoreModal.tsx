"use client";

import React, { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { X, Clock } from "lucide-react";

export const triggerAppStoreModal = () => {
  if (typeof window !== "undefined") {
    window.dispatchEvent(new CustomEvent("open-appstore-modal"));
  }
};

export default function AppStoreModal() {
  const [isOpen, setIsOpen] = useState(false);

  useEffect(() => {
    const handleOpen = () => setIsOpen(true);
    window.addEventListener("open-appstore-modal", handleOpen);
    return () => window.removeEventListener("open-appstore-modal", handleOpen);
  }, []);

  const handleClose = () => {
    setIsOpen(false);
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
          {/* Backdrop */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={handleClose}
            className="absolute inset-0 bg-black/80 backdrop-blur-md"
          />

          {/* Modal Card */}
          <motion.div
            initial={{ opacity: 0, scale: 0.94, y: 16 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.94, y: 16 }}
            transition={{ type: "spring", stiffness: 320, damping: 25 }}
            className="relative w-full max-w-md rounded-3xl bg-gradient-to-b from-[#1F1612] via-[#160E0A] to-[#0E0805] border border-[#D4642C]/40 p-6 sm:p-8 shadow-[0_25px_60px_rgba(0,0,0,0.85),0_0_40px_rgba(212,100,44,0.22)] text-center overflow-hidden z-10"
          >
            {/* Top Close Button */}
            <button
              type="button"
              onClick={handleClose}
              aria-label="Close"
              className="absolute top-4 right-4 p-2 rounded-full bg-white/5 hover:bg-white/10 text-neutral-400 hover:text-white transition-colors cursor-pointer"
            >
              <X className="w-4 h-4" />
            </button>

            {/* Apple Icon with Theme Glow */}
            <div className="mx-auto w-14 h-14 rounded-2xl bg-gradient-to-br from-[#2D180E] to-[#150A04] border border-[#D4642C]/40 flex items-center justify-center text-white shadow-[0_0_24px_rgba(212,100,44,0.4)] mb-4">
              <svg className="w-7 h-7 fill-white" viewBox="0 0 384 512" fill="currentColor">
                <path d="M318.7 268.7c-.2-36.7 16.4-64.4 50-84.8-18.8-26.9-47.2-41.7-84.7-44.6-35.5-2.8-74.3 20.7-88.5 20.7-15 0-49.4-19.7-76.4-19.7C63.3 141.2 4 184.8 4 273.5q0 39.3 14.4 81.2c12.8 36.7 59 126.7 107.2 125.2 25.2-.6 43-17.9 75.8-17.9 31.8 0 48.3 17.9 76.4 17.9 48.6-.7 90.4-82.5 102.6-119.3-65.2-30.7-61.7-90-61.7-91.9zm-56.6-164.2c27.3-32.4 24.8-61.9 24-72.5-24.1 1.4-52 16.4-67.9 34.9-17.5 19.8-27.8 44.3-25.6 71.9 26.1 2 49.9-11.4 69.5-34.3z" />
              </svg>
            </div>

            {/* Status Pill */}
            <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#D4642C]/15 border border-[#D4642C]/40 text-[#FFA370] text-[10px] font-bold uppercase tracking-wider mb-2.5">
              <Clock className="w-3 h-3 text-[#D4642C]" />
              <span>LAUNCHING SOON ON APPLE APP STORE</span>
            </div>

            <h3 className="text-2xl font-black text-white tracking-tight">
              We Are Launching Soon!
            </h3>

            <p className="mt-2 text-xs sm:text-sm text-neutral-300 leading-relaxed max-w-sm mx-auto">
              Our iOS app is currently in TestFlight review with Apple. It will be available for direct download on the App Store very soon!
            </p>

            {/* Android Live Promotion */}
            <div className="mt-5 p-3.5 rounded-2xl bg-black/50 border border-white/10 text-xs text-neutral-300 flex items-center justify-between gap-3 text-left">
              <div>
                <div className="font-bold text-white text-[11px]">Using an Android device?</div>
                <div className="text-[10px] text-neutral-400">Our official Google Play app is live!</div>
              </div>
              <a
                href="https://play.google.com/store/apps/details?id=com_pentacloud.mycarshare"
                target="_blank"
                rel="noopener noreferrer"
                className="px-3.5 py-1.5 rounded-xl bg-[#D4642C] hover:bg-[#BF5422] text-white text-[11px] font-bold shrink-0 transition-colors shadow-xs"
              >
                Get on Play Store
              </a>
            </div>

            {/* Dismiss Button */}
            <button
              type="button"
              onClick={handleClose}
              className="mt-4 w-full py-2.5 rounded-xl bg-white/10 hover:bg-white/15 text-white text-xs font-bold transition-colors cursor-pointer"
            >
              Got it, thanks!
            </button>
          </motion.div>
        </div>
      )}
    </AnimatePresence>
  );
}
