"use client";

import React, { useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { AlertCircle, X, Users } from "lucide-react";

interface IndividualLeadsProps {
  isVisible: boolean;
  onClose: () => void;
  message?: string;
  type?: "error" | "warning" | "info";
  duration?: number;
}

const IndividualLeads: React.FC<IndividualLeadsProps> = ({
  isVisible,
  onClose,
  message = "Please fill all required lead details",
  type = "error",
  duration = 5000,
}) => {
  useEffect(() => {
    if (isVisible) {
      const timer = setTimeout(() => {
        onClose();
      }, duration);
      return () => clearTimeout(timer);
    }
  }, [isVisible, onClose, duration]);

  const styles = {
    error: {
      border: "rgba(239, 68, 68, 0.3)",
      bg: "rgba(30, 10, 10, 0.85)",
      accent: "text-red-400",
      glow: "bg-red-500/10",
      iconBg: "bg-red-500/15",
      iconBorder: "border-red-500/30",
      progress: "from-red-500 to-amber-500"
    },
    warning: {
      border: "rgba(245, 158, 11, 0.3)",
      bg: "rgba(30, 20, 5, 0.85)",
      accent: "text-amber-400",
      glow: "bg-amber-500/10",
      iconBg: "bg-amber-500/15",
      iconBorder: "border-amber-500/30",
      progress: "from-amber-500 to-yellow-500"
    },
    info: {
      border: "rgba(56, 189, 248, 0.3)",
      bg: "rgba(5, 15, 30, 0.85)",
      accent: "text-sky-400",
      glow: "bg-sky-500/10",
      iconBg: "bg-sky-500/15",
      iconBorder: "border-sky-500/30",
      progress: "from-sky-500 to-indigo-500"
    }
  };

  const currentStyle = styles[type];

  return (
    <AnimatePresence>
      {isVisible && (
        <div className="fixed inset-0 z-[120] flex items-end justify-center sm:items-center p-4 pointer-events-none">
          <motion.div
            initial={{ opacity: 0, y: 50, scale: 0.9, rotateX: -20 }}
            animate={{ opacity: 1, y: 0, scale: 1, rotateX: 0 }}
            exit={{ opacity: 0, y: 20, scale: 0.95, filter: "blur(10px)" }}
            transition={{
              type: "spring",
              damping: 25,
              stiffness: 300,
              mass: 0.8,
            }}
            className="pointer-events-auto"
          >
            <div
              className="relative overflow-hidden glass-heavy px-6 py-4 flex items-center gap-4 min-w-[320px] shadow-2xl"
              style={{
                border: `1px solid ${currentStyle.border}`,
                background: currentStyle.bg,
              }}
            >
              {/* Background Glow Effect */}
              <div className={`absolute top-0 right-0 -mr-8 -mt-8 w-24 h-24 ${currentStyle.glow} blur-3xl rounded-full`} />
              <div className={`absolute bottom-0 left-0 -ml-8 -mb-8 w-24 h-24 ${currentStyle.glow} blur-3xl rounded-full`} />

              {/* Animated Icon */}
              <div className="relative">
                <motion.div
                  initial={{ scale: 0, rotate: -45 }}
                  animate={{ scale: 1, rotate: 0 }}
                  transition={{ delay: 0.1, type: "spring", bounce: 0.6 }}
                  className={`w-10 h-10 rounded-full ${currentStyle.iconBg} flex items-center justify-center border ${currentStyle.iconBorder}`}
                >
                  <Users size={20} className={currentStyle.accent} />
                </motion.div>
                <motion.div
                  animate={{
                    scale: [1, 1.3, 1],
                    opacity: [0, 0.4, 0],
                  }}
                  transition={{ duration: 2, repeat: Infinity }}
                  className={`absolute inset-0 rounded-full ${currentStyle.iconBg}`}
                />
              </div>

              {/* Text Content */}
              <div className="flex-1">
                <h4 className="text-[11px] font-black text-white tracking-[0.2em] m-0 uppercase">
                  Lead Management
                </h4>
                <p
                  className="text-xs mt-1 font-medium leading-relaxed"
                  style={{ color: "rgba(255,255,255,0.7)" }}
                >
                  {message}
                </p>
              </div>

              {/* Close Button */}
              <button
                onClick={onClose}
                className="w-8 h-8 rounded-lg flex items-center justify-center text-white/40 hover:text-white hover:bg-white/5 transition-all cursor-pointer ml-2"
              >
                <X size={16} />
              </button>

              {/* Progress Bar Timer */}
              <motion.div
                initial={{ scaleX: 1 }}
                animate={{ scaleX: 0 }}
                transition={{ duration: duration / 1000, ease: "linear" }}
                className={`absolute bottom-0 left-0 right-0 h-[2px] bg-gradient-to-r ${currentStyle.progress} origin-left`}
              />
            </div>
          </motion.div>
        </div>
      )}
    </AnimatePresence>
  );
};

export default IndividualLeads;
