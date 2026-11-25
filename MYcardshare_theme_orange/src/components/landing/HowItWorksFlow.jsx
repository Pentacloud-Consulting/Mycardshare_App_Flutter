"use client";

import { motion, useInView, useScroll, useTransform } from "framer-motion";
import { useRef } from "react";
import {
  Globe,
  QrCode,
  Nfc,
  Link2,
  Zap,
  UserCircle,
  ArrowRightLeft,
  Target,
  CloudCog,
  Sparkles,
  Rocket,
  CheckCircle2,
} from "lucide-react";

/* ═══════════════════════════════════════════════════════════
   ORBITING SATELLITE CIRCLE - LUXURY WARM PALETTE
   ═══════════════════════════════════════════════════════════ */
const OrbitingFeatureCircle = ({
  title,
  subtitle,
  icon: Icon,
  angle,
  color,
  duration = 40,
}) => {
  const theme = {
    orange: {
      border: "border-[#D4642C]/40 hover:border-[#D4642C]",
      glow: "shadow-[0_10px_30px_rgba(212,100,44,0.18)]",
      text: "text-stone-500",
      icon: "text-[#D4642C]",
      bg: "bg-white",
      stemGrad: "from-transparent to-[#D4642C]",
      particle: "shadow-[0_0_12px_#D4642C] bg-[#D4642C]",
      aura: "bg-[#D4642C]/15",
    },
    amber: {
      border: "border-[#E87A43]/40 hover:border-[#E87A43]",
      glow: "shadow-[0_10px_30px_rgba(232,122,67,0.18)]",
      text: "text-stone-500",
      icon: "text-[#E87A43]",
      bg: "bg-white",
      stemGrad: "from-transparent to-[#E87A43]",
      particle: "shadow-[0_0_12px_#E87A43] bg-[#E87A43]",
      aura: "bg-[#E87A43]/15",
    },
    terracotta: {
      border: "border-[#F59E0B]/40 hover:border-[#F59E0B]",
      glow: "shadow-[0_10px_30px_rgba(245,158,11,0.18)]",
      text: "text-stone-500",
      icon: "text-[#F59E0B]",
      bg: "bg-white",
      stemGrad: "from-transparent to-[#F59E0B]",
      particle: "shadow-[0_0_12px_#F59E0B] bg-[#F59E0B]",
      aura: "bg-[#F59E0B]/15",
    },
  }[color];

  return (
    <div className="absolute top-1/2 left-1/2 w-0 h-0 z-30">
      <motion.div
        className="absolute inset-0"
        animate={{ rotate: [angle, angle + 360] }}
        transition={{ repeat: Infinity, duration, ease: "linear" }}
      >
        <div
          className={`absolute top-[-160px] left-1/2 w-[2px] h-[50px] -translate-x-1/2 opacity-70 bg-gradient-to-b ${theme.stemGrad}`}
        />
        <div
          className={`absolute top-[-110px] left-1/2 w-2.5 h-2.5 rounded-full -translate-x-1/2 -translate-y-1/2 animate-pulse ${theme.particle}`}
        />

        <motion.div
          className="absolute"
          style={{ top: -240, left: 0 }}
          animate={{ rotate: [-angle, -(angle + 360)] }}
          transition={{ repeat: Infinity, duration, ease: "linear" }}
        >
          <div className="absolute -translate-x-1/2 -translate-y-1/2">
            <div
              className={`absolute inset-[-15px] rounded-full blur-[25px] ${theme.aura} pointer-events-none`}
            />

            <div
              className={`relative w-[155px] h-[155px] rounded-full backdrop-blur-xl border flex flex-col items-center justify-center p-4 transition-all duration-400 hover:scale-105 cursor-default group overflow-hidden ${theme.bg} ${theme.border} ${theme.glow}`}
            >
              <div className="w-10 h-10 rounded-full bg-[#FAF6F2] flex items-center justify-center mb-2 shadow-xs">
                <Icon
                  size={20}
                  className={`transition-transform duration-300 group-hover:scale-110 ${theme.icon}`}
                />
              </div>
              <span
                className="text-[#18181B] font-extrabold text-[14px] tracking-tight mb-0.5 text-center leading-tight"
                style={{ fontFamily: "var(--font-display)" }}
              >
                {title}
              </span>
              <span
                className={`font-semibold text-[10px] text-center leading-tight px-2 ${theme.text}`}
              >
                {subtitle}
              </span>
            </div>
          </div>
        </motion.div>
      </motion.div>
    </div>
  );
};

