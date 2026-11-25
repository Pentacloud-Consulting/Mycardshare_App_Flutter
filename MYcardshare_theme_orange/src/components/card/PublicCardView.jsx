"use client";

import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  Mail,
  Phone,
  MapPin,
  Link as LinkIcon,
  X,
  QrCode,
  Share2,
  CheckCircle2,
  FileText,
  BookOpen,
  Download,
  ExternalLink,
} from "lucide-react";
import QRCode from "qrcode";
import Conformation from "./Confirmation";
import { getCardShareUrl } from "@/lib/urls";

/** QR Preview helper */
function QRPreview({ url }) {
  const [src, setSrc] = useState("");
  useEffect(() => {
    QRCode.toDataURL(url, { width: 400, margin: 2 }).then(setSrc);
  }, [url]);

  if (!src)
    return (
      <div className="w-40 h-40 flex items-center justify-center bg-slate-100 rounded-xl">
        ...
      </div>
    );
  return <img src={src} className="w-32 h-32" alt="QR Code" />;
}

/** Resolve a user-entered value into a working URL */
function resolveSocialUrl(id, raw) {
  if (!raw) return null;
  const val = String(raw).trim();
  if (!val) return null;

  if (id === "whatsapp") {
    const digits = val.replace(/[^0-9]/g, "");
    return digits ? `https://wa.me/${digits}` : null;
  }

  // Already starts with full protocol
  if (val.startsWith("http://") || val.startsWith("https://")) {
    return val;
  }

  // If starts with domain without protocol e.g. "instagram.com/...", "facebook.com/..."
  if (/^(www\.)?(instagram\.com|facebook\.com|x\.com|twitter\.com|github\.com|youtube\.com|linkedin\.com|calendly\.com)/i.test(val)) {
    return `https://${val.replace(/^www\./i, "")}`;
  }

  const bases = {
    linkedin: "https://linkedin.com/in/",
    twitter: "https://x.com/",
    instagram: "https://instagram.com/",
    github: "https://github.com/",
    youtube: "https://youtube.com/@",
    website: "https://",
    calendly: "https://calendly.com/",
    facebook: "https://facebook.com/",
  };

  const clean = val.replace(/^@/, "").replace(/^\/+/, "");
  return (bases[id] || "https://") + clean;
}

function getStatusColor(status, fallback) {
  const colors = {
    "Actively Networking": "#10b981",
    "Open to Collaborations": "#38bdf8",
    "Available for Hire": "#fbbf24",
    "Looking for Co-founder": "#c084fc",
    "Open to Freelance": "#2dd4bf",
    "Seeking Mentorship": "#fb923c",
    "Offering Mentorship": "#818cf8",
    "Open to Speaking": "#fb7185",
    Investor: "#facc15",
    "Building in Stealth": "#94a3b8",
  };
  return colors[status] || fallback;
}

