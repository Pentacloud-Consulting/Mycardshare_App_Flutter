"use client";

import React, { useState, useEffect } from "react";
import { motion } from "framer-motion";
import {
  Eye,
  Users,
  ShieldCheck,
  Pencil,
  Globe,
  Settings,
  User,
  Plus,
  Compass,
  LayoutDashboard,
  TrendingUp,
  Activity,
  Wallet,
  QrCode,
  ExternalLink,
  Camera,
  CreditCard,
  Mail,
  Phone,
  MapPin,
  Download,
  X,
  Sparkles,
  Building2,
  ChevronRight,
  Radio,
  Copy,
  Check,
  Share2,
} from "lucide-react";
import { authFetch, toUserMessage } from "@/lib/api";
import { UiloraBrandButton } from "../UIComponents/Button/tsx/UiloraModernButtons";
import QRCode from "qrcode";
import { getCardShareUrl } from "@/lib/urls";
import ProfileCardPreview from "@/components/profile/ProfileCardPreview";
import ProfileCardVariant2 from "@/components/profile/ProfileCardVariant2";

const fadeUp = {
  hidden: { opacity: 0, y: 20 },
  visible: (i) => ({
    opacity: 1,
    y: 0,
    transition: { delay: i * 0.1, duration: 0.5, ease: "easeOut" },
  }),
};

/**
 * Brand marks mirror the public landing hero (DigitalSection).
 * Apple: white logo on black tile.
 * Google: blue credit-card glyph with red/yellow dots on white tile.
 * Samsung: white symbol on Samsung-blue tile.
 */
function WalletBrandIcon({ id }) {
  if (id === "apple") {
    return (
      <div className="mb-3 flex h-14 w-14 items-center justify-center rounded-2xl bg-black border border-white/15 shadow-inner">
        <img
          src="/wallet-brands/apple.svg"
          alt=""
          aria-hidden
          className="h-6 w-auto"
          loading="lazy"
          decoding="async"
        />
      </div>
    );
  }
  if (id === "google") {
    return (
      <div className="mb-3 flex h-14 w-14 items-center justify-center rounded-full bg-white shadow-inner relative overflow-hidden">
        <img
          src="/wallet-brands/google-g.svg"
          alt="Google Wallet"
          className="h-full w-full object-cover"
          loading="lazy"
          decoding="async"
        />
      </div>
    );
  }
  return (
    <div className="mb-3 flex h-14 w-14 items-center justify-center rounded-full shadow-inner overflow-hidden">
      <img
        src="/wallet-brands/samsung-symbol.svg"
        alt="Samsung Wallet"
        className="w-full h-full object-cover"
        loading="lazy"
        decoding="async"
      />
    </div>
  );
}

function QRPreview({ url }) {
  const [src, setSrc] = useState("");

  useEffect(() => {
    QRCode.toDataURL(url, { width: 400, margin: 2 }).then(setSrc);
  }, [url]);

  if (!src) return <div className="w-[200px] h-[200px] flex items-center justify-center bg-slate-100 rounded-xl">Generating...</div>;

  return (
    <img
      src={src}
      className="w-[200px] h-[200px] sm:w-[250px] sm:h-[250px]"
      alt="QR Code"
    />
  );
}

/**
 * Brand marks mapped to the on-disk assets. Keeping this as a single source
 * of truth so modals and tiles render identical artwork.
 */
const WALLET_BRAND_MARK = {
  apple: { src: "/wallet-brands/apple.svg", bg: "#000000" },
  google: { src: "/wallet-brands/google-g.svg", bg: "#ffffff" },
  samsung: { src: "/wallet-brands/samsung-symbol.svg", bg: "#1428a0" },
};

/**
 * Lightweight QR generator sized for compact card previews. Transparent
 * background + dark modules on a soft light tile so it reads on any theme.
 */
function MiniQR({ url, size = 96 }) {
  const [src, setSrc] = useState("");
  useEffect(() => {
    if (!url) return;
    QRCode.toDataURL(url, {
      width: size * 3,
      margin: 1,
      color: { dark: "#0a0f1f", light: "#ffffff" },
    })
      .then(setSrc)
      .catch(() => setSrc(""));
  }, [url, size]);

  if (!src) {
    return (
      <div
        className="rounded-xl bg-white/[0.06] border border-white/10 animate-pulse"
        style={{ width: size, height: size }}
        aria-label="Generating QR code"
      />
    );
  }
  return (
    <img
      src={src}
      width={size}
      height={size}
      alt="Scan to view full card"
      className="rounded-xl bg-white p-1.5 shadow-[0_8px_24px_rgba(6,182,212,0.18)]"
    />
  );
}

/**
 * Modern wallet card preview — Midnight Aurora aesthetic.
 * Mirrors the Live Card Preview: banner + brand mark, avatar with status dot,
 * name/role hierarchy, labeled contact rows, compact QR. All tokens from
 * globals.css. Mobile-first, 375px baseline.
 */