/* ═══════════════════════════════════════════════════════════
   TIMELINE CARD COMPONENT
   ═══════════════════════════════════════════════════════════ */
const TimelineCard = ({
  icon: Icon,
  title,
  desc,
  badge,
  align = "left",
  delay = 0,
}) => {
  const ref = useRef(null);
  const inView = useInView(ref, { once: true, margin: "-60px" });

  return (
    <div
      ref={ref}
      className={`flex w-full ${
        align === "left" ? "justify-start" : "justify-end"
      } mb-12 sm:mb-16 relative`}
    >
      {/* Central Node Indicator */}
      <div
        className={`absolute top-1/2 -translate-y-1/2 w-3 h-3 rounded-full bg-[#D4642C] shadow-[0_0_12px_rgba(212,100,44,0.6)] z-20 hidden sm:block ${
          align === "left" ? "right-[calc(50%-6px)]" : "left-[calc(50%-6px)]"
        }`}
      />

      <motion.div
        initial={{ opacity: 0, x: align === "left" ? -40 : 40, y: 20 }}
        animate={inView ? { opacity: 1, x: 0, y: 0 } : {}}
        transition={{ duration: 0.7, delay, ease: [0.16, 1, 0.3, 1] }}
        className={`w-full sm:w-[calc(50%-2rem)] relative z-10 flex ${
          align === "left" ? "justify-end sm:pr-8" : "justify-start sm:pl-8"
        }`}
      >
        <div className="group relative w-full max-w-[370px]">
          {/* Hover Border Glow */}
          <div className="absolute -inset-[1px] bg-gradient-to-r from-[#D4642C] to-[#F59E0B] rounded-[24px] opacity-0 group-hover:opacity-100 blur-[2px] transition-opacity duration-400" />

          <div className="relative bg-white border border-[#EFE8E1] rounded-[24px] p-6 sm:p-7 shadow-[0_4px_20px_rgba(0,0,0,0.03)] flex flex-col justify-center overflow-hidden transition-all duration-300 group-hover:-translate-y-1 group-hover:shadow-[0_15px_30px_rgba(212,100,44,0.08)]">
            {badge && (
              <div className="absolute top-5 right-5 px-2.5 py-0.5 rounded-full bg-[#FAF6F2] border border-[#EFE8E1] text-[9px] font-bold text-[#D4642C] tracking-widest uppercase">
                {badge}
              </div>
            )}

            <div className="relative z-10">
              <div className="w-11 h-11 rounded-xl bg-[#FAF6F2] border border-[#EFE8E1] flex items-center justify-center text-[#D4642C] mb-3.5 group-hover:bg-[#D4642C] group-hover:text-white transition-all duration-300 shadow-xs">
                <Icon size={22} />
              </div>
              <h4
                className="text-[#18181B] font-bold text-lg tracking-tight mb-2"
                style={{ fontFamily: "var(--font-display)" }}
              >
                {title}
              </h4>
              <p className="text-stone-500 text-xs sm:text-[13px] leading-relaxed font-normal">
                {desc}
              </p>
            </div>
          </div>
        </div>
      </motion.div>
    </div>
  );
};

/* ═══════════════════════════════════════════════════════════
   SUCCESS CAPSTONE
   ═══════════════════════════════════════════════════════════ */
