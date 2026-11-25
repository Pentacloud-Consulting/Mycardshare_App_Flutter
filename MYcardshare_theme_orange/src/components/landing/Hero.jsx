"use client"; // Enables client-side rendering (needed for hooks & animations)

import { motion, useScroll, useTransform } from "framer-motion"; // Animation library
import { useRef } from "react"; // To reference DOM element
import Link from "next/link"; // For navigation between pages

// Icons used in UI
import {
  Zap,
  ArrowRight,
  Sparkles,
  Smartphone,
  Mail,
  Phone,
  Linkedin,
  Twitter,
  Instagram,
  Github,
  Share2,
  Cloud,
  Wallet,
  Link as LinkIcon,
  BarChart3,
} from "lucide-react";
import { UiloraBrandButton } from "../UIComponents/Button/tsx/UiloraModernButtons";
import { UiloraFloatingIcon } from "../UIComponents/Misc/UiloraFloatingIcon";

/* ═══════════════════════════════════════════════════════════
   Animation Variant (fade + slide up effect)
   Used for staggered animations of elements
   ═══════════════════════════════════════════════════════════ */

const fadeUp = {
  hidden: { opacity: 0, y: 35, filter: "blur(8px)" },
  visible: (i) => ({
    opacity: 1,
    y: 0,
    filter: "blur(0px)",
    transition: { delay: i * 0.1, duration: 0.7, ease: [0.16, 1, 0.3, 1] },
  }),
};