function WalletPreviewCard({ data, brand = "apple" }) {
  const fullName = data.fullName || "Your Name";
  const jobTitle = data.jobTitle || "";
  const companyName = data.companyName || "";
  const email = data.workEmail || data.email || "";
  const phone = data.workPhone || data.phoneNumber || "";
  const website = data.website || "";
  const location = [data.city, data.country].filter(Boolean).join(", ");
  const avatarUrl = data.avatarUrl;
  const bannerUrl = data.bannerUrl;
  const publicCardUrl = data.publicCardUrl;
  const initial = (fullName || "U").trim().charAt(0).toUpperCase();
  const brandMark = WALLET_BRAND_MARK[brand] || WALLET_BRAND_MARK.apple;

  const rows = [
    email && { id: "email", icon: Mail, label: "Email", value: email },
    phone && { id: "phone", icon: Phone, label: "Phone", value: phone },
    website && { id: "web", icon: Globe, label: "Website", value: website },
    location && { id: "loc", icon: MapPin, label: "Location", value: location },
  ].filter(Boolean);

  return (
    <div className="relative w-full max-w-[420px]">
      {/* Aurora gradient halo */}
      <div
        aria-hidden
        className="absolute -inset-[1px] rounded-[30px] bg-[conic-gradient(from_140deg_at_50%_50%,rgba(99,102,241,0.55),rgba(6,182,212,0.45),rgba(167,139,250,0.45),rgba(99,102,241,0.55))] opacity-70 blur-[2px]"
      />
      {/* Soft outer glow */}
      <div
        aria-hidden
        className="absolute -inset-6 rounded-[40px] bg-indigo-500/20 blur-3xl opacity-60"
      />

      <article
        className="relative overflow-hidden rounded-[28px] border border-white/10 bg-[linear-gradient(180deg,#0b1230_0%,#080f28_50%,#05091a_100%)] shadow-[0_30px_80px_-20px_rgba(0,0,0,0.7),0_0_0_1px_rgba(99,102,241,0.08)_inset]"
        aria-label={`${fullName} digital business card`}
      >
        {/* ── BANNER ── */}
        <div className="relative h-32 sm:h-36 w-full overflow-hidden">
          {bannerUrl ? (
            <img
              src={bannerUrl}
              alt=""
              aria-hidden
              className="absolute inset-0 h-full w-full object-cover"
            />
          ) : (
            <div
              aria-hidden
              className="absolute inset-0 bg-[radial-gradient(80%_120%_at_20%_10%,rgba(99,102,241,0.55),transparent_60%),radial-gradient(80%_120%_at_90%_20%,rgba(6,182,212,0.45),transparent_55%),linear-gradient(180deg,#0c1535,#05091a)]"
            />
          )}
          {/* readability gradient */}
          <div
            aria-hidden
            className="absolute inset-0 bg-gradient-to-b from-black/10 via-black/40 to-[#05091a]"
          />

          {/* Brand mark chip (top-left) */}
          <div
            className={`absolute left-4 top-4 flex h-9 w-9 items-center justify-center overflow-hidden ${
              brand === "samsung" || brand === "google"
                ? "rounded-full"
                : "rounded-xl border border-white/15 backdrop-blur-md"
            }`}
            style={{
              background: brand === "samsung" ? "transparent" : brandMark.bg,
            }}
          >
            <img
              src={brandMark.src}
              alt={`${brand} wallet`}
              className={
                brand === "samsung" || brand === "google"
                  ? "h-full w-full object-cover"
                  : "h-4 w-4 object-contain"
              }
              loading="lazy"
            />
          </div>

          {/* Ready pill (top-right) */}
          <div className="absolute right-4 top-4 inline-flex items-center gap-1.5 rounded-full border border-cyan-400/25 bg-cyan-400/10 px-2.5 py-1 backdrop-blur-md">
            <span className="h-1.5 w-1.5 rounded-full bg-cyan-300 shadow-[0_0_8px_rgba(34,211,238,0.9)]" />
            <span className="text-[10px] font-bold uppercase tracking-[0.14em] text-cyan-200">
              Ready to add
            </span>
          </div>
        </div>

        {/* ── IDENTITY BLOCK ── */}
        <div className="relative px-5 sm:px-6 pb-5 -mt-10">
          <div className="flex items-end gap-4">
            {/* Avatar with mint status dot */}
            <div className="relative">
              <div className="h-20 w-20 rounded-2xl border-2 border-[#05091a] bg-[#0c1535] overflow-hidden shadow-[0_10px_30px_rgba(0,0,0,0.6)]">
                {avatarUrl ? (
                  <img
                    src={avatarUrl}
                    alt={`${fullName} avatar`}
                    className="h-full w-full object-cover"
                  />
                ) : (
                  <div className="flex h-full w-full items-center justify-center p-4">
                    <img
                      src="/logo/image (4).png"
                      alt="My Card Share Logo"
                      className="w-full h-full object-contain opacity-50"
                    />
                  </div>
                )}
              </div>
              <span
                aria-hidden
                className="absolute -bottom-0.5 -right-0.5 h-4 w-4 rounded-full border-2 border-[#05091a] bg-emerald-400 shadow-[0_0_10px_rgba(16,217,168,0.8)]"
              />
            </div>

            <div className="min-w-0 flex-1 pb-1">
              {companyName && (
                <div
                  className="inline-flex items-center gap-1.5 rounded-full border border-white/10 bg-white/5 px-2 py-0.5 mb-1.5 max-w-full"
                  title={companyName}
                >
                  <Building2 size={11} className="text-cyan-300 shrink-0" />
                  <span className="truncate text-[10px] font-bold uppercase tracking-[0.12em] text-white/70">
                    {companyName}
                  </span>
                </div>
              )}
              <h3
                className="truncate text-2xl font-black text-white tracking-tight"
                style={{ fontFamily: "var(--font-display)" }}
                title={fullName}
              >
                {fullName}
              </h3>
              {jobTitle && (
                <p className="truncate text-sm font-medium text-white/60">
                  {jobTitle}
                </p>
              )}
            </div>
          </div>

          {/* hairline */}
          <div
            aria-hidden
            className="mt-5 h-px w-full bg-gradient-to-r from-transparent via-white/10 to-transparent"
          />

          {/* ── CONTACT ROWS ── */}
          {rows.length > 0 && (
            <dl className="mt-4 grid grid-cols-1 gap-2">
              {rows.map(({ id, icon: Icon, label, value }) => (
                <div
                  key={id}
                  className="flex items-center gap-3 rounded-xl border border-white/5 bg-white/[0.025] px-3 py-2.5"
                >
                  <span className="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg bg-gradient-to-br from-indigo-500/20 to-cyan-400/10 border border-white/10">
                    <Icon size={14} className="text-cyan-200" />
                  </span>
                  <div className="min-w-0 flex-1">
                    <dt className="text-[9px] font-bold uppercase tracking-[0.16em] text-white/40">
                      {label}
                    </dt>
                    <dd
                      className="truncate text-sm font-semibold text-white/90"
                      title={value}
                    >
                      {value}
                    </dd>
                  </div>
                </div>
              ))}
            </dl>
          )}

          {/* ── QR STRIP ── */}
          {publicCardUrl && (
            <div className="mt-4 flex items-center gap-4 rounded-2xl border border-white/10 bg-gradient-to-br from-white/[0.04] to-transparent p-3">
              <MiniQR url={publicCardUrl} size={84} />
              <div className="min-w-0 flex-1">
                <div className="inline-flex items-center gap-1.5 text-[10px] font-bold uppercase tracking-[0.16em] text-cyan-200/80">
                  <Sparkles size={11} />
                  Tap · Scan · Share
                </div>
                <p className="mt-1 text-[13px] leading-snug font-medium text-white/70">
                  Point any camera at this code to open the live card.
                </p>
              </div>
            </div>
          )}
        </div>
      </article>
    </div>
  );
}

