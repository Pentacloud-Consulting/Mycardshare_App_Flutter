"use client";

import { useEffect, useState, useRef } from "react";
import { useSearchParams } from "next/navigation";
import { motion, AnimatePresence } from "framer-motion";
import {
  User,
  Mail,
  MapPin,
  Camera,
  Linkedin,
  Globe,
  Phone,
  Briefcase,
  Zap,
  ArrowRight,
  ArrowLeft,
  Check,
  Building,
  Ticket,
  Sparkles,
  Instagram,
  Twitter,
  Github,
  MessageCircle,
  Image as ImageIcon,
  X,
  Crop,
  Trash2,
  Upload,
  CheckCircle2,
  ExternalLink,
  Layers,
  Palette,
  Eye,
  Smartphone,
  Share2,
  Link as LinkIcon,
} from "lucide-react";
import GlassInput from "./GlassInput";
import EditBanner from "../Edits/EditBanner";
import FillForm from "../Popup/FillForm";
import LiveCardPreview from "./LiveCardPreview";
import { authFetch, parseFetchJson, toUserMessage } from "@/lib/api";

const showEmployeeVoucherSkip =
  typeof process !== "undefined" &&
  process.env.NEXT_PUBLIC_EMPLOYEE_ALLOW_SKIP === "true";

function voucherErrorHint(codeOrMsg) {
  const m = String(codeOrMsg || "");
  if (m.includes("SKIP_NOT_ALLOWED")) {
    return "Skipping the company code is not enabled for this deployment.";
  }
  if (m.includes("GLOBAL_COMPANY_NOT_CONFIGURED")) {
    return "Global company is not configured. Contact support.";
  }
  if (m.includes("COMPANY_NOT_FOUND")) {
    return "Company record not found for the configured link. Contact support.";
  }
  if (m.includes("INVALID_VOUCHER")) {
    return "That code was not recognized. Use your organization voucher or the master code from your admin.";
  }
  return m;
}

