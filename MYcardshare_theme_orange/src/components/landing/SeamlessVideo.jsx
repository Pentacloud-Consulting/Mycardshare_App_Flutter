"use client"; // Enables client-side features like state & refs

import { motion } from "framer-motion"; // Animation library
import { Play, Volume2, VolumeX } from "lucide-react"; // Icons for sound control
import { useState, useRef } from "react"; // React hooks

export default function SeamlessVideo() {
  const [isPlaying, setIsPlaying] = useState(true);
  const [isMuted, setIsMuted] = useState(true);
  const videoRef = useRef(null);

  const togglePlay = () => {
    if (videoRef.current) {
      if (isPlaying) {
        videoRef.current.pause();
      } else {
        videoRef.current.play();
      }
      setIsPlaying(!isPlaying);
    }
  };

  const toggleMute = (e) => {
    e.stopPropagation();
    setIsMuted(!isMuted);
  };

  return (
    <section className="py-20 md:py-28 bg-[#FAF6F2]">
      <div className="max-w-7xl mx-auto px-6">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          className="bg-white border border-[#EFE8E1] rounded-[36px] p-6 sm:p-10 md:p-14 relative overflow-hidden shadow-[0_10px_35px_rgba(212,100,44,0.04)]"
        >
          {/* Background warm glow effect */}
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-full h-full max-w-[600px] blur-[120px] bg-[#D4642C]/10 pointer-events-none" />

          <div className="grid lg:grid-cols-2 gap-10 md:gap-16 items-center relative z-10">
            {/* Left side - text content */}
            <div>
              {/* Small label */}
              <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#FAF6F2] border border-[#EFE8E1] text-[#D4642C] font-bold tracking-widest uppercase text-xs mb-5">
                <span className="w-1.5 h-1.5 rounded-full bg-[#D4642C]" />
                Seamless Experience
              </div>

              {/* Heading */}
              <h2
                className="text-3xl sm:text-4xl md:text-5xl font-black text-[#18181B] mb-5 uppercase leading-[1.1] tracking-tight"
                style={{
                  fontFamily: "var(--font-display)",
                }}
              >
                See how it
                <br />
                <span className="text-[#D4642C]">works in action</span>
              </h2>

              {/* Description */}
              <p className="text-base sm:text-lg text-stone-600 mb-8 leading-relaxed font-normal">
                A frictionless digital card experience natively embedded in
                modern networking workflows. Instant NFC tapping, digital wallet
                sync, and seamless lead exchange.
              </p>

              {/* Stats */}
              <div className="flex gap-10 sm:gap-14 pt-2 border-t border-[#EFE8E1]">
                <div>
                  <h3
                    className="text-3xl sm:text-4xl font-black text-[#18181B] mb-1 tracking-tight"
                    style={{ fontFamily: "var(--font-display)" }}
                  >
                    +90%
                  </h3>
                  <div className="text-stone-500 font-bold text-xs uppercase tracking-wider">
                    Faster Access
                  </div>
                </div>

                <div>
                  <h3
                    className="text-3xl sm:text-4xl font-black text-[#18181B] mb-1 tracking-tight"
                    style={{ fontFamily: "var(--font-display)" }}
                  >
                    100%
                  </h3>
                  <div className="text-stone-500 font-bold text-xs uppercase tracking-wider">
                    Compatibility
                  </div>
                </div>
              </div>
            </div>

            {/* Right side - video player */}
            <div
              className="relative rounded-[24px] overflow-hidden bg-[#FAF6F2] aspect-video border border-[#EFE8E1] group cursor-pointer shadow-md"
              onClick={togglePlay}
            >
              <video
                ref={videoRef}
                autoPlay
                muted={isMuted}
                loop
                playsInline
                className="w-full h-full object-cover opacity-90 group-hover:opacity-100 transition-opacity"
              >
                <source src="/assets/customer-review.mp4" type="video/mp4" />
              </video>

              {/* Play/Pause Button Overlay */}
              <div className="absolute inset-0 flex items-center justify-center">
                <div
                  className={`w-14 h-14 rounded-full bg-white/80 backdrop-blur-md border border-white/60 flex items-center justify-center shadow-lg transition-all duration-300 ${
                    isPlaying
                      ? "opacity-0 scale-50 group-hover:opacity-100 group-hover:scale-100"
                      : "opacity-100 scale-100"
                  }`}
                >
                  {isPlaying ? (
                    <div className="flex gap-1">
                      <div className="w-1.5 h-4 bg-[#D4642C] rounded-full" />
                      <div className="w-1.5 h-4 bg-[#D4642C] rounded-full" />
                    </div>
                  ) : (
                    <Play className="w-5 h-5 text-[#D4642C] ml-0.5" fill="#D4642C" />
                  )}
                </div>
              </div>

              {/* Bottom Overlay (badges + mute button) */}
              <div className="absolute bottom-0 left-0 right-0 p-5 bg-gradient-to-t from-black/75 to-transparent flex items-center justify-between">
                <div className="flex gap-2.5">
                  <div className="bg-white/95 backdrop-blur-md border border-white/60 shadow-xs px-3.5 py-1.5 rounded-xl flex items-center justify-center cursor-default">
                    <img
                      src="https://upload.wikimedia.org/wikipedia/commons/f/fa/Apple_logo_black.svg"
                      alt="Apple"
                      className="h-3.5 w-auto"
                    />
                  </div>
                  <div className="bg-white/95 backdrop-blur-md border border-white/60 shadow-xs px-3.5 py-1.5 rounded-xl flex items-center justify-center cursor-default">
                    <img
                      src="/wallet-brands/google-g.svg"
                      alt="Google Wallet"
                      className="h-3.5 w-auto"
                    />
                  </div>
                </div>

                <button
                  onClick={toggleMute}
                  className="bg-white/95 backdrop-blur-md border border-white/60 shadow-xs hover:bg-white p-2.5 rounded-full flex items-center justify-center transition-all duration-300 group/audio"
                  title={isMuted ? "Unmute" : "Mute"}
                >
                  {isMuted ? (
                    <VolumeX className="w-4 h-4 text-stone-700" />
                  ) : (
                    <Volume2 className="w-4 h-4 text-[#D4642C]" />
                  )}
                </button>
              </div>
            </div>
          </div>
        </motion.div>
      </div>
    </section>
  );
}