export default function IndividualDashboard({ userData, refreshUserData }) {
  const [stats, setStats] = useState({
    views: 0,
    connectionsCount: 0,
    viewsTrend: "+0%",
    connectionsTrend: "+0%",
  });
  const [loading, setLoading] = useState(true);
  const [walletLoading, setWalletLoading] = useState("");
  const [showQR, setShowQR] = useState(false);
  const [publishLoading, setPublishLoading] = useState(false);
  const [toast, setToast] = useState(null);
  const [showAppleDemo, setShowAppleDemo] = useState(false);
  const [activeVariant, setActiveVariant] = useState(1);
  const [isOverlayOpen, setIsOverlayOpen] = useState(false);

  const showToast = (message, type = "info") => {
    setToast({ message: toUserMessage(message, "Something went wrong"), type });
    setTimeout(() => setToast(null), 4000);
  };

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const res = await authFetch("/api/user/stats");
        const data = await res.json();
        if (data.success) {
          setStats(data.data);
        }
      } catch (err) {
        console.error("Failed to fetch dashboard stats:", err);
      } finally {
        setLoading(false);
      }
    };
    fetchStats();
  }, []);

  const getProfileUrl = () => {
    const slug = userData.cardSlug || userData.uid;
    return getCardShareUrl(slug);
  };

  const handleDownloadQR = async () => {
    try {
      const url = getProfileUrl();
      const dataUrl = await QRCode.toDataURL(url, {
        width: 1000,
        margin: 2,
        color: {
          dark: "#000000",
          light: "#ffffff",
        },
      });

      const link = document.createElement("a");
      link.href = dataUrl;
      link.download = `My_Card_Share_QR_${userData.fullName || "Card"}.png`;
      link.click();
    } catch (err) {
      console.error("QR Download failed", err);
      showToast("Failed to download QR code", "error");
    }
  };

  const downloadVcf = (overrides = {}) => {
    const fullName = overrides.fullName || userData.fullName || "My Card Share Contact";
    const nameParts = String(fullName).trim().split(/\s+/);
    const first = nameParts[0] || "";
    const last = nameParts.slice(1).join(" ") || "";
    const publicCardUrl = overrides.publicCardUrl || getProfileUrl();
    const email = userData.workEmail || userData.email || "";
    const phone = userData.workPhone || userData.phoneNumber || "";
    const website = userData.website || "";
    const company = userData.companyName || "";
    const jobTitle = userData.jobTitle || "";
    const tagline = userData.tagline || userData.bio || "";

    const escape = (v) =>
      String(v || "")
        .replace(/\\/g, "\\\\")
        .replace(/\r?\n/g, "\\n")
        .replace(/,/g, "\\,")
        .replace(/;/g, "\\;");

    const lines = [
      "BEGIN:VCARD",
      "VERSION:3.0",
      `N:${escape(last)};${escape(first)};;;`,
      `FN:${escape(fullName)}`,
    ];

    if (company) lines.push(`ORG:${escape(company)}`);
    if (jobTitle) lines.push(`TITLE:${escape(jobTitle)}`);

    if (phone) lines.push(`TEL;TYPE=CELL,VOICE:${escape(phone)}`);
    if (email) lines.push(`EMAIL;TYPE=INTERNET,WORK:${escape(email)}`);
    if (website) {
      const safeUrl = /^https?:\/\//i.test(website) ? website : `https://${website}`;
      lines.push(`URL;TYPE=WORK:${escape(safeUrl)}`);
    }
    if (publicCardUrl) lines.push(`URL;TYPE=HOME:${escape(publicCardUrl)}`);

    const street = userData.address || "";
    const city = userData.city || "";
    const country = userData.country || "";
    if (street || city || country) {
      lines.push(
        `ADR;TYPE=WORK:;;${escape(street)};${escape(city)};;;${escape(country)}`,
      );
    }

    if (tagline) lines.push(`NOTE:${escape(tagline)}`);

    if (userData.avatarUrl && /^https?:\/\//i.test(userData.avatarUrl)) {
      lines.push(`PHOTO;VALUE=URI:${userData.avatarUrl}`);
    }

    lines.push(`REV:${new Date().toISOString()}`);
    lines.push("END:VCARD");

    const vCardData = lines.join("\r\n");

    const blob = new Blob([vCardData], { type: "text/vcard;charset=utf-8" });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `${String(fullName).replace(/\s+/g, "_")}.vcf`;
    a.click();
    window.URL.revokeObjectURL(url);
  };

  const firstName = (userData.fullName || "").split(" ")[0] || "there";
  const isPublished = userData?.cardStatus === "Published";
  const [copiedLink, setCopiedLink] = useState(false);

  const handleCopyShareLink = async () => {
    const url = getProfileUrl();
    try {
      await navigator.clipboard.writeText(url);
      setCopiedLink(true);
      showToast("Card URL copied to clipboard!", "success");
      setTimeout(() => setCopiedLink(false), 2000);
    } catch (err) {
      console.error(err);
    }
  };

  const handleWalletClick = async (brandId) => {
    if (!isPublished) {
      showToast(
        "Please publish your card first (Go Live) before adding to wallet.",
        "warning",
      );
      return;
    }
    setWalletLoading(brandId);
    try {
      const cardSlug = userData.cardSlug || "";
      const publicCardUrl = getCardShareUrl(cardSlug || userData.uid);

      if (brandId === "google") {
        const res = await authFetch("/api/wallet/google", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            userId: userData.uid,
            fullName: userData.fullName,
            jobTitle: userData.jobTitle,
            companyName: userData.companyName,
            workEmail: userData.workEmail || userData.email,
            workPhone: userData.workPhone || userData.phoneNumber,
            website: userData.website,
            themeColor: userData.themeColor || "#D4622C",
            avatarUrl: userData.avatarUrl,
            bannerUrl: userData.bannerUrl,
            publicCardUrl,
          }),
        });
        const data = await res.json().catch(() => ({}));
        if (data.success && data.data?.saveUrl) {
          window.open(data.data.saveUrl, "_blank");
        } else {
          showToast(
            toUserMessage(data.error, "Failed to create Google Wallet pass."),
            "error",
          );
        }
      } else if (brandId === "apple") {
        downloadVcf({ publicCardUrl });
        setShowAppleDemo(true);
        showToast("Apple Wallet demo: contact card downloaded (VCF).", "info");
      } else if (brandId === "samsung") {
        const refId = `ref-${userData.uid || "u"}-${Date.now()}`;
        const formData = {
          uid: userData.uid,
          cardSlug: userData.cardSlug || userData.uid,
          fullName: userData.fullName,
          jobTitle: userData.jobTitle,
          companyName: userData.companyName,
          workEmail: userData.workEmail || userData.email,
          workPhone: userData.workPhone || userData.phoneNumber,
          website: userData.website,
          address: userData.address,
          city: userData.city,
          country: userData.country,
          tagline: userData.tagline || userData.bio,
          avatarUrl: userData.avatarUrl,
          bannerUrl: userData.bannerUrl,
          companyLogo: userData.companyLogo,
          themeColor: userData.themeColor || "#D4622C",
          publicCardUrl,
        };

        const res = await authFetch("/api/wallet/samsung", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ refId, formData }),
        });
        const data = await res.json().catch(() => ({}));
        if (!res.ok || !data?.success || !data?.data?.addToWalletUrl) {
          throw new Error(
            toUserMessage(
              data?.error,
              "Could not generate Samsung Wallet pass. Please ensure your card details are saved.",
            ),
          );
        }
        window.open(data.data.addToWalletUrl, "_blank");
      }
    } catch (err) {
      console.error(`${brandId} error:`, err);
      showToast(`Failed to add to ${brandId} wallet: ${err.message}`, "error");
    } finally {
      setWalletLoading("");
    }
  };

  const handlePublishToggle = async () => {
    const newStatus = isPublished ? "Draft" : "Published";
    setPublishLoading(true);
    try {
      const res = await authFetch("/api/user/me", {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          cardStatus: newStatus,
          cardSlug: userData.cardSlug,
          fullName: userData.fullName,
        }),
      });
      if (res.ok) {
        await refreshUserData();
      }
    } catch (err) {
      console.error("Failed to toggle publish status:", err);
    } finally {
      setPublishLoading(false);
    }
  };

  const statsCards = [
    {
      label: "Card Impressions",
      value: stats.views || 0,
      trend: stats.viewsTrend || "+0%",
      icon: Eye,
      color: "text-[#D4622C]",
      bg: "bg-[#FCE9DF]",
      stroke: "#D4622C",
    },
    {
      label: "Profile Status",
      value: isPublished ? "Published" : "Draft",
      trend: "100% Active",
      icon: ShieldCheck,
      color: "text-emerald-600",
      bg: "bg-emerald-50",
      stroke: "#10b981",
    },
    {
      label: "Connections",
      value: stats.connectionsCount || 0,
      trend: stats.connectionsTrend || "+0%",
      icon: Users,
      color: "text-[#D4622C]",
      bg: "bg-[#FCE9DF]",
      stroke: "#D4622C",
    },
  ];

  const previewData = {
    name: userData?.fullName || "",
    title: userData?.jobTitle || "",
    company: userData?.companyName || "",
    email: userData?.workEmail || userData?.email || "",
    phone: userData?.workPhone || userData?.phoneNumber || "",
    website: userData?.website || "",
    linkedin: userData?.linkedin || "",
    city: userData?.city || "",
    country: userData?.country || "",
    address: userData?.address || "",
    bio: userData?.bio || "",
    avatarUrl: userData?.avatarUrl || "",
    bannerUrl: userData?.bannerUrl || "",
    whatsapp: userData?.whatsapp || "",
    instagram: userData?.instagram || "",
    twitter: userData?.twitter || "",
    facebook: userData?.facebook || "",
    github: userData?.github || "",
    youtube: userData?.youtube || "",
    calendly: userData?.calendly || "",
    networkingStatus: userData?.networkingStatus || "Actively Networking",
    focusAreas: userData?.focusAreas || "",
    cardStatus: isPublished ? "Published" : "Draft",
    experience: userData?.experience || "",
    resumeUrl: userData?.resumeUrl || "",
    brochureUrl: userData?.brochureUrl || "",
    slug: userData?.cardSlug || userData?.uid || "",
    cardLayout: userData?.cardLayout || "editorial",
    themeColor: userData?.themeColor || "#D4622C",
  };

  return (
    <div className="max-w-[1650px] mx-auto">
      <div className="flex flex-col xl:flex-row gap-8 items-start">
        {/* ── Left / Main Dashboard Column ── */}
        <div className="flex-1 min-w-0 space-y-6 sm:space-y-7 w-full">
      {/* ── EXECUTIVE HERO CARD ── */}
      <motion.div
        initial="hidden"
        animate="visible"
        variants={fadeUp}
        custom={0}
        className="relative overflow-hidden rounded-[32px] border border-[#3A2E26] shadow-[0_22px_50px_-15px_rgba(28,25,23,0.35)] bg-gradient-to-br from-[#1A1614] via-[#241A14] to-[#120E0C] text-white"
      >
        {/* Subtle Ambient Lighting Meshes */}
        <div className="absolute inset-0 select-none pointer-events-none overflow-hidden">
          <div className="absolute -top-[30%] -right-[10%] w-[55%] h-[160%] bg-[radial-gradient(ellipse_at_center,rgba(212,98,44,0.28)_0%,transparent_70%)] rounded-full blur-[60px]" />
          <div className="absolute -bottom-[40%] left-[20%] w-[45%] h-[140%] bg-[radial-gradient(ellipse_at_center,rgba(242,140,89,0.12)_0%,transparent_70%)] rounded-full blur-[50px]" />
          <div
            className="absolute inset-0 opacity-[0.04]"
            style={{
              backgroundImage: "radial-gradient(circle at 1px 1px, #ffffff 1px, transparent 0)",
              backgroundSize: "24px 24px",
            }}
          />
        </div>

        {/* Optional Cover Photo Watermark Blend on Right */}
        {userData.bannerUrl && (
          <div
            className="absolute right-0 top-0 bottom-0 w-2/5 opacity-15 pointer-events-none bg-cover bg-center"
            style={{
              backgroundImage: `url(${userData.bannerUrl})`,
              maskImage: "linear-gradient(to left, rgba(0,0,0,1) 0%, transparent 100%)",
              WebkitMaskImage: "linear-gradient(to left, rgba(0,0,0,1) 0%, transparent 100%)",
            }}
          />
        )}

        <div className="relative z-10 p-6 sm:p-8 md:p-9 flex flex-col md:flex-row items-start md:items-center justify-between gap-6 md:gap-8">
          <div className="flex flex-col sm:flex-row items-center sm:items-start gap-5 sm:gap-6 text-center sm:text-left w-full">
            {/* Avatar with Precision Concentric Ring & Online Badge */}
            <div className="relative shrink-0">
              <div className="w-20 h-20 sm:w-24 sm:h-24 rounded-[22px] p-[3px] bg-gradient-to-b from-[#D4642C] via-[#E87A43] to-[#BD5523] shadow-xl ring-1 ring-white/10 flex items-center justify-center">
                <div className="w-full h-full rounded-[19px] overflow-hidden bg-white flex items-center justify-center border border-black/5 shadow-[inset_0_2px_4px_rgba(0,0,0,0.03)] relative">
                  {userData.avatarUrl ? (
                    <img
                      src={userData.avatarUrl}
                      alt={`${userData.fullName || "User"} profile photo`}
                      className="w-full h-full object-cover"
                    />
                  ) : (
                    <span className="text-3xl sm:text-4xl font-black text-[#D4642C] tracking-tight select-none">
                      {userData.fullName?.[0] || "U"}
                    </span>
                  )}
                </div>
              </div>
              <div
                className="absolute -bottom-1 -right-1 flex items-center justify-center"
                title={isPublished ? "Card is Live & Public" : "Draft Mode"}
              >
                <div className="w-5.5 h-5.5 sm:w-6 sm:h-6 rounded-full bg-[#1A1614] p-0.5 shadow-lg flex items-center justify-center">
                  <div
                    className={`w-full h-full rounded-full flex items-center justify-center ${
                      isPublished
                        ? "bg-emerald-500 shadow-[0_0_8px_rgba(16,185,129,0.7)]"
                        : "bg-[#D4642C]"
                    }`}
                  >
                    <div className="w-1.5 h-1.5 rounded-full bg-white animate-pulse" />
                  </div>
                </div>
              </div>
            </div>

            {/* Profile Identity Details */}
            <div className="flex-1 min-w-0">
              <div className="flex flex-wrap items-center justify-center sm:justify-start gap-2.5 mb-1.5">
                <h1 className="text-2xl sm:text-3xl font-black tracking-tight text-white drop-shadow-sm">
                  {firstName} {userData.lastName}
                </h1>
                <div
                  className={`inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[11px] font-bold uppercase tracking-wider backdrop-blur-md transition-all ${
                    isPublished
                      ? "bg-emerald-500/15 text-emerald-300 border border-emerald-400/30"
                      : "bg-[#D4622C]/20 text-[#FF9B71] border border-[#D4622C]/40"
                  }`}
                >
                  <span
                    className={`w-2 h-2 rounded-full ${
                      isPublished ? "bg-emerald-400 animate-pulse" : "bg-[#FF9B71]"
                    }`}
                  />
                  <span>{isPublished ? "Live & Public" : "Draft Mode"}</span>
                </div>
              </div>

              {/* Role & Company Metadata */}
              <div className="flex flex-wrap items-center justify-center sm:justify-start gap-2 text-xs text-[#EAE2DB]/85 mb-3">
                <span className="font-semibold text-white/95">
                  {userData.jobTitle || "Digital Cardholder"}
                </span>
                {userData.companyName && (
                  <>
                    <span className="text-white/40">•</span>
                    <span className="flex items-center gap-1 font-medium text-[#EAE2DB]/80">
                      <Building2 size={13} className="text-[#D4622C]" />
                      {userData.companyName}
                    </span>
                  </>
                )}
              </div>

              {/* Public Link Bar with 1-click copy */}
              <div className="inline-flex items-center gap-2 px-3 py-1 rounded-xl bg-white/5 border border-white/10 text-xs text-[#EAE2DB]/80 backdrop-blur-xs">
                <Globe size={12} className="text-[#D4622C]" />
                <span className="font-mono text-[11px] text-white/80 truncate max-w-[220px]">
                  mycardshare.in/card/{userData?.cardSlug || userData?.uid || "your-card"}
                </span>
                <button
                  onClick={handleCopyShareLink}
                  className="ml-1 text-[10px] font-bold uppercase tracking-wider text-[#D4622C] hover:text-white transition-colors cursor-pointer flex items-center gap-1"
                >
                  {copiedLink ? <Check size={11} className="text-emerald-400" /> : <Copy size={11} />}
                  <span>{copiedLink ? "Copied" : "Copy"}</span>
                </button>
              </div>
            </div>
          </div>

          {/* Action Buttons */}
          <div className="flex flex-row md:flex-col gap-2.5 w-full md:w-auto shrink-0 justify-center">
            <button
              onClick={() => (window.location.href = "/portal/profile")}
              className="flex-1 md:flex-initial py-2.5 px-5 rounded-xl bg-white/10 hover:bg-white/20 text-white border border-white/20 font-bold text-xs transition-all flex items-center justify-center gap-2 backdrop-blur-md cursor-pointer hover:shadow-md"
            >
              <Pencil size={14} />
              <span>Edit Card</span>
            </button>

            <button
              onClick={handlePublishToggle}
              disabled={publishLoading}
              className="flex-1 md:flex-initial py-2.5 px-6 rounded-xl bg-[#D4622C] hover:bg-[#BD5523] text-white font-bold text-xs transition-all shadow-[0_4px_16px_rgba(212,98,44,0.4)] hover:shadow-[0_6px_22px_rgba(212,98,44,0.5)] flex items-center justify-center gap-2 cursor-pointer hover:-translate-y-0.5"
            >
              <Globe size={14} />
              <span>{publishLoading ? "Updating..." : isPublished ? "Unpublish Card" : "Go Live Now"}</span>
            </button>
          </div>
        </div>
      </motion.div>

      {/* ── METRICS ROW ── */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-3.5 sm:gap-4">
        {/* Card 1: Card Impressions */}
        <motion.div
          variants={fadeUp}
          initial="hidden"
          animate="visible"
          custom={1}
          className="bg-white border border-[#EAE2DB] rounded-2xl p-4 sm:p-4.5 shadow-xs hover:shadow-md hover:border-[#D4622C]/40 transition-all group relative overflow-hidden flex flex-col justify-between"
        >
          <div>
            <div className="flex items-center justify-between mb-2.5">
              <div className="w-9 h-9 rounded-xl bg-[#FCE9DF] text-[#D4622C] flex items-center justify-center shadow-2xs group-hover:scale-105 transition-transform">
                <Eye size={17} strokeWidth={2.2} />
              </div>
              <span className="inline-flex items-center gap-1 text-[10px] font-bold px-2 py-0.5 rounded-full bg-[#FCE9DF] text-[#D4622C]">
                <TrendingUp size={10} /> {stats.viewsTrend || "+0%"}
              </span>
            </div>
            <div className="text-[11px] font-bold uppercase tracking-wider text-[#77716C] mb-0.5">
              Card Impressions
            </div>
            <div className="text-2xl sm:text-[26px] font-black tracking-tight text-[#191919]">
              {loading ? "..." : stats.views || 0}
            </div>
          </div>
          <div className="mt-3 pt-2 border-t border-[#F8F4EF] flex items-center justify-between text-[11px] text-[#77716C]">
            <span>Total views & taps</span>
            <span className="font-semibold text-[#191919]">All-time</span>
          </div>
        </motion.div>

        {/* Card 2: Profile Status & Health */}
        <motion.div
          variants={fadeUp}
          initial="hidden"
          animate="visible"
          custom={2}
          className="bg-white border border-[#EAE2DB] rounded-2xl p-4 sm:p-4.5 shadow-xs hover:shadow-md hover:border-[#D4622C]/40 transition-all group relative overflow-hidden flex flex-col justify-between"
        >
          <div>
            <div className="flex items-center justify-between mb-2.5">
              <div className="w-9 h-9 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center shadow-2xs group-hover:scale-105 transition-transform">
                <ShieldCheck size={17} strokeWidth={2.2} />
              </div>
              <span
                className={`inline-flex items-center gap-1 text-[10px] font-bold px-2 py-0.5 rounded-full ${
                  isPublished
                    ? "bg-emerald-50 text-emerald-700 border border-emerald-200"
                    : "bg-[#FCE9DF] text-[#D4622C] border border-[#D4622C]/20"
                }`}
              >
                <span className={`w-1.5 h-1.5 rounded-full ${isPublished ? "bg-emerald-500 animate-pulse" : "bg-[#D4622C]"}`} />
                {isPublished ? "Active" : "Draft"}
              </span>
            </div>
            <div className="text-[11px] font-bold uppercase tracking-wider text-[#77716C] mb-0.5">
              Profile Status
            </div>
            <div className="text-xl sm:text-[22px] font-black tracking-tight text-[#191919]">
              {isPublished ? "Live Card" : "Draft Card"}
            </div>
          </div>
          <div className="mt-3 pt-2 border-t border-[#F8F4EF]">
            <div className="flex items-center justify-between text-[10px] text-[#77716C] mb-1">
              <span>Completeness</span>
              <span className="font-bold text-[#D4622C]">85%</span>
            </div>
            <div className="w-full h-1 bg-[#F8F4EF] rounded-full overflow-hidden">
              <div className="h-full bg-gradient-to-r from-[#D4622C] to-[#F28C59] rounded-full" style={{ width: "85%" }} />
            </div>
          </div>
        </motion.div>

        {/* Card 3: Network Connections */}
        <motion.div
          variants={fadeUp}
          initial="hidden"
          animate="visible"
          custom={3}
          className="bg-white border border-[#EAE2DB] rounded-2xl p-4 sm:p-4.5 shadow-xs hover:shadow-md hover:border-[#D4622C]/40 transition-all group relative overflow-hidden flex flex-col justify-between"
        >
          <div>
            <div className="flex items-center justify-between mb-2.5">
              <div className="w-9 h-9 rounded-xl bg-[#FCE9DF] text-[#D4622C] flex items-center justify-center shadow-2xs group-hover:scale-105 transition-transform">
                <Users size={17} strokeWidth={2.2} />
              </div>
              <span className="inline-flex items-center gap-1 text-[10px] font-bold px-2 py-0.5 rounded-full bg-[#FCE9DF] text-[#D4622C]">
                <TrendingUp size={10} /> {stats.connectionsTrend || "+0%"}
              </span>
            </div>
            <div className="text-[11px] font-bold uppercase tracking-wider text-[#77716C] mb-0.5">
              Total Connections
            </div>
            <div className="text-2xl sm:text-[26px] font-black tracking-tight text-[#191919]">
              {loading ? "..." : stats.connectionsCount || 0}
            </div>
          </div>
          <div className="mt-3 pt-2 border-t border-[#F8F4EF] flex items-center justify-between text-[11px] text-[#77716C]">
            <span>Saved contacts</span>
            <span className="font-semibold text-[#191919]">This month</span>
          </div>
        </motion.div>
      </div>

      {/* ── DIGITAL WALLET PASSES ── */}
      <div className="space-y-3">
        <div className="flex items-center justify-between px-1">
          <div className="flex items-center gap-2">
            <div className="w-7 h-7 rounded-lg bg-[#FCE9DF] text-[#D4622C] flex items-center justify-center">
              <Wallet size={15} strokeWidth={2.2} />
            </div>
            <div>
              <h2 className="text-base font-black text-[#191919] tracking-tight">
                Digital Wallet Passes
              </h2>
              <p className="text-[11px] text-[#77716C]">
                Instant contactless NFC & QR sharing on mobile devices
              </p>
            </div>
          </div>
          <span className="text-[10px] font-bold text-[#D4622C] bg-[#FCE9DF] px-2.5 py-0.5 rounded-full uppercase tracking-wider">
            1-Tap Install
          </span>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-3 gap-3.5 sm:gap-4">
          {/* Apple Wallet Pass */}
          <motion.div
            whileHover={{ y: -3, scale: 1.01 }}
            whileTap={{ scale: 0.98 }}
            onClick={() => handleWalletClick("apple")}
            className="cursor-pointer relative rounded-2xl p-4 sm:p-4.5 bg-gradient-to-br from-[#1C1917] via-[#241A14] to-[#120E0C] text-white border border-[#3A2E26] shadow-[0_8px_20px_-6px_rgba(28,25,23,0.35)] group overflow-hidden flex flex-col justify-between h-[160px] sm:h-[168px] transition-all"
          >
            <div className="absolute top-0 right-0 w-28 h-28 bg-radial from-white/10 to-transparent blur-xl pointer-events-none group-hover:scale-125 transition-transform" />

            <div className="relative z-10 flex items-start justify-between">
              <div className="w-9 h-9 rounded-xl bg-black border border-white/15 flex items-center justify-center shadow-xs">
                <img src="/wallet-brands/apple.svg" alt="Apple" className="h-4.5 w-auto" />
              </div>
              <div className="flex items-center gap-1 text-white/50 group-hover:text-white transition-colors">
                <Radio size={15} />
              </div>
            </div>

            <div className="relative z-10">
              <div className="text-sm font-black tracking-tight text-white mb-0.5">
                Apple Wallet
              </div>
              <p className="text-[11px] text-[#EAE2DB]/75 font-medium mb-2.5 truncate">
                Official Apple PKPass for iPhone & Watch
              </p>
              <div className="inline-flex items-center justify-between w-full py-1.5 px-3 rounded-lg bg-white/10 hover:bg-white text-white hover:text-[#1C1917] font-bold text-[11px] transition-all backdrop-blur-xs">
                <span>Add to Apple Wallet</span>
                <ChevronRight size={13} />
              </div>
            </div>
          </motion.div>

          {/* Google Wallet Pass */}
          <motion.div
            whileHover={{ y: -3, scale: 1.01 }}
            whileTap={{ scale: 0.98 }}
            onClick={() => handleWalletClick("google")}
            className="cursor-pointer relative rounded-2xl p-4 sm:p-4.5 bg-white border border-[#EAE2DB] shadow-xs hover:shadow-md hover:border-[#D4622C]/40 group overflow-hidden flex flex-col justify-between h-[160px] sm:h-[168px] transition-all"
          >
            <div className="absolute -bottom-4 -right-4 w-20 h-20 bg-[#FCE9DF]/40 rounded-full blur-lg pointer-events-none group-hover:scale-125 transition-transform" />

            <div className="relative z-10 flex items-start justify-between">
              <div className="w-9 h-9 rounded-xl bg-white border border-[#EAE2DB] flex items-center justify-center shadow-xs overflow-hidden">
                <img src="/wallet-brands/google-g.svg" alt="Google" className="w-5.5 h-5.5 object-contain" />
              </div>
              <div className="flex items-center gap-1 text-[#77716C]/60 group-hover:text-[#D4622C] transition-colors">
                <Radio size={15} />
              </div>
            </div>

            <div className="relative z-10">
              <div className="text-sm font-black tracking-tight text-[#191919] mb-0.5">
                Google Wallet
              </div>
              <p className="text-[11px] text-[#77716C] font-medium mb-2.5 truncate">
                Fast NFC tap for Android & Wear OS
              </p>
              <div className="inline-flex items-center justify-between w-full py-1.5 px-3 rounded-lg bg-[#FAF6F2] group-hover:bg-[#D4622C] text-[#191919] group-hover:text-white font-bold text-[11px] transition-all border border-[#EAE2DB] group-hover:border-transparent">
                <span>{walletLoading === "google" ? "Creating Pass..." : "Add to Google Wallet"}</span>
                <ChevronRight size={13} />
              </div>
            </div>
          </motion.div>

          {/* Samsung Wallet Pass */}
          <motion.div
            whileHover={{ y: -3, scale: 1.01 }}
            whileTap={{ scale: 0.98 }}
            onClick={() => handleWalletClick("samsung")}
            className="cursor-pointer relative rounded-2xl p-4 sm:p-4.5 bg-white border border-[#EAE2DB] shadow-xs hover:shadow-md hover:border-[#D4622C]/40 group overflow-hidden flex flex-col justify-between h-[160px] sm:h-[168px] transition-all"
          >
            <div className="relative z-10 flex items-start justify-between">
              <div className="w-9 h-9 rounded-xl bg-[#034EA2]/5 border border-[#034EA2]/15 flex items-center justify-center shadow-xs overflow-hidden">
                <img src="/wallet-brands/samsung-symbol.svg" alt="Samsung" className="w-6 h-6 object-contain" />
              </div>
              <span className="text-[9px] font-black uppercase tracking-wider text-[#D4622C] bg-[#FCE9DF] px-2 py-0.5 rounded-full border border-[#D4622C]/30">
                Coming Soon
              </span>
            </div>

            <div className="relative z-10">
              <div className="text-sm font-black tracking-tight text-[#191919] mb-0.5">
                Samsung Wallet
              </div>
              <p className="text-[11px] text-[#77716C] font-medium mb-2.5 truncate">
                Galaxy Quick Access & Samsung Pay
              </p>
              <div className="inline-flex items-center justify-between w-full py-1.5 px-3 rounded-lg bg-[#FAF6F2] text-[#77716C] font-bold text-[11px] border border-[#EAE2DB]">
                <span>Notify When Available</span>
                <ChevronRight size={13} />
              </div>
            </div>
          </motion.div>
        </div>
      </div>

      {/* ── APPLE WALLET DEMO MODAL ── */}
      {showAppleDemo && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          role="dialog"
          aria-modal="true"
          aria-labelledby="apple-wallet-demo-title"
          className="fixed inset-0 z-[110] flex items-center justify-center overflow-y-auto bg-black/75 px-4 py-8 backdrop-blur-md"
          onClick={() => setShowAppleDemo(false)}
        >
          <motion.div
            initial={{ opacity: 0, scale: 0.94, y: 12 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.96, y: 8 }}
            transition={{ duration: 0.35, ease: [0.16, 1, 0.3, 1] }}
            onClick={(e) => e.stopPropagation()}
            className="relative w-full max-w-[460px]"
          >
            <button
              onClick={() => setShowAppleDemo(false)}
              aria-label="Close Apple Wallet preview"
              className="absolute -top-3 -right-3 z-10 grid h-11 w-11 place-items-center rounded-full border border-white/10 bg-[#1C1917] text-white/70 shadow-lg transition-all hover:scale-105 hover:text-white hover:border-white/20 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-[#D4622C]"
            >
              <X size={16} />
            </button>

            <h2 id="apple-wallet-demo-title" className="sr-only">
              Apple Wallet preview for {userData.fullName || "your card"}
            </h2>

            <WalletPreviewCard
              brand="apple"
              data={{
                ...userData,
                workEmail: userData.workEmail || userData.email,
                workPhone: userData.workPhone || userData.phoneNumber,
                publicCardUrl: getProfileUrl(),
              }}
            />

            <div className="mt-5 flex flex-col gap-2 sm:flex-row">
              <button
                onClick={() => setShowAppleDemo(false)}
                className="h-12 flex-1 rounded-2xl border border-white/10 bg-white/[0.06] text-sm font-bold text-white/80 backdrop-blur-md transition-all hover:border-white/20 hover:bg-white/[0.1] hover:text-white focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-[#D4622C]"
              >
                Done
              </button>
              <button
                onClick={() => downloadVcf()}
                className="group relative h-12 flex-[1.4] overflow-hidden rounded-2xl text-sm font-bold text-white bg-[#D4622C] hover:bg-[#BD5523] shadow-[0_4px_16px_rgba(212,98,44,0.4)] transition-all hover:-translate-y-0.5 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-[#D4622C] flex items-center justify-center gap-2"
              >
                <Download size={15} />
                Download contact file
              </button>
            </div>

            <p className="mt-3 text-center text-[11px] font-medium text-white/50">
              Native Apple Wallet pass coming soon · vCard works on every
              phone today
            </p>
          </motion.div>
        </motion.div>
      )}

      {/* ── QUICK ACTIONS ── */}
      <div className="space-y-3">
        <h2 className="text-base sm:text-lg font-black text-[#191919] tracking-tight flex items-center gap-2 px-1">
          <Activity size={18} className="text-[#D4622C]" />
          Quick Actions
        </h2>
        <div className="grid grid-cols-2 sm:grid-cols-2 lg:grid-cols-3 gap-3 sm:gap-4">
          {[
            {
              title: "Modify Profile",
              desc: "Update your digital business card details and branding.",
              icon: Pencil,
              iconColor: "text-[#D4622C]",
              iconBg: "bg-[#FCE9DF]",
              href: "/portal/profile",
            },
            {
              title: "Visual Preview",
              desc: "See exactly how others view your professional profile.",
              icon: ExternalLink,
              iconColor: "text-[#D4622C]",
              iconBg: "bg-[#FCE9DF]",
              onClick: () => {
                const slug = userData.cardSlug || userData.uid;
                if (isPublished) {
                  window.open(getCardShareUrl(slug), "_blank");
                } else {
                  showToast("Publish your card first to preview.", "warning");
                }
              },
            },
            {
              title: "QR Code",
              desc: "Generate your unique QR code for instant physical sharing.",
              icon: QrCode,
              iconColor: "text-[#D4622C]",
              iconBg: "bg-[#FCE9DF]",
              onClick: () => {
                const slug = userData.cardSlug || userData.uid;
                if (!isPublished) {
                  showToast("Publish your card first.", "warning");
                  return;
                }
                setShowQR(true);
              },
            },
            {
              title: "Smart Scanner",
              desc: "Instantly digitize paper cards into your secure cloud contacts.",
              icon: Camera,
              iconColor: "text-emerald-600",
              iconBg: "bg-emerald-50",
              href: "/portal/scanner",
            },
            {
              title: "Contact Vault",
              desc: "Manage all leads and network connections you've built.",
              icon: Users,
              iconColor: "text-[#D4622C]",
              iconBg: "bg-[#FCE9DF]",
              href: "/portal/vault",
            },
            {
              title: "Settings",
              desc: "Account preferences, notifications, and security options.",
              icon: Settings,
              iconColor: "text-[#77716C]",
              iconBg: "bg-[#F8F4EF]",
              href: "/portal/settings",
            },
          ].map((action, i) => (
            <motion.div
              key={action.title}
              variants={fadeUp}
              initial="hidden"
              animate="visible"
              custom={i + 4}
              onClick={() => {
                if (action.onClick) action.onClick();
                else if (action.href) window.location.href = action.href;
              }}
              className="relative p-4 sm:p-5 cursor-pointer group bg-white rounded-2xl border border-[#EAE2DB] shadow-xs hover:shadow-lg hover:border-[#D4622C]/40 hover:-translate-y-0.5 transition-all duration-300 overflow-hidden flex flex-col justify-between h-[150px] sm:h-[160px]"
            >
              <div className="relative z-10 flex flex-col h-full justify-between">
                <div className="flex justify-between items-start">
                  <div className={`w-10 h-10 rounded-xl ${action.iconBg} flex items-center justify-center transition-all duration-300 group-hover:scale-105`}>
                    <action.icon
                      size={19}
                      className={action.iconColor}
                      strokeWidth={2.2}
                    />
                  </div>
                  
                  {/* Subtle hover arrow */}
                  <div className="w-7 h-7 rounded-full bg-[#F8F4EF] flex items-center justify-center opacity-0 -translate-x-1.5 group-hover:opacity-100 group-hover:translate-x-0 transition-all duration-300">
                    <ChevronRight size={14} className="text-[#D4622C]" strokeWidth={2.5} />
                  </div>
                </div>

                <div className="mt-2.5">
                  <h3 className="text-sm sm:text-[15px] font-black text-[#191919] mb-0.5 tracking-tight group-hover:text-[#D4622C] transition-colors duration-200">
                    {action.title}
                  </h3>
                  <p className="text-[11px] text-[#77716C] font-normal leading-relaxed line-clamp-2">
                    {action.desc}
                  </p>
                </div>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </div>

    {/* ── Right / Live Card Preview Column ── */}
    <div className="w-full xl:w-[390px] 2xl:w-[410px] shrink-0">
      <div className="xl:sticky xl:top-24 space-y-4">
        <div className="flex items-center justify-between px-2">
          <div className="text-xs font-black uppercase tracking-[0.18em] text-[#77716C] flex items-center gap-2">
            <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
            Live Card Preview
          </div>
          <button
            onClick={() => setActiveVariant((prev) => (prev === 1 ? 2 : 1))}
            className="text-[10px] bg-[#FCE9DF] text-[#D4622C] border border-[#D4622C]/30 px-3 py-1 rounded-full hover:bg-[#D4622C] hover:text-white transition-all uppercase tracking-wider font-black shadow-2xs cursor-pointer"
          >
            Variant {activeVariant === 1 ? "2" : "1"}
          </button>
        </div>

        <div className="w-full flex justify-center">
          {activeVariant === 1 ? (
            <ProfileCardPreview data={previewData} onPopupToggle={setIsOverlayOpen} />
          ) : (
            <ProfileCardVariant2 data={previewData} onPopupToggle={setIsOverlayOpen} />
          )}
        </div>

        {/* Quick Link bar */}
        <div className="p-4 rounded-2xl bg-white border border-[#EAE2DB] shadow-xs flex items-center justify-between gap-3">
          <div className="min-w-0 flex-1">
            <p className="text-xs font-bold text-[#191919] truncate">
              {userData?.cardSlug ? `mycardshare.in/card/${userData.cardSlug}` : "Ready to share"}
            </p>
            <p className="text-[10px] text-[#77716C] truncate">
              {isPublished ? "Your card is currently Live" : "Card is in Draft mode"}
            </p>
          </div>
          <button
            onClick={() => {
              const slug = userData?.cardSlug || userData?.uid;
              window.open(getCardShareUrl(slug), "_blank");
            }}
            className="px-3.5 py-2 rounded-xl bg-[#D4622C] hover:bg-[#BD5523] text-white text-xs font-bold transition-all shadow-xs flex items-center gap-1.5 shrink-0 cursor-pointer"
          >
            <span>View</span>
            <ExternalLink size={12} />
          </button>
        </div>
      </div>
    </div>
  </div>

      {/* ── QR CODE MODAL ── */}
      {showQR && (
        <div
          className="fixed inset-0 bg-black/70 backdrop-blur-sm z-[100] flex items-center justify-center p-4"
          onClick={() => setShowQR(false)}
        >
          <motion.div
            initial={{ scale: 0.9, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            onClick={(e) => e.stopPropagation()}
            className="bg-white border border-[#EAE2DB] rounded-3xl p-8 text-center max-w-[400px] w-full shadow-2xl"
          >
            <h2 className="text-xl font-black text-[#191919] mb-1">Your QR Code</h2>
            <p className="text-xs text-[#77716C] mb-6">
              Scan to view your digital card
            </p>
            <div className="bg-[#F8F4EF] p-5 rounded-2xl border border-[#EAE2DB] mb-6 inline-block shadow-inner">
              <QRPreview url={getProfileUrl()} />
            </div>
            <div className="flex gap-3">
              <button
                onClick={() => setShowQR(false)}
                className="flex-1 py-3 rounded-xl bg-[#F8F4EF] hover:bg-[#EAE2DB] text-[#191919] font-bold text-sm border border-[#EAE2DB] transition-colors"
              >
                Close
              </button>
              <button
                onClick={handleDownloadQR}
                className="flex-1 py-3 rounded-xl bg-[#D4622C] hover:bg-[#BD5523] text-white font-bold text-sm shadow-[0_4px_14px_rgba(212,98,44,0.3)] transition-colors flex items-center justify-center gap-2"
              >
                Download Image
              </button>
            </div>
          </motion.div>
        </div>
      )}

      {/* Toast Notification */}
      {toast && (
        <motion.div
          initial={{ opacity: 0, y: 40, scale: 0.95 }}
          animate={{ opacity: 1, y: 0, scale: 1 }}
          exit={{ opacity: 0, y: 40, scale: 0.95 }}
          className={`fixed bottom-8 right-8 z-[200] px-6 py-4 rounded-2xl text-sm font-bold shadow-2xl backdrop-blur-md border ${
            toast.type === "error"
              ? "bg-red-500/20 text-red-600 border-red-500/30"
              : toast.type === "warning"
                ? "bg-amber-500/20 text-amber-700 border-amber-500/30"
                : "bg-[#FCE9DF] text-[#D4622C] border-[#D4622C]/30"
          }`}
        >
          {toast.message}
        </motion.div>
      )}
    </div>
  );
}