export default function PublicCardView({ data }) {
  const themeColor = data.themeColor || "#6366f1";
  const cardLayout = data.cardLayout || "editorial";

  const [isBioExpanded, setIsBioExpanded] = useState(false);
  const [isExpExpanded, setIsExpExpanded] = useState(false);
  const [showShareMenu, setShowShareMenu] = useState(false);
  const [showQr, setShowQr] = useState(false);
  const [copied, setCopied] = useState(false);
  const [showConfirm, setShowConfirm] = useState(false);

  const [avatarError, setAvatarError] = useState(false);
  const [bannerError, setBannerError] = useState(false);
  const [canShare, setCanShare] = useState(false);

  useEffect(() => {
    if (typeof navigator !== "undefined" && navigator.share) {
      setCanShare(true);
    }
  }, []);

  // Resolve data fields (public card uses different field names)
  const name = data.fullName || data.name;
  const title = data.jobTitle || data.title;
  const company = data.companyName || data.company;
  const email = data.workEmail || data.email;
  const phone = data.workPhone || data.phone;

  const shareUrl = getCardShareUrl(data.slug || data.cardSlug);

  const handleCopyLink = async () => {
    try {
      await navigator.clipboard.writeText(shareUrl);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch (err) {
      console.log("Copy failed", err);
    }
  };

  const handleDownloadQR = async () => {
    try {
      const dataUrl = await QRCode.toDataURL(shareUrl, {
        width: 1000,
        margin: 2,
        color: { dark: "#000000", light: "#ffffff" },
      });
      const link = document.createElement("a");
      link.href = dataUrl;
      link.download = `QR_Code_${name || "Card"}.png`;
      link.click();
    } catch (err) {
      console.error("QR Download failed", err);
    }
  };

  const shareNative = async () => {
    if (navigator.share) {
      try {
        await navigator.share({
          title: name,
          text: `Check out ${name}'s digital business card`,
          url: shareUrl,
        });
      } catch (error) {
        console.log("Error sharing:", error);
      }
    }
  };

  const handleDownloadVCard = () => {
    const fullName = name || "User";
    const nameParts = fullName.trim().split(" ");
    const firstName = nameParts[0] || "";
    const lastName = nameParts.slice(1).join(" ") || "";

    const vCardData = `BEGIN:VCARD
VERSION:3.0
N:${lastName};${firstName};;;
FN:${fullName}
TITLE:${title || ""}
ORG:${company || ""}
TEL:${phone || ""}
EMAIL:${email || ""}
URL:${data.website || ""}
ADR:;;${data.address || ""};${data.city || ""};${data.country || ""}
NOTE:${data.bio || ""}
X-SOCIALPROFILE;TYPE=linkedin:${data.linkedin || ""}
X-SOCIALPROFILE;TYPE=twitter:${data.twitter || ""}
END:VCARD`;

    const blob = new Blob([vCardData], { type: "text/vcard" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = `${(name || "Contact").replace(/\s+/g, "_")}.vcf`;
    link.click();

    // Show confirmation experience
    setShowConfirm(true);
  };

  const customIcons = {
    whatsapp: "/uploads/icons/WhatsApp.svg",
    linkedin: "/uploads/icons/linkedin.svg",
    instagram: "/uploads/icons/instagram.svg",
    twitter: "/uploads/icons/X Twitter.svg",
    github: "/uploads/icons/git hub.svg",
    website: "/uploads/icons/Global.svg",
    youtube: "/uploads/icons/YouTube.svg",
    calendly: "/uploads/icons/Calendly.svg",
    facebook: "/uploads/icons/facebook.png",
  };

  const socials = [
    { id: "whatsapp", value: data.whatsapp },
    { id: "linkedin", value: data.linkedin },
    { id: "instagram", value: data.instagram },
    { id: "twitter", value: data.twitter },
    { id: "facebook", value: data.facebook },
    { id: "github", value: data.github },
    { id: "youtube", value: data.youtube },
    { id: "website", value: data.website },
    { id: "calendly", value: data.calendly },
  ].filter((s) => s.value);

  return (
    <div className="w-full flex items-center justify-center p-0 sm:p-4 relative overflow-hidden">
      {/* Subtle Background Ambient */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <motion.div
          animate={{
            scale: [1, 1.2, 1],
            opacity: [0.3, 0.5, 0.3],
          }}
          transition={{ duration: 15, repeat: Infinity, ease: "linear" }}
          className="absolute -top-1/4 -left-1/4 w-[80%] h-[80%] rounded-full blur-[120px]"
          style={{ background: `radial-gradient(circle, ${themeColor} 0%, transparent 70%)` }}
        />
        <motion.div
          animate={{
            scale: [1, 1.3, 1],
            opacity: [0.2, 0.4, 0.2],
          }}
          transition={{ duration: 20, repeat: Infinity, ease: "linear", delay: 2 }}
          className="absolute -bottom-1/4 -right-1/4 w-[80%] h-[80%] rounded-full blur-[120px]"
          style={{ background: `radial-gradient(circle, var(--color-cyan) 0%, transparent 70%)` }}
        />
      </div>

      {/* Card Container — Premium Light Glass */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ type: "spring", damping: 28, stiffness: 120 }}
        className="relative w-full max-w-[390px] bg-white/80 backdrop-blur-2xl flex flex-col font-sans overflow-hidden rounded-[2.5rem] border border-white shadow-2xl"
        style={{
          boxShadow: `0 30px 60px -12px rgba(0,0,0,0.1), 0 0 40px -10px ${themeColor}15 inset`,
        }}
      >
        {/* Dynamic Background / Banner */}
        <div className="relative w-full h-40 overflow-hidden z-0 shrink-0">
          {data.bannerUrl ? (
            <img
              src={data.bannerUrl}
              alt="Banner"
              className="w-full h-full object-cover"
            />
          ) : (
            <div
              className="w-full h-full opacity-60"
              style={{
                background: `linear-gradient(135deg, ${themeColor}, var(--color-cyan))`,
              }}
            />
          )}
          {/* Fading overlay to blend banner into white card body */}
          <div className="absolute inset-0 bg-gradient-to-t from-white/90 via-white/20 to-transparent" />
          <div className="absolute bottom-0 inset-x-0 h-16 bg-gradient-to-t from-white to-transparent" />

          {/* Networking Status Badge On Banner */}
          {data.networkingStatus &&
            data.networkingStatus !== "Not Networking" && (
              <div className="absolute top-5 right-5 z-20">
                <span
                  className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-[9px] font-black uppercase tracking-widest border border-white/40 shadow-sm backdrop-blur-md bg-white/80"
                  style={{
                    color: getStatusColor(data.networkingStatus, themeColor),
                  }}
                >
                  <span
                    className="w-1.5 h-1.5 rounded-full animate-pulse shadow-sm"
                    style={{
                      background: getStatusColor(
                        data.networkingStatus,
                        themeColor,
                      ),
                      boxShadow: `0 0 8px ${getStatusColor(data.networkingStatus, themeColor)}`,
                    }}
                  />
                  {data.networkingStatus}
                </span>
              </div>
            )}
        </div>

        {/* Card Content Layer */}
        <div className="relative flex flex-col px-5 sm:px-8 pb-4 sm:pb-8 pt-0 z-10 w-full flex-1">
          {/* Header: Avatar & Identity (Adapting dynamically to cardLayout) */}
          {cardLayout === "minimal" ? (
            <div className="flex flex-col items-center text-center z-10 -mt-12 sm:-mt-14 mb-2">
              <div
                className="w-20 h-20 sm:w-24 sm:h-24 rounded-full border-[3px] border-white overflow-hidden bg-white shrink-0 shadow-xl mb-2 mx-auto"
              >
                {data.avatarUrl && !avatarError ? (
                  <img
                    src={data.avatarUrl}
                    alt={name || "Avatar"}
                    className="w-full h-full object-cover"
                    onError={() => setAvatarError(true)}
                  />
                ) : (
                  <div className="w-full h-full flex items-center justify-center text-3xl font-bold text-slate-300 bg-slate-50">
                    {name?.charAt(0) || "U"}
                  </div>
                )}
              </div>
              <div className="w-full text-center drop-shadow-[0_1px_1px_rgba(255,255,255,1)]">
                <h3 className="text-xl sm:text-2xl font-black text-[var(--color-ink-2)] tracking-tight leading-snug break-words">
                  {name || "User"}
                </h3>
                <p className="text-xs sm:text-sm font-semibold text-slate-500 mt-0.5 line-clamp-2 break-words">
                  {title || "Professional"}
                </p>
                {company && (
                  <div className="inline-flex items-center justify-center gap-1.5 text-[9px] font-black text-indigo-600 uppercase tracking-[0.15em] mt-1.5 px-3 py-0.5 rounded-full bg-slate-100 border border-slate-200">
                    <span className="w-1.5 h-1.5 rounded-full bg-indigo-500 shrink-0" />
                    <span className="break-words">{company}</span>
                  </div>
                )}
              </div>
            </div>
          ) : cardLayout === "banner-right" ? (
            <div className="flex items-center justify-between gap-3.5 sm:gap-4 z-10 -mt-10">
              <div className="min-w-0 flex-1 pt-6 sm:pt-8 drop-shadow-[0_1px_1px_rgba(255,255,255,1)] text-left">
                <h3 className="text-xl sm:text-2xl font-black text-[var(--color-ink-2)] tracking-tight leading-snug break-words">
                  {name || "User"}
                </h3>
                <p className="text-xs sm:text-sm font-semibold text-slate-500 mt-0.5 line-clamp-2 break-words">
                  {title || "Professional"}
                </p>
                {company && (
                  <div className="flex items-center gap-1.5 text-[9px] font-black text-indigo-600 uppercase tracking-[0.15em] mt-1.5 flex-wrap">
                    <span className="w-1.5 h-1.5 rounded-full bg-indigo-500 shrink-0" />
                    <span className="break-words">{company}</span>
                  </div>
                )}
              </div>
              <div
                className="w-20 h-20 sm:w-24 sm:h-24 rounded-full border-[3px] border-white overflow-hidden bg-white shrink-0 shadow-xl"
              >
                {data.avatarUrl && !avatarError ? (
                  <img
                    src={data.avatarUrl}
                    alt={name || "Avatar"}
                    className="w-full h-full object-cover"
                    onError={() => setAvatarError(true)}
                  />
                ) : (
                  <div className="w-full h-full flex items-center justify-center text-3xl font-bold text-slate-300 bg-slate-50">
                    {name?.charAt(0) || "U"}
                  </div>
                )}
              </div>
            </div>
          ) : cardLayout === "wide" ? (
            <div className="z-10 pt-2 mb-2">
              <div className="flex items-center gap-3.5 p-3 rounded-2xl bg-white/90 border border-slate-200 shadow-md">
                <div
                  className="w-16 h-16 sm:w-18 sm:h-18 rounded-2xl border-2 border-white overflow-hidden bg-white shrink-0 shadow-sm"
                >
                  {data.avatarUrl && !avatarError ? (
                    <img
                      src={data.avatarUrl}
                      alt={name || "Avatar"}
                      className="w-full h-full object-cover rounded-2xl"
                      onError={() => setAvatarError(true)}
                    />
                  ) : (
                    <div className="w-full h-full flex items-center justify-center text-2xl font-bold text-slate-300 bg-slate-50">
                      {name?.charAt(0) || "U"}
                    </div>
                  )}
                </div>
                <div className="min-w-0 flex-1 text-left">
                  <h3 className="text-lg sm:text-xl font-black text-[var(--color-ink-2)] tracking-tight leading-snug break-words">
                    {name || "User"}
                  </h3>
                  <p className="text-xs font-semibold text-slate-500 mt-0.5 truncate">
                    {title || "Professional"}
                  </p>
                  {company && (
                    <div className="flex items-center gap-1.5 text-[9px] font-black text-indigo-600 uppercase tracking-[0.15em] mt-1 truncate">
                      <span className="w-1.5 h-1.5 rounded-full bg-indigo-500 shrink-0" />
                      <span className="truncate">{company}</span>
                    </div>
                  )}
                </div>
              </div>
            </div>
          ) : (
            /* Default: Editorial / Left Avatar */
            <div className="flex items-center gap-3.5 sm:gap-4 z-10 -mt-10">
              <div
                className="w-20 h-20 sm:w-24 sm:h-24 rounded-full border-[3px] border-white overflow-hidden bg-white shrink-0 shadow-xl"
              >
                {data.avatarUrl && !avatarError ? (
                  <img
                    src={data.avatarUrl}
                    alt={name || "Avatar"}
                    className="w-full h-full object-cover"
                    onError={() => setAvatarError(true)}
                  />
                ) : (
                  <div className="w-full h-full flex items-center justify-center text-3xl font-bold text-slate-300 bg-slate-50">
                    {name?.charAt(0) || "U"}
                  </div>
                )}
              </div>
              <div className="min-w-0 flex-1 pt-6 sm:pt-8 drop-shadow-[0_1px_1px_rgba(255,255,255,1)]">
                <h3 className="text-xl sm:text-2xl font-black text-[var(--color-ink-2)] tracking-tight leading-snug break-words">
                  {name || "User"}
                </h3>
                <p className="text-xs sm:text-sm font-semibold text-slate-500 mt-0.5 line-clamp-2 break-words">
                  {title || "Professional"}
                </p>
                {company && (
                  <div className="flex items-center gap-1.5 text-[9px] font-black text-indigo-600 uppercase tracking-[0.15em] mt-1.5 flex-wrap">
                    <span className="w-1.5 h-1.5 rounded-full bg-indigo-500 shrink-0" />
                    <span className="break-words">{company}</span>
                  </div>
                )}
              </div>
            </div>
          )}
        </div>

        {/* Content Body */}
        <div className="p-5 space-y-6 flex-1 overflow-y-auto pb-6">
          {/* Primary Action Buttons */}
          <div className="grid grid-cols-2 gap-3 mb-6">
            <motion.button
              onClick={() => {
                if (!email) return;
                // On mobile, open mail app; on desktop, copy to clipboard
                const isMobile = /Android|iPhone|iPad|iPod/i.test(navigator.userAgent);
                if (isMobile) {
                  window.location.href = `mailto:${email}`;
                } else {
                  navigator.clipboard.writeText(email).then(() => {
                    setCopied("email");
                    setTimeout(() => setCopied(false), 2000);
                  });
                }
              }}
              whileHover={{ scale: 1.02, backgroundColor: "rgba(255, 255, 255, 0.9)" }}
              whileTap={{ scale: 0.98 }}
              className="bg-white/80 backdrop-blur-sm border border-white shadow-sm rounded-2xl py-4 flex items-center justify-center gap-3 transition-all duration-300 relative hover:shadow-md"
            >
              <Mail size={18} className="text-slate-600" />
              <span className="text-[13px] font-bold text-[var(--color-ink-2)] tracking-wide">
                {copied === "email" ? "Copied!" : "Email"}
              </span>
            </motion.button>
            <motion.button
              onClick={() => {
                if (!phone) return;
                const isMobile = /Android|iPhone|iPad|iPod/i.test(navigator.userAgent);
                if (isMobile) {
                  window.location.href = `tel:${phone}`;
                } else {
                  navigator.clipboard.writeText(phone).then(() => {
                    setCopied("phone");
                    setTimeout(() => setCopied(false), 2000);
                  });
                }
              }}
              whileHover={{ scale: 1.02, backgroundColor: "rgba(255, 255, 255, 0.9)" }}
              whileTap={{ scale: 0.98 }}
              className="bg-white/80 backdrop-blur-sm border border-white shadow-sm rounded-2xl py-4 flex items-center justify-center gap-3 transition-all duration-300 relative hover:shadow-md"
            >
              <Phone size={18} className="text-slate-600" />
              <span className="text-[13px] font-bold text-[var(--color-ink-2)] tracking-wide">
                {copied === "phone" ? "Copied!" : "Contact"}
              </span>
            </motion.button>
          </div>

          {/* Social Icons */}
          <div className="flex items-center justify-center w-full">
            <div
              className="flex flex-wrap items-center justify-center gap-3"
              style={socials.length >= 8 ? { maxWidth: "305px" } : {}}
            >
              {socials.length > 0 &&
                socials.map((s) => {
                  const url = resolveSocialUrl(s.id, s.value);
                  const customIconPath = customIcons[s.id];
                  return (
                    <motion.a
                      key={s.id}
                      href={url}
                      target="_blank"
                      rel="noopener noreferrer"
                      whileHover={{ y: -3, scale: 1.1 }}
                      className="w-11 h-11 shrink-0 rounded-full bg-white flex items-center justify-center border border-white shadow-sm hover:shadow-md transition-all overflow-hidden"
                    >
                      {customIconPath ? (
                        <img src={customIconPath} alt={s.id} className="w-full h-full object-cover" />
                      ) : (
                        <div className="p-2.5 text-slate-500">
                          <LinkIcon size={20} />
                        </div>
                      )}
                    </motion.a>
                  );
                })}
            </div>
          </div>

          {/* Location Badge */}
          {(data.city || data.address) && (
            <div className="flex items-center gap-2 text-slate-500 bg-white/60 px-4 py-2 rounded-full border border-white shadow-sm backdrop-blur-md w-fit">
              <MapPin size={12} className="text-sky-500" />
              <span className="text-[10px] font-black uppercase tracking-[0.15em]">
                {data.city || data.address}
              </span>
            </div>
          )}

          {/* Bio Section */}
          {data.bio && (
            <div className="space-y-2.5">
              <h4 className="text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] ml-1">Bio</h4>
              <div className="bg-white/60 backdrop-blur-md border border-white rounded-[1rem] p-5 relative shadow-sm">
                <div
                  className="text-[13px] text-slate-600 font-medium leading-relaxed overflow-hidden transition-all duration-300"
                  style={!isBioExpanded ? {
                    display: "-webkit-box",
                    WebkitLineClamp: "3",
                    WebkitBoxOrient: "vertical",
                    maxHeight: "4.5rem",
                  } : {}}
                >
                  {data.bio}
                </div>
                {data.bio.length > 80 && (
                  <button
                    onClick={() => setIsBioExpanded(!isBioExpanded)}
                    className="mt-3 text-[10px] font-black uppercase tracking-widest hover:text-slate-900 transition-colors"
                    style={{ color: themeColor }}
                  >
                    {isBioExpanded ? "LESS" : "MORE"}
                  </button>
                )}
              </div>
            </div>
          )}

          {/* Exp. Matrix Section */}
          {data.experience && (
            <div className="space-y-2.5">
              <h4 className="text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] ml-1">Experience</h4>
              <div className="bg-white/60 backdrop-blur-md border border-white rounded-[1rem] p-5 relative shadow-sm">
                <div
                  className={`text-[12px] text-slate-600 font-medium overflow-hidden transition-all duration-300 ${!isExpExpanded ? "max-h-[58px]" : "max-h-[2000px]"}`}
                  style={{ lineHeight: "1.6" }}
                >
                  <div className="space-y-3">
                    {data.experience.split("\n").map((line, idx) => (
                      <div key={idx} className="flex items-start gap-2.5">
                        <span className="mt-[6px] w-1.5 h-1.5 bg-slate-300 rounded-full shrink-0" />
                        <span className="leading-tight">{line}</span>
                      </div>
                    ))}
                  </div>
                </div>
                {data.experience.length > 100 && (
                  <button
                    onClick={() => setIsExpExpanded(!isExpExpanded)}
                    className="mt-4 text-[10px] font-black uppercase tracking-widest hover:text-slate-900 transition-colors"
                    style={{ color: themeColor }}
                  >
                    {isExpExpanded ? "LESS" : "MORE"}
                  </button>
                )}
              </div>
            </div>
          )}

          {/* Documents Section */}
          {(data.resumeUrl || data.brochureUrl) && (
            <div className="space-y-2.5">
              <h4 className="text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] ml-1">Documents</h4>
              <div className="space-y-2.5">
                {data.resumeUrl && (
                  <div className="bg-white/60 backdrop-blur-md border border-white rounded-[1rem] p-4 flex items-center justify-between gap-3 shadow-sm hover:shadow-md transition-shadow">
                    <div className="flex items-center gap-3 min-w-0">
                      <div className="w-10 h-10 rounded-xl bg-indigo-50 flex items-center justify-center shrink-0 border border-indigo-100">
                        <FileText size={18} className="text-indigo-600" />
                      </div>
                      <div className="min-w-0">
                        <div className="text-sm font-bold text-slate-700">Resume / CV</div>
                        <p className="text-[10px] text-slate-400 font-medium truncate mt-0.5">
                          {data.resumeUrl.split("/").pop()}
                        </p>
                      </div>
                    </div>
                    <div className="flex items-center gap-2 shrink-0">
                      <a
                        href={data.resumeUrl}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="w-8 h-8 rounded-lg bg-slate-50 border border-slate-200 flex items-center justify-center text-slate-500 hover:bg-slate-100 hover:text-indigo-600 transition-all"
                        title="View"
                      >
                        <ExternalLink size={14} />
                      </a>
                      <a
                        href={data.resumeUrl}
                        download
                        className="w-8 h-8 rounded-lg bg-slate-50 border border-slate-200 flex items-center justify-center text-slate-500 hover:bg-slate-100 hover:text-indigo-600 transition-all"
                        title="Download"
                      >
                        <Download size={14} />
                      </a>
                    </div>
                  </div>
                )}
                {data.brochureUrl && (
                  <div className="bg-white/60 backdrop-blur-md border border-white rounded-[1rem] p-4 flex items-center justify-between gap-3 shadow-sm hover:shadow-md transition-shadow">
                    <div className="flex items-center gap-3 min-w-0">
                      <div className="w-10 h-10 rounded-xl bg-sky-50 flex items-center justify-center shrink-0 border border-sky-100">
                        <BookOpen size={18} className="text-sky-600" />
                      </div>
                      <div className="min-w-0">
                        <div className="text-sm font-bold text-slate-700">Company Brochure</div>
                        <p className="text-[10px] text-slate-400 font-medium truncate mt-0.5">
                          {data.brochureUrl.split("/").pop()}
                        </p>
                      </div>
                    </div>
                    <div className="flex items-center gap-2 shrink-0">
                      <a
                        href={data.brochureUrl}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="w-8 h-8 rounded-lg bg-slate-50 border border-slate-200 flex items-center justify-center text-slate-500 hover:bg-slate-100 hover:text-sky-600 transition-all"
                        title="View"
                      >
                        <ExternalLink size={14} />
                      </a>
                      <a
                        href={data.brochureUrl}
                        download
                        className="w-8 h-8 rounded-lg bg-slate-50 border border-slate-200 flex items-center justify-center text-slate-500 hover:bg-slate-100 hover:text-sky-600 transition-all"
                        title="Download"
                      >
                        <Download size={14} />
                      </a>
                    </div>
                  </div>
                )}
              </div>
            </div>
          )}


          {/* Footer Save / Share Buttons */}
          <div className="grid grid-cols-2 gap-4 pt-4 pb-2">
            <motion.button
              onClick={handleDownloadVCard}
              whileHover={{ scale: 1.02, filter: "brightness(1.1)" }}
              whileTap={{ scale: 0.98 }}
              className="bg-gradient-to-br from-[#6366f1] via-[#2563eb] to-[#06b6d4] border border-white/20 rounded-[0.6rem] py-4 text-sm font-bold text-white shadow-[0_10px_40px_rgba(99,102,241,0.4)] transition-all cursor-pointer"
            >
              Save
            </motion.button>
            <motion.button
              onClick={() => { setShowShareMenu(true); setShowQr(false); }}
              whileHover={{ scale: 1.02, filter: "brightness(1.1)" }}
              whileTap={{ scale: 0.98 }}
              className="bg-gradient-to-br from-[#6366f1] via-[#2563eb] to-[#06b6d4] border border-white/20 rounded-[0.6rem] py-4 text-sm font-bold text-white shadow-[0_10px_40px_rgba(99,102,241,0.4)] transition-all cursor-pointer"
            >
              Share
            </motion.button>
          </div>

          {/* Bottom Footer Text */}
          <div className="pt-6 flex items-center justify-center w-full pb-4">
            <div
              className="text-[9px] font-black uppercase tracking-[0.2em] text-center text-slate-400"
            >
              Powered by <span style={{ color: themeColor }}>My Card Share</span>
            </div>
          </div>
        </div>

        {/* Share Sub-Menu Overlay */}
        <AnimatePresence>
          {showShareMenu && (
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="absolute inset-0 bg-slate-900/40 backdrop-blur-md z-50 flex items-center justify-center px-4 rounded-[2.5rem]"
            >
              <motion.div
                initial={{ scale: 0.9, opacity: 0, y: 10 }}
                animate={{ scale: 1, opacity: 1, y: 0 }}
                exit={{ scale: 0.95, opacity: 0, y: 5 }}
                transition={{ type: "spring", damping: 25, stiffness: 300 }}
                className="w-full bg-white/95 backdrop-blur-xl p-6 rounded-3xl border border-white shadow-2xl relative"
                onClick={(e) => e.stopPropagation()}
              >
                <button
                  onClick={() => { setShowShareMenu(false); setShowQr(false); }}
                  className="absolute top-4 right-4 p-2 text-slate-400 hover:text-slate-800 bg-slate-100 hover:bg-slate-200 rounded-full transition-colors"
                >
                  <X size={14} strokeWidth={3} />
                </button>

                <h4 className="text-slate-800 font-black text-[12px] mb-4 uppercase tracking-[0.2em] text-center">
                  Share Card
                </h4>

                {/* URL Preview */}
                <div className="mb-5 px-3 py-2.5 rounded-xl bg-slate-50 border border-slate-200 flex items-center gap-2 overflow-hidden shadow-inner">
                  <LinkIcon size={14} className="text-slate-400 shrink-0" />
                  <code className="text-[11px] text-slate-600 font-mono font-medium truncate flex-1">
                    {shareUrl}
                  </code>
                </div>

                {showQr ? (
                  <motion.div
                    initial={{ opacity: 0, scale: 0.95 }}
                    animate={{ opacity: 1, scale: 1 }}
                    className="flex flex-col items-center gap-5"
                  >
                    <div className="p-4 bg-white rounded-2xl shadow-[0_4px_20px_rgba(0,0,0,0.08)] border border-slate-100">
                      <QRPreview url={shareUrl} />
                    </div>
                    <div className="flex flex-col items-center gap-3">
                      <button
                        onClick={handleDownloadQR}
                        className="text-[9px] font-black bg-indigo-600 text-white px-6 py-2.5 rounded-full hover:bg-indigo-700 transition-colors uppercase tracking-widest shadow-md"
                      >
                        Download QR
                      </button>
                      <button
                        onClick={() => setShowQr(false)}
                        className="text-[9px] font-black text-slate-400 uppercase tracking-widest hover:text-slate-700 transition-colors mt-1"
                      >
                        Back to Options
                      </button>
                    </div>
                  </motion.div>
                ) : (
                  <div className="grid grid-cols-2 gap-3">
                    <button
                      onClick={handleCopyLink}
                      className="flex flex-col items-center justify-center gap-2 p-5 rounded-2xl bg-white border border-slate-200 hover:border-indigo-300 hover:bg-indigo-50/50 transition-all group shadow-sm hover:shadow-md"
                    >
                      {copied ? (
                        <CheckCircle2 size={26} className="text-emerald-500" />
                      ) : (
                        <LinkIcon size={26} className="text-slate-400 group-hover:text-indigo-500 transition-colors" />
                      )}
                      <span className="text-[10px] font-black uppercase tracking-widest text-slate-500 group-hover:text-indigo-600 transition-colors">
                        {copied ? "Copied!" : "Copy Link"}
                      </span>
                    </button>

                    <button
                      onClick={() => setShowQr(true)}
                      className="flex flex-col items-center justify-center gap-2 p-5 rounded-2xl bg-white border border-slate-200 hover:border-sky-300 hover:bg-sky-50/50 transition-all group shadow-sm hover:shadow-md"
                    >
                      <QrCode size={26} className="text-sky-500 group-hover:text-sky-600 transition-colors" />
                      <span className="text-[10px] font-black uppercase tracking-widest text-slate-500 group-hover:text-sky-600 transition-colors">
                        QR Code
                      </span>
                    </button>

                    {canShare && (
                      <button
                        onClick={shareNative}
                        className="col-span-2 mt-2 py-3.5 rounded-xl border border-slate-200 bg-slate-50 hover:bg-slate-100 text-[10px] font-black uppercase tracking-widest text-slate-600 hover:text-slate-900 transition-all flex items-center justify-center gap-2 shadow-sm"
                      >
                        <Share2 size={14} /> Device Share
                      </button>
                    )}
                  </div>
                )}
              </motion.div>
            </motion.div>
          )}
        </AnimatePresence>

        {/* Post-Save Confirmation Experience */}
        <Conformation
          isOpen={showConfirm}
          onClose={() => setShowConfirm(false)}
          userName={name}
          themeColor={themeColor}
        />
      </motion.div>
    </div>
  );
}
