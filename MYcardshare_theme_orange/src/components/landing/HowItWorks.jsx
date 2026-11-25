"use client";

import { motion, useInView } from "framer-motion";
import { useRef } from "react";
import { Scan, Palette, Share2, BarChart3 } from "lucide-react";

/* ═══════════════════════════════════════════════════════════
   HOW IT WORKS — UILORA Scroll Reveal Steps
   ═══════════════════════════════════════════════════════════ */

const STEPS = [
  {
    num: "01",
    icon: Palette,
    title: "Create Your Card",
    desc: "Sign up in 30 seconds. Choose a premium theme, upload your photo, add your details. Your digital identity is live instantly.",
    color: "#6366f1",
  },
  {
    num: "02",
    icon: Share2,
    title: "Share Anywhere",
    desc: "Scan QR, share a link, AirDrop — your card works everywhere. One identity, infinite touchpoints.",
    color: "#06b6d4",
  },
  {
    num: "03",
    icon: Scan,
    title: "Scan & Save",
    desc: "Use AI-powered OCR to scan paper business cards. They're auto-imported to your contact vault with all details extracted.",
    color: "#a78bfa",
  },
  {
    num: "04",
    icon: BarChart3,
    title: "Track & Grow",
    desc: "Monitor who viewed your card, where, and when. Get insights to optimize your professional reach and conversion.",
    color: "#10d9a8",
  },
];

function Step({ num, icon: Icon, title, desc, color, index }) {
  const ref = useRef(null);
  const inView = useInView(ref, { once: true, margin: "-80px" });

  return (
    <motion.div
      ref={ref}
      initial={{ opacity: 0, x: index % 2 === 0 ? -40 : 40 }}
      animate={inView ? { opacity: 1, x: 0 } : {}}
      transition={{ delay: 0.1, duration: 0.7, ease: [0.16, 1, 0.3, 1] }}
      className="relative flex gap-6 md:gap-8"
    >
      {/* Timeline line */}
      <div className="flex flex-col items-center">
        <div
          className="w-14 h-14 rounded-2xl flex items-center justify-center shrink-0 text-xl font-black"
          style={{
            background: `${color}15`,
            color,
            fontFamily: "var(--font-display)",
          }}
        >
          {num}
        </div>
        {index < STEPS.length - 1 && (
          <div
            className="w-px flex-1 mt-4"
            style={{
              background: `linear-gradient(to bottom, ${color}40, transparent)`,
            }}
          />
        )}
      </div>

      {/* Content */}
      <div className="pb-14">
        <div className="flex items-center gap-3 mb-3">
          <Icon size={18} style={{ color }} />
          <h3
            className="text-xl font-bold text-slate-800"
            style={{ fontFamily: "var(--font-display)" }}
          >
            {title}
          </h3>
        </div>
        <p
          className="text-sm leading-relaxed max-w-md"
          style={{ color: "var(--color-muted)" }}
        >
          {desc}
        </p>
      </div>
    </motion.div>
  );
}

export default function HowItWorks() {
  const ref = useRef(null);
  const inView = useInView(ref, { once: true, margin: "-100px" });

  return (
    <section
      className="relative py-24 md:py-32"
      style={{ background: "var(--color-aurora-surface)" }}
    >
      {/* Subtle aurora */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div
          className="absolute w-[500px] h-[500px] rounded-full top-1/4 right-0"
          style={{
            background:
              "radial-gradient(circle, rgba(6,182,212,0.08), transparent 70%)",
            filter: "blur(80px)",
          }}
        />
      </div>

      <div className="relative z-10 max-w-3xl mx-auto px-6">
        <motion.div
          ref={ref}
          initial={{ opacity: 0, y: 30 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          className="text-center mb-16"
        >
          <div
            className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full text-xs font-bold uppercase tracking-[0.15em] mb-4"
            style={{
              background: "rgba(6,182,212,0.1)",
              border: "1px solid rgba(6,182,212,0.2)",
              color: "#22d3ee",
            }}
          >
            How It Works
          </div>
          <h2 className="text-gradient mb-4">Four Steps to Digital Identity</h2>
          <p className="text-base" style={{ color: "var(--color-muted)" }}>
            From zero to a fully connected professional presence in under a
            minute.
          </p>
        </motion.div>

        <div className="flex flex-col">
          {STEPS.map((step, i) => (
            <Step key={step.num} {...step} index={i} />
          ))}
        </div>
      </div>
    </section>
  );
}
