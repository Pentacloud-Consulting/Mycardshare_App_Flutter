"use client";

import { motion, useInView } from "framer-motion";
import { useRef } from "react";
import {
  Smartphone,
  Shield,
  BarChart3,
  Globe,
  Zap,
  Users,
  Share2,
  Palette,
  Scan,
  Database,
  Lock,
  Sparkles,
} from "lucide-react";

const FEATURES = [
  {
    icon: Smartphone,
    title: "Digital Identity Card",
    desc: "Stunning mobile-first card with QR code and custom link sharing.",
    color: "#D4642C",
    span: "col-span-1 md:col-span-2 lg:col-span-2",
  },
  {
    icon: Scan,
    title: "AI Card Scanner",
    desc: "Scan any physical business card with AI-powered OCR. Auto-imports to your vault.",
    color: "#D4642C",
    span: "col-span-1",
  },
  {
    icon: Database,
    title: "Contact Vault",
    desc: "Seamless contact management. Tags, notes, search, and CSV export.",
    color: "#E87A43",
    span: "col-span-1",
  },
  {
    icon: BarChart3,
    title: "Live Analytics",
    desc: "Track views, taps, saves, and geographical reach in real-time.",
    color: "#D4642C",
    span: "col-span-1",
  },
  {
    icon: Users,
    title: "Enterprise Portal",
    desc: "Deploy branded cards across your entire team with admin approvals.",
    color: "#F59E0B",
    span: "col-span-1",
  },
  {
    icon: Lock,
    title: "Enterprise Security",
    desc: "256-bit AES encryption and robust data protection for peace of mind.",
    color: "#D4642C",
    span: "col-span-1 md:col-span-2 lg:col-span-2",
  },
  {
    icon: Palette,
    title: "Custom Themes",
    desc: "Choose from curated luxury themes or match your exact corporate palette.",
    color: "#E87A43",
    span: "col-span-1",
  },
  {
    icon: Share2,
    title: "One-Tap Share",
    desc: "NFC, QR, web link, Apple Wallet, Google Wallet — share effortlessly.",
    color: "#D4642C",
    span: "col-span-1",
  },
];

function FeatureCard({ icon: Icon, title, desc, color, span, index }) {
  const ref = useRef(null);
  const inView = useInView(ref, {
    once: true,
    margin: "-60px",
  });

  return (
    <motion.div
      ref={ref}
      initial={{ opacity: 0, y: 25 }}
      animate={inView ? { opacity: 1, y: 0 } : {}}
      transition={{
        delay: index * 0.06,
        duration: 0.6,
        ease: [0.16, 1, 0.3, 1],
      }}
      className={`${span} group relative rounded-[24px] p-6 sm:p-7 cursor-pointer transition-all duration-400 hover:border-[#D4642C]/40 hover:shadow-[0_12px_30px_rgba(212,100,44,0.07)] bg-white border border-[#EFE8E1] shadow-xs`}
    >
      {/* Hover Warm Glow */}
      <div
        className="absolute inset-0 rounded-[24px] opacity-0 group-hover:opacity-100 transition-opacity duration-400 pointer-events-none"
        style={{
          background: `radial-gradient(circle at 30% 30%, rgba(212,100,44,0.06), transparent 70%)`,
        }}
      />

      <div className="relative z-10">
        {/* Icon container */}
        <div className="w-11 h-11 rounded-xl flex items-center justify-center mb-4 bg-[#FAF6F2] border border-[#EFE8E1] group-hover:bg-white group-hover:border-[#D4642C]/30 transition-all duration-300">
          <Icon size={20} className="text-[#D4642C] transition-colors" />
        </div>

        {/* Title */}
        <h3
          className="text-base sm:text-lg font-bold text-[#18181B] mb-2 tracking-tight"
          style={{ fontFamily: "var(--font-display)" }}
        >
          {title}
        </h3>

        {/* Description */}
        <p className="text-xs sm:text-[13px] leading-relaxed text-stone-500 font-normal">
          {desc}
        </p>
      </div>
    </motion.div>
  );
}

export default function Features() {
  const sectionRef = useRef(null);
  const inView = useInView(sectionRef, { once: true, margin: "-80px" });

  return (
    <section className="relative py-20 sm:py-28 bg-white">
      <div className="max-w-7xl mx-auto px-6">
        {/* Header */}
        <motion.div
          ref={sectionRef}
          initial={{ opacity: 0, y: 25 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="text-center mb-14 sm:mb-18"
        >
          <div className="inline-flex items-center gap-2 px-3.5 py-1 rounded-full text-xs font-bold uppercase tracking-widest mb-4 bg-[#FAF6F2] border border-[#EFE8E1] text-[#D4642C]">
            <Sparkles size={13} className="text-[#D4642C]" />
            Platform Capabilities
          </div>

          <h2
            className="text-3xl sm:text-4xl md:text-5xl font-black text-[#18181B] mb-4 tracking-tight"
            style={{ fontFamily: "var(--font-display)" }}
          >
            Everything You Need to{" "}
            <span className="text-[#D4642C]">Dominate Your Network</span>
          </h2>

          <p className="text-base sm:text-lg text-stone-500 max-w-xl mx-auto leading-relaxed">
            A complete professional identity platform. From instantaneous card
            creation to enterprise-wide workforce rollout.
          </p>
        </motion.div>

        {/* Bento Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-5">
          {FEATURES.map((f, i) => (
            <FeatureCard key={f.title} {...f} index={i} />
          ))}
        </div>
      </div>
    </section>
  );
}
