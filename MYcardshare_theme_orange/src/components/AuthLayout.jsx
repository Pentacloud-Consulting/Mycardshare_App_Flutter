"use client";

import Link from "next/link";
import { motion } from "framer-motion";

/* ═══════════════════════════════════════════════════════════
   AUTH LAYOUT — UILORA Split Panel
   Left: Branding · Right: Form · Aurora decorations
   ═══════════════════════════════════════════════════════════ */

const fadeUp = (d = 0) => ({
  hidden: { opacity: 0, y: 20 },
  visible: {
    opacity: 1,
    y: 0,
    transition: { delay: d, duration: 0.6, ease: [0.16, 1, 0.3, 1] },
  },
});

export default function AuthLayout({ children }) {
  return (
    <div
      className="min-h-[100dvh] flex flex-col lg:flex-row relative overflow-hidden"
      style={{ background: "#FAF6F2" }}
    >
      {/* ── Left Branding Panel ─── */}
      <motion.div
        initial={{ opacity: 0, x: -40 }}
        animate={{ opacity: 1, x: 0 }}
        transition={{ duration: 0.7, ease: [0.16, 1, 0.3, 1] }}
        className="hidden lg:flex lg:w-1/2 relative flex-col justify-center items-center p-16 overflow-hidden bg-white/70 backdrop-blur-xl border-r border-[#EFE8E1]"
      >
        {/* Subtle Warm Orange Glows */}
        <div className="absolute inset-0 pointer-events-none overflow-hidden">
          <div
            className="absolute w-[500px] h-[500px] rounded-full -top-32 -left-32"
            style={{
              background:
                "radial-gradient(circle, rgba(212,100,44,0.12), transparent 70%)",
              filter: "blur(90px)",
            }}
          />
          <div
            className="absolute w-[400px] h-[400px] rounded-full bottom-0 right-0"
            style={{
              background:
                "radial-gradient(circle, rgba(245,158,11,0.08), transparent 70%)",
              filter: "blur(80px)",
            }}
          />
        </div>

        {/* Grid overlay */}
        <div
          className="absolute inset-0 pointer-events-none"
          style={{
            backgroundImage:
              "linear-gradient(rgba(212,100,44,0.03) 1px, transparent 1px), linear-gradient(90deg, rgba(212,100,44,0.03) 1px, transparent 1px)",
            backgroundSize: "48px 48px",
          }}
        />

        <div className="relative z-10 max-w-md">
          {/* Logo */}
          <motion.div
            variants={fadeUp(0.1)}
            initial="hidden"
            animate="visible"
            className="flex items-center mb-10"
          >
            <img
              src="/logo/image (4).png"
              alt="Logo"
              className="w-48 h-auto object-contain origin-left"
            />
          </motion.div>

          {/* Headline */}
          <motion.h1
            variants={fadeUp(0.2)}
            initial="hidden"
            animate="visible"
            className="text-4xl font-black tracking-tight mb-4 text-[#18181B]"
            style={{
              fontFamily: "var(--font-display)",
              letterSpacing: "-0.04em",
              lineHeight: 1.1,
            }}
          >
            Your Digital
            <br />
            Identity, <span className="text-[#D4642C]">Elevated.</span>
          </motion.h1>

          <motion.p
            variants={fadeUp(0.3)}
            initial="hidden"
            animate="visible"
            className="text-base mb-10 leading-relaxed text-[#78716C]"
          >
            The professional networking platform built for the modern era. NFC,
            QR, and cloud-synced — all in one card.
          </motion.p>

          {/* Stats */}
          <motion.div
            variants={fadeUp(0.4)}
            initial="hidden"
            animate="visible"
            className="grid grid-cols-2 gap-3"
          >
            {[
              { val: "Instant", label: "QR & link sharing" },
              { val: "Paperless", label: "Eco-friendly networking" },
              { val: "256-bit", label: "Encryption standard" },
              { val: "UAE", label: "Based & trusted" },
            ].map(({ val, label }) => (
              <div
                key={label}
                className="rounded-2xl p-4 bg-[#FAF6F2] border border-[#EFE8E1] transition-all hover:border-[#D4642C]/30"
              >
                <div
                  className="text-xl font-black text-[#D4642C]"
                  style={{ fontFamily: "var(--font-display)" }}
                >
                  {val}
                </div>
                <div
                  className="text-xs mt-1 text-[#78716C]"
                >
                  {label}
                </div>
              </div>
            ))}
          </motion.div>

          {/* Trust bar */}
          <motion.div
            variants={fadeUp(0.5)}
            initial="hidden"
            animate="visible"
            className="flex flex-wrap gap-4 mt-8"
          >
            {["QR Code", "Cloud Sync", "SSL Secure"].map((t) => (
              <span
                key={t}
                className="text-[11px] font-semibold tracking-wider uppercase text-[#A8A29E]"
              >
                {t}
              </span>
            ))}
          </motion.div>
        </div>
      </motion.div>

      {/* ── Right Form Panel ─── */}
      <motion.div
        initial={{ opacity: 0, x: 40 }}
        animate={{ opacity: 1, x: 0 }}
        transition={{ duration: 0.7, ease: [0.16, 1, 0.3, 1], delay: 0.1 }}
        className="flex-1 flex items-center justify-center p-6 md:p-12 min-h-[100dvh] lg:min-h-0 bg-[#FAF6F2]"
      >
        <div className="w-full max-w-md bg-white rounded-3xl p-8 md:p-10 border border-[#EFE8E1] shadow-[0_20px_50px_rgba(212,100,44,0.06)]">
          {/* Mobile logo */}
          <Link href="/" className="lg:hidden flex items-center mb-8">
            <img
              src="/logo/image (4).png"
              alt="Logo"
              className="w-40 h-auto object-contain origin-left"
            />
          </Link>
          {children}
        </div>
      </motion.div>
    </div>
  );
}
