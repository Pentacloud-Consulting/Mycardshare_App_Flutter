import React from 'react';
import { AlertCircle, X } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

interface FillFormProps {
  isOpen: boolean;
  onClose: () => void;
  message?: string;
}

export default function FillForm({ isOpen, onClose, message = "Please fill all requested fields." }: FillFormProps) {
  return (
    <AnimatePresence>
      {isOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-0 bg-black/40 backdrop-blur-sm">
          <motion.div
            initial={{ opacity: 0, scale: 0.95, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.95, y: 20 }}
            className="w-full max-w-[280px] sm:max-w-sm p-6 sm:p-8 rounded-2xl sm:rounded-3xl bg-white border border-[#EFE8E1] shadow-2xl relative overflow-hidden"
          >
            {/* Subtle warm glow */}
            <div className="absolute top-0 left-0 w-full h-24 bg-gradient-to-b from-[#D4642C]/5 to-transparent pointer-events-none" />
            
            <button
              onClick={onClose}
              className="absolute top-3 right-3 sm:top-4 sm:right-4 p-1.5 sm:p-2 rounded-full hover:bg-[#FAF6F2] text-[#78716C] hover:text-[#18181B] transition-colors z-10 cursor-pointer"
            >
              <X className="w-4 h-4 sm:w-5 sm:h-5" />
            </button>

            <div className="flex flex-col items-center text-center gap-3 sm:gap-4 relative z-10">
              <div className="w-12 h-12 sm:w-14 sm:h-14 rounded-full bg-red-50 border border-red-200 flex items-center justify-center mb-0.5 sm:mb-2 shadow-sm">
                <AlertCircle className="w-5 h-5 sm:w-6 sm:h-6 text-red-500" />
              </div>
              
              <div className="space-y-1 sm:space-y-2">
                <h3 className="text-base sm:text-xl font-black text-[#18181B] tracking-tight">Missing Information</h3>
                <p className="text-xs sm:text-sm font-medium text-[#78716C] leading-relaxed px-1">
                  {message}
                </p>
              </div>

              <button
                onClick={onClose}
                className="w-full mt-3 sm:mt-5 py-3 sm:py-3.5 rounded-full bg-[#D4642C] text-white font-bold text-xs uppercase tracking-wider hover:bg-[#B85323] transition-all shadow-md cursor-pointer"
              >
                Got it
              </button>
            </div>
          </motion.div>
        </div>
      )}
    </AnimatePresence>
  );
}
