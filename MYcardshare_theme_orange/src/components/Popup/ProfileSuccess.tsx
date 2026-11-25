"use client";

import React, { useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { CheckCircle2, X } from "lucide-react";

interface ProfileSuccessProps {
  isVisible: boolean;
  onClose: () => void;
  message?: string;
  duration?: number;
}

const ProfileSuccess: React.FC<ProfileSuccessProps> = ({
  isVisible,
  onClose,
  message = "Settings saved successfully",
  duration = 4000,
}) => {
  useEffect(() => {
    if (isVisible) {
      const timer = setTimeout(() => {
        onClose();
      }, duration);
      return () => clearTimeout(timer);
    }
  }, [isVisible, onClose, duration]);

  return (
    <AnimatePresence>
      {isVisible && (
        <div className="fixed inset-0 z-[100] flex items-end justify-center sm:items-center p-4 pointer-events-none">
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
              className="relative overflow-hidden glass-heavy px-6 py-4 flex items-center gap-4 min-w-[320px] shadow-glow-indigo"
              style={{
                border: "1px solid rgba(99, 102, 241, 0.3)",
                background: "rgba(12, 21, 53, 0.85)",
              }}
            >
              {/* Background Glow Effect */}
              <div className="absolute top-0 right-0 -mr-8 -mt-8 w-24 h-24 bg-indigo-500/10 blur-3xl rounded-full" />
              <div className="absolute bottom-0 left-0 -ml-8 -mb-8 w-24 h-24 bg-cyan-500/10 blur-3xl rounded-full" />

              {/* Animated Icon */}
              <div className="relative">
                <motion.div
                  initial={{ scale: 0, rotate: -45 }}
                  animate={{ scale: 1, rotate: 0 }}
                  transition={{ delay: 0.2, type: "spring", bounce: 0.6 }}
                  className="w-10 h-10 rounded-full bg-indigo-500/15 flex items-center justify-center border border-indigo-500/30"
                >
                  <CheckCircle2 size={24} className="text-indigo-400" />
                </motion.div>
                <motion.div
                  animate={{
                    scale: [1, 1.5, 1],
                    opacity: [0, 0.5, 0],
                  }}
                  transition={{ duration: 1.5, repeat: Infinity }}
                  className="absolute inset-0 rounded-full bg-indigo-500/20"
                />
              </div>

              {/* Text Content */}
              <div className="flex-1">
                <h4 className="text-sm font-black text-white tracking-tight m-0">
                  Success
                </h4>
                <p
                  className="text-xs mt-0.5"
                  style={{ color: "var(--color-muted)" }}
                >
                  {message}
                </p>
              </div>

              {/* Close Button */}
              <button
                onClick={onClose}
                className="w-8 h-8 rounded-lg flex items-center justify-center text-white/40 hover:text-white hover:bg-white/5 transition-all cursor-pointer"
              >
                <X size={16} />
              </button>

              {/* Progress Bar Timer */}
              <motion.div
                initial={{ scaleX: 1 }}
                animate={{ scaleX: 0 }}
                transition={{ duration: duration / 1000, ease: "linear" }}
                className="absolute bottom-0 left-0 right-0 h-[2px] bg-gradient-to-r from-indigo-500 to-cyan-400 origin-left"
              />
            </div>
          </motion.div>
        </div>
      )}
    </AnimatePresence>
  );
};

export default ProfileSuccess;