function slugFromName(name) {
  return String(name || "")
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

function generateEmployeeSlug(companySlug, fullName) {
  const namePart = slugFromName(fullName);
  if (companySlug && namePart) return `${companySlug}-${namePart}`;
  if (companySlug) return companySlug;
  return namePart;
}

function buildOnboardingPayload(formData, isEmployee) {
  const safeStoredImageUrl = (v) => {
    if (!v || typeof v !== "string") return undefined;
    if (v.startsWith("data:")) return undefined;
    if (v.startsWith("/")) return v;
    if (/^https?:\/\//i.test(v)) return v;
    return undefined;
  };

  return {
    fullName: formData.fullName,
    jobTitle: formData.jobTitle,
    companyName: formData.companyName,
    bio: formData.bio,
    cardSlug: formData.cardSlug,
    workPhone: formData.workPhone,
    workEmail: formData.workEmail,
    personalEmail: formData.personalEmail,
    website: formData.website,
    address: formData.address,
    country: formData.country,
    city: formData.city,
    linkedin: formData.linkedin,
    instagram: formData.instagram,
    twitter: formData.twitter,
    github: formData.github,
    whatsapp: formData.whatsapp,
    experience: formData.experience,
    skills: formData.skills,
    voucherCode: formData.voucherCode,
    themeColor: formData.themeColor,
    cardLayout: formData.cardLayout,
    avatarUrl: safeStoredImageUrl(formData.avatarUrl),
    bannerUrl: safeStoredImageUrl(formData.bannerUrl),
    companyLogo: safeStoredImageUrl(formData.companyLogo),
    onboardingCompleted: true,
    role: isEmployee ? "employee" : "individual",
  };
}

// 8 Curated Luxury Color Palettes
const COLOR_PRESETS = [
  { name: "Matte Orange", hex: "#D4622C" },
  { name: "Coral Terracotta", hex: "#E05A47" },
  { name: "Amber Gold", hex: "#F59E0B" },
  { name: "Olive Green", hex: "#84CC16" },
  { name: "Teal Mint", hex: "#10B981" },
  { name: "Cyan Sky", hex: "#0EA5E9" },
  { name: "Cobalt Blue", hex: "#2563EB" },
  { name: "Iris Purple", hex: "#8B5CF6" },
  { name: "Fuchsia Pink", hex: "#D946EF" },
  { name: "Deep Charcoal", hex: "#191919" },
  { name: "Slate Silver", hex: "#94A3B8" },
];

// Curated Card Layout Options (4 Curated Styles)
const LAYOUT_OPTIONS = [
  {
    id: "editorial",
    name: "Editorial",
    desc: "Left avatar with clean typography lines",
  },
  {
    id: "minimal",
    name: "Centered",
    desc: "Centered portrait with balanced layout",
  },
  {
    id: "banner-right",
    name: "Banner Right",
    desc: "Top banner with right-aligned avatar",
  },
  {
    id: "wide",
    name: "Modern Wide",
    desc: "Full-bleed card with prominent brand bar",
  },
];

// Visual Layout Blueprint Wireframe with Proper Padding
function LayoutMiniWireframe({ layoutId, themeColor = "#D4622C", isSelected = false }) {
  if (layoutId === "minimal") {
    return (
      <div className={`w-full h-13 sm:h-14 rounded-xl p-2 flex flex-col items-center justify-center transition-all ${isSelected ? 'bg-white' : 'bg-[#F8F4EF]/70'}`}>
        <div className="w-4.5 h-4.5 rounded-full bg-[#D4622C]/25 border border-[#D4622C]/40 flex items-center justify-center mb-1">
          <User size={10} className="text-[#D4622C]" />
        </div>
        <div className="w-10 h-1 bg-[#191919]/25 rounded-full mb-0.5" />
        <div className="w-6 h-0.5 bg-[#77716C]/20 rounded-full" />
      </div>
    );
  }

  if (layoutId === "banner-right") {
    return (
      <div className={`w-full h-13 sm:h-14 rounded-xl overflow-hidden flex flex-col transition-all ${isSelected ? 'bg-white' : 'bg-[#F8F4EF]/70'}`}>
        <div className="w-full h-4.5 bg-[#D4622C]/20 border-b border-[#EAE2DB] flex justify-end px-2 pt-0.5">
          <div className="w-3.5 h-3.5 rounded-full bg-white border border-[#D4622C]/40 shadow-2xs" />
        </div>
        <div className="p-1.5 flex flex-col gap-1">
          <div className="w-8 h-1 bg-[#191919]/25 rounded-full" />
          <div className="w-5 h-0.5 bg-[#77716C]/20 rounded-full" />
        </div>
      </div>
    );
  }

  if (layoutId === "wide") {
    return (
      <div className={`w-full h-13 sm:h-14 rounded-xl overflow-hidden flex flex-col transition-all ${isSelected ? 'bg-white' : 'bg-[#F8F4EF]/70'}`}>
        <div className="w-full h-3.5 bg-[#191919]/20" />
        <div className="p-1.5 flex items-center gap-1.5 flex-1">
          <div className="w-4 h-4 rounded-full bg-[#D4622C]/25 shrink-0" />
          <div className="flex flex-col gap-1 flex-1">
            <div className="w-8 h-1 bg-[#191919]/25 rounded-full" />
            <div className="w-4 h-0.5 bg-[#77716C]/20 rounded-full" />
          </div>
        </div>
      </div>
    );
  }

  // Default: editorial (Avatar on left with text lines beside it)
  return (
    <div className={`w-full h-13 sm:h-14 rounded-xl p-2 flex flex-col justify-center transition-all ${isSelected ? 'bg-white' : 'bg-[#F8F4EF]/70'}`}>
      <div className="flex items-center gap-1.5 mb-1">
        <div className="w-4.5 h-4.5 rounded-full bg-[#D4622C]/20 border border-[#D4622C]/40 flex items-center justify-center shrink-0">
          <User size={9} className="text-[#D4622C]" />
        </div>
        <div className="flex flex-col gap-0.5 flex-1">
          <div className="w-8 h-1 bg-[#191919]/30 rounded-full" />
          <div className="w-5 h-0.5 bg-[#77716C]/20 rounded-full" />
        </div>
      </div>
      <div className="w-11 h-0.5 bg-[#191919]/15 rounded-full" />
    </div>
  );
}

export default function IndividualOnboarding({ isEmployee, onComplete, userData, user }) {
  const searchParams = useSearchParams();
  const workspaceRef = useRef(null);
  const [step, setStep] = useState(isEmployee ? 0 : 1);
  const [mobileTab, setMobileTab] = useState("edit");
  useEffect(() => {
    if (workspaceRef.current) {
      workspaceRef.current.scrollTop = 0;
    }
  }, [step]); // "edit" | "preview" on mobile
  const [loading, setLoading] = useState(false);
  const [uploadState, setUploadState] = useState({
    avatar: { uploading: false, error: null },
    banner: { uploading: false, error: null },
    logo: { uploading: false, error: null },
  });

  const [workspaceCtx, setWorkspaceCtx] = useState({
    companyName: "",
    companySlug: "",
    locked: false,
  });

  // Extract initial values from all possible sources
  const [formData, setFormData] = useState(() => {
    let sessionCtx = null;
    try {
      if (typeof window !== "undefined") {
        const raw = sessionStorage.getItem("dbc_signup_context");
        if (raw) sessionCtx = JSON.parse(raw);
      }
    } catch (_) {}

    const initialName =
      searchParams?.get("prefillName") ||
      searchParams?.get("fullName") ||
      searchParams?.get("name") ||
      sessionCtx?.fullName ||
      sessionCtx?.name ||
      userData?.fullName ||
      userData?.displayName ||
      userData?.name ||
      user?.displayName ||
      "";

    const initialEmail =
      searchParams?.get("prefillEmail") ||
      searchParams?.get("email") ||
      sessionCtx?.workEmail ||
      sessionCtx?.email ||
      userData?.workEmail ||
      userData?.email ||
      user?.email ||
      "";

    const initialCompany =
      searchParams?.get("companyName") ||
      sessionCtx?.companyName ||
      userData?.companyName ||
      "";

    const initialSlug = initialName ? slugFromName(initialName) : "";

    const nameParts = initialName.trim().split(/\s+/).filter(Boolean);
    const firstName = nameParts[0] || "";
    const lastName = nameParts.slice(1).join(" ") || "";

    return {
      fullName: initialName,
      firstName,
      lastName,
      jobTitle: "",
      companyName: initialCompany,
      bio: "",
      cardSlug: initialSlug,
      workPhone: userData?.workPhone || userData?.phoneNumber || "",
      workEmail: initialEmail,
      personalEmail: "",
      website: "",
      address: "",
      country: "",
      city: "",
      linkedin: "",
      instagram: "",
      twitter: "",
      github: "",
      whatsapp: "",
      experience: "",
      skills: [],
      voucherCode: "",
      avatarUrl: "",
      bannerUrl: "",
      companyLogo: "",
      themeColor: "#D4622C",
      cardLayout: "editorial",
    };
  });

  const [showBannerEditor, setShowBannerEditor] = useState(false);
  const [showMoreNameFields, setShowMoreNameFields] = useState(false);
  const [showPopup, setShowPopup] = useState(false);
  const [popupMessage, setPopupMessage] = useState("");

  // Sync firstName / lastName into fullName whenever either changes
  const handleNameChange = (first, last) => {
    const combined = `${first || ""} ${last || ""}`.trim();
    setFormData((prev) => {
      const next = { ...prev, firstName: first, lastName: last, fullName: combined };
      if (!prev.cardSlug || prev.cardSlug === slugFromName(prev.fullName)) {
        next.cardSlug = workspaceCtx.locked
          ? generateEmployeeSlug(workspaceCtx.companySlug, combined)
          : slugFromName(combined);
      }
      return next;
    });
  };

  // Autopopulate from user / session / searchParams when available
  useEffect(() => {
    let sessionCtx = null;
    try {
      if (typeof window !== "undefined") {
        const raw = sessionStorage.getItem("dbc_signup_context");
        if (raw) sessionCtx = JSON.parse(raw);
      }
    } catch (_) {}

    const nameHint =
      searchParams?.get("prefillName") ||
      searchParams?.get("fullName") ||
      searchParams?.get("name") ||
      sessionCtx?.fullName ||
      sessionCtx?.name ||
      userData?.fullName ||
      userData?.displayName ||
      userData?.name ||
      user?.displayName ||
      "";

    const emailHint =
      searchParams?.get("prefillEmail") ||
      searchParams?.get("email") ||
      sessionCtx?.workEmail ||
      sessionCtx?.email ||
      userData?.workEmail ||
      userData?.email ||
      user?.email ||
      "";

    const phoneHint =
      userData?.workPhone ||
      userData?.phoneNumber ||
      sessionCtx?.phoneNumber ||
      sessionCtx?.workPhone ||
      "";

    const companyHint =
      searchParams?.get("companyName") ||
      sessionCtx?.companyName ||
      userData?.companyName ||
      "";

    setFormData((prev) => {
      const next = { ...prev };
      let changed = false;

      if (nameHint && (!prev.fullName || !prev.fullName.trim())) {
        next.fullName = String(nameHint).trim();
        const parts = next.fullName.split(/\s+/).filter(Boolean);
        next.firstName = parts[0] || "";
        next.lastName = parts.slice(1).join(" ") || "";
        changed = true;
        if (!prev.cardSlug || !prev.cardSlug.trim()) {
          next.cardSlug = workspaceCtx.locked
            ? generateEmployeeSlug(workspaceCtx.companySlug, next.fullName)
            : slugFromName(next.fullName);
        }
      }
      if (emailHint && (!prev.workEmail || !prev.workEmail.trim())) {
        next.workEmail = String(emailHint).trim();
        changed = true;
      }
      if (phoneHint && (!prev.workPhone || !prev.workPhone.trim())) {
        next.workPhone = String(phoneHint).trim();
        changed = true;
      }
      if (companyHint && !workspaceCtx.locked && (!prev.companyName || !prev.companyName.trim())) {
        next.companyName = String(companyHint).trim();
        changed = true;
      }

      return changed ? next : prev;
    });
  }, [userData, user, searchParams, workspaceCtx.locked, workspaceCtx.companySlug]);

  // Employee Voucher Auto-Validation from invite links
  useEffect(() => {
    if (!isEmployee || typeof window === "undefined") return;

    async function autoValidate(voucher, workspaceId, companyName, companySlug) {
      setLoading(true);
      try {
        const res = await authFetch("/api/company/validate-voucher", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ voucherCode: voucher, workspaceId }),
        });
        const result = await parseFetchJson(res);
        if (result.success) {
          const resolvedName = result.data?.companyName || companyName || "";
          const resolvedSlug = result.data?.companySlug || companySlug || "";
          if (resolvedName) {
            setWorkspaceCtx({
              companyName: resolvedName,
              companySlug: resolvedSlug,
              locked: true,
            });
            setFormData((prev) => ({ ...prev, companyName: resolvedName }));
          }
          setStep(1);
        }
      } catch (err) {
        console.error("Auto-validation error", err);
      } finally {
        setLoading(false);
      }
    }

    try {
      const storedVoucher = sessionStorage.getItem("dbc_employee_voucher");
      const storedWorkspaceId = sessionStorage.getItem("dbc_employee_workspaceId");
      const storedCompanyName = sessionStorage.getItem("dbc_employee_companyName") || "";
      const storedCompanySlug = sessionStorage.getItem("dbc_employee_companySlug") || "";
      if (storedVoucher) {
        setFormData((prev) =>
          prev.voucherCode ? prev : { ...prev, voucherCode: storedVoucher },
        );
        if (storedCompanyName) {
          setWorkspaceCtx({
            companyName: storedCompanyName,
            companySlug: storedCompanySlug,
            locked: true,
          });
          setFormData((prev) => ({ ...prev, companyName: storedCompanyName }));
        }
        sessionStorage.removeItem("dbc_employee_voucher");
        sessionStorage.removeItem("dbc_employee_workspaceId");
        sessionStorage.removeItem("dbc_employee_companyName");
        sessionStorage.removeItem("dbc_employee_companySlug");
        autoValidate(storedVoucher, storedWorkspaceId, storedCompanyName, storedCompanySlug);
      }
    } catch (_) {}
  }, [isEmployee]);

  const stepsList = isEmployee
    ? [
        { id: 0, label: "Organization", title: "Corporate Link" },
        { id: 1, label: "Design Card", title: "Visual Identity" },
        { id: 2, label: "Details & Channels", title: "Role & Contact" },
        { id: 3, label: "Review & Publish", title: "Final Activation" },
      ]
    : [
        { id: 1, label: "Design Card", title: "Visual Identity" },
        { id: 2, label: "Details & Channels", title: "Role & Contact" },
        { id: 3, label: "Review & Publish", title: "Final Activation" },
      ];

  const scrollWorkspaceToTop = () => {
    workspaceRef.current?.scrollTo({ top: 0, behavior: "smooth" });
    window.scrollTo({ top: 0, behavior: "smooth" });
  };

  const handleNext = () => {
    setStep((s) => Math.min(s + 1, 3));
    scrollWorkspaceToTop();
  };
  const handleBack = () => {
    setStep((s) => Math.max(s - 1, isEmployee ? 0 : 1));
    scrollWorkspaceToTop();
  };

  const handleStep1Next = () => {
    const name = (formData.fullName || `${formData.firstName || ""} ${formData.lastName || ""}`).trim();
    const missing = [];
    if (!name) missing.push("Name");
    if (!formData.jobTitle || !formData.jobTitle.trim()) missing.push("Job Title");
    if (!formData.companyName || !formData.companyName.trim()) missing.push("Company Name");

    if (missing.length > 0) {
      setPopupMessage(`Please enter your ${missing.join(", ")} to proceed.`);
      setShowPopup(true);
      return;
    }
    setStep(2);
    scrollWorkspaceToTop();
  };

  const handleStep2Next = () => {
    const missing = [];
    if (!formData.cardSlug || !formData.cardSlug.trim()) missing.push("Username / Card URL");

    if (missing.length > 0) {
      setPopupMessage(`Please fill in your ${missing.join(", ")} to continue.`);
      setShowPopup(true);
      return;
    }
    setStep(3);
    scrollWorkspaceToTop();
  };

  const updateForm = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => {
      const next = { ...prev, [name]: value };
      if (name === "fullName") {
        if (workspaceCtx.locked) {
          next.cardSlug = generateEmployeeSlug(workspaceCtx.companySlug, value);
        } else if (!prev.cardSlug || prev.cardSlug === slugFromName(prev.fullName)) {
          next.cardSlug = slugFromName(value);
        }
      }
      return next;
    });
  };

  const handleImageUpload = async (e, type) => {
    const file = e.target.files[0];
    if (e.target) e.target.value = "";
    if (!file) return;
    if (!file.type?.startsWith("image/")) {
      setUploadState((prev) => ({
        ...prev,
        [type]: { uploading: false, error: "Please choose an image file (PNG, JPG, WebP)." },
      }));
      return;
    }

    const field = type === "avatar" ? "avatarUrl" : type === "logo" ? "companyLogo" : "bannerUrl";
    setUploadState((prev) => ({
      ...prev,
      [type]: { uploading: true, error: null },
    }));
    setLoading(true);

    const previewUrl = URL.createObjectURL(file);
    setFormData((prev) => ({ ...prev, [field]: previewUrl }));

    try {
      const fd = new FormData();
      fd.append("type", type);
      fd.append("file", file, file.name || `${type}.${file.type.split("/")[1] || "bin"}`);

      const res = await authFetch("/api/user/upload", {
        method: "POST",
        body: fd,
      });
      const data = await parseFetchJson(res);
      if (data.success && data.data?.url) {
        setFormData((prev) => ({ ...prev, [field]: data.data.url }));
        setUploadState((prev) => ({
          ...prev,
          [type]: { uploading: false, error: null },
        }));
      } else {
        const message = toUserMessage(
          data.error,
          `Failed to upload ${type}. Please try a smaller image.`,
        );
        setFormData((prev) => ({ ...prev, [field]: "" }));
        setUploadState((prev) => ({
          ...prev,
          [type]: { uploading: false, error: message },
        }));
      }
    } catch (err) {
      console.error(err);
      setFormData((prev) => ({ ...prev, [field]: "" }));
      setUploadState((prev) => ({
        ...prev,
        [type]: {
          uploading: false,
          error: err?.message || `Network error while uploading ${type}. Please try again.`,
        },
      }));
    } finally {
      URL.revokeObjectURL(previewUrl);
      setLoading(false);
    }
  };

  const handleVoucherValidation = async () => {
    setLoading(true);
    try {
      const res = await authFetch("/api/company/validate-voucher", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ voucherCode: formData.voucherCode }),
      });
      const result = await parseFetchJson(res);
      if (result.success) {
        setStep(1);
      } else {
        alert(voucherErrorHint(toUserMessage(result.error, "Invalid voucher code.")));
      }
    } catch (err) {
      alert(voucherErrorHint(err.message) || "Failed to validate voucher.");
    } finally {
      setLoading(false);
    }
  };

  const handleSkipEmployeeVoucher = async () => {
    setLoading(true);
    try {
      const res = await authFetch("/api/company/validate-voucher", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ skip: true }),
      });
      const result = await parseFetchJson(res);
      if (result.success) setStep(1);
      else alert(voucherErrorHint(toUserMessage(result.error, "Could not continue.")));
    } catch (err) {
      alert(voucherErrorHint(err.message));
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async () => {
    if (uploadState.avatar.uploading || uploadState.banner.uploading || uploadState.logo.uploading) {
      alert("An image is still uploading. Please wait until it finishes.");
      return;
    }
    if (
      (formData.avatarUrl && formData.avatarUrl.startsWith("data:")) ||
      (formData.bannerUrl && formData.bannerUrl.startsWith("data:")) ||
      (formData.companyLogo && formData.companyLogo.startsWith("data:"))
    ) {
      alert("Images are still uploading. Please wait.");
      return;
    }

    setLoading(true);
    try {
      const payload = buildOnboardingPayload(formData, isEmployee);
      const res = await authFetch("/api/user/me", {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      });
      const result = await parseFetchJson(res);
      if (result.success) {
        onComplete();
      } else {
        alert(toUserMessage(result.error, "Could not save digital card."));
      }
    } catch (err) {
      alert(err.message || "Failed to finalize digital card. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  const fade = {
    initial: { opacity: 0, y: 14 },
    animate: { opacity: 1, y: 0 },
    exit: { opacity: 0, y: -14 },
    transition: { duration: 0.35, ease: [0.16, 1, 0.3, 1] },
  };

  return (
    <div className="w-full flex-1 flex flex-col min-h-0">
      {/* ══════════════════════════════════════════════════════
          MOBILE PREVIEW TOGGLE (Sticky on Mobile/Tablet)
         ══════════════════════════════════════════════════════ */}
      <div className="lg:hidden flex items-center justify-center mb-6">
        <div className="inline-flex p-1 bg-white rounded-full border border-[#EAE2DB] shadow-sm">
          <button
            type="button"
            onClick={() => setMobileTab("edit")}
            className={`px-5 py-2 rounded-full text-xs font-bold transition-all flex items-center gap-2 ${
              mobileTab === "edit"
                ? "bg-[#D4622C] text-white shadow-xs"
                : "text-[#77716C] hover:text-[#191919]"
            }`}
          >
            <span>✏️</span> Edit Details
          </button>
          <button
            type="button"
            onClick={() => setMobileTab("preview")}
            className={`px-5 py-2 rounded-full text-xs font-bold transition-all flex items-center gap-2 ${
              mobileTab === "preview"
                ? "bg-[#D4622C] text-white shadow-xs"
                : "text-[#77716C] hover:text-[#191919]"
            }`}
          >
            <span>👁️</span> Live Card Preview
          </button>
        </div>
      </div>

      {/* ══════════════════════════════════════════════════════
          SPLIT SCREEN LAYOUT: LEFT FIXED PREVIEW · RIGHT SCROLLABLE WORKSPACE
         ══════════════════════════════════════════════════════ */}
      <div className="w-full flex-1 flex flex-col lg:flex-row lg:overflow-hidden gap-6 xl:gap-10 max-w-[1450px] mx-auto px-4 sm:px-6 lg:px-8 pb-3 pt-0 min-h-0">
        {/* ── LEFT PANEL: LIVE DIGITAL CARD PREVIEW (FIXED ON DESKTOP) ── */}
        <div
          className={`lg:w-[42%] xl:w-[40%] h-full shrink-0 lg:flex flex-col items-center justify-center relative select-none py-1 sm:py-2 overflow-visible ${
            mobileTab === "preview" ? "flex" : "hidden lg:flex"
          }`}
        >
          <LiveCardPreview formData={formData} />
        </div>

        {/* ── RIGHT PANEL: IDENTITY CREATION WORKSPACE (FULL HEIGHT TILL BOTTOM) ── */}
        <div
          className={`lg:w-[58%] xl:w-[58%] h-full pb-1 flex flex-col min-h-0 ${
            mobileTab === "edit" ? "block" : "hidden lg:flex"
          }`}
        >
          <div className="bg-white rounded-[28px] sm:rounded-[32px] border border-[#EAE2DB] p-5 sm:p-6 lg:p-7 shadow-[0_16px_40px_rgba(28,25,23,0.03)] relative h-full flex flex-col min-h-0 overflow-hidden">
            {/* Step Progress Header */}
            <div className="mb-3 pb-2 shrink-0">
              <div className="flex items-center justify-between mb-2">
                <span className="text-[11px] font-black uppercase tracking-[0.14em] text-[#191919]">
                  STEP {step === 0 ? "00" : `0${step}`} OF 03
                </span>
              </div>

              {/* Single smooth progress bar track with solid orange fill */}
              <div className="w-full h-1.5 bg-[#F8F4EF] border border-[#EAE2DB] rounded-full overflow-hidden flex p-0.5">
                <div
                  className="h-full rounded-full bg-[#D4622C] transition-all duration-500"
                  style={{ width: `${(Math.max(step, 1) / 3) * 100}%` }}
                />
              </div>
            </div>

            {/* Scrollable Form Content Area */}
            <div ref={workspaceRef} className="flex-1 overflow-y-auto pr-1 sm:pr-2 min-h-0 custom-scrollbar flex flex-col pt-2 sm:pt-2.5">
              <AnimatePresence mode="wait">
              {/* STEP 0: EMPLOYEE VOUCHER */}
              {step === 0 && (
                <motion.div key="step0" {...fade} className="min-h-full flex-1 flex flex-col justify-between space-y-6">
                  <div>
                    <h2
                      className="text-2xl sm:text-3xl font-black text-[#191919] tracking-tight mb-2"
                      style={{ fontFamily: "var(--font-display, inherit)" }}
                    >
                      Connect Corporate Workspace
                    </h2>
                    <p className="text-sm text-[#77716C] leading-relaxed">
                      Enter your organization&apos;s master voucher code to link your digital identity to your company fleet.
                    </p>
                  </div>

                  <div className="pt-2">
                    <GlassInput
                      id="voucherCode"
                      label="Corporate Voucher Code"
                      icon={Ticket}
                      placeholder="e.g. ALPHA-99X-CORE"
                      value={formData.voucherCode}
                      onChange={updateForm}
                    />
                  </div>

                  <div className="space-y-3 pt-4">
                    <button
                      type="button"
                      onClick={handleVoucherValidation}
                      disabled={loading || !formData.voucherCode}
                      className="w-full py-4 rounded-full bg-[#D4622C] text-white font-black text-sm uppercase tracking-widest hover:bg-[#B85323] transition-all disabled:opacity-50 flex items-center justify-center gap-2 shadow-[0_8px_20px_rgba(212,100,44,0.25)] cursor-pointer"
                    >
                      {loading ? "Verifying..." : "Verify & Continue"}{" "}
                      <ArrowRight size={16} />
                    </button>
                    {showEmployeeVoucherSkip && (
                      <button
                        type="button"
                        onClick={handleSkipEmployeeVoucher}
                        disabled={loading}
                        className="w-full py-3 rounded-full border border-[#EAE2DB] bg-[#F8F4EF] text-[#77716C] text-xs font-bold uppercase tracking-widest hover:bg-[#EAE2DB] transition-all disabled:opacity-50"
                      >
                        Continue without company code (sandbox)
                      </button>
                    )}
                  </div>
                </motion.div>
              )}

              {/* ══════════════════════════════════════════════════
                  STEP 1: CREATE YOUR FIRST CARD (BLINQ-STYLE STUDIO)
                 ══════════════════════════════════════════════════ */}
              {step === 1 && (
                <motion.div key="step1" {...fade} className="min-h-full flex-1 flex flex-col justify-between">
                  <div className="space-y-3 sm:space-y-3.5">
                    <div className="pt-1">
                      <h2
                        className="text-2xl sm:text-[26px] font-serif text-[#191919] tracking-tight leading-[1.25] pt-0.5"
                        style={{ fontFamily: "var(--font-display, inherit)" }}
                      >
                        Create your <span className="italic text-[#D4622C] font-serif">first card</span>
                      </h2>
                      <p className="text-xs text-[#77716C] leading-normal mt-0.5">
                        Ready to design your card. Start by adding your name and brand.
                      </p>
                    </div>

                  {/* 1. Name, Role & Company Fields */}
                  <div className="space-y-3">
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 sm:gap-4">
                      <GlassInput
                        label="First Name"
                        name="firstName"
                        value={formData.firstName || ""}
                        onChange={(e) => handleNameChange(e.target.value, formData.lastName)}
                        icon={User}
                        placeholder="John"
                        required
                      />
                      <GlassInput
                        label="Last Name"
                        name="lastName"
                        value={formData.lastName || ""}
                        onChange={(e) => handleNameChange(formData.firstName, e.target.value)}
                        icon={User}
                        placeholder="Doe"
                        required
                      />
                    </div>

                    {/* Job Title & Company Name Fields */}
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 sm:gap-4">
                      <GlassInput
                        label="Job Title"
                        name="jobTitle"
                        value={formData.jobTitle || ""}
                        onChange={updateForm}
                        icon={Briefcase}
                        placeholder="Head of Engineering"
                        required
                      />
                      <div className="flex flex-col gap-1">
                        <GlassInput
                          label="Company Name"
                          name="companyName"
                          value={formData.companyName || ""}
                          onChange={updateForm}
                          icon={Building}
                          placeholder="NODEXIS"
                          disabled={workspaceCtx.locked}
                          required
                        />
                        {workspaceCtx.locked && (
                          <span className="text-[10px] font-bold text-emerald-600 ml-1">
                            ✓ Linked to company workspace
                          </span>
                        )}
                      </div>
                    </div>

                    <div className="text-[10.5px] text-[#77716C] ml-0.5">
                      <span>Required to create your card</span>
                    </div>
                  </div>

                  {/* 2. Add Images */}
                  <div>
                    <div className="flex items-center justify-between mb-1.5">
                      <label className="text-[13px] font-bold text-[#191919]">
                        Add images
                      </label>
                      <span className="text-[10px] text-[#77716C]">
                        Click to upload or drag & drop
                      </span>
                    </div>

                    <div className="grid grid-cols-2 gap-3 sm:gap-4">
                      {/* Box 1: Profile Picture */}
                      <div className="relative h-20 sm:h-22 rounded-2xl border transition-all overflow-hidden flex flex-col items-center justify-center p-2 text-center group bg-[#F8F4EF]/30 hover:bg-[#F8F4EF]/70 border-dashed border-[#EAE2DB] hover:border-[#D4622C]/40">
                        {formData.avatarUrl ? (
                          <div className="relative w-full h-full flex flex-col items-center justify-center p-1">
                            <img
                              src={formData.avatarUrl}
                              alt="Profile"
                              className="w-9 h-9 rounded-full object-cover mb-1 border border-white shadow-xs"
                            />
                            <span className="text-[10.5px] font-bold text-[#191919] truncate w-full">
                              Profile Picture
                            </span>
                            <div className="absolute top-1.5 right-1.5 flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                              <button
                                type="button"
                                onClick={(e) => {
                                  e.stopPropagation();
                                  setFormData((p) => ({ ...p, avatarUrl: "" }));
                                }}
                                className="p-1 rounded bg-white shadow-xs text-red-500 hover:bg-red-50 cursor-pointer"
                                title="Remove Picture"
                              >
                                <Trash2 size={11} />
                              </button>
                            </div>
                            <span className="absolute bottom-1.5 right-1.5 w-4 h-4 rounded-full bg-emerald-500 text-white flex items-center justify-center text-[8.5px]">
                              ✓
                            </span>
                          </div>
                        ) : (
                          <label className="flex flex-col items-center justify-center w-full h-full cursor-pointer">
                            <div className="w-8 h-8 rounded-full bg-[#FCE9DF] text-[#D4622C] flex items-center justify-center mb-1 shadow-2xs">
                              <User size={15} />
                            </div>
                            <span className="text-[11px] font-bold text-[#191919] leading-tight">
                              Profile Picture
                            </span>
                            <span className="text-[9px] text-[#77716C] mt-0.5">PNG, JPG (≤5MB)</span>
                            <input
                              type="file"
                              accept="image/*"
                              className="hidden"
                              onChange={(e) => handleImageUpload(e, "avatar")}
                            />
                          </label>
                        )}
                        {uploadState.avatar.uploading && (
                          <div className="absolute inset-0 bg-white/90 flex flex-col items-center justify-center gap-1 z-20">
                            <div className="w-4 h-4 border-2 border-[#D4622C]/20 border-t-[#D4622C] rounded-full animate-spin" />
                            <span className="text-[8px] font-bold text-[#191919]">Uploading...</span>
                          </div>
                        )}
                      </div>

                      {/* Box 2: Cover Photo */}
                      <div className="relative h-20 sm:h-22 rounded-2xl border transition-all overflow-hidden flex flex-col items-center justify-center p-2 text-center group bg-[#F8F4EF]/30 hover:bg-[#F8F4EF]/70 border-dashed border-[#EAE2DB] hover:border-[#D4622C]/40">
                        {formData.bannerUrl ? (
                          <div className="relative w-full h-full flex flex-col items-center justify-center p-1">
                            <img
                              src={formData.bannerUrl}
                              alt="Banner"
                              className="w-full h-9 object-cover rounded-md mb-1 shadow-2xs"
                            />
                            <span className="text-[10.5px] font-bold text-[#191919] truncate w-full">
                              Cover Photo
                            </span>
                            <div className="absolute top-1.5 right-1.5 flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                              <button
                                type="button"
                                onClick={(e) => {
                                  e.stopPropagation();
                                  setShowBannerEditor(true);
                                }}
                                className="p-1 rounded bg-white shadow-xs text-[#191919] hover:text-[#D4622C] cursor-pointer"
                                title="Crop Banner"
                              >
                                <Crop size={11} />
                              </button>
                              <button
                                type="button"
                                onClick={(e) => {
                                  e.stopPropagation();
                                  setFormData((p) => ({ ...p, bannerUrl: "" }));
                                }}
                                className="p-1 rounded bg-white shadow-xs text-red-500 hover:bg-red-50 cursor-pointer"
                                title="Remove Banner"
                              >
                                <Trash2 size={11} />
                              </button>
                            </div>
                            <span className="absolute bottom-1.5 right-1.5 w-4 h-4 rounded-full bg-emerald-500 text-white flex items-center justify-center text-[8.5px]">
                              ✓
                            </span>
                          </div>
                        ) : (
                          <label className="flex flex-col items-center justify-center w-full h-full cursor-pointer">
                            <div className="w-8 h-8 rounded-full bg-[#FCE9DF] text-[#D4622C] flex items-center justify-center mb-1 shadow-2xs">
                              <ImageIcon size={15} />
                            </div>
                            <span className="text-[11px] font-bold text-[#191919] leading-tight">
                              Cover Photo
                            </span>
                            <span className="text-[9px] text-[#77716C] mt-0.5">JPG, PNG (≤10MB)</span>
                            <input
                              type="file"
                              accept="image/*"
                              className="hidden"
                              onChange={(e) => handleImageUpload(e, "banner")}
                            />
                          </label>
                        )}
                        {uploadState.banner.uploading && (
                          <div className="absolute inset-0 bg-white/90 flex flex-col items-center justify-center gap-1 z-20">
                            <div className="w-4 h-4 border-2 border-[#D4622C]/20 border-t-[#D4622C] rounded-full animate-spin" />
                            <span className="text-[8px] font-bold text-[#191919]">Uploading...</span>
                          </div>
                        )}
                      </div>
                    </div>
                  </div>

                  {/* 3. Layout Selection (4 Curated Layouts with proper padding) */}
                  <div>
                    <div className="mb-2">
                      <label className="text-[13px] font-bold text-[#191919] block">
                        Layout
                      </label>
                      <p className="text-[10.5px] text-[#77716C]">
                        Choose how your digital card is composed
                      </p>
                    </div>

                    <div className="grid grid-cols-4 gap-2.5 sm:gap-3.5">
                      {LAYOUT_OPTIONS.map((layout) => {
                        const isSelected = (formData.cardLayout || "editorial") === layout.id;
                        return (
                          <button
                            key={layout.id}
                            type="button"
                            onClick={() => setFormData((p) => ({ ...p, cardLayout: layout.id }))}
                            className={`p-1.5 sm:p-2 rounded-2xl text-left transition-all cursor-pointer group flex flex-col relative ${
                              isSelected
                                ? "border-2 border-[#D4622C] bg-white shadow-sm ring-1 ring-[#D4622C]/20"
                                : "border border-[#EAE2DB] bg-[#F8F4EF]/40 hover:bg-white hover:border-[#D4622C]/40"
                            }`}
                          >
                            {/* Selected Checkmark Badge on Top-Right Corner */}
                            {isSelected && (
                              <div className="absolute -top-1 -right-1 w-4 h-4 rounded-full bg-[#D4622C] text-white flex items-center justify-center text-[9px] font-bold shadow-xs z-10">
                                ✓
                              </div>
                            )}
                            <div className="w-full">
                              <LayoutMiniWireframe
                                layoutId={layout.id}
                                themeColor={formData.themeColor}
                                isSelected={isSelected}
                              />
                            </div>
                          </button>
                        );
                      })}
                    </div>
                  </div>
                </div>

                  {/* Bottom Row / Terms & Next - Anchored to bottom of card */}
                  <div className="pt-3.5 mt-auto border-t border-[#EAE2DB] flex flex-col sm:flex-row items-center justify-between gap-3 shrink-0">
                    <p className="text-[11px] text-[#77716C]">
                      By continuing you agree to our{" "}
                      <span className="underline cursor-default">Privacy Policy</span> and{" "}
                      <span className="underline cursor-default">Terms of Service</span>.
                    </p>
                    <button
                      type="button"
                      onClick={handleStep1Next}
                      className="w-full sm:w-auto py-3 px-8 rounded-full bg-[#D4622C] hover:bg-[#B94D1D] text-white font-bold text-xs tracking-wider uppercase transition-all shadow-[0_4px_14px_rgba(212,98,44,0.25)] cursor-pointer flex items-center justify-center gap-1.5 group active:scale-[0.98]"
                    >
                      CONTINUE TO ROLE <ArrowRight size={15} className="transition-transform group-hover:translate-x-0.5" />
                    </button>
                  </div>
                </motion.div>
              )}

              {/* ══════════════════════════════════════════════════
                  STEP 2: PROFESSIONAL & CONTACT DETAILS
                 ══════════════════════════════════════════════════ */}
              {step === 2 && (
                <motion.div key="step2" {...fade} className="min-h-full flex flex-col justify-between pb-2">
                  <div className="space-y-3 pb-3">
                    <div className="pt-1">
                      <h2
                        className="text-2xl sm:text-[26px] font-serif text-[#191919] tracking-tight leading-[1.25] pt-0.5 mb-1"
                        style={{ fontFamily: "var(--font-display, inherit)" }}
                      >
                        Bio & Contact Details
                      </h2>
                      <p className="text-xs text-[#77716C] leading-normal">
                        Add your digital card URL, bio, and direct communication channels.
                      </p>
                    </div>

                  {/* Custom URL Slug */}
                  <div className="pt-1">
                    <label className="text-[11px] font-bold uppercase tracking-[0.12em] text-[#77716C] ml-1 block mb-2">
                      Custom Digital Card URL <span className="text-[#D4622C]">*</span>
                    </label>
                    <div className="flex flex-col sm:flex-row items-stretch sm:items-center bg-[#F8F4EF] border border-[#EAE2DB] rounded-2xl p-1.5 focus-within:border-[#D4622C] focus-within:ring-2 focus-within:ring-[#D4622C]/15 transition-all">
                      <div className="px-3.5 py-2.5 bg-white rounded-xl border border-[#EAE2DB] text-[12px] font-mono text-[#77716C] font-semibold shrink-0">
                        mycardshare.in/card/
                      </div>
                      <input
                        type="text"
                        name="cardSlug"
                        value={formData.cardSlug}
                        onChange={updateForm}
                        placeholder="username"
                        required
                        className="flex-1 bg-transparent border-none outline-none px-3.5 py-2.5 text-sm font-bold text-[#191919] placeholder:text-[#77716C]/50"
                      />
                    </div>
                  </div>

                  {/* Professional Bio */}
                  <div className="flex flex-col gap-2 pt-1">
                    <div className="flex justify-between items-center ml-1">
                      <label className="text-[11px] font-bold uppercase tracking-[0.12em] text-[#77716C]">
                        Professional Bio / Summary
                      </label>
                      <span className="text-[10px] font-medium text-[#77716C]">
                        {(formData.bio || "").length} / 160
                      </span>
                    </div>
                    <div className="rounded-2xl border border-[#EAE2DB] bg-[#F8F4EF] overflow-hidden focus-within:ring-2 focus-within:ring-[#D4622C]/15 focus-within:border-[#D4622C] transition-all">
                      <textarea
                        name="bio"
                        maxLength={160}
                        value={formData.bio}
                        onChange={updateForm}
                        rows={3}
                        className="w-full bg-transparent border-none p-4 text-sm font-semibold text-[#191919] placeholder:text-[#77716C]/60 outline-none resize-none"
                        placeholder="Briefly describe what you do, who you help, and your core area of expertise..."
                      />
                    </div>
                  </div>

                  {/* Direct Contact Channels */}
                  <div className="pt-2">
                    <label className="text-[11px] font-bold uppercase tracking-[0.12em] text-[#77716C] block mb-3">
                      Direct Contact Channels
                    </label>

                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                      <GlassInput
                        label="Work Phone / Mobile"
                        name="workPhone"
                        value={formData.workPhone}
                        onChange={updateForm}
                        icon={Phone}
                        placeholder="+1 (646) 555-0224"
                        required={false}
                      />
                      <GlassInput
                        label="Work Email"
                        name="workEmail"
                        value={formData.workEmail}
                        onChange={updateForm}
                        icon={Mail}
                        placeholder="roy@nodexis.com"
                        required={false}
                      />
                      <GlassInput
                        label="Official Website"
                        name="website"
                        value={formData.website}
                        onChange={updateForm}
                        icon={Globe}
                        placeholder="https://nodexis.com"
                        required={false}
                      />
                      <GlassInput
                        label="LinkedIn Handle or URL"
                        name="linkedin"
                        value={formData.linkedin}
                        onChange={updateForm}
                        icon={Linkedin}
                        placeholder="linkedin.com/in/username"
                        required={false}
                      />
                      <GlassInput
                        label="WhatsApp Number"
                        name="whatsapp"
                        value={formData.whatsapp}
                        onChange={updateForm}
                        icon={MessageCircle}
                        placeholder="+16465550224"
                        required={false}
                      />
                      <GlassInput
                        label="Instagram Handle"
                        name="instagram"
                        value={formData.instagram}
                        onChange={updateForm}
                        icon={Instagram}
                        placeholder="@username"
                        required={false}
                      />
                    </div>
                  </div>
                </div>

                  <div className="sticky bottom-0 bg-white/95 backdrop-blur-xs pt-3 mt-4 border-t border-[#EAE2DB] flex gap-3 shrink-0 pb-1 z-10">
                    <button
                      type="button"
                      onClick={handleBack}
                      className="py-3 px-6 rounded-full bg-[#F8F4EF] border border-[#EAE2DB] text-[#57534E] font-bold text-xs tracking-wider uppercase hover:bg-[#EAE2DB] transition-all flex items-center justify-center gap-2 cursor-pointer shadow-2xs"
                    >
                      <ArrowLeft size={15} /> Back
                    </button>
                    <button
                      type="button"
                      onClick={handleStep2Next}
                      className="flex-1 py-3 rounded-full bg-[#D4622C] text-white font-bold text-xs tracking-wider uppercase hover:bg-[#B94D1D] transition-all flex items-center justify-center gap-2 shadow-[0_4px_14px_rgba(212,98,44,0.22)] cursor-pointer"
                    >
                      Continue to Review <ArrowRight size={15} />
                    </button>
                  </div>
                </motion.div>
              )}

              {/* ══════════════════════════════════════════════════
                  STEP 3: REVIEW & PUBLISH
                 ══════════════════════════════════════════════════ */}
              {step === 3 && (
                <motion.div key="step3" {...fade} className="min-h-full flex-1 flex flex-col justify-between">
                  <div>
                    <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-emerald-50 border border-emerald-200 text-emerald-700 text-[11px] font-bold uppercase tracking-wider mb-2">
                      <Sparkles size={13} />
                      Identity Configured
                    </div>
                    <h2
                      className="text-3xl sm:text-4xl font-serif text-[#191919] tracking-tight mb-2"
                      style={{ fontFamily: "var(--font-display, inherit)" }}
                    >
                      Your digital card is ready
                    </h2>
                    <p className="text-sm text-[#77716C] leading-relaxed">
                      Review your live preview on the left. Click Create My Digital Card to activate your digital card.
                    </p>
                  </div>

                  {/* Summary Card */}
                  <div className="p-6 rounded-2xl bg-[#F8F4EF] border border-[#EAE2DB] space-y-4">
                    <div className="flex items-center justify-between pb-3 border-b border-[#EAE2DB]">
                      <div className="flex items-center gap-3">
                        <div
                          className="w-12 h-12 rounded-full flex items-center justify-center font-bold text-white text-base shadow-sm overflow-hidden"
                          style={{ backgroundColor: formData.themeColor || "#D4622C" }}
                        >
                          {formData.avatarUrl ? (
                            <img
                              src={formData.avatarUrl}
                              alt="Avatar"
                              className="w-full h-full object-cover"
                            />
                          ) : (
                            formData.fullName?.slice(0, 2).toUpperCase() || "MC"
                          )}
                        </div>
                        <div>
                          <div className="text-base font-bold text-[#191919]">
                            {formData.fullName || `${formData.firstName} ${formData.lastName}`}
                          </div>
                          <div className="text-xs text-[#77716C]">
                            {formData.jobTitle || "Professional"} · {formData.companyName || "Organization"}
                          </div>
                        </div>
                      </div>
                      <span className="text-xs font-bold text-[#D4622C] bg-white px-3 py-1 rounded-full border border-[#EAE2DB]">
                        Ready to Publish
                      </span>
                    </div>

                    {/* Public URL highlight */}
                    <div className="flex items-center justify-between bg-white rounded-xl p-3.5 border border-[#EAE2DB]">
                      <div className="flex items-center gap-2.5 truncate">
                        <Globe size={15} className="text-[#D4622C] shrink-0" />
                        <span className="text-xs font-mono font-bold text-[#191919] truncate">
                          mycardshare.in/card/{formData.cardSlug || "your-slug"}
                        </span>
                      </div>
                      <span className="text-[10px] font-bold text-emerald-600 bg-emerald-50 px-2.5 py-0.5 rounded-full shrink-0">
                        Reserved
                      </span>
                    </div>

                    {/* Features checklist */}
                    <div className="grid grid-cols-2 gap-2.5 pt-1 text-xs text-[#77716C]">
                      <div className="flex items-center gap-2">
                        <Check size={14} className="text-emerald-500 shrink-0" />
                        <span>NFC Tap & QR Enabled</span>
                      </div>
                      <div className="flex items-center gap-2">
                        <Check size={14} className="text-emerald-500 shrink-0" />
                        <span>Apple & Google Wallet Ready</span>
                      </div>
                      <div className="flex items-center gap-2">
                        <Check size={14} className="text-emerald-500 shrink-0" />
                        <span>Instant Contact Sharing</span>
                      </div>
                      <div className="flex items-center gap-2">
                        <Check size={14} className="text-emerald-500 shrink-0" />
                        <span>Lead Capture Enabled</span>
                      </div>
                    </div>
                  </div>

                  {/* Navigation CTA Buttons */}
                  <div className="pt-6 mt-auto border-t border-[#EAE2DB] flex gap-4">
                    <button
                      type="button"
                      onClick={handleBack}
                      className="py-3.5 px-6 rounded-full bg-[#F8F4EF] border border-[#EAE2DB] text-[#57534E] font-bold text-sm tracking-wide hover:bg-[#EAE2DB] transition-all flex items-center justify-center gap-2 cursor-pointer"
                    >
                      <ArrowLeft size={16} /> Back
                    </button>
                    <button
                      type="button"
                      onClick={handleSubmit}
                      disabled={loading}
                      className="flex-1 py-3.5 rounded-full bg-[#D4622C] text-white font-bold text-sm tracking-wide hover:bg-[#B85323] shadow-[0_8px_20px_rgba(212,100,44,0.25)] transition-all flex items-center justify-center gap-2.5 cursor-pointer disabled:opacity-50"
                    >
                      <span>{loading ? "Activating Digital Card..." : "Create My Digital Card"}</span>
                      {!loading && <ArrowRight size={18} />}
                    </button>
                  </div>
                </motion.div>
              )}
            </AnimatePresence>
            </div>
          </div>
        </div>
      </div>

      {/* ══════════════════════════════════════════════════════
          AUXILIARY MODALS: CROPPER & MISSING FIELDS POPUP
         ══════════════════════════════════════════════════════ */}
      {showBannerEditor && (
        <EditBanner
          imageUrl={formData.bannerUrl}
          onClose={() => setShowBannerEditor(false)}
          onSave={(newUrl) => setFormData((prev) => ({ ...prev, bannerUrl: newUrl }))}
        />
      )}

      <FillForm
        isOpen={showPopup}
        onClose={() => setShowPopup(false)}
        message={popupMessage}
      />
    </div>
  );
}