export default function Hero() {
  const ref = useRef(null);

  /* ======================================================
     Scroll-based animations
     ====================================================== */
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ["start start", "end start"],
  });
  // Moves background downward while scrolling
  const yBg = useTransform(scrollYProgress, [0, 1], [0, 160]);
  // Slight zoom-out effect while scrolling
  const scale = useTransform(scrollYProgress, [0, 1], [1, 0.94]);
  // Fade-out effect while scrolling
  const opacity = useTransform(scrollYProgress, [0, 0.8], [1, 0]);

  return (
    <section
      ref={ref}
      className="relative min-h-[100dvh] flex items-center justify-center overflow-hidden"
      style={{ background: "#FAF6F2" }}
    >
      {/* ── Ambient Warm Background Glows ─── */}
      <motion.div
        className="absolute inset-0 pointer-events-none overflow-hidden"
        style={{ y: yBg }}
      >
        {/* Glow circle 1 - Warm Orange Tint */}
        <div
          className="absolute w-[750px] h-[750px] rounded-full -top-32 -left-32 pointer-events-none"
          style={{
            background:
              "radial-gradient(circle, rgba(212,100,44,0.12) 0%, transparent 65%)",
            filter: "blur(90px)",
          }}
        />
        {/* Glow circle 2 - Soft Terracotta / Amber Tint */}
        <div
          className="absolute w-[600px] h-[600px] rounded-full top-1/4 -right-20 pointer-events-none"
          style={{
            background:
              "radial-gradient(circle, rgba(245,158,11,0.08) 0%, transparent 65%)",
            filter: "blur(80px)",
          }}
        />
        {/* Glow circle 3 - Deep Warm Accent Tint */}
        <div
          className="absolute w-[500px] h-[500px] rounded-full bottom-0 left-1/3 pointer-events-none"
          style={{
            background:
              "radial-gradient(circle, rgba(212,100,44,0.08) 0%, transparent 60%)",
            filter: "blur(80px)",
          }}
        />

        {/* ── Brand Curved Accent Element (From Reference Palette Image) ─── */}
        <div
          className="absolute -right-32 top-1/3 w-[500px] h-[500px] rounded-full pointer-events-none opacity-[0.18]"
          style={{
            background: "#D4642C",
            filter: "blur(60px)",
          }}
        />
        <div
          className="hidden xl:block absolute right-0 top-1/4 w-[360px] h-[360px] rounded-l-full pointer-events-none opacity-20"
          style={{
            background: "linear-gradient(135deg, #D4642C 0%, #FAF6F2 100%)",
            filter: "blur(40px)",
          }}
        />
      </motion.div>

      {/* ======================================================
         Subtle Grid Overlay (Warm tint)
         ====================================================== */}
      <div
        className="absolute inset-0 pointer-events-none"
        style={{
          backgroundImage:
            "linear-gradient(rgba(212, 100, 44, 0.035) 1px, transparent 1px), linear-gradient(90deg, rgba(212, 100, 44, 0.035) 1px, transparent 1px)",
          backgroundSize: "56px 56px",
        }}
      />

      {/* ======================================================
         Main Content Container
         ====================================================== */}
      <div className="relative z-10 max-w-7xl mx-auto px-6 pt-32 sm:pt-36 pb-20 w-full">
        <div className="grid lg:grid-cols-2 gap-12 lg:gap-16 items-center">
          {/* ================= LEFT SIDE ================= */}
          <motion.div className="text-left" style={{ scale, opacity }}>
            {/* Pill Badge */}
            <motion.div
              variants={fadeUp}
              initial="hidden"
              animate="visible"
              custom={0}
              className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full mb-6 sm:mb-8 text-xs sm:text-sm font-bold shadow-sm"
              style={{
                background: "rgba(255, 255, 255, 0.9)",
                border: "1px solid rgba(212, 100, 44, 0.25)",
                color: "#D4642C",
              }}
            >
              <span className="w-1.5 h-1.5 rounded-full bg-[#D4642C] animate-pulse" />
              <span>Introducing MyCardShare</span>
              <ArrowRight size={14} className="text-[#D4642C]" />
            </motion.div>

            {/* Main Heading */}
            <motion.h1
              variants={fadeUp}
              initial="hidden"
              animate="visible"
              custom={1}
              className="mb-6 leading-[1.08] text-4xl sm:text-5xl md:text-6xl font-black tracking-tight"
              style={{
                fontFamily: "var(--font-display)",
              }}
            >
              <span className="block text-[#18181B] tracking-tight">
                Every Connection Starts
              </span>
              <span className="block text-[#D4642C] tracking-tight mt-1">
                a New Opportunity.
              </span>
            </motion.h1>

            {/* Description */}
            <motion.p
              variants={fadeUp}
              initial="hidden"
              animate="visible"
              custom={2}
              className="text-base sm:text-lg md:text-xl max-w-xl mb-10 leading-relaxed font-normal"
              style={{ color: "#57534E" }}
            >
              Network with confidence. Share your professional identity, build
              meaningful relationships, capture opportunities, and stay
              connected—all from one intelligent networking platform.
            </motion.p>

            {/* CTA Buttons */}
            <motion.div
              variants={fadeUp}
              initial="hidden"
              animate="visible"
              custom={3}
              className="flex flex-col sm:flex-row items-stretch sm:items-center justify-start gap-4"
            >
              {/* Primary Signup CTA */}
              <Link href="/signup">
                <UiloraBrandButton className="w-full sm:w-auto px-8 py-3.5 text-xs sm:text-sm normal-case tracking-wider font-bold">
                  <Zap size={16} />
                  Join MyCardShare
                </UiloraBrandButton>
              </Link>
              {/* Secondary Explore Features Button */}
              <Link href="/features">
                <UiloraBrandButton
                  variant="outline"
                  className="w-full sm:w-auto px-8 py-3.5 text-xs sm:text-sm normal-case tracking-wider font-bold group"
                >
                  <span>Explore Features</span>
                  <ArrowRight
                    size={16}
                    className="transition-transform duration-300 group-hover:translate-x-1 text-[#D4642C]"
                  />
                </UiloraBrandButton>
              </Link>
            </motion.div>
          </motion.div>

          {/* Right Column: Floating Mobile Frame with Interactive Badges */}
          <motion.div
            initial={{ opacity: 0, y: 40 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3, duration: 0.9, ease: [0.16, 1, 0.3, 1] }}
            className="relative lg:h-[530px] flex items-center justify-center pointer-events-none mt-10 lg:mt-0"
          >
            {/* Glow / Ambient warm halo behind the phone */}
            <div
              className="absolute w-[85%] h-[85%] rounded-full opacity-40 pointer-events-none"
              style={{
                background:
                  "radial-gradient(circle, rgba(212,100,44,0.35) 0%, rgba(245,158,11,0.15) 50%, transparent 75%)",
                filter: "blur(60px)",
              }}
            />

            {/* The Floating Phone UI Mockup */}
            <motion.div
              animate={{ y: [0, -12, 0] }}
              transition={{ repeat: Infinity, duration: 5, ease: "easeInOut" }}
              className="relative z-10 w-[220px] sm:w-[250px] rounded-[40px] border-[7px] border-white bg-white overflow-hidden shadow-[0_25px_50px_-12px_rgba(212,100,44,0.2),_0_0_0_1px_rgba(239,232,225,0.8)]"
              style={{ aspectRatio: "9/19" }}
            >
              {/* Dynamic Island Notch */}
              <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[110px] h-[26px] bg-[#18181B] rounded-b-2xl z-50 flex items-center justify-center px-3">
                <div className="w-[8px] h-[8px] rounded-full bg-stone-700 ml-auto" />
              </div>

              {/* Profile Card Interface */}
              <div className="absolute inset-0 bg-[#FAF6F2] overflow-hidden flex flex-col pointer-events-none">
                {/* Banner image with Warm Gradient Overlay */}
                <div
                  className="relative h-[28%] w-full bg-cover bg-center"
                  style={{
                    backgroundImage:
                      "url('https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=2564&auto=format&fit=crop')",
                  }}
                >
                  <div className="absolute inset-0 bg-gradient-to-t from-[#FAF6F2] via-black/10 to-transparent" />
                  {/* Status Badge */}
                  <div className="absolute top-8 right-2.5 px-2 py-0.5 rounded-full bg-white/90 backdrop-blur-md border border-white/60 flex items-center gap-1.5 shadow-sm">
                    <div className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse" />
                    <span className="text-[6px] font-bold text-stone-900 uppercase tracking-widest">
                      Actively Networking
                    </span>
                  </div>
                </div>

                {/* Profile content */}
                <div className="relative px-3.5 -mt-6">
                  {/* Avatar Area */}
                  <div className="relative mb-2.5 flex items-center gap-2.5">
                    <div className="relative shrink-0">
                      <div className="w-12 h-12 sm:w-14 sm:h-14 rounded-2xl overflow-hidden border-white border-[3px] shadow-md bg-white">
                        <img
                          src="https://i.pravatar.cc/300?u=a042581f4e29026704d"
                          alt="Avatar"
                          className="w-full h-full object-cover"
                        />
                      </div>
                    </div>

                    {/* Identity Details */}
                    <div className="flex-1 min-w-0">
                      <h3
                        className="text-[12px] sm:text-[13px] font-black tracking-tight text-[#18181B] truncate"
                        style={{ fontFamily: "var(--font-display)" }}
                      >
                        Alex Stanton
                      </h3>
                      <p className="text-[8px] font-semibold text-stone-500 truncate">
                        Director of Partnerships
                      </p>
                      <div className="flex items-center gap-1 text-[6.5px] font-bold text-[#D4642C] uppercase tracking-widest mt-0.5">
                        <span className="w-1 h-1 rounded-full bg-[#D4642C] shrink-0" />
                        <span className="truncate">My Card Share Network</span>
                      </div>
                    </div>
                  </div>

                  {/* Actions Grid */}
                  <div className="grid grid-cols-2 gap-1.5 mb-2.5">
                    <div className="py-2 rounded-xl bg-white border border-[#EFE8E1] flex flex-col items-center gap-1 shadow-xs">
                      <Mail size={11} className="text-[#D4642C]" />
                      <span className="text-[6.5px] font-bold uppercase tracking-widest text-stone-600">
                        Email
                      </span>
                    </div>
                    <div className="py-2 rounded-xl bg-white border border-[#EFE8E1] flex flex-col items-center gap-1 shadow-xs">
                      <Phone size={11} className="text-[#D4642C]" />
                      <span className="text-[6.5px] font-bold uppercase tracking-widest text-stone-600">
                        Contact
                      </span>
                    </div>
                  </div>

                  {/* Bio */}
                  <div className="space-y-1 mb-2.5">
                    <p className="text-[7.5px] sm:text-[8px] leading-[1.5] font-normal text-stone-600 px-0.5">
                      Bridging the gap between enterprise solutions and global
                      partners. Leading partnerships and growth at My Card Share.
                    </p>
                  </div>

                  {/* Experience Matrix (Miniature) */}
                  <div className="bg-white border border-[#EFE8E1] rounded-xl p-2 shadow-xs mb-2.5">
                    <div className="text-[6.5px] font-black uppercase text-[#D4642C] tracking-widest mb-1 flex items-center gap-1">
                      <span className="w-1 h-1 rounded-full bg-[#D4642C]" />
                      Experience Matrix
                    </div>
                    <div>
                      <div className="text-[7.5px] font-bold text-[#18181B]">
                        Enterprise Growth
                      </div>
                      <div className="text-[6.5px] font-medium text-stone-500">
                        2021 — Present
                      </div>
                      <div className="text-[6px] mt-0.5 leading-[1.3] text-stone-500">
                        Scaled enterprise partnerships globally, achieving 400%
                        ARR growth.
                      </div>
                    </div>
                  </div>

                  {/* Socials icons */}
                  <div className="flex items-center gap-1.5 mb-3">
                    {[Linkedin, Twitter, Instagram, Github].map((Icon, idx) => (
                      <div
                        key={idx}
                        className="w-5 h-5 rounded-full bg-white flex items-center justify-center text-stone-600 border border-[#EFE8E1] shadow-xs"
                      >
                        <Icon size={8} strokeWidth={1.8} />
                      </div>
                    ))}
                  </div>

                  {/* Bottom Actions */}
                  <div className="flex gap-1.5 w-full">
                    <div className="flex-1 py-1.5 rounded-xl bg-[#D4642C] text-white flex items-center justify-center gap-1 font-bold text-[7px] tracking-wider uppercase shadow-xs">
                      Save Contact
                    </div>
                    <div className="w-6 h-6 rounded-xl bg-white border border-[#EFE8E1] flex items-center justify-center text-stone-700 shadow-xs">
                      <Share2 size={9} />
                    </div>
                  </div>
                </div>
              </div>
            </motion.div>

            {/* ── 5 Floating Feature Badges (Matching Reference Layout) ─── */}
            <UiloraFloatingIcon
              icon={Zap}
              title="Instant Setup"
              subtitle="Live in < 2m"
              color="#D4642C"
              delay={0.4}
              className="-right-2 sm:-right-20 top-[8%] sm:top-[12%]"
            />

            <UiloraFloatingIcon
              icon={LinkIcon}
              title="Share Anywhere"
              subtitle="QR · Link · AI Scan"
              color="#D4642C"
              delay={0.7}
              className="-left-2 sm:-left-12 top-[18%] sm:top-[14%]"
            />

            <UiloraFloatingIcon
              icon={Cloud}
              title="CRM Synced"
              subtitle="HubSpot · SF"
              color="#57534E"
              delay={1.0}
              className="-right-4 sm:-right-24 top-[46%]"
            />

            <UiloraFloatingIcon
              icon={BarChart3}
              title="Engagement"
              subtitle="Real-time Analytics"
              color="#D4642C"
              delay={1.3}
              className="-left-2 sm:-left-12 bottom-[24%] sm:bottom-[14%]"
            />

            <UiloraFloatingIcon
              icon={Zap}
              title="Card Scanned"
              subtitle="Just Now"
              color="#10B981"
              delay={1.6}
              className="-right-1 sm:-right-16 bottom-[8%] sm:bottom-[12%]"
            />
          </motion.div>
        </div>

        {/* ── Stats Row (Full Width 4 Pillars Below Hero) ─── */}
        <motion.div
          variants={fadeUp}
          initial="hidden"
          animate="visible"
          custom={4}
          className="grid grid-cols-2 md:grid-cols-4 gap-6 sm:gap-8 mt-16 md:mt-24 pt-8 md:pt-10 w-full"
          style={{ borderTop: "1px solid #EFE8E1" }}
        >
          {[
            { value: "Instant", label: "QR & Link Sharing" },
            { value: "Seamless", label: "Lead Capture" },
            { value: "Paperless", label: "Eco-Friendly Networking" },
            { value: "Secure", label: "Enterprise Ready" },
          ].map(({ value, label }) => (
            <div
              key={label}
              className="text-center sm:text-left flex flex-col items-center sm:items-start p-3 rounded-2xl transition-colors hover:bg-white/40"
            >
              <div
                className="text-2xl sm:text-3xl md:text-4xl font-black tracking-tight text-[#18181B]"
                style={{ fontFamily: "var(--font-display)" }}
              >
                {value}
              </div>
              <div
                className="text-[11px] sm:text-xs mt-1.5 font-bold tracking-wider uppercase text-stone-500"
              >
                {label}
              </div>
            </div>
          ))}
        </motion.div>
      </div>

      {/* ── Bottom Smooth Fade to Pure White Base ─── */}
      <div
        className="absolute bottom-0 left-0 right-0 h-24 pointer-events-none"
        style={{
          background:
            "linear-gradient(to bottom, transparent, #FFFFFF)",
        }}
      />
    </section>
  );
}
