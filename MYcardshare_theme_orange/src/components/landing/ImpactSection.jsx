"use client";

import { motion, useInView, useMotionValue, useTransform, animate } from "framer-motion";
import { useRef, useEffect, useState } from "react";
import {
  QrCode,
  Share2,
  ShieldCheck,
  Workflow,
  Bot,
  LineChart,
} from "lucide-react";

/* ═══════════════════════════════════════════════════════════
   BENTO GRID DATA (Asymmetric Layout) - Warm Cream & Orange Theme
   ═══════════════════════════════════════════════════════════ */
const bentoItems = [
  {
    num: "01",
    title: "Dynamic QR",
    desc: "Real-time updates ensure every shared profile stays current across all devices instantly.",
    icon: <QrCode size={28} />,
    colSpan: "col-span-1 lg:col-span-4",
    badge: "LIVE UPDATES",
    action: "SCAN TO VIEW",
    gradient: "from-[#D4642C] to-[#E87A43]",
    textHighlight: "text-[#D4642C]",
    bgHighlight: "bg-[#D4642C]/10 border-[#D4642C]/20",
  },
  {
    num: "02",
    title: "CRM Sync",
    desc: "Automatically route leads to Salesforce & HubSpot without manual data entry.",
    icon: <Workflow size={28} />,
    colSpan: "col-span-1 lg:col-span-2",
    badge: "AUTOMATED",
    action: "CONNECT CRM",
    gradient: "from-[#E87A43] to-[#F59E0B]",
    textHighlight: "text-[#D4642C]",
    bgHighlight: "bg-[#D4642C]/10 border-[#D4642C]/20",
  },
  {
    num: "03",
    title: "Secure Identity",
    desc: "Bank-level encryption protecting your entire digital identity and contact vault.",
    icon: <ShieldCheck size={28} />,
    colSpan: "col-span-1 lg:col-span-2",
    badge: "ENCRYPTED",
    action: "VIEW SECURITY",
    gradient: "from-[#D4642C] to-[#A44617]",
    textHighlight: "text-[#D4642C]",
    bgHighlight: "bg-[#D4642C]/10 border-[#D4642C]/20",
  },
  {
    num: "04",
    title: "Live Analytics",
    desc: "Track engagement, total scans, and conversion rates in a real-time command center.",
    icon: <LineChart size={28} />,
    colSpan: "col-span-1 lg:col-span-4",
    badge: "REAL-TIME",
    action: "VIEW METRICS",
    gradient: "from-[#D4642C] to-[#E87A43]",
    textHighlight: "text-[#D4642C]",
    bgHighlight: "bg-[#D4642C]/10 border-[#D4642C]/20",
  },
  {
    num: "05",
    title: "AI Follow-Up",
    desc: "Intelligent contextual reminders to reconnect exactly when it matters most.",
    icon: <Bot size={28} />,
    colSpan: "col-span-1 lg:col-span-3",
    badge: "SMART AI",
    action: "ENABLE AI",
    gradient: "from-[#E87A43] to-[#F59E0B]",
    textHighlight: "text-[#D4642C]",
    bgHighlight: "bg-[#D4642C]/10 border-[#D4642C]/20",
  },
  {
    num: "06",
    title: "Smart Networking",
    desc: "Transform single interactions into powerful, interconnected business ecosystems.",
    icon: <Share2 size={28} />,
    colSpan: "col-span-1 lg:col-span-3",
    badge: "ECOSYSTEM",
    action: "BUILD NETWORK",
    gradient: "from-[#D4642C] to-[#A44617]",
    textHighlight: "text-[#D4642C]",
    bgHighlight: "bg-[#D4642C]/10 border-[#D4642C]/20",
  },
];

/* ═══════════════════════════════════════════════════════════
   3D BENTO CARD COMPONENT
   ═══════════════════════════════════════════════════════════ */
