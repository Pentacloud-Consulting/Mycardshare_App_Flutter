"use client";

import React from "react";
import { motion, AnimatePresence } from "framer-motion";
import { 
  CheckCircle2, 
  Smartphone, 
  Share2, 
  X, 
  Download,
  ArrowRight
} from "lucide-react";

const Conformation = ({ isOpen, onClose, userName, themeColor = "#6366f1" }) => {
  if (!isOpen) return null;

  return (
    <AnimatePresence>
      <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 sm:p-6 overflow-hidden">
        {/* Backdrop with extreme blur */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          onClick={onClose}
          className="absolute inset-0 bg-black/60 backdrop-blur-xl transition-all"
        />

        {/* Modal Container */}
        <motion.div
          initial={{ scale: 0.9, opacity: 0, y: 30 }}
          animate={{ scale: 1, opacity: 1, y: 0 }}
          exit={{ scale: 0.9, opacity: 0, y: 20 }}
          transition={{ type: "spring", damping: 25, stiffness: 300 }}
          className="relative w-full max-w-md bg-[#0A0D14] rounded-[2.5rem] border border-white/10 shadow-[0_40px_100px_-12px_rgba(0,0,0,1)] overflow-hidden"
          style={{
            boxShadow: `0 40px 100px -12px rgba(0,0,0,0.8), 0 0 60px -20px ${themeColor}33 inset`,
          }}
        >
          {/* Ambient Top Light */}
          <div 
            className="absolute top-0 inset-x-0 h-px bg-gradient-to-r from-transparent via-white/20 to-transparent" 
          />

          {/* Close Button */}
          <button
            onClick={onClose}
            className="absolute top-6 right-6 p-2 rounded-full bg-white/5 border border-white/10 text-slate-400 hover:text-white hover:bg-white/10 transition-all z-20"
          >
            <X size={20} />
          </button>

          <div className="p-8 sm:p-10 flex flex-col items-center text-center">
            {/* Animated Success Ring */}
            <div className="relative mb-8">
              <motion.div
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                transition={{ type: "spring", delay: 0.2 }}
                className="w-24 h-24 rounded-full bg-emerald-500/10 border border-emerald-500/20 flex items-center justify-center"
              >
                <CheckCircle2 size={48} className="text-emerald-400 drop-shadow-[0_0_15px_rgba(52,211,153,0.5)]" />
              </motion.div>
              
              {/* Pulsing Aura */}
              <motion.div
                animate={{ scale: [1, 1.2, 1], opacity: [0.3, 0.1, 0.3] }}
                transition={{ duration: 3, repeat: Infinity }}
                className="absolute inset-0 rounded-full bg-emerald-500/20 -z-10"
              />
            </div>

            <h2 className="text-2xl sm:text-3xl font-black text-white tracking-tight leading-tight">
              Contact Saved!
            </h2>
            <p className="mt-3 text-slate-400 text-sm sm:text-base font-medium max-w-[280px]">
              {userName}'s digital card has been successfully added to your device.
            </p>

            {/* Steps / Info */}
            <div className="w-full mt-10 space-y-4">
              <div className="group p-5 rounded-2xl bg-white/[0.03] border border-white/[0.05] hover:bg-white/[0.06] hover:border-white/[0.1] transition-all text-left">
                <div className="flex items-center gap-4">
                  <div className="p-3 rounded-xl bg-indigo-500/10 border border-indigo-500/20">
                    <Smartphone size={20} className="text-indigo-400" />
                  </div>
                  <div>
                    <h4 className="text-[13px] font-black text-white uppercase tracking-widest">Saved to Contacts</h4>
                    <p className="text-[11px] text-slate-500 font-bold mt-1 uppercase tracking-wider">Available on all your devices</p>
                  </div>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="pt-4 grid grid-cols-2 gap-4">
                <button
                  onClick={onClose}
                  className="py-4 rounded-2xl bg-white/5 border border-white/10 text-[11px] font-black uppercase tracking-[0.2em] text-slate-300 hover:bg-white/10 transition-all flex items-center justify-center gap-2"
                >
                  Dismiss
                </button>
                <button
                  onClick={onClose} // Typically would open share or something
                  className="py-4 rounded-2xl text-[11px] font-black uppercase tracking-[0.2em] text-white transition-all flex items-center justify-center gap-2 group shadow-lg"
                  style={{ backgroundColor: themeColor }}
                >
                  Share Card <ArrowRight size={14} className="group-hover:translate-x-1 transition-transform" />
                </button>
              </div>
            </div>

            {/* Footer Branding */}
            <div className="mt-10 flex flex-col items-center gap-2">
              <span className="text-[10px] font-black text-slate-600 uppercase tracking-[0.3em]">Powered by</span>
              <div className="text-[12px] font-black text-white tracking-tighter italic">My Card Share</div>
            </div>
          </div>
        </motion.div>

        {/* Floating Background Particles */}
        <div className="absolute top-1/4 left-1/4 w-32 h-32 bg-indigo-500/10 blur-[60px] pointer-events-none rounded-full" />
        <div className="absolute bottom-1/4 right-1/4 w-32 h-32 bg-emerald-500/10 blur-[60px] pointer-events-none rounded-full" />
      </div>
    </AnimatePresence>
  );
};

export default Conformation;