const SuccessCapstone = () => {
  const ref = useRef(null);
  const inView = useInView(ref, { once: true, margin: "-80px" });

  return (
    <div
      ref={ref}
      className="w-full flex justify-center mt-8 relative z-20 pb-16"
    >
      <motion.div
        initial={{ opacity: 0, y: 30 }}
        animate={inView ? { opacity: 1, y: 0 } : {}}
        transition={{ duration: 0.7, delay: 0.2, ease: [0.16, 1, 0.3, 1] }}
        className="group relative w-full max-w-[580px]"
      >
        <div className="absolute -inset-[2px] bg-gradient-to-r from-[#D4642C] via-[#E87A43] to-[#F59E0B] rounded-[30px] opacity-25 group-hover:opacity-100 blur-md transition-opacity duration-500" />

        <div className="relative bg-white border border-[#EFE8E1] rounded-[28px] p-8 sm:p-10 shadow-[0_20px_50px_rgba(212,100,44,0.1)] flex flex-col items-center text-center overflow-hidden transition-all duration-300 group-hover:-translate-y-1">
          <div className="w-14 h-14 rounded-2xl bg-[#D4642C] flex items-center justify-center text-white mb-5 shadow-[0_10px_25px_rgba(212,100,44,0.4)]">
            <Rocket size={28} />
          </div>

          <h3
            className="text-2xl sm:text-3xl font-black text-[#18181B] mb-3 tracking-tight"
            style={{ fontFamily: "var(--font-display)" }}
          >
            Continuous Business Growth
          </h3>
          <p className="text-stone-500 text-sm max-w-sm mx-auto leading-relaxed">
            Transform every single digital handshake into measurable, long-term
            business opportunities and lasting relationships.
          </p>
        </div>
      </motion.div>
    </div>
  );
};

/* ═══════════════════════════════════════════════════════════
   MAIN COMPONENT
   ═══════════════════════════════════════════════════════════ */
