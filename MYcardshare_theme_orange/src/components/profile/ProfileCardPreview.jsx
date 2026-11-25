"use client";

import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  Mail,
  Phone,
  Globe,
  Linkedin,
  Twitter,
  Instagram,
  Github,
  Youtube,
  MessageCircle,
  MapPin,
  Plus,
  Share2,
  X,
  QrCode,
  Link as LinkIcon,
  CheckCircle2,
  Facebook,
  Calendar,
  FileText,
  BookOpen,
  Download,
  ExternalLink,
} from "lucide-react";
import { UiloraBrandButton } from "../UIComponents/Button/tsx/UiloraModernButtons";
import QRCode from "qrcode";
import Confirmation from "../card/Confirmation";
import { getCardShareUrl } from "@/lib/urls";

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
    "Actively Networking": "#10b981", // emerald-500
    "Open to Collaborations": "#38bdf8", // sky-400
    "Available for Hire": "#fbbf24", // amber-400
    "Looking for Co-founder": "#c084fc", // purple-400
    "Open to Freelance": "#2dd4bf", // teal-400
    "Seeking Mentorship": "#fb923c", // orange-400
    "Offering Mentorship": "#818cf8", // indigo-400
    "Open to Speaking": "#fb7185", // rose-400
    Investor: "#facc15", // yellow-400
    "Building in Stealth": "#94a3b8", // slate-400
  };
  return colors[status] || fallback;
}

