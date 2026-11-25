"use client";

import React, { useState, useEffect, useRef } from "react";
import Link from "next/link";
import { motion } from "framer-motion";
import {
  Mail,
  Phone,
  Globe,
  Linkedin,
  Twitter,
  Instagram,
  Github,
  MessageCircle,
  Share2,
  Download,
  Building,
  CheckCircle2,
  ShieldCheck,
  Link as LinkIcon,
} from "lucide-react";
import QRCode from "qrcode";

function getInitials(name) {
  if (!name || typeof name !== "string") return "TE";
  const parts = name.trim().split(/\s+/).filter(Boolean);
  if (parts.length === 0) return "TE";
  if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase();
  return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
}

function RenderAvatar({
  formData,
  themeColor,
  initials,
  className = "w-[62px] h-[62px] sm:w-[66px] sm:h-[66px]",
  rounded = "rounded-full",
}) {
  return (
    <div className="relative shrink-0">
      <div
        className={`${className} ${rounded} p-[2.5px] bg-white shadow-md overflow-hidden flex items-center justify-center`}
      >
        {formData.avatarUrl ? (
          <img
            src={formData.avatarUrl}
            alt="Profile"
            className={`w-full h-full object-cover ${rounded}`}
          />
        ) : (
          <div
            className={`w-full h-full ${rounded} flex items-center justify-center font-bold text-xl text-white tracking-tight shadow-inner transition-colors duration-500`}
            style={{
              background: `linear-gradient(135deg, ${themeColor} 0%, #873815 100%)`,
            }}
          >
            {initials}
          </div>
        )}
      </div>
      {/* Active Green Dot Badge on Avatar */}
      <div className="absolute top-0 right-0 w-3.5 h-3.5 rounded-full bg-[#10B981] border-2 border-white shadow-xs" />
    </div>
  );
}

function RenderActions({ hasEmail, hasPhone }) {
  if (!hasEmail && !hasPhone) return null;
  return (
    <div
      className={`grid ${
        hasEmail && hasPhone ? "grid-cols-2" : "grid-cols-1"
      } gap-2.5 px-3.5 mb-2.5 shrink-0 animate-fadeIn`}
    >
      {hasEmail && (
        <div className="py-2.5 sm:py-3 px-3 rounded-full bg-white border border-[#EAE2DB] flex items-center justify-center gap-2 shadow-xs transition-all">
          <Mail size={14} className="text-[#D4622C] shrink-0" />
          <span className="text-[11px] font-black uppercase tracking-[0.1em] text-[#191919]">
            Email
          </span>
        </div>
      )}
      {hasPhone && (
        <div className="py-2.5 sm:py-3 px-3 rounded-full bg-white border border-[#EAE2DB] flex items-center justify-center gap-2 shadow-xs transition-all">
          <Phone size={14} className="text-[#D4622C] shrink-0" />
          <span className="text-[11px] font-black uppercase tracking-[0.1em] text-[#191919]">
            Contact
          </span>
        </div>
      )}
    </div>
  );
}

function RenderSocials({ activeSocials }) {
  if (!activeSocials || activeSocials.length === 0) return null;
  return (
    <div className="px-3.5 flex items-center justify-center flex-wrap gap-1.5 mb-2 shrink-0 animate-fadeIn">
      {activeSocials.map((social) => {
        const IconComp = social.icon;
        return (
          <div
            key={social.id}
            title={social.label}
            className={`w-6.5 h-6.5 rounded-full ${social.bg} ${social.text} flex items-center justify-center border ${social.border} shadow-2xs transition-transform hover:scale-110`}
          >
            <IconComp size={12} />
          </div>
        );
      })}
    </div>
  );
}

function RenderBio({ hasBio, bio }) {
  if (!hasBio) return null;
  return (
    <div className="px-3.5 flex-1 flex flex-col mb-2 overflow-hidden animate-fadeIn">
      <div className="p-3 sm:p-3.5 rounded-2xl bg-white border border-[#EAE2DB] shadow-2xs text-left">
        <div className="flex items-center justify-between mb-1.5">
          <span className="text-[9px] font-bold uppercase tracking-[0.12em] text-[#77716C]">
            Bio
          </span>
          <span className="text-[8px] font-bold text-[#D4622C] uppercase tracking-wider bg-[#FCE9DF] px-2 py-0.5 rounded-full">
            Overview
          </span>
        </div>
        <p className="text-[10px] sm:text-[10.5px] text-[#191919] font-medium leading-relaxed line-clamp-3">
          {bio}
        </p>
      </div>
    </div>
  );
}

