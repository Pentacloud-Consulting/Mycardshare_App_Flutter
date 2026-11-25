"use client";

import { motion, useInView } from "framer-motion";
import { useRef } from "react";
import Link from "next/link";
import { Zap, ArrowRight, Sparkles } from "lucide-react";
import { UiloraBrandButton } from "../UIComponents/Button/tsx/UiloraModernButtons";

export default function CTA() {
  const ref = useRef(null);
  const inView = useInView(ref, { once: true, margin: "-80px" });

  return (
    <section className="relative py-20 md:py-28 overflow-hidden bg-[#FAF6F2]">
      {/* Background warm ambient glow */}
      <div className="absolute inset-0 pointer-events-none overflow-hidden">
        <div
          className="absolute w-[600px] h-[600px] rounded-full top-0 left-1/2 -translate-x-1/2"
          style={{
            background:
              "radial-gradient(circle, rgba(212,100,44,0.12), transparent 65%)",
            filter: "blur(100px)",
          }}
        />
      </div>

      <motion.div
        ref={ref}
        initial={{ opacity: 0, y: 35, scale: 0.97 }}
        animate={inView ? { opacity: 1, y: 0, scale: 1 } : {}}
        transition={{ duration: 0.8, ease: [0.16, 1, 0.3, 1] }}
        className="relative z-10 max-w-4xl mx-auto px-6"
      >
        {/* Luxury Card Container */}
        <div className="text-center rounded-[36px] p-8 sm:p-14 md:p-16 relative overflow-hidden bg-white border border-[#EFE8E1] shadow-[0_25px_60px_rgba(212,100,44,0.08)]">
          <div
            className="absolute inset-0 pointer-events-none"
            style={{
              background:
                "radial-gradient(circle at 50% 0%, rgba(212,100,44,0.06), transparent 70%)",
            }}
          />

          <div className="relative z-10">
            {/* Tag */}
            <div className="inline-flex items-center gap-2 px-3.5 py-1 rounded-full text-xs font-bold uppercase tracking-widest mb-6 bg-[#FAF6F2] border border-[#EFE8E1] text-[#D4642C]">
              <Sparkles size={13} className="text-[#D4642C]" /> Get Started in
              Seconds
            </div>

            {/* Heading */}
            <h2
              className="text-3xl sm:text-4xl md:text-5xl font-black tracking-tight mb-4 text-[#18181B] leading-tight"
              style={{
                fontFamily: "var(--font-display)",
              }}
            >
              Ready to Upgrade
              <br />
              <span className="text-[#D4642C]">Your Professional Identity?</span>
            </h2>

            {/* Description */}
            <p className="text-base sm:text-lg max-w-xl mx-auto mb-10 text-stone-500 leading-relaxed font-normal">
              Create your shareable digital business card in under 30 seconds.
              Engineered for ambitious professionals and high-performance teams.
            </p>

            {/* Buttons */}
            <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
              <Link href="/signup">
                <UiloraBrandButton className="w-full sm:w-auto text-sm px-9 py-4 font-bold normal-case">
                  <Zap size={18} />
                  Create Your Card — Free
                </UiloraBrandButton>
              </Link>

              <Link
                href="/contact"
                className="flex items-center gap-2 text-sm font-bold text-[#D4642C] hover:text-[#BD5523] transition-colors px-6 py-3"
              >
                Talk to Enterprise Sales <ArrowRight size={15} />
              </Link>
            </div>

            {/* Trust line */}
            <p className="text-xs mt-8 text-stone-400 font-medium">
              No credit card required · Free forever for individuals ·
              Enterprise volume plans available
            </p>
          </div>
        </div>
      </motion.div>
    </section>
  );
}