export default function ProfileCardPreview({ data, onPopupToggle }) {
  const themeColor = data.themeColor || "#6366f1";
  const cardLayout = data.cardLayout || "editorial";

  const [showShareMenu, setShowShareMenu] = useState(false);
  const [copied, setCopied] = useState(false);
  const [showQr, setShowQr] = useState(false);
  const [isExpExpanded, setIsExpExpanded] = useState(false);
  const [isBioExpanded, setIsBioExpanded] = useState(false);
  const [showConfirm, setShowConfirm] = useState(false);

  // Sync popup state with parent to hide external floating buttons
  useEffect(() => {
    if (onPopupToggle) {
      onPopupToggle(showConfirm || showShareMenu);
    }
  }, [showConfirm, showShareMenu, onPopupToggle]);

  const slug = (data.slug || data.cardSlug || "").toString().trim();
  const shareUrl = getCardShareUrl(slug);
  const hasPublicCard = Boolean(slug) && data.cardStatus === "Published";

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
        color: {
          dark: "#000000",
          light: "#ffffff",
        },
      });

      const link = document.createElement("a");
      link.href = dataUrl;
      link.download = `QR_Code_${data.name || "Card"}.png`;
      link.click();
    } catch (err) {
      console.error("QR Download failed", err);
    }
  };

  const shareNative = async () => {
    if (navigator.share) {
      try {
        await navigator.share({
          title: data.name,
          text: `Check out ${data.name}'s digital business card`,
          url: shareUrl,
        });
      } catch (error) {
        console.log("Error sharing:", error);
      }
    }
  };

  const handleDownloadVCard = () => {
    const fullName = data.name || "User";
    const nameParts = fullName.trim().split(" ");
    const firstName = nameParts[0] || "";
    const lastName = nameParts.slice(1).join(" ") || "";

    const vCardData = `BEGIN:VCARD
VERSION:3.0
N:${lastName};${firstName};;;
FN:${fullName}
TITLE:${data.title || ""}
ORG:${data.company || ""}
TEL:${data.phone || ""}
EMAIL:${data.email || ""}
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
    link.download = `${(data.name || "Contact").replace(/\s+/g, "_")}.vcf`;
    link.click();

    // Show confirmation experience
    setShowConfirm(true);
  };

  const socialIcons = {
    linkedin: Linkedin,
    twitter: Twitter,
    instagram: Instagram,
    github: Github,
    youtube: Youtube,
    whatsapp: MessageCircle,
    website: Globe,
    facebook: Facebook,
    calendly: Calendar,
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
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="relative w-full rounded-[2.5rem] overflow-hidden bg-white/70 backdrop-blur-2xl shadow-2xl border border-white group flex flex-col font-sans"
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
        <div className="absolute inset-0 bg-gradient-to-t from-white/30 to-transparent to-[50%]" />
        <div className="absolute top-0 inset-x-0 h-px bg-gradient-to-r from-transparent via-white/40 to-transparent" />

        {/* Networking Status Badge On Banner */}
        {data.networkingStatus &&
          data.networkingStatus !== "Not Networking" && (
            <div className="absolute top-5 right-5 z-20">
              <span
                className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-[9px] font-black uppercase tracking-widest border border-white/10 shadow-lg backdrop-blur-md bg-black/50"
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
      <div className="relative flex flex-col px-6 sm:px-8 pb-6 sm:pb-8 pt-4 z-10 w-full flex-1">
        {/* Header: Avatar & Identity (Adapting dynamically to cardLayout) */}
        {cardLayout === "minimal" ? (
          <div className="relative mb-5 flex flex-col items-center text-center -mt-10 sm:-mt-12">
            <div className="relative shrink-0 mb-2">
              <motion.div
                whileHover={{ scale: 1.05 }}
                className="w-18 h-18 sm:w-20 sm:h-20 rounded-full overflow-hidden border-2 border-white shadow-[0_10px_30px_rgba(0,0,0,0.1)] bg-white backdrop-blur-md mx-auto"
                style={{
                  boxShadow: `0 0 30px ${themeColor}33`,
                  width: 72,
                  height: 72,
                }}
              >
                {data.avatarUrl ? (
                  <img
                    src={data.avatarUrl}
                    alt="Avatar"
                    className="w-full h-full object-cover"
                  />
                ) : (
                  <div className="w-full h-full flex items-center justify-center text-2xl font-black text-slate-300">
                    {data.name?.charAt(0) || "U"}
                  </div>
                )}
              </motion.div>
              <div className="absolute top-[-3px] right-[-3px] bg-white p-1 rounded-full z-20 shadow-sm border border-slate-100">
                <div className="w-2.5 h-2.5 rounded-full bg-emerald-400 shadow-[0_0_12px_rgba(52,211,153,0.8)]" />
              </div>
            </div>

            <div className="w-full text-center">
              <h3 className="text-lg sm:text-xl font-black text-[var(--color-ink-2)] tracking-tight leading-tight drop-shadow-sm line-clamp-2 break-words">
                {data.name || "Alex Morgan"}
              </h3>
              <p className="text-[11px] sm:text-[12px] font-semibold text-slate-500 tracking-wide mt-1 truncate">
                {data.title || "Creative Director"}
              </p>
              {data.company && (
                <div className="inline-flex items-center justify-center gap-1.5 text-[9px] font-bold text-sky-500 uppercase tracking-[0.2em] mt-1.5 px-3 py-0.5 rounded-full bg-slate-100 border border-slate-200 truncate">
                  <span className="w-1 h-1 rounded-full bg-sky-500 shrink-0" />
                  <span className="truncate">{data.company}</span>
                </div>
              )}
            </div>
          </div>
        ) : cardLayout === "banner-right" ? (
          <div className="relative mb-5 flex items-center justify-between gap-4">
            <div className="flex-1 min-w-0 text-left">
              <h3 className="text-lg sm:text-xl font-black text-[var(--color-ink-2)] tracking-tight leading-tight drop-shadow-sm line-clamp-2 break-words">
                {data.name || "Alex Morgan"}
              </h3>
              <p className="text-[11px] sm:text-[12px] font-semibold text-slate-500 tracking-wide mt-1 truncate">
                {data.title || "Creative Director"}
              </p>
              {data.company && (
                <div className="flex items-center gap-1.5 text-[9px] font-bold text-sky-500 uppercase tracking-[0.2em] mt-1.5 truncate">
                  <span className="w-1 h-1 rounded-full bg-sky-500 shrink-0" />
                  <span className="truncate">{data.company}</span>
                </div>
              )}
            </div>
            <div className="relative shrink-0">
              <motion.div
                whileHover={{ scale: 1.05 }}
                className="w-18 h-18 sm:w-20 sm:h-20 rounded-2xl overflow-hidden border border-white/50 shadow-[0_10px_30px_rgba(0,0,0,0.1)] bg-white backdrop-blur-md"
                style={{
                  boxShadow: `0 0 30px ${themeColor}33`,
                  width: 72,
                  height: 72,
                }}
              >
                {data.avatarUrl ? (
                  <img
                    src={data.avatarUrl}
                    alt="Avatar"
                    className="w-full h-full object-cover"
                  />
                ) : (
                  <div className="w-full h-full flex items-center justify-center text-2xl font-black text-slate-300">
                    {data.name?.charAt(0) || "U"}
                  </div>
                )}
              </motion.div>
              <div className="absolute top-[-3px] right-[-3px] bg-white p-1 rounded-full z-20 shadow-sm border border-slate-100">
                <div className="w-2.5 h-2.5 rounded-full bg-emerald-400 shadow-[0_0_12px_rgba(52,211,153,0.8)]" />
              </div>
            </div>
          </div>
        ) : cardLayout === "wide" ? (
          <div className="relative mb-5">
            <div className="flex items-center gap-4 p-3 rounded-2xl bg-slate-50 border border-slate-200 shadow-sm">
              <div className="relative shrink-0">
                <div
                  className="w-16 h-16 rounded-2xl overflow-hidden border border-white/80 shadow-md bg-white"
                  style={{ width: 64, height: 64 }}
                >
                  {data.avatarUrl ? (
                    <img
                      src={data.avatarUrl}
                      alt="Avatar"
                      className="w-full h-full object-cover rounded-2xl"
                    />
                  ) : (
                    <div className="w-full h-full flex items-center justify-center text-xl font-black text-slate-300">
                      {data.name?.charAt(0) || "U"}
                    </div>
                  )}
                </div>
              </div>
              <div className="flex-1 min-w-0 text-left">
                <h3 className="text-base sm:text-lg font-black text-[var(--color-ink-2)] tracking-tight leading-tight line-clamp-2 break-words">
                  {data.name || "Alex Morgan"}
                </h3>
                <p className="text-[11px] font-semibold text-slate-500 tracking-wide mt-0.5 truncate">
                  {data.title || "Creative Director"}
                </p>
                {data.company && (
                  <div className="flex items-center gap-1.5 text-[9px] font-bold text-sky-500 uppercase tracking-[0.2em] mt-1 truncate">
                    <span className="w-1 h-1 rounded-full bg-sky-500 shrink-0" />
                    <span className="truncate">{data.company}</span>
                  </div>
                )}
              </div>
            </div>
          </div>
        ) : (
          /* Default: Editorial / Left Avatar */
          <div className="relative mb-5 flex items-center gap-4">
            <div className="relative shrink-0">
              <motion.div
                whileHover={{ scale: 1.05 }}
                className="w-18 h-18 sm:w-20 sm:h-20 rounded-2xl overflow-hidden border border-white/50 shadow-[0_10px_30px_rgba(0,0,0,0.1)] bg-white backdrop-blur-md"
                style={{
                  boxShadow: `0 0 30px ${themeColor}33`,
                  width: 72,
                  height: 72,
                }}
              >
                {data.avatarUrl ? (
                  <img
                    src={data.avatarUrl}
                    alt="Avatar"
                    className="w-full h-full object-cover"
                  />
                ) : (
                  <div className="w-full h-full flex items-center justify-center text-2xl font-black text-slate-300">
                    {data.name?.charAt(0) || "U"}
                  </div>
                )}
              </motion.div>
              <div className="absolute top-[-3px] right-[-3px] bg-white p-1 rounded-full z-20 shadow-sm border border-slate-100">
                <div className="w-2.5 h-2.5 rounded-full bg-emerald-400 shadow-[0_0_12px_rgba(52,211,153,0.8)]" />
              </div>
            </div>

            <div className="flex-1 min-w-0">
              <h3 className="text-lg sm:text-xl font-black text-[var(--color-ink-2)] tracking-tight leading-tight drop-shadow-sm line-clamp-2 break-words">
                {data.name || "Alex Morgan"}
              </h3>
              <p className="text-[11px] sm:text-[12px] font-semibold text-slate-500 tracking-wide mt-1 truncate">
                {data.title || "Creative Director"}
              </p>
              {data.company && (
                <div className="flex items-center gap-1.5 text-[9px] font-bold text-sky-500 uppercase tracking-[0.2em] mt-1.5 truncate">
                  <span className="w-1 h-1 rounded-full bg-sky-500 shrink-0" />
                  <span className="truncate">{data.company}</span>
                </div>
              )}
            </div>
          </div>
        )}

        {/* Action Grid (Ovals) */}
        <div className="grid grid-cols-2 gap-3 mb-4">
          <a
            href={`mailto:${data.email || ""}`}
            className="py-3 px-2 rounded-2xl bg-white/40 border border-white flex flex-col items-center gap-2 hover:bg-white/60 transition-all cursor-pointer shadow-sm group/btn"
          >
            <Mail
              size={16}
              className="text-slate-400 group-hover/btn:text-[var(--color-ink-2)] transition-colors"
            />
            <span className="text-[8px] font-black uppercase text-slate-500 tracking-widest group-hover/btn:text-[var(--color-ink-2)]">
              Email
            </span>
          </a>
          <a
            href={`tel:${data.phone || ""}`}
            className="py-3 px-2 rounded-2xl bg-white/40 border border-white flex flex-col items-center gap-2 hover:bg-white/60 transition-all cursor-pointer shadow-sm group/btn"
          >
            <Phone
               size={16}
              className="text-slate-400 group-hover/btn:text-[var(--color-ink-2)] transition-colors"
            />
            <span className="text-[8px] font-black uppercase text-slate-500 tracking-widest group-hover/btn:text-[var(--color-ink-2)]">
              Contact
            </span>
          </a>
        </div>

        {/* Centered Social Icons */}
        <div className="flex items-center justify-center mb-4 w-full">
          <div
            className="flex flex-wrap items-center justify-center gap-2.5"
            style={socials.length >= 8 ? { maxWidth: "270px" } : {}}
          >
            {socials.length > 0 ? (
              socials.map((s) => {
                const Icon = socialIcons[s.id] || LinkIcon;
                const customIconPath = customIcons[s.id];
                const url = resolveSocialUrl(s.id, s.value);
                return (
                  <motion.a
                    key={s.id}
                    href={url}
                    target="_blank"
                    rel="noopener noreferrer"
                    whileHover={{ y: -3, scale: 1.1 }}
                    className="w-9 h-9 shrink-0 rounded-full bg-white flex items-center justify-center text-slate-400 hover:text-[var(--color-ink)] border border-slate-100 shadow-sm overflow-hidden p-0"
                  >
                    {customIconPath ? (
                      <img src={customIconPath} alt={s.id} className="w-full h-full object-cover" />
                    ) : (
                      <div className="p-2.5">
                        <Icon size={18} strokeWidth={1.5} />
                      </div>
                    )}
                  </motion.a>
                );
              })
            ) : (
              <div className="text-[8px] font-bold text-slate-600 uppercase tracking-widest italic py-2">
                Expand your network by adding socials
              </div>
            )}
          </div>
        </div>

        {/* Left-Aligned Location */}
        {(data.city || data.address) && (
          <div className="mb-6 flex items-center gap-2 text-slate-500 bg-white/40 px-3 py-1.5 rounded-full border border-white w-fit shadow-sm">
            <MapPin size={12} className="text-sky-500" />
            <span className="text-[9px] font-black uppercase tracking-[0.15em]">
              {data.city || data.address}
            </span>
          </div>
        )}

        {/* Experience + Bio */}
        <div className="space-y-4 mb-5 w-full">
          {data.experience && (
            <div className="bg-white/80 backdrop-blur-sm border border-[#EAE2DB] p-4 sm:p-5 rounded-2xl shadow-xs w-full">
              <div className="text-[9px] font-black uppercase text-[#D4622C] tracking-widest mb-2">
                Experience
              </div>
              <p className={`text-[11px] text-[#57534E] leading-[1.6] whitespace-pre-line pr-2 ${!isExpExpanded ? "line-clamp-3" : ""}`}>
                {data.experience}
              </p>
              {data.experience.length > 100 && (
                <button
                  onClick={() => setIsExpExpanded(!isExpExpanded)}
                  className="text-[9px] font-bold text-[#D4622C] mt-1.5 hover:text-[#BD5523] transition-colors uppercase tracking-widest"
                >
                  {isExpExpanded ? "Less" : "More"}
                </button>
              )}
            </div>
          )}
          {data.bio && (
            <div className="bg-white/80 backdrop-blur-sm border border-[#EAE2DB] p-4 sm:p-5 rounded-2xl shadow-xs w-full">
              <div className="text-[9px] font-black uppercase text-[#77716C] tracking-widest mb-2">
                Bio
              </div>
              <div className="relative">
                <p className={`text-[11px] text-[#57534E] leading-[1.6] whitespace-pre-line pr-2 ${!isBioExpanded ? "line-clamp-3" : ""}`}>
                  {data.bio}
                </p>
                {data.bio.length > 80 && (
                  <button
                    onClick={() => setIsBioExpanded(!isBioExpanded)}
                    className="text-[9px] font-bold text-[#77716C] mt-1.5 hover:text-[#191919] transition-colors uppercase tracking-widest"
                  >
                    {isBioExpanded ? "Less" : "More"}
                  </button>
                )}
              </div>
            </div>
          )}
        </div>

        {/* Documents Section */}
        {(data.resumeUrl || data.brochureUrl) && (
          <div className="space-y-2.5 mb-5 w-full">
            <h4 className="text-base font-bold text-[#77716C] uppercase tracking-wider text-[11px]">Documents</h4>
            <div className="space-y-2.5">
              {data.resumeUrl && (
                <div className="bg-white/80 backdrop-blur-sm border border-[#EAE2DB] rounded-2xl p-4 flex items-center justify-between gap-3 shadow-xs">
                  <div className="flex items-center gap-3 min-w-0">
                    <div className="w-9 h-9 rounded-xl bg-[#FCE9DF] flex items-center justify-center shrink-0">
                      <FileText size={16} className="text-[#D4622C]" />
                    </div>
                    <div className="min-w-0">
                      <div className="text-sm font-bold text-[#191919]">Resume / CV</div>
                      <p className="text-[10px] text-[#77716C] truncate">
                        {data.resumeUrl.split("/").pop()}
                      </p>
                    </div>
                  </div>
                  <div className="flex items-center gap-2 shrink-0">
                    <a
                      href={data.resumeUrl}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="w-8 h-8 rounded-lg bg-[#FAF6F2] border border-[#EAE2DB] flex items-center justify-center text-[#D4622C] hover:bg-[#D4622C] hover:text-white transition-all"
                      title="View"
                    >
                      <ExternalLink size={13} />
                    </a>
                    <a
                      href={data.resumeUrl}
                      download
                      className="w-8 h-8 rounded-lg bg-[#FAF6F2] border border-[#EAE2DB] flex items-center justify-center text-[#D4622C] hover:bg-[#D4622C] hover:text-white transition-all"
                      title="Download"
                    >
                      <Download size={13} />
                    </a>
                  </div>
                </div>
              )}
              {data.brochureUrl && (
                <div className="bg-white/80 backdrop-blur-sm border border-[#EAE2DB] rounded-2xl p-4 flex items-center justify-between gap-3 shadow-xs">
                  <div className="flex items-center gap-3 min-w-0">
                    <div className="w-9 h-9 rounded-xl bg-[#FCE9DF] flex items-center justify-center shrink-0">
                      <BookOpen size={16} className="text-[#D4622C]" />
                    </div>
                    <div className="min-w-0">
                      <div className="text-sm font-bold text-[#191919]">Company Brochure</div>
                      <p className="text-[10px] text-[#77716C] truncate">
                        {data.brochureUrl.split("/").pop()}
                      </p>
                    </div>
                  </div>
                  <div className="flex items-center gap-2 shrink-0">
                    <a
                      href={data.brochureUrl}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="w-8 h-8 rounded-lg bg-[#FAF6F2] border border-[#EAE2DB] flex items-center justify-center text-[#D4622C] hover:bg-[#D4622C] hover:text-white transition-all"
                      title="View"
                    >
                      <ExternalLink size={13} />
                    </a>
                    <a
                      href={data.brochureUrl}
                      download
                      className="w-8 h-8 rounded-lg bg-[#FAF6F2] border border-[#EAE2DB] flex items-center justify-center text-[#D4622C] hover:bg-[#D4622C] hover:text-white transition-all"
                      title="Download"
                    >
                      <Download size={13} />
                    </a>
                  </div>
                </div>
              )}
            </div>
          </div>
        )}

        {/* Save Contact + Share */}
        <div className="flex gap-3 w-full mb-5">
          <UiloraBrandButton
            onClick={handleDownloadVCard}
            className="flex-1 py-3 normal-case tracking-normal"
          >
            Save Contact
          </UiloraBrandButton>
          <motion.div
            onClick={() => setShowShareMenu(true)}
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            className="w-10 h-10 shrink-0 rounded-full bg-white border border-slate-200 flex items-center justify-center text-slate-600 backdrop-blur-sm cursor-pointer shadow-sm hover:bg-slate-50 transition-colors"
          >
            <Share2 size={14} />
          </motion.div>
        </div>

        {/* Bottom Footer */}
        <div className="pt-4 border-t border-slate-200/50 flex items-center justify-center w-full">
          <div className="text-[8px] font-black text-slate-400 uppercase tracking-[0.2em] font-display">
            My Card Share
          </div>
        </div>
      </div>

      {/* Side Lighting */}
      <div className="absolute top-1/4 -right-1/4 w-1/2 h-1/2 bg-white/[0.01] blur-[80px] pointer-events-none rounded-full" />

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
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.95, opacity: 0 }}
              transition={{ type: "spring", damping: 25, stiffness: 300 }}
              className="w-full bg-white/95 p-5 rounded-3xl border border-white shadow-2xl relative"
              onClick={(e) => e.stopPropagation()}
            >
              <button
                onClick={() => {
                  setShowShareMenu(false);
                  setShowQr(false);
                }}
                className="absolute top-3 right-3 p-1.5 text-slate-400 hover:text-slate-800 bg-slate-100 rounded-full transition-colors"
              >
                <X size={14} />
              </button>

              <h4 className="text-slate-800 font-black text-[11px] mb-3 uppercase tracking-[0.2em] text-center">
                Share Card
              </h4>

              {/* Public URL preview */}
              <div className="mb-4 px-3 py-2 rounded-xl bg-slate-50 border border-slate-200 flex items-center gap-2 overflow-hidden">
                <LinkIcon
                  size={12}
                  className="text-slate-500 shrink-0"
                />
                <code className="text-[10px] text-slate-600 font-mono truncate flex-1">
                  {shareUrl}
                </code>
              </div>

              {!hasPublicCard && (
                <div className="mb-4 px-3 py-2 rounded-xl bg-amber-50 border border-amber-100 text-amber-600 text-[9px] font-bold uppercase tracking-widest leading-relaxed">
                  {slug
                    ? "Your card is in Draft. Publish it to make this link public."
                    : "Save your profile with a custom URL slug to enable sharing."}
                </div>
              )}

              {showQr ? (
                <motion.div
                  initial={{ opacity: 0, scale: 0.95 }}
                  animate={{ opacity: 1, scale: 1 }}
                  className="flex flex-col items-center gap-4"
                >
                  <div className="p-3 bg-white rounded-xl shadow-sm border border-slate-200">
                    <QRPreview url={shareUrl} />
                  </div>
                  <div className="flex flex-col items-center gap-4">
                    <button
                      onClick={handleDownloadQR}
                      className="text-[8px] font-black bg-[#FCE9DF] text-[#D4622C] px-5 py-2 rounded-full hover:bg-[#D4622C] hover:text-white transition-colors uppercase tracking-widest border border-[#D4622C]/30"
                    >
                      Download QR
                    </button>
                    <button
                      onClick={() => setShowQr(false)}
                      className="text-[9px] font-black text-slate-400 uppercase tracking-widest hover:text-slate-700 transition-colors"
                    >
                      Back to Options
                    </button>
                  </div>
                </motion.div>
              ) : (
                <div className="grid grid-cols-2 gap-3">
                  <button
                    onClick={handleCopyLink}
                    className="flex flex-col items-center justify-center gap-2 p-4 rounded-2xl bg-slate-50 border border-slate-100 hover:bg-slate-100 transition-all group shadow-sm"
                  >
                    {copied ? (
                      <CheckCircle2
                        size={24}
                        className="text-emerald-500"
                      />
                    ) : (
                      <LinkIcon
                        size={24}
                        className="text-slate-400 group-hover:text-slate-600 transition-colors"
                      />
                    )}
                    <span className="text-[9px] font-black uppercase tracking-widest text-slate-600">
                      {copied ? "Copied!" : "Copy Link"}
                    </span>
                  </button>

                  <button
                    onClick={() => setShowQr(true)}
                    className="flex flex-col items-center justify-center gap-2 p-4 rounded-2xl bg-slate-50 border border-slate-100 hover:bg-slate-100 transition-all group shadow-sm"
                  >
                    <QrCode
                      size={24}
                      className="text-sky-500 group-hover:text-sky-600 transition-colors"
                    />
                    <span className="text-[9px] font-black uppercase tracking-widest text-slate-600">
                      QR Code
                    </span>
                  </button>

                  {typeof navigator !== "undefined" && navigator.share && (
                    <button
                      onClick={shareNative}
                      className="col-span-2 mt-1 py-3 rounded-xl border border-slate-200 bg-slate-50 hover:bg-slate-100 text-[9px] font-black uppercase tracking-widest text-slate-600 hover:text-slate-900 transition-all flex items-center justify-center gap-2 shadow-sm"
                    >
                      <Share2 size={13} /> Device Share
                    </button>
                  )}
                </div>
              )}
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      <Confirmation
        isOpen={showConfirm}
        onClose={() => setShowConfirm(false)}
        userName={data.name}
        themeColor={themeColor}
      />
    </motion.div>
  );
}