export default function HowItWorksFlow() {
  const containerRef = useRef(null);
  const { scrollYProgress } = useScroll({
    target: containerRef,
    offset: ["start end", "end start"],
  });

  const beamHeight = useTransform(scrollYProgress, [0.1, 0.9], ["0%", "100%"]);

  return (
    <section
      ref={containerRef}
      className="relative w-full pt-24 sm:pt-32 overflow-hidden bg-[#FAF6F2]"
    >
      {/* Background warm environment */}
      <div className="absolute inset-0 pointer-events-none overflow-hidden">
        <div className="absolute w-[900px] h-[900px] rounded-full top-0 left-1/2 -translate-x-1/2 -translate-y-[40%] bg-[radial-gradient(circle,rgba(212,100,44,0.06),transparent_70%)] blur-[120px]" />
      </div>

      <div className="relative z-10 w-full max-w-6xl mx-auto px-6">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 25 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.8 }}
          className="text-center mb-16 sm:mb-24 relative z-20"
        >
          <div className="inline-flex items-center gap-2 px-3.5 py-1 rounded-full text-xs font-bold uppercase tracking-widest mb-4 bg-white border border-[#EFE8E1] text-[#D4642C] shadow-xs">
            <Sparkles size={13} className="text-[#D4642C]" />
            Connection Ecosystem
          </div>
          <h2
            className="text-3xl sm:text-4xl md:text-5xl font-black text-[#18181B] tracking-tight leading-tight mb-4"
            style={{ fontFamily: "var(--font-display)" }}
          >
            The Journey of Every{" "}
            <span className="text-[#D4642C]">Connection</span>
          </h2>
          <p className="text-base sm:text-lg text-stone-500 max-w-2xl mx-auto font-normal leading-relaxed">
            Every introduction is the beginning of a new opportunity. From
            sharing your digital card to converting relationships into contracts.
          </p>
        </motion.div>

        {/* Orbiting Ecosystem */}
        <div className="relative flex justify-center w-full max-w-[800px] mx-auto h-[320px] sm:h-[580px] mb-8 sm:mb-12 z-20">
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[700px] h-[700px] scale-[0.52] sm:scale-100 origin-center">
            {/* SVG Background Orbit Rings */}
            <svg
              className="absolute inset-0 w-full h-full z-0 pointer-events-none"
              viewBox="0 0 700 700"
            >
              <circle
                cx="350"
                cy="350"
                r="240"
                fill="none"
                stroke="#D4642C"
                strokeWidth="1.5"
                opacity="0.3"
              />
              <circle
                cx="350"
                cy="350"
                r="190"
                fill="none"
                stroke="#E87A43"
                strokeWidth="1"
                strokeDasharray="4 8"
                opacity="0.25"
              />
              <circle
                cx="350"
                cy="350"
                r="150"
                fill="none"
                stroke="#D4642C"
                strokeWidth="1"
                strokeDasharray="2 6"
                opacity="0.2"
              />
            </svg>

            {/* Orbiting Particle */}
            <motion.div
              animate={{ rotate: 360 }}
              transition={{ duration: 18, repeat: Infinity, ease: "linear" }}
              className="absolute top-1/2 left-1/2 w-0 h-0 z-10"
            >
              <div className="absolute top-[-240px] left-1/2 w-3 h-3 rounded-full bg-[#D4642C] shadow-[0_0_15px_#D4642C] -translate-x-1/2 -translate-y-1/2" />
            </motion.div>

            {/* Central Globe */}
            <div className="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 z-20 flex flex-col items-center justify-center w-[210px] h-[210px] rounded-full bg-white border-[3px] border-[#D4642C]/40 shadow-[0_15px_45px_rgba(212,100,44,0.2)] overflow-hidden">
              <Globe
                className="text-[#D4642C] mb-2 relative z-10"
                size={44}
                strokeWidth={1.5}
              />
              <span
                className="font-black text-[22px] tracking-widest mb-1 relative z-10 text-[#18181B]"
                style={{ fontFamily: "var(--font-display)" }}
              >
                NETWORK
              </span>
              <div className="flex items-center gap-1.5 text-[10px] font-bold tracking-widest relative z-10 uppercase text-stone-500">
                <span className="text-[#D4642C]">Connect</span>
                <span>•</span>
                <span className="text-stone-700">Share</span>
                <span>•</span>
                <span className="text-[#D4642C]">Grow</span>
              </div>
            </div>

            {/* Orbiting Feature Satellites */}
            <OrbitingFeatureCircle
              title="Smart Link"
              subtitle="Share instantly anywhere"
              icon={Link2}
              angle={0}
              color="orange"
              duration={40}
            />
            <OrbitingFeatureCircle
              title="Dynamic QR"
              subtitle="Scan to save directly"
              icon={QrCode}
              angle={240}
              color="amber"
              duration={40}
            />
            <OrbitingFeatureCircle
              title="NFC Tap"
              subtitle="Hardware-level exchange"
              icon={Nfc}
              angle={120}
              color="terracotta"
              duration={40}
            />
          </div>
        </div>

        {/* Timeline Beam */}
        <div className="relative w-full max-w-4xl mx-auto pt-10 border-t border-[#EFE8E1]">
          {/* Vertical Line */}
          <div className="absolute left-[24px] sm:left-1/2 top-0 bottom-12 w-[3px] -translate-x-1/2 rounded-full overflow-hidden bg-stone-200">
            <motion.div
              style={{ height: beamHeight }}
              className="w-full bg-gradient-to-b from-[#D4642C] via-[#E87A43] to-[#F59E0B]"
            />
          </div>

          <div className="pl-12 sm:pl-0 flex flex-col z-10 relative">
            <TimelineCard
              icon={Zap}
              title="Instant Connection"
              desc="Meet anyone anywhere with a single NFC tap or QR scan."
              badge="LIVE"
              align="left"
              delay={0.1}
            />
            <TimelineCard
              icon={UserCircle}
              title="Professional Identity"
              desc="Present your credentials, portfolio, and social presence cleanly."
              badge="SECURE"
              align="right"
              delay={0.2}
            />
            <TimelineCard
              icon={ArrowRightLeft}
              title="Two-Way Contact Exchange"
              desc="Exchange details instantly without asking clients to type."
              badge="FAST"
              align="left"
              delay={0.3}
            />
            <TimelineCard
              icon={Target}
              title="Automated Lead Capture"
              desc="Capture contact details directly into your centralized dashboard."
              badge="AUTO"
              align="right"
              delay={0.4}
            />
            <TimelineCard
              icon={CloudCog}
              title="CRM Integration"
              desc="Instant auto-sync with Salesforce, HubSpot, and Google Contacts."
              badge="SYNCED"
              align="left"
              delay={0.5}
            />
            <TimelineCard
              icon={Sparkles}
              title="Smart Follow-Up"
              desc="Never lose momentum with contextual AI reconnection reminders."
              badge="SMART AI"
              align="right"
              delay={0.6}
            />
          </div>

          <SuccessCapstone />
        </div>
      </div>
    </section>
  );
}