function RenderUrlPill({ publicSlug }) {
  return (
    <div className="mt-auto px-3.5 pb-2.5 shrink-0">
      <div className="flex items-center justify-between px-3 py-1.5 rounded-full bg-white border border-[#EAE2DB] shadow-xs text-[9.5px]">
        <div className="flex items-center gap-1.5 overflow-hidden">
          <LinkIcon size={11} className="text-[#D4622C] shrink-0" />
          <span className="font-mono text-[#77716C] font-semibold truncate text-[9px]">
            mycardshare.in/card/{publicSlug}
          </span>
        </div>
        <div className="flex items-center gap-1 shrink-0 pl-1">
          <span className="text-[9px] font-bold text-[#10B981] flex items-center gap-1">
            <span className="w-1.5 h-1.5 rounded-full bg-[#10B981] animate-pulse" />
            LIVE
          </span>
        </div>
      </div>
    </div>
  );
}

export default function LiveCardPreview({ formData, className = "" }) {
  const themeColor = formData.themeColor || "#D4622C";
  const cardLayout = formData.cardLayout || "editorial";

  // Dynamic slow 3D rotation and delayed layout change
  const [rotationKey, setRotationKey] = useState(0);
  const [displayedLayout, setDisplayedLayout] = useState(cardLayout);
  const prevLayoutRef = useRef(cardLayout);

  useEffect(() => {
    if (cardLayout && cardLayout !== prevLayoutRef.current) {
      prevLayoutRef.current = cardLayout;
      setRotationKey((k) => k + 1);

      // Halfway through rotation (at ~550ms of 1150ms animation), switch layout design
      const switchTimer = setTimeout(() => {
        setDisplayedLayout(cardLayout);
      }, 550);

      return () => clearTimeout(switchTimer);
    }
  }, [cardLayout]);

  const [qrSrc, setQrSrc] = useState("");
  const publicSlug =
    (formData.cardSlug || "").trim() ||
    (formData.fullName
      ? formData.fullName.toLowerCase().replace(/\s+/g, "")
      : "test1");
  const publicUrl = `https://mycardshare.in/card/${publicSlug}`;

  useEffect(() => {
    QRCode.toDataURL(publicUrl, {
      width: 300,
      margin: 1,
      color: { dark: "#1C1917", light: "#FFFFFF" },
    })
      .then(setQrSrc)
      .catch(() => setQrSrc(""));
  }, [publicUrl]);

  const hasName = Boolean(
    (formData.fullName && formData.fullName.trim()) ||
      (formData.firstName && formData.firstName.trim())
  );
  const displayName = hasName
    ? (
        formData.fullName ||
        `${formData.firstName || ""} ${formData.lastName || ""}`
      ).trim()
    : "Your Name";
  const initials = getInitials(displayName);

  const hasTitle = Boolean(formData.jobTitle && formData.jobTitle.trim());
  const displayTitle = hasTitle ? formData.jobTitle.trim() : "";

  const hasCompany = Boolean(
    formData.companyName && formData.companyName.trim()
  );
  const displayCompany = hasCompany ? formData.companyName.trim() : "";

  const hasEmail = Boolean(formData.workEmail && formData.workEmail.trim());
  const hasPhone = Boolean(formData.workPhone && formData.workPhone.trim());
  const hasBio = Boolean(formData.bio && formData.bio.trim());

  // Social channels entered by user - rendered one by one dynamically
  const activeSocials = [
    {
      id: "whatsapp",
      label: "WhatsApp",
      icon: MessageCircle,
      value: formData.whatsapp,
      bg: "bg-[#25D366]/10",
      border: "border-[#25D366]/25",
      text: "text-[#25D366]",
    },
    {
      id: "linkedin",
      label: "LinkedIn",
      icon: Linkedin,
      value: formData.linkedin,
      bg: "bg-[#0A66C2]/10",
      border: "border-[#0A66C2]/25",
      text: "text-[#0A66C2]",
    },
    {
      id: "instagram",
      label: "Instagram",
      icon: Instagram,
      value: formData.instagram,
      bg: "bg-[#E4405F]/10",
      border: "border-[#E4405F]/25",
      text: "text-[#E4405F]",
    },
    {
      id: "twitter",
      label: "X / Twitter",
      icon: Twitter,
      value: formData.twitter,
      bg: "bg-black/10",
      border: "border-black/20",
      text: "text-[#191919]",
    },
    {
      id: "website",
      label: "Website",
      icon: Globe,
      value: formData.website,
      bg: "bg-[#1877F2]/10",
      border: "border-[#1877F2]/25",
      text: "text-[#1877F2]",
    },
    {
      id: "github",
      label: "GitHub",
      icon: Github,
      value: formData.github,
      bg: "bg-slate-800/10",
      border: "border-slate-800/20",
      text: "text-slate-800",
    },
  ].filter((s) => Boolean(s.value && s.value.trim()));

  return (
    <div
      className={`relative flex flex-col items-center justify-center select-none w-full h-full py-1 ${className}`}
    >
      {/* 3D Perspective Stage Container for Smooth Phone Rotation */}
      <div
        className="relative z-10 w-full flex flex-col items-center"
        style={{ perspective: 1200 }}
      >
        <motion.div
          key={rotationKey}
          initial={rotationKey > 0 ? { rotateY: 0 } : false}
          animate={
            rotationKey > 0
              ? {
                  rotateY: [0, 180, 360],
                  scale: [1, 0.94, 0.92, 0.94, 1],
                  transition: {
                    duration: 1.15,
                    ease: [0.45, 0.05, 0.25, 1],
                  },
                }
              : { rotateY: 0, scale: 1 }
          }
          style={{ transformStyle: "preserve-3d" }}
          className="relative w-full max-w-[305px] sm:max-w-[318px] lg:max-w-[328px] shrink-0"
        >
          {/* PHONE FRONT FACE (Visible at 0deg and 360deg) */}
          <div
            className="w-full rounded-[48px] p-[7px] bg-gradient-to-br from-[#F5D0B5] via-[#C98B60] to-[#7D4522] shadow-[0_22px_50px_-10px_rgba(28,25,23,0.22),0_8px_20px_-6px_rgba(212,98,44,0.15),0_1px_0_1px_rgba(255,255,255,0.7)_inset] transition-all duration-300 flex flex-col shrink-0"
            style={{
              backfaceVisibility: "hidden",
              WebkitBackfaceVisibility: "hidden",
            }}
          >
            {/* Antenna band slits on edge */}
            <div className="absolute top-20 -left-[1px] w-[2px] h-3 bg-[#8C5531]/60 rounded-r-xs pointer-events-none" />
            <div className="absolute top-20 -right-[1px] w-[2px] h-3 bg-[#8C5531]/60 rounded-l-xs pointer-events-none" />

            {/* Inner Black Device Bezel */}
            <div className="w-full rounded-[42px] bg-[#1C1917] p-[2.5px] shadow-inner">
              {/* Dynamic Screen Container */}
              <div className="relative w-full rounded-[40px] bg-[#F8F4EF] overflow-hidden flex flex-col h-[480px] sm:h-[510px] lg:h-[min(540px,calc(100vh-215px))] border border-[#EAE2DB]/60 shadow-inner">
                {/* Top Status Bar & Dynamic Island */}
                <div className="relative z-30 pt-2.5 px-5 flex items-center justify-between text-[11px] font-semibold text-[#1C1917]/85 shrink-0">
                  <span className="font-bold tracking-tight text-[11px]">
                    9:41
                  </span>
                  {/* Dynamic Island Pill */}
                  <div className="w-22 h-4.5 rounded-full bg-[#1C1917] flex items-center justify-end px-2 gap-1.5 shadow-xs">
                    <span className="w-1.5 h-1.5 rounded-full bg-[#10B981] animate-pulse" />
                  </div>
                  <div className="flex items-center gap-1.5 text-[#1C1917]/75">
                    <div className="w-3.5 h-2 rounded-2xs border border-[#1C1917]/75 p-0.5 flex items-center">
                      <div className="w-full h-full bg-[#1C1917] rounded-2xs" />
                    </div>
                  </div>
                </div>

                {/* CARD SCREEN BODY - DYNAMIC LAYOUT BASED ON displayedLayout */}
                <div className="flex-1 flex flex-col relative overflow-hidden">
                  {/* ─────────────────────────────────────────────────────────────
                      1. EDITORIAL LAYOUT (Left Avatar + Dune Banner)
                     ───────────────────────────────────────────────────────────── */}
                  {displayedLayout === "editorial" && (
                    <>
                      <div className="relative w-full h-26 sm:h-30 overflow-hidden shrink-0 bg-[#A2481B]">
                        <img
                          src={formData.bannerUrl || "/default-dune-banner.png"}
                          alt="Cover"
                          className="w-full h-full object-cover transition-opacity duration-300"
                          onError={(e) => {
                            e.currentTarget.style.display = "none";
                          }}
                        />
                        <div
                          className="absolute inset-0 opacity-20 pointer-events-none"
                          style={{
                            background:
                              "radial-gradient(ellipse at 80% 20%, rgba(255,255,255,0.8) 0%, transparent 60%)",
                          }}
                        />
                        <div className="absolute top-2.5 right-3 z-20">
                          <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[8px] font-black uppercase tracking-widest border border-white/20 shadow-md backdrop-blur-md bg-black/45 text-emerald-400">
                            <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse shadow-xs" />
                            ACTIVELY NETWORKING
                          </span>
                        </div>
                      </div>

                      <div className="flex items-center gap-3 px-3.5 -mt-7 mb-2 relative z-20 shrink-0">
                        <RenderAvatar
                          formData={formData}
                          themeColor={themeColor}
                          initials={initials}
                        />
                        <div className="flex-1 min-w-0 text-left pt-2.5">
                          <h3
                            className="text-[16px] sm:text-[17px] font-black tracking-tight text-[#191919] leading-tight truncate"
                            style={{
                              fontFamily: "var(--font-display, inherit)",
                            }}
                          >
                            {displayName}
                          </h3>
                          {hasTitle && (
                            <p className="text-[11px] font-semibold text-[#77716C] truncate mt-0.5 animate-fadeIn">
                              {displayTitle}
                            </p>
                          )}
                          {hasCompany && (
                            <div className="flex items-center gap-1.5 text-[9px] font-bold text-[#D4622C] uppercase tracking-[0.14em] mt-1 truncate animate-fadeIn">
                              <span className="w-1.5 h-1.5 rounded-full bg-[#D4622C] shrink-0" />
                              <span className="truncate">{displayCompany}</span>
                            </div>
                          )}
                        </div>
                      </div>

                      <RenderActions
                        hasEmail={hasEmail}
                        hasPhone={hasPhone}
                      />
                      <RenderSocials activeSocials={activeSocials} />
                      <RenderBio hasBio={hasBio} bio={formData.bio} />
                      <RenderUrlPill publicSlug={publicSlug} />
                    </>
                  )}

                  {/* ─────────────────────────────────────────────────────────────
                      2. MINIMAL LAYOUT (Centered Portrait + Balanced Layout)
                     ───────────────────────────────────────────────────────────── */}
                  {displayedLayout === "minimal" && (
                    <>
                      <div className="relative w-full h-20 sm:h-22 overflow-hidden shrink-0 bg-[#A2481B]">
                        <img
                          src={formData.bannerUrl || "/default-dune-banner.png"}
                          alt="Cover"
                          className="w-full h-full object-cover transition-opacity duration-300"
                          onError={(e) => {
                            e.currentTarget.style.display = "none";
                          }}
                        />
                        <div className="absolute top-2 right-2.5 z-20">
                          <span className="inline-flex items-center gap-1 px-1.5 py-0.5 rounded-full text-[7.5px] font-bold uppercase tracking-wider bg-black/45 text-emerald-400 backdrop-blur-md">
                            <span className="w-1 h-1 rounded-full bg-emerald-400 animate-pulse" />
                            ONLINE
                          </span>
                        </div>
                      </div>

                      <div className="flex flex-col items-center px-4 -mt-9 mb-2 relative z-20 shrink-0 text-center">
                        <RenderAvatar
                          formData={formData}
                          themeColor={themeColor}
                          initials={initials}
                          className="w-[66px] h-[66px] sm:w-[70px] sm:h-[70px]"
                        />
                        <div className="w-full text-center mt-1.5">
                          <h3
                            className="text-[16px] sm:text-[17px] font-black tracking-tight text-[#191919] leading-tight truncate"
                            style={{
                              fontFamily: "var(--font-display, inherit)",
                            }}
                          >
                            {displayName}
                          </h3>
                          {hasTitle && (
                            <p className="text-[11px] font-semibold text-[#77716C] truncate mt-0.5 animate-fadeIn">
                              {displayTitle}
                            </p>
                          )}
                          {hasCompany && (
                            <div className="inline-flex items-center justify-center gap-1.5 text-[9px] font-bold text-[#D4622C] uppercase tracking-[0.14em] mt-1 px-2.5 py-0.5 rounded-full bg-[#FCE9DF] border border-[#EAE2DB] animate-fadeIn">
                              <span className="w-1.5 h-1.5 rounded-full bg-[#D4622C] shrink-0" />
                              <span className="truncate">{displayCompany}</span>
                            </div>
                          )}
                        </div>
                      </div>

                      <RenderActions
                        hasEmail={hasEmail}
                        hasPhone={hasPhone}
                      />
                      <RenderSocials activeSocials={activeSocials} />
                      <RenderBio hasBio={hasBio} bio={formData.bio} />
                      <RenderUrlPill publicSlug={publicSlug} />
                    </>
                  )}

                  {/* ─────────────────────────────────────────────────────────────
                      3. BANNER-RIGHT LAYOUT (Right-aligned Avatar)
                     ───────────────────────────────────────────────────────────── */}
                  {displayedLayout === "banner-right" && (
                    <>
                      <div className="relative w-full h-26 sm:h-30 overflow-hidden shrink-0 bg-[#A2481B]">
                        <img
                          src={formData.bannerUrl || "/default-dune-banner.png"}
                          alt="Cover"
                          className="w-full h-full object-cover transition-opacity duration-300"
                          onError={(e) => {
                            e.currentTarget.style.display = "none";
                          }}
                        />
                        <div className="absolute top-2.5 left-3 z-20">
                          <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[8px] font-black uppercase tracking-widest border border-white/20 shadow-md backdrop-blur-md bg-black/45 text-emerald-400">
                            <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse shadow-xs" />
                            NETWORKING
                          </span>
                        </div>
                      </div>

                      <div className="flex items-center justify-between gap-3 px-3.5 -mt-7 mb-2 relative z-20 shrink-0">
                        <div className="flex-1 min-w-0 text-left pt-2.5">
                          <h3
                            className="text-[16px] sm:text-[17px] font-black tracking-tight text-[#191919] leading-tight truncate"
                            style={{
                              fontFamily: "var(--font-display, inherit)",
                            }}
                          >
                            {displayName}
                          </h3>
                          {hasTitle && (
                            <p className="text-[11px] font-semibold text-[#77716C] truncate mt-0.5 animate-fadeIn">
                              {displayTitle}
                            </p>
                          )}
                          {hasCompany && (
                            <div className="flex items-center gap-1.5 text-[9px] font-bold text-[#D4622C] uppercase tracking-[0.14em] mt-1 truncate animate-fadeIn">
                              <span className="w-1.5 h-1.5 rounded-full bg-[#D4622C] shrink-0" />
                              <span className="truncate">{displayCompany}</span>
                            </div>
                          )}
                        </div>
                        <RenderAvatar
                          formData={formData}
                          themeColor={themeColor}
                          initials={initials}
                        />
                      </div>

                      <RenderActions
                        hasEmail={hasEmail}
                        hasPhone={hasPhone}
                      />
                      <RenderSocials activeSocials={activeSocials} />
                      <RenderBio hasBio={hasBio} bio={formData.bio} />
                      <RenderUrlPill publicSlug={publicSlug} />
                    </>
                  )}

                  {/* ─────────────────────────────────────────────────────────────
                      4. EXECUTIVE LAYOUT (Corporate Badge & Verification Card)
                     ───────────────────────────────────────────────────────────── */}
                  {displayedLayout === "executive" && (
                    <>
                      <div className="relative w-full h-22 sm:h-24 bg-gradient-to-br from-[#1C1917] via-[#2A2420] to-[#1C1917] border-b-2 border-[#D4622C] p-3 flex flex-col justify-between shrink-0 shadow-sm overflow-hidden">
                        <div className="absolute inset-0 opacity-15 bg-[radial-gradient(#D4622C_1px,transparent_1px)] [background-size:12px_12px] pointer-events-none" />
                        <div className="relative z-10 flex items-center justify-between">
                          <div className="flex items-center gap-1.5 text-[8.5px] font-black uppercase tracking-widest text-[#EAE2DB]">
                            <ShieldCheck size={12} className="text-[#D4622C]" />
                            <span>EXECUTIVE PASS</span>
                          </div>
                          <span className="px-2 py-0.5 rounded-full text-[7.5px] font-bold bg-[#D4622C]/25 text-[#D4622C] border border-[#D4622C]/40">
                            VERIFIED
                          </span>
                        </div>
                        <div className="relative z-10 text-[8px] font-mono tracking-wider text-[#A89F91]">
                          ID: MCS-{publicSlug.slice(0, 6).toUpperCase()}
                        </div>
                      </div>

                      <div className="flex items-center gap-3 px-3.5 -mt-6 mb-2 relative z-20 shrink-0">
                        <div className="relative shrink-0">
                          <div className="w-[64px] h-[64px] rounded-full p-[3px] bg-gradient-to-br from-[#D4622C] via-[#F5D0B5] to-[#873815] shadow-lg overflow-hidden flex items-center justify-center">
                            {formData.avatarUrl ? (
                              <img
                                src={formData.avatarUrl}
                                alt="Profile"
                                className="w-full h-full object-cover rounded-full"
                              />
                            ) : (
                              <div className="w-full h-full rounded-full flex items-center justify-center font-bold text-xl text-white tracking-tight bg-[#1C1917]">
                                {initials}
                              </div>
                            )}
                          </div>
                          <div className="absolute top-0 right-0 w-3.5 h-3.5 rounded-full bg-[#10B981] border-2 border-white shadow-xs" />
                        </div>
                        <div className="flex-1 min-w-0 text-left pt-2">
                          <div className="flex items-center gap-1.5">
                            <h3
                              className="text-[16px] sm:text-[17px] font-black tracking-tight text-[#191919] leading-tight truncate"
                              style={{
                                fontFamily: "var(--font-display, inherit)",
                              }}
                            >
                              {displayName}
                            </h3>
                            <CheckCircle2
                              size={13}
                              className="text-[#D4622C] shrink-0"
                            />
                          </div>
                          {hasTitle && (
                            <p className="text-[11px] font-bold text-[#191919] uppercase tracking-wide truncate mt-0.5 animate-fadeIn">
                              {displayTitle}
                            </p>
                          )}
                          {hasCompany && (
                            <div className="flex items-center gap-1.5 text-[9px] font-black text-[#D4622C] uppercase tracking-[0.14em] mt-1 truncate animate-fadeIn">
                              <Building
                                size={10}
                                className="text-[#D4622C] shrink-0"
                              />
                              <span className="truncate">{displayCompany}</span>
                            </div>
                          )}
                        </div>
                      </div>

                      <RenderActions
                        hasEmail={hasEmail}
                        hasPhone={hasPhone}
                      />
                      <RenderSocials activeSocials={activeSocials} />
                      <RenderBio hasBio={hasBio} bio={formData.bio} />
                      <RenderUrlPill publicSlug={publicSlug} />
                    </>
                  )}

                  {/* ─────────────────────────────────────────────────────────────
                      5. WIDE LAYOUT (Modern Wide & Full-Bleed Brand Bar)
                     ───────────────────────────────────────────────────────────── */}
                  {displayedLayout === "wide" && (
                    <>
                      <div className="w-full h-12 bg-gradient-to-r from-[#D4622C] via-[#E28352] to-[#B94D1D] px-3.5 flex items-center justify-between shrink-0 shadow-xs">
                        <span
                          className="text-[9px] font-black tracking-widest text-white uppercase"
                          style={{ fontFamily: "var(--font-display, inherit)" }}
                        >
                          MYCARD
                        </span>
                        <span className="text-[8px] font-bold text-white/90 bg-black/20 px-2 py-0.5 rounded-full">
                          CONNECT
                        </span>
                      </div>

                      <div className="px-3.5 pt-3 mb-2 shrink-0">
                        <div className="flex items-center gap-3 p-2.5 rounded-2xl bg-white border border-[#EAE2DB] shadow-2xs">
                          <RenderAvatar
                            formData={formData}
                            themeColor={themeColor}
                            initials={initials}
                            className="w-[56px] h-[56px]"
                            rounded="rounded-2xl"
                          />
                          <div className="flex-1 min-w-0 text-left">
                            <h3
                              className="text-[15px] sm:text-[16px] font-black tracking-tight text-[#191919] leading-tight truncate"
                              style={{
                                fontFamily: "var(--font-display, inherit)",
                              }}
                            >
                              {displayName}
                            </h3>
                            {hasTitle && (
                              <p className="text-[11px] font-semibold text-[#77716C] truncate mt-0.5 animate-fadeIn">
                                {displayTitle}
                              </p>
                            )}
                            {hasCompany && (
                              <div className="flex items-center gap-1.5 text-[9px] font-bold text-[#D4622C] uppercase tracking-[0.14em] mt-1 truncate animate-fadeIn">
                                <span className="w-1.5 h-1.5 rounded-full bg-[#D4622C] shrink-0" />
                                <span className="truncate">
                                  {displayCompany}
                                </span>
                              </div>
                            )}
                          </div>
                        </div>
                      </div>

                      <RenderActions
                        hasEmail={hasEmail}
                        hasPhone={hasPhone}
                      />
                      <RenderSocials activeSocials={activeSocials} />
                      <RenderBio hasBio={hasBio} bio={formData.bio} />
                      <RenderUrlPill publicSlug={publicSlug} />
                    </>
                  )}
                </div>
              </div>
            </div>
          </div>

          {/* PHONE BACK FACE (Rendered during 3D rotation at 180deg) */}
          <div
            className="absolute inset-0 w-full h-full rounded-[48px] p-[7px] bg-gradient-to-br from-[#F5D0B5] via-[#C98B60] to-[#7D4522] shadow-[0_22px_50px_-10px_rgba(28,25,23,0.22),0_8px_20px_-6px_rgba(212,98,44,0.15)] flex flex-col pointer-events-none select-none"
            style={{
              transform: "rotateY(180deg)",
              backfaceVisibility: "hidden",
              WebkitBackfaceVisibility: "hidden",
            }}
          >
            <div className="w-full h-full rounded-[42px] bg-[#1C1917] p-4 flex flex-col justify-between items-center relative overflow-hidden border border-[#C98B60]/30 shadow-inner">
              {/* Metallic surface sheen */}
              <div className="absolute inset-0 bg-gradient-to-tr from-transparent via-white/5 to-transparent pointer-events-none" />

              {/* Realistic Luxury Triple Camera Module in Top-Left */}
              <div className="self-start w-20 h-20 rounded-[22px] bg-[#12100E] p-2 shadow-xl border border-white/10 grid grid-cols-2 gap-1.5 relative">
                <div className="w-6.5 h-6.5 rounded-full bg-[#0A0908] border-2 border-[#38332D] flex items-center justify-center shadow-inner">
                  <div className="w-3 h-3 rounded-full bg-[#182030] border border-blue-400/30" />
                </div>
                <div className="w-6.5 h-6.5 rounded-full bg-[#0A0908] border-2 border-[#38332D] flex items-center justify-center shadow-inner">
                  <div className="w-3 h-3 rounded-full bg-[#182030] border border-blue-400/30" />
                </div>
                <div className="w-6.5 h-6.5 rounded-full bg-[#0A0908] border-2 border-[#38332D] flex items-center justify-center shadow-inner">
                  <div className="w-3 h-3 rounded-full bg-[#182030] border border-blue-400/30" />
                </div>
                <div className="flex flex-col items-center justify-around py-0.5">
                  <div className="w-2.5 h-2.5 rounded-full bg-[#FFFCEB] shadow-[0_0_6px_#FFF] border border-amber-200" />
                  <div className="w-1.5 h-1.5 rounded-full bg-[#201C18] border border-white/10" />
                </div>
              </div>

              {/* Center Embossed MyCardShare Monogram */}
              <div className="flex flex-col items-center gap-2 my-auto">
                <div className="w-12 h-12 rounded-2xl bg-gradient-to-br from-[#D4622C] to-[#873815] flex items-center justify-center shadow-lg border border-white/20">
                  <span
                    className="text-white font-black text-xl tracking-tighter"
                    style={{ fontFamily: "var(--font-display, inherit)" }}
                  >
                    M
                  </span>
                </div>
                <span className="text-[9.5px] font-bold uppercase tracking-[0.25em] text-[#C98B60]">
                  MyCardShare
                </span>
              </div>

              {/* Bottom NFC Certification */}
              <div className="pb-2 text-center">
                <span className="text-[7.5px] font-mono tracking-widest text-[#77716C]/70">
                  NFC ENABLED • DIGITAL IDENTITY
                </span>
              </div>
            </div>
          </div>
        </motion.div>
      </div>

      {/* 3D Cylindrical Circular Stand / Podium beneath phone - Luxury 2-tier architectural display */}
      <div className="relative -mt-1 sm:-mt-1.5 z-0 w-full max-w-[395px] sm:max-w-[420px] lg:max-w-[438px] flex flex-col items-center pointer-events-none select-none shrink-0">
        <svg
          viewBox="0 0 380 95"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
          className="w-full h-auto drop-shadow-xs"
        >
          <defs>
            {/* Soft Floor Ambient Shadows */}
            <radialGradient
              id="floorAmbientDrop"
              cx="50%"
              cy="50%"
              r="50%"
              fx="50%"
              fy="50%"
            >
              <stop offset="0%" stopColor="#1E1915" stopOpacity="0.28" />
              <stop offset="45%" stopColor="#2E241D" stopOpacity="0.14" />
              <stop offset="80%" stopColor="#786B60" stopOpacity="0.04" />
              <stop offset="100%" stopColor="#F8F4EF" stopOpacity="0" />
            </radialGradient>

            <linearGradient
              id="phoneContactShadow"
              x1="0%"
              y1="0%"
              x2="100%"
              y2="0%"
            >
              <stop offset="0%" stopColor="#1C1917" stopOpacity="0" />
              <stop offset="25%" stopColor="#1C1917" stopOpacity="0.65" />
              <stop offset="50%" stopColor="#0F0D0C" stopOpacity="0.85" />
              <stop offset="75%" stopColor="#1C1917" stopOpacity="0.65" />
              <stop offset="100%" stopColor="#1C1917" stopOpacity="0" />
            </linearGradient>

            {/* Base Tier (Plinth) Shading */}
            <linearGradient
              id="baseRimHighlight"
              x1="0%"
              y1="0%"
              x2="0%"
              y2="100%"
            >
              <stop offset="0%" stopColor="#FFFFFF" stopOpacity="0.95" />
              <stop offset="40%" stopColor="#F5EFE8" stopOpacity="0.8" />
              <stop offset="100%" stopColor="#DFD5CA" stopOpacity="0.9" />
            </linearGradient>

            <linearGradient
              id="baseCylinderFace"
              x1="0%"
              y1="0%"
              x2="100%"
              y2="0%"
            >
              <stop offset="0%" stopColor="#B3A596" />
              <stop offset="15%" stopColor="#C8BCAD" />
              <stop offset="50%" stopColor="#EDE5DC" />
              <stop offset="85%" stopColor="#C8BCAD" />
              <stop offset="100%" stopColor="#A89A8B" />
            </linearGradient>

            {/* Top Tier (Podium) Shading */}
            <linearGradient
              id="podiumTopSurface"
              x1="50%"
              y1="0%"
              x2="50%"
              y2="100%"
            >
              <stop offset="0%" stopColor="#FAF7F2" />
              <stop offset="60%" stopColor="#EFE8DE" />
              <stop offset="100%" stopColor="#E2D7C9" />
            </linearGradient>

            <linearGradient
              id="podiumRimLight"
              x1="0%"
              y1="0%"
              x2="0%"
              y2="100%"
            >
              <stop offset="0%" stopColor="#FFFFFF" stopOpacity="0.9" />
              <stop offset="100%" stopColor="#D9CDBD" stopOpacity="0.5" />
            </linearGradient>

            <linearGradient
              id="podiumCylinderFace"
              x1="0%"
              y1="0%"
              x2="100%"
              y2="0%"
            >
              <stop offset="0%" stopColor="#9C8D7E" />
              <stop offset="12%" stopColor="#BDB0A1" />
              <stop offset="50%" stopColor="#E8DFD4" />
              <stop offset="88%" stopColor="#BDB0A1" />
              <stop offset="100%" stopColor="#948576" />
            </linearGradient>

            <linearGradient
              id="tierContactCrevice"
              x1="0%"
              y1="0%"
              x2="0%"
              y2="100%"
            >
              <stop offset="0%" stopColor="#3D3227" stopOpacity="0.4" />
              <stop offset="100%" stopColor="#8A7A6C" stopOpacity="0" />
            </linearGradient>
          </defs>

          {/* 1. Cast Floor Shadow on Table Surface */}
          <ellipse
            cx="190"
            cy="76"
            rx="160"
            ry="18"
            fill="url(#floorAmbientDrop)"
          />

          {/* 2. Tier 1 (Lower Plinth) Cylinder Wall */}
          <path
            d="M 25 58 
               C 25 58, 25 72, 25 72 
               C 25 84, 99 93, 190 93 
               C 281 93, 355 84, 355 72 
               C 355 72, 355 58, 355 58 
               Z"
            fill="url(#baseCylinderFace)"
          />

          {/* 3. Tier 1 (Lower Plinth) Top Ellipse Surface */}
          <ellipse
            cx="190"
            cy="58"
            rx="165"
            ry="15.5"
            fill="url(#baseRimHighlight)"
            stroke="#C4B6A6"
            strokeWidth="0.75"
          />

          {/* 4. Ambient Contact Shadow cast by Top Podium onto Lower Plinth */}
          <ellipse
            cx="190"
            cy="59"
            rx="132"
            ry="13"
            fill="url(#tierContactCrevice)"
          />

          {/* 5. Tier 2 (Upper Podium) Cylinder Wall */}
          <path
            d="M 46 39 
               C 46 39, 46 54, 46 54 
               C 46 64, 110 71, 190 71 
               C 270 71, 334 64, 334 54 
               C 334 54, 334 39, 334 39 
               Z"
            fill="url(#podiumCylinderFace)"
          />

          {/* 6. Tier 2 (Upper Podium) Top Ellipse Surface */}
          <ellipse
            cx="190"
            cy="39"
            rx="144"
            ry="14.5"
            fill="url(#podiumTopSurface)"
            stroke="url(#podiumRimLight)"
            strokeWidth="1.2"
          />

          {/* 7. Inner Rim Specular Glint */}
          <ellipse
            cx="190"
            cy="38.5"
            rx="142"
            ry="13.8"
            fill="none"
            stroke="#FFFFFF"
            strokeOpacity="0.75"
            strokeWidth="0.8"
          />

          {/* 8. Phone Direct Weighted Contact Shadow on Top of Upper Podium */}
          <ellipse
            cx="190"
            cy="42"
            rx="86"
            ry="4.5"
            fill="url(#phoneContactShadow)"
          />
        </svg>
      </div>
    </div>
  );
}