const BentoCard = ({ item, index }) => {
  const cardRef = useRef(null);
  const inView = useInView(cardRef, { once: true, margin: "-40px" });

  const x = useMotionValue(0);
  const y = useMotionValue(0);

  const rotateX = useTransform(y, [-150, 150], [3, -3]);
  const rotateY = useTransform(x, [-150, 150], [-3, 3]);

  function handleMouse(event) {
    if (!cardRef.current) return;
    const rect = cardRef.current.getBoundingClientRect();
    x.set(event.clientX - rect.left - rect.width / 2);
    y.set(event.clientY - rect.top - rect.height / 2);
  }

  function handleMouseLeave() {
    x.set(0);
    y.set(0);
  }

  return (
    <motion.div
      ref={cardRef}
      initial={{ opacity: 0, scale: 0.95, y: 50 }}
      animate={inView ? { opacity: 1, scale: 1, y: 0 } : {}}
      transition={{
        type: "spring",
        stiffness: 240,
        damping: 22,
        delay: index * 0.08,
      }}
      className={`${item.colSpan} relative group perspective-1000`}
    >
      <motion.div
        onMouseMove={handleMouse}
        onMouseLeave={handleMouseLeave}
        style={{ rotateX, rotateY }}
        whileHover={{ scale: 1.02, y: -6 }}
        transition={{ type: "spring", stiffness: 240, damping: 20 }}
        className="w-full h-full relative"
      >
        {/* Animated Gradient Border Layer (Visible on Hover) */}
        <div
          className={`absolute -inset-[1px] bg-gradient-to-r ${item.gradient} rounded-[24px] opacity-0 group-hover:opacity-100 blur-[2px] transition-opacity duration-500`}
        />

        {/* Ambient Glow Behind Card */}
        <div
          className={`absolute -inset-2 bg-gradient-to-r ${item.gradient} rounded-[24px] opacity-0 group-hover:opacity-15 blur-xl transition-opacity duration-500`}
        />

        {/* Main Light Glass Card */}
        <div className="relative h-full bg-white border border-[#EFE8E1] rounded-[22px] p-6 sm:p-7 shadow-[0_4px_20px_rgba(0,0,0,0.03)] flex flex-col justify-between overflow-hidden group-hover:shadow-[0_15px_35px_rgba(212,100,44,0.08)] group-hover:border-[#D4642C]/30 transition-all duration-400">
          {/* Subtle Warm Background Accent on hover */}
          <div
            className={`absolute -top-24 -right-24 w-36 h-36 bg-gradient-to-br ${item.gradient} opacity-0 group-hover:opacity-10 blur-2xl transition-opacity duration-500 pointer-events-none`}
          />

          {/* Top Row: Num & Badge */}
          <div className="flex justify-between items-start mb-6 relative z-10">
            <span className="text-stone-300 font-mono text-xs font-bold tracking-widest group-hover:text-[#D4642C] transition-colors duration-300">
              {item.num}
            </span>
            <div className="px-2.5 py-1 rounded-full bg-[#FAF6F2] border border-[#EFE8E1] text-[9px] font-bold text-stone-600 tracking-wider uppercase shadow-xs flex items-center justify-center">
              <span className="w-1.5 h-1.5 rounded-full bg-[#D4642C] mr-1.5 animate-pulse" />
              {item.badge}
            </div>
          </div>

          {/* Bottom Content Area */}
          <div className="relative z-10 mt-auto">
            <motion.div
              className={`w-12 h-12 rounded-2xl ${item.bgHighlight} flex items-center justify-center mb-4 shadow-xs transition-all duration-300`}
              whileHover={{ rotate: 6, scale: 1.05 }}
            >
              <div className={item.textHighlight}>{item.icon}</div>
            </motion.div>

            <h3
              className="text-xl font-black text-[#18181B] tracking-tight mb-2"
              style={{ fontFamily: "var(--font-display)" }}
            >
              {item.title}
            </h3>

            <p className="text-stone-500 text-sm leading-relaxed font-normal mb-5">
              {item.desc}
            </p>

            {/* Slide-Up Action Label */}
            <div className="overflow-hidden h-5 mt-auto">
              <div className="flex items-center gap-2 text-[10px] font-bold tracking-widest uppercase text-stone-400 transform translate-y-5 group-hover:translate-y-0 transition-transform duration-300 ease-out group-hover:text-[#D4642C]">
                <span className="w-4 h-[2px] bg-[#D4642C]" />
                {item.action}
              </div>
            </div>
          </div>
        </div>
      </motion.div>
    </motion.div>
  );
};

/* ═══════════════════════════════════════════════════════════
   MAIN IMPACT SECTION COMPONENT
   ═══════════════════════════════════════════════════════════ */
export default function ImpactSection() {
  const sectionRef = useRef(null);
  const inView = useInView(sectionRef, { once: true, margin: "-80px" });

  return (
    <section
      ref={sectionRef}
      className="relative w-full py-24 sm:py-32 overflow-hidden bg-white"
    >
      {/* ─── Ambient Environment ─── */}
      <div className="absolute inset-0 pointer-events-none overflow-hidden">
        {/* Soft Warm Radial Glow */}
        <div className="absolute w-[700px] h-[700px] rounded-full top-0 left-1/2 -translate-x-1/2 -translate-y-[20%] bg-[radial-gradient(circle,rgba(212,100,44,0.06),transparent_70%)] blur-[90px]" />
        <div className="absolute w-[800px] h-[800px] rounded-full bottom-0 left-1/2 -translate-x-1/2 translate-y-[30%] bg-[radial-gradient(circle,rgba(245,158,11,0.04),transparent_70%)] blur-[120px]" />
      </div>

      <div className="relative z-10 w-full max-w-7xl mx-auto px-6">
        {/* ─── Section Header ─── */}
        <div className="text-center mb-16 sm:mb-24">
          <div className="inline-flex items-center gap-2 px-3.5 py-1 rounded-full mb-4 text-xs font-bold tracking-widest uppercase bg-[#FAF6F2] border border-[#EFE8E1] text-[#D4642C]">
            Performance & Impact
          </div>
          <h2
            className="text-3xl sm:text-4xl md:text-5xl lg:text-6xl font-black tracking-tight leading-tight mb-5"
            style={{ fontFamily: "var(--font-display)" }}
          >
            <span className="text-[#18181B] block">ENGINEERED FOR</span>
            <span className="text-transparent bg-clip-text bg-gradient-to-r from-[#D4642C] via-[#E87A43] to-[#F59E0B] block">
              MAXIMUM IMPACT
            </span>
          </h2>

          <motion.p
            initial={{ opacity: 0 }}
            animate={inView ? { opacity: 1 } : {}}
            transition={{ duration: 0.8, delay: 0.3 }}
            className="text-stone-500 text-base sm:text-lg md:text-xl font-normal max-w-2xl mx-auto leading-relaxed"
          >
            We don't just build digital cards. We engineer professional
            ecosystems designed to multiply your growth and secure your network.
          </motion.p>
        </div>

        {/* ─── Asymmetric Bento Grid ─── */}
        <div className="grid grid-cols-1 md:grid-cols-6 gap-5 sm:gap-6 lg:gap-7">
          {bentoItems.map((item, i) => (
            <BentoCard key={item.title} item={item} index={i} />
          ))}
        </div>
      </div>
    </section>
  );
}
