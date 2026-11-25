"use client";

import { useEffect, useState } from "react";
import { motion, AnimatePresence } from "framer-motion";

export default function SplashScreen() {
  const [isVisible, setIsVisible] = useState(true);

  useEffect(() => {
    // Keep the splash screen visible for 2 seconds to show off the premium animation
    const timer = setTimeout(() => {
      setIsVisible(false);
    }, 2000);

    return () => clearTimeout(timer);
  }, []);

  return (
    <AnimatePresence>
      {isVisible && (
        <motion.div
          key="splash"
          initial={{ opacity: 1, y: 0 }}
          exit={{ 
            opacity: 0, 
            y: "-100%", 
            transition: { duration: 0.8, ease: [0.76, 0, 0.24, 1] } 
          }}
          className="fixed inset-0 z-[9999] flex flex-col items-center justify-center bg-[#FAF6F2] overflow-hidden"
        >
          {/* Subtle Background Aurora Glow */}
          <div className="absolute inset-0 overflow-hidden pointer-events-none">
            <motion.div 
              initial={{ scale: 0.8, opacity: 0 }}
              animate={{ scale: 1.2, opacity: 0.6 }}
              transition={{ duration: 2, ease: "easeOut" }}
              className="absolute w-[600px] h-[600px] rounded-full top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 bg-[radial-gradient(circle,rgba(212,100,44,0.18),transparent_70%)] filter blur-3xl" 
            />
          </div>

          <div className="relative z-10 flex flex-col items-center">
            {/* Logo Reveal */}
            <motion.div
              initial={{ opacity: 0, scale: 0.9, filter: "blur(10px)" }}
              animate={{ opacity: 1, scale: 1, filter: "blur(0px)" }}
              transition={{ duration: 0.8, ease: "easeOut" }}
              className="mb-8"
            >
              <img
                src="/logo/image (4).png"
                alt="Pentacloud Logo"
                className="w-56 md:w-72 h-auto object-contain drop-shadow-xl"
              />
            </motion.div>

            {/* Premium Loading Bar */}
            <div className="w-48 h-1 rounded-full bg-[#EFE8E1] overflow-hidden">
              <motion.div
                initial={{ x: "-100%" }}
                animate={{ x: "100%" }}
                transition={{
                  repeat: Infinity,
                  duration: 1,
                  ease: "easeInOut",
                }}
                className="w-full h-full bg-gradient-to-r from-transparent via-[#D4642C] to-transparent"
              />
            </div>
            
            {/* Text Glow */}
            <motion.p
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.4, duration: 0.6 }}
              className="mt-6 text-[10px] font-bold uppercase tracking-[0.3em] text-stone-500"
            >
              Initializing
            </motion.p>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
