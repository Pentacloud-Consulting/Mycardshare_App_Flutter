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
import Confirmation from "../card/Confirmation";
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

export default function ProfileCardVariant2({ data, onPopupToggle }) {
  const themeColor = data.themeColor || "#6366f1";
  const cardLayout = data.cardLayout || "editorial";
  const [isBioExpanded, setIsBioExpanded] = useState(false);
  const [isExpExpanded, setIsExpExpanded] = useState(false);
  const [showShareMenu, setShowShareMenu] = useState(false);
  const [showQr, setShowQr] = useState(false);
  const [copied, setCopied] = useState(false);
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
        color: { dark: "#000000", light: "#ffffff" },
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

    // Show confirmation popup (same as Card 1)
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
    <motion.div
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      className="relative w-full bg-[#05070A] flex flex-col font-sans min-h-[700px] shadow-2xl overflow-hidden rounded-[2.5rem] border border-white/[0.04]"
      style={{
        boxShadow: `0 30px 60px -12px rgba(0,0,0,1), 0 0 40px -10px ${themeColor}22 inset`,
      }}
    >
      {/* Banner Section */}
      <div className="relative w-full h-48 shrink-0 overflow-hidden">
        {data.bannerUrl ? (
          <img
            src={data.bannerUrl}
            alt="Banner"
            className="w-full h-full object-cover object-top"
          />
        ) : (
          <div 
            className="w-full h-full opacity-30" 
            style={{ background: `linear-gradient(135deg, ${themeColor}, #000)` }}
          />
        )}

        {/* Gradient Overlay for Text Readability - reduced since text is below */}
        <div className="absolute inset-0 bg-gradient-to-t from-[#05070A] to-transparent to-[40%]" />

        {/* Status Badge */}
        {data.networkingStatus && data.networkingStatus !== "Not Networking" && (
          <div className="absolute top-4 right-4 z-10">
            <span
              className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-[9px] font-black uppercase tracking-widest border border-white/10 shadow-lg backdrop-blur-md bg-black/50"
              style={{ color: getStatusColor(data.networkingStatus, themeColor) }}
            >
              <span
                className="w-1.5 h-1.5 rounded-full animate-pulse shadow-sm"
                style={{
                  background: getStatusColor(data.networkingStatus, themeColor),
                  boxShadow: `0 0 8px ${getStatusColor(data.networkingStatus, themeColor)}`
                }}
              />
              {data.networkingStatus}
            </span>
          </div>
        )}
      </div>

      {/* Identity Section (Adapting to cardLayout) */}
      {cardLayout === "minimal" ? (
        <div className="px-6 -mt-10 flex flex-col items-center text-center z-10 shrink-0">
          <div 
            className="w-20 h-20 rounded-full border-2 border-white overflow-hidden bg-gray-900 shrink-0 shadow-lg mb-2 relative"
            style={{ boxShadow: `0 0 30px ${themeColor}33` }}
          >
            {data.avatarUrl ? (
              <img
                src={data.avatarUrl}
                alt="Avatar"
                className="w-full h-full object-cover"
              />
            ) : (
              <div className="w-full h-full flex items-center justify-center text-2xl font-bold text-white/20">
                {data.name?.charAt(0) || "U"}
              </div>
            )}
          </div>
          <div className="drop-shadow-md w-full text-center">
            <h3 className="text-2xl font-bold text-white tracking-tight leading-tight line-clamp-2 break-words">
              {data.name || "Maria Lawrence"}
            </h3>
            <p className="text-sm text-white/80 mt-0.5 truncate">
              {data.title || "Sales executive"}
            </p>
            {data.company && (
              <div className="inline-flex items-center justify-center gap-1.5 text-[9px] font-bold text-sky-400 uppercase tracking-[0.2em] mt-1.5 px-3 py-0.5 rounded-full bg-white/10 border border-white/15 brightness-110 truncate">
                <span className="w-1 h-1 rounded-full bg-sky-400 shrink-0" />
                <span className="truncate">{data.company}</span>
              </div>
            )}
          </div>
        </div>
      ) : cardLayout === "banner-right" ? (
        <div className="px-6 pt-5 flex items-center justify-between gap-4 z-10 shrink-0">
          <div className="drop-shadow-md min-w-0 flex-1 text-left">
            <h3 className="text-2xl font-bold text-white tracking-tight leading-tight line-clamp-2 break-words">
              {data.name || "Maria Lawrence"}
            </h3>
            <p className="text-sm text-white/80 mt-0.5 truncate">
              {data.title || "Sales executive"}
            </p>
            {data.company && (
              <div className="flex items-center gap-1.5 text-[9px] font-bold text-sky-400 uppercase tracking-[0.2em] mt-1.5 brightness-110 truncate">
                <span className="w-1 h-1 rounded-full bg-sky-400 shrink-0" />
                <span className="truncate">{data.company}</span>
              </div>
            )}
          </div>
          <div 
            className="w-20 h-20 rounded-full border-2 border-white overflow-hidden bg-gray-900 shrink-0 shadow-lg"
            style={{ boxShadow: `0 0 30px ${themeColor}33` }}
          >
            {data.avatarUrl ? (
              <img
                src={data.avatarUrl}
                alt="Avatar"
                className="w-full h-full object-cover"
              />
            ) : (
              <div className="w-full h-full flex items-center justify-center text-2xl font-bold text-white/20">
                {data.name?.charAt(0) || "U"}
              </div>
            )}
          </div>
        </div>
      ) : cardLayout === "wide" ? (
        <div className="px-6 pt-4 z-10 shrink-0">
          <div className="flex items-center gap-4 p-3 rounded-2xl bg-white/[0.04] border border-white/[0.08] shadow-lg">
            <div 
              className="w-16 h-16 rounded-2xl border-2 border-white/60 overflow-hidden bg-gray-900 shrink-0 shadow-md"
              style={{ boxShadow: `0 0 20px ${themeColor}33` }}
            >
              {data.avatarUrl ? (
                <img
                  src={data.avatarUrl}
                  alt="Avatar"
                  className="w-full h-full object-cover rounded-2xl"
                />
              ) : (
                <div className="w-full h-full flex items-center justify-center text-xl font-bold text-white/20">
                  {data.name?.charAt(0) || "U"}
                </div>
              )}
            </div>
            <div className="drop-shadow-md min-w-0 flex-1">
              <h3 className="text-xl font-bold text-white tracking-tight leading-tight line-clamp-2 break-words">
                {data.name || "Maria Lawrence"}
              </h3>
              <p className="text-xs text-white/80 mt-0.5 truncate">
                {data.title || "Sales executive"}
              </p>
              {data.company && (
                <div className="flex items-center gap-1.5 text-[9px] font-bold text-sky-400 uppercase tracking-[0.2em] mt-1 brightness-110 truncate">
                  <span className="w-1 h-1 rounded-full bg-sky-400 shrink-0" />
                  <span className="truncate">{data.company}</span>
                </div>
              )}
            </div>
          </div>
        </div>
      ) : (
        /* Default: Editorial / Left Avatar */
        <div className="px-6 pt-5 flex items-center gap-4 z-10 shrink-0">
          <div 
            className="w-20 h-20 rounded-full border-2 border-white overflow-hidden bg-gray-900 shrink-0 shadow-lg"
            style={{ boxShadow: `0 0 30px ${themeColor}33` }}
          >
            {data.avatarUrl ? (
              <img
                src={data.avatarUrl}
                alt="Avatar"
                className="w-full h-full object-cover"
              />
            ) : (
              <div className="w-full h-full flex items-center justify-center text-2xl font-bold text-white/20">
                {data.name?.charAt(0) || "U"}
              </div>
            )}
          </div>
          <div className="drop-shadow-md min-w-0">
            <h3 className="text-2xl font-bold text-white tracking-tight leading-tight line-clamp-2 break-words">
              {data.name || "Maria Lawrence"}
            </h3>
            <p className="text-sm text-white/80 mt-0.5 truncate">
              {data.title || "Sales executive"}
            </p>
            {data.company && (
              <div className="flex items-center gap-1.5 text-[9px] font-bold text-sky-400 uppercase tracking-[0.2em] mt-1.5 brightness-110 truncate">
                <span className="w-1 h-1 rounded-full bg-sky-400 shrink-0" />
                <span className="truncate">{data.company}</span>
              </div>
            )}
          </div>
        </div>
      )}

      {/* Content Body */}
      <div className="p-5 space-y-6 flex-1 overflow-y-auto pb-6">
        {/* Primary Action Buttons */}
        <div className="grid grid-cols-2 gap-3 mb-6">
          <motion.a
            href={`mailto:${data.email || ""}`}
            whileHover={{ scale: 1.02, backgroundColor: "rgba(255, 255, 255, 0.05)", borderColor: "rgba(255, 255, 255, 0.12)" }}
            whileTap={{ scale: 0.98 }}
            className="bg-white/[0.02] border border-white/[0.04] rounded-md py-3 flex items-center justify-center gap-2.5 transition-all duration-300"
          >
            <Mail size={16} className="text-white" />
            <span className="text-[10px] font-black text-white uppercase tracking-widest">Email</span>
          </motion.a>
          <motion.a
            href={`tel:${data.phone || ""}`}
            whileHover={{ scale: 1.02, backgroundColor: "rgba(255, 255, 255, 0.05)", borderColor: "rgba(255, 255, 255, 0.12)" }}
            whileTap={{ scale: 0.98 }}
            className="bg-white/[0.02] border border-white/[0.04] rounded-md py-3 flex items-center justify-center gap-2.5 transition-all duration-300"
          >
            <Phone size={16} className="text-white" />
            <span className="text-[10px] font-black text-white uppercase tracking-widest">Contact</span>
          </motion.a>
        </div>

        {/* Social Icons */}
        <div className="flex items-center justify-center w-full">
          <div
            className="flex flex-wrap items-center justify-center gap-3"
            style={socials.length >= 8 ? { maxWidth: "305px" } : {}}
          >
            {socials.length > 0 ? (
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
                    className="w-10 h-10 shrink-0 rounded-full bg-white/[0.03] flex items-center justify-center border border-white/[0.05] overflow-hidden shadow-lg"
                  >
                    {customIconPath ? (
                      <img src={customIconPath} alt={s.id} className="w-full h-full object-cover" />
                    ) : (
                      <div className="p-2.5 text-white">
                        <LinkIcon size={20} />
                      </div>
                    )}
                  </motion.a>
                );
              })
            ) : (
              <p className="text-[10px] text-gray-600 uppercase tracking-widest italic py-2">
                Expand your network by adding socials
              </p>
            )}
          </div>
        </div>

        {/* Location Badge */}
        {(data.city || data.address) && (
          <div className="flex items-center gap-2 text-slate-400/80 bg-white/[0.02] px-3 py-1.5 rounded-full border border-white/[0.04] w-fit">
            <MapPin size={12} className="text-sky-400" />
            <span className="text-[9px] font-black uppercase tracking-[0.15em]">
              {data.city || data.address}
            </span>
          </div>
        )}

        {/* Bio Section */}
        {data.bio && (
          <div className="space-y-2.5">
            <h4 className="text-base font-bold text-white uppercase tracking-wider text-[11px]">Bio</h4>
            <div className="bg-white/[0.02] border border-white/[0.04] rounded-[0.6rem] p-5 relative shadow-inner">
              <div
                className="text-[13px] text-white overflow-hidden transition-all duration-300"
                style={!isBioExpanded ? {
                  display: "-webkit-box",
                  WebkitLineClamp: "3",
                  WebkitBoxOrient: "vertical",
                  maxHeight: "4.5rem",
                } : {}}
              >
                {data.bio}
              </div>
              <button
                onClick={() => setIsBioExpanded(!isBioExpanded)}
                className="mt-3 text-[10px] font-black uppercase tracking-widest hover:brightness-125 transition-all"
                style={{ color: themeColor }}
              >
                {isBioExpanded ? "LESS" : "MORE"}
              </button>
            </div>
          </div>
        )}

        {/* Exp. Matrix Section */}
        {data.experience && (
          <div className="space-y-2.5">
            <h4 className="text-base font-bold text-white uppercase tracking-wider text-[11px]">Experience</h4>
            <div className="bg-white/[0.02] border border-white/[0.04] rounded-[0.6rem] p-5 relative shadow-inner">
              <div
                className={`text-[12px] text-white/90 overflow-hidden transition-all duration-300 ${!isExpExpanded ? "max-h-[58px]" : "max-h-[2000px]"}`}
                style={{ lineHeight: "1.5" }}
              >
                <div className="space-y-3">
                  {data.experience.split("\n").map((line, idx) => (
                    <div key={idx} className="flex items-start gap-2.5">
                      <span className="mt-1.5 w-1 h-1 bg-white rounded-full shrink-0" />
                      <span className="leading-tight">{line}</span>
                    </div>
                  ))}
                </div>
              </div>
              <button
                onClick={() => setIsExpExpanded(!isExpExpanded)}
                className="mt-4 text-[10px] font-black uppercase tracking-widest hover:brightness-125 transition-all"
                style={{ color: themeColor }}
              >
                {isExpExpanded ? "LESS" : "MORE"}
              </button>
            </div>
          </div>
        )}

        {/* Documents Section */}
        {(data.resumeUrl || data.brochureUrl) && (
          <div className="space-y-2.5">
            <h4 className="text-base font-bold text-white uppercase tracking-wider text-[11px]">Documents</h4>
            <div className="space-y-2.5">
              {data.resumeUrl && (
                <div className="bg-white/[0.02] border border-white/[0.04] rounded-[0.6rem] p-4 flex items-center justify-between gap-3 shadow-inner">
                  <div className="flex items-center gap-3 min-w-0">
                    <div className="w-9 h-9 rounded-lg bg-[#D4622C]/15 flex items-center justify-center shrink-0">
                      <FileText size={16} className="text-[#D4622C]" />
                    </div>
                    <div className="min-w-0">
                      <div className="text-sm font-bold text-white">Resume / CV</div>
                      <p className="text-[10px] text-white/30 truncate">
                        {data.resumeUrl.split("/").pop()}
                      </p>
                    </div>
                  </div>
                  <div className="flex items-center gap-2 shrink-0">
                    <a
                      href={data.resumeUrl}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="w-8 h-8 rounded-lg bg-[#D4622C]/15 border border-[#D4622C]/30 flex items-center justify-center text-[#D4622C] hover:bg-[#D4622C]/30 transition-all"
                      title="View"
                    >
                      <ExternalLink size={13} />
                    </a>
                    <a
                      href={data.resumeUrl}
                      download
                      className="w-8 h-8 rounded-lg bg-[#D4622C]/15 border border-[#D4622C]/30 flex items-center justify-center text-[#D4622C] hover:bg-[#D4622C]/30 transition-all"
                      title="Download"
                    >
                      <Download size={13} />
                    </a>
                  </div>
                </div>
              )}
              {data.brochureUrl && (
                <div className="bg-white/[0.02] border border-white/[0.04] rounded-[0.6rem] p-4 flex items-center justify-between gap-3 shadow-inner">
                  <div className="flex items-center gap-3 min-w-0">
                    <div className="w-9 h-9 rounded-lg bg-sky-500/10 flex items-center justify-center shrink-0">
                      <BookOpen size={16} className="text-sky-400" />
                    </div>
                    <div className="min-w-0">
                      <div className="text-sm font-bold text-white">Company Brochure</div>
                      <p className="text-[10px] text-white/30 truncate">
                        {data.brochureUrl.split("/").pop()}
                      </p>
                    </div>
                  </div>
                  <div className="flex items-center gap-2 shrink-0">
                    <a
                      href={data.brochureUrl}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="w-8 h-8 rounded-lg bg-sky-500/10 border border-sky-500/20 flex items-center justify-center text-sky-400 hover:bg-sky-500/30 transition-all"
                      title="View"
                    >
                      <ExternalLink size={13} />
                    </a>
                    <a
                      href={data.brochureUrl}
                      download
                      className="w-8 h-8 rounded-lg bg-sky-500/10 border border-sky-500/20 flex items-center justify-center text-sky-400 hover:bg-sky-500/30 transition-all"
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

        {/* Footer Save / Share Buttons */}
        <div className="grid grid-cols-2 gap-4 pt-4 pb-2">
          <motion.button
            onClick={handleDownloadVCard}
            whileHover={{ scale: 1.02, filter: "brightness(1.1)" }}
            whileTap={{ scale: 0.98 }}
            className="bg-gradient-to-br from-[#6366f1] via-[#2563eb] to-[#06b6d4] border border-white/20 rounded-md py-3 text-[11px] font-black uppercase tracking-[0.2em] text-white shadow-[0_10px_40px_rgba(99,102,241,0.3)] transition-all cursor-pointer"
          >
            Save
          </motion.button>
          <motion.button
            onClick={() => { setShowShareMenu(true); setShowQr(false); }}
            whileHover={{ scale: 1.02, filter: "brightness(1.1)" }}
            whileTap={{ scale: 0.98 }}
            className="bg-gradient-to-br from-[#6366f1] via-[#2563eb] to-[#06b6d4] border border-white/20 rounded-md py-3 text-[11px] font-black uppercase tracking-[0.2em] text-white shadow-[0_10px_40px_rgba(99,102,241,0.3)] transition-all cursor-pointer"
          >
            Share
          </motion.button>
        </div>

        {/* Bottom Footer Text */}
        <div className="pt-6 border-t border-white/[0.04] flex items-center justify-center w-full">
          <div 
            className="text-[8px] font-black uppercase tracking-[0.2em] text-center"
            style={{ color: themeColor }}
          >
            My Card Share
          </div>
        </div>
      </div>

      {/* Share Sub-Menu Overlay (same as Card 1) */}
      <AnimatePresence>
        {showShareMenu && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="absolute inset-0 bg-black/60 backdrop-blur-md z-50 flex items-center justify-center px-4 rounded-[2.5rem]"
          >
            <motion.div
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.95, opacity: 0 }}
              transition={{ type: "spring", damping: 25, stiffness: 300 }}
              className="w-full bg-[#0A0D14] p-5 rounded-3xl border border-white/10 shadow-2xl relative"
              onClick={(e) => e.stopPropagation()}
            >
              <button
                onClick={() => { setShowShareMenu(false); setShowQr(false); }}
                className="absolute top-3 right-3 p-1.5 text-slate-400 hover:text-white bg-white/5 rounded-full transition-colors"
              >
                <X size={14} />
              </button>

              <h4 className="text-white font-black text-[11px] mb-3 uppercase tracking-[0.2em] text-center">
                Share Card
              </h4>

              {/* URL Preview */}
              <div className="mb-4 px-3 py-2 rounded-xl bg-white/[0.03] border border-white/5 flex items-center gap-2 overflow-hidden">
                <LinkIcon size={12} className="text-slate-500 shrink-0" />
                <code className="text-[10px] text-slate-300 font-mono truncate flex-1">
                  {shareUrl}
                </code>
              </div>

              {!hasPublicCard && (
                <div className="mb-4 px-3 py-2 rounded-xl bg-amber-500/10 border border-amber-500/20 text-amber-300 text-[9px] font-bold uppercase tracking-widest leading-relaxed">
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
                  <div className="p-3 bg-white rounded-xl shadow-[0_0_30px_rgba(255,255,255,0.1)]">
                    <QRPreview url={shareUrl} />
                  </div>
                  <div className="flex flex-col items-center gap-4">
                    <button
                      onClick={handleDownloadQR}
                      className="text-[8px] font-black bg-[#D4622C]/20 text-[#D4622C] px-5 py-2 rounded-full hover:bg-[#D4622C]/30 transition-colors uppercase tracking-widest border border-[#D4622C]/30"
                    >
                      Download QR
                    </button>
                    <button
                      onClick={() => setShowQr(false)}
                      className="text-[9px] font-black text-slate-400 uppercase tracking-widest hover:text-white transition-colors"
                    >
                      Back to Options
                    </button>
                  </div>
                </motion.div>
              ) : (
                <div className="grid grid-cols-2 gap-3">
                  <button
                    onClick={handleCopyLink}
                    className="flex flex-col items-center justify-center gap-2 p-4 rounded-2xl bg-white/[0.03] border border-white/5 hover:bg-white/[0.08] hover:border-white/20 transition-all group shadow-inner"
                  >
                    {copied ? (
                      <CheckCircle2 size={24} className="text-emerald-400 drop-shadow-[0_0_12px_rgba(52,211,153,0.4)]" />
                    ) : (
                      <LinkIcon size={24} className="text-slate-400 group-hover:text-white transition-colors" />
                    )}
                    <span className="text-[9px] font-black uppercase tracking-widest text-slate-300">
                      {copied ? "Copied!" : "Copy Link"}
                    </span>
                  </button>

                  <button
                    onClick={() => setShowQr(true)}
                    className="flex flex-col items-center justify-center gap-2 p-4 rounded-2xl bg-white/[0.03] border border-white/5 hover:bg-white/[0.08] hover:border-white/20 transition-all group shadow-inner"
                  >
                    <QrCode size={24} className="text-sky-400 group-hover:text-sky-300 transition-colors drop-shadow-[0_0_12px_rgba(56,189,248,0.2)]" />
                    <span className="text-[9px] font-black uppercase tracking-widest text-slate-300">
                      QR Code
                    </span>
                  </button>

                  {typeof navigator !== "undefined" && navigator.share && (
                    <button
                      onClick={shareNative}
                      className="col-span-2 mt-1 py-3 rounded-xl border border-white/10 bg-white/[0.01] hover:bg-white/[0.05] text-[9px] font-black uppercase tracking-widest text-slate-400 hover:text-white transition-all flex items-center justify-center gap-2"
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

      {/* Save Confirmation Popup (same as Card 1) */}
      <Confirmation
        isOpen={showConfirm}
        onClose={() => setShowConfirm(false)}
        userName={data.name}
        themeColor={data.themeColor || "#6366f1"}
      />
    </motion.div>
  );
}
