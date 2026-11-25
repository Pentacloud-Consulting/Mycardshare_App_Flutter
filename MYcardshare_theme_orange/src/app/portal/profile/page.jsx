"use client";

import { useEffect, useRef, useState } from "react";
import { motion } from "framer-motion";
import { useAuth } from "@/lib/auth-context";
import {
  User,
  Mail,
  Phone,
  Globe,
  Linkedin,
  Briefcase,
  Camera,
  Save,
  Loader2,
  MapPin,
  Zap,
  Image,
  X,
  Crop,
  Trash2,
  ChevronDown,
  FileText,
  BookOpen,
  Upload,
  Download,
  Layout,
  Share2,
  Lock,
  Check,
} from "lucide-react";
import { authFetch, parseFetchJson, toUserMessage } from "@/lib/api";
import { AnimatePresence } from "framer-motion";
import ProfileCardPreview from "@/components/profile/ProfileCardPreview";
import ProfileCardVariant2 from "@/components/profile/ProfileCardVariant2";
import EditBanner from "@/components/Edits/EditBanner";
import { UiloraBrandButton } from "@/components/UIComponents/Button/tsx/UiloraModernButtons";
import FieldRequest from "@/components/Popup/FieldRequest";
import { getCardShareUrl } from "@/lib/urls";

/* ═══════════════════════════════════════════════════════════
   PROFILE / IDENTITY — UILORA Form Cards
   ═══════════════════════════════════════════════════════════ */

const inputStyles = {
  background: "#FAF6F2",
  border: "1px solid #EAE2DB",
  color: "#191919",
};
const inputFocusClass =
  "focus:outline-none focus:ring-2 focus:ring-[#D4622C]/20 focus:border-[#D4622C]";

const EMPTY_FORM = {
  name: "",
  title: "",
  company: "",
  email: "",
  phone: "",
  website: "",
  linkedin: "",
  city: "",
  country: "",
  address: "",
  bio: "",
  avatarUrl: "",
  bannerUrl: "",
  whatsapp: "",
  instagram: "",
  twitter: "",
  facebook: "",
  github: "",
  youtube: "",
  calendly: "",
  networkingStatus: "Actively Networking",
  focusAreas: "",
  slug: "",
  cardStatus: "Draft",
  experience: "",
  resumeUrl: "",
  brochureUrl: "",
  cardLayout: "editorial",
};

function mapUserDataToForm(userData) {
  if (!userData) return EMPTY_FORM;
  return {
    name: userData.fullName || "",
    title: userData.jobTitle || "",
    company: userData.companyName || "",
    email: userData.workEmail || userData.email || "",
    phone: userData.workPhone || userData.phoneNumber || "",
    website: userData.website || "",
    linkedin: userData.linkedin || "",
    city: userData.city || "",
    country: userData.country || "",
    address: userData.address || "",
    bio: userData.bio || "",
    avatarUrl: userData.avatarUrl || "",
    bannerUrl: userData.bannerUrl || "",
    whatsapp: userData.whatsapp || "",
    instagram: userData.instagram || "",
    twitter: userData.twitter || "",
    facebook: userData.facebook || "",
    github: userData.github || "",
    youtube: userData.youtube || "",
    calendly: userData.calendly || "",
    networkingStatus: userData.networkingStatus || "Actively Networking",
    focusAreas: userData.focusAreas || "",
    cardStatus: userData.cardStatus || "Draft",
    experience: userData.experience || "",
    resumeUrl: userData.resumeUrl || "",
    brochureUrl: userData.brochureUrl || "",
    slug: userData.cardSlug || "",
    cardLayout: userData.cardLayout || "editorial",
  };
}

function isDataUrl(value) {
  return typeof value === "string" && value.startsWith("data:");
}

/**
 * Normalizes and auto-corrects user-entered social handles, URLs, and partials
 * into canonical full URLs (e.g. "@zuhaib" -> "https://instagram.com/zuhaib",
 * "https://zuhaib-port" -> "https://instagram.com/zuhaib-port", "facebook.com/user" -> "https://facebook.com/user")
 */
export function autoCorrectSocialInput(name, rawValue) {
  if (!rawValue) return "";
  let val = String(rawValue).trim();
  if (!val) return "";

  switch (name) {
    case "instagram": {
      const m = val.match(/(?:https?:\/\/)?(?:www\.)?instagram\.com\/([a-zA-Z0-9_.]+)/i);
      if (m && m[1]) return `https://instagram.com/${m[1]}`;
      // If user typed e.g. https://zuhaib-port without domain
      if (/^https?:\/\/[a-zA-Z0-9_.-]+$/i.test(val)) {
        const user = val.replace(/^https?:\/\//i, "").replace(/\/+$/, "");
        return `https://instagram.com/${user}`;
      }
      if (val.startsWith("http://") || val.startsWith("https://")) return val;
      const clean = val.replace(/^@/, "").replace(/^\/+/, "").trim();
      return clean ? `https://instagram.com/${clean}` : "";
    }

    case "twitter": {
      const m = val.match(/(?:https?:\/\/)?(?:www\.)?(?:twitter\.com|x\.com)\/([a-zA-Z0-9_]+)/i);
      if (m && m[1]) return `https://x.com/${m[1]}`;
      if (/^https?:\/\/[a-zA-Z0-9_.-]+$/i.test(val)) {
        const user = val.replace(/^https?:\/\//i, "").replace(/\/+$/, "");
        return `https://x.com/${user}`;
      }
      if (val.startsWith("http://") || val.startsWith("https://")) return val;
      const clean = val.replace(/^@/, "").replace(/^\/+/, "").trim();
      return clean ? `https://x.com/${clean}` : "";
    }

    case "facebook": {
      const m = val.match(/(?:https?:\/\/)?(?:www\.)?facebook\.com\/([a-zA-Z0-9_.]+)/i);
      if (m && m[1]) return `https://facebook.com/${m[1]}`;
      if (/^https?:\/\/[a-zA-Z0-9_.-]+$/i.test(val)) {
        const user = val.replace(/^https?:\/\//i, "").replace(/\/+$/, "");
        return `https://facebook.com/${user}`;
      }
      if (val.startsWith("http://") || val.startsWith("https://")) return val;
      const clean = val.replace(/^@/, "").replace(/^\/+/, "").trim();
      return clean ? `https://facebook.com/${clean}` : "";
    }

    case "github": {
      const m = val.match(/(?:https?:\/\/)?(?:www\.)?github\.com\/([a-zA-Z0-9_-]+)/i);
      if (m && m[1]) return `https://github.com/${m[1]}`;
      if (/^https?:\/\/[a-zA-Z0-9_.-]+$/i.test(val)) {
        const user = val.replace(/^https?:\/\//i, "").replace(/\/+$/, "");
        return `https://github.com/${user}`;
      }
      if (val.startsWith("http://") || val.startsWith("https://")) return val;
      const clean = val.replace(/^@/, "").replace(/^\/+/, "").trim();
      return clean ? `https://github.com/${clean}` : "";
    }

    case "youtube": {
      const m = val.match(/(?:https?:\/\/)?(?:www\.)?youtube\.com\/(?:@)?([a-zA-Z0-9_.-]+)/i);
      if (m && m[1]) return `https://youtube.com/@${m[1]}`;
      if (/^https?:\/\/[a-zA-Z0-9_.-]+$/i.test(val)) {
        const user = val.replace(/^https?:\/\//i, "").replace(/\/+$/, "");
        return `https://youtube.com/@${user}`;
      }
      if (val.startsWith("http://") || val.startsWith("https://")) return val;
      const clean = val.replace(/^@/, "").replace(/^\/+/, "").trim();
      return clean ? `https://youtube.com/@${clean}` : "";
    }

    case "linkedin": {
      const m = val.match(/(?:https?:\/\/)?(?:www\.)?linkedin\.com\/(in|company)\/([a-zA-Z0-9_-]+)/i);
      if (m && m[2]) return `https://linkedin.com/${m[1]}/${m[2]}`;
      if (/^https?:\/\/[a-zA-Z0-9_.-]+$/i.test(val)) {
        const user = val.replace(/^https?:\/\//i, "").replace(/\/+$/, "");
        return `https://linkedin.com/in/${user}`;
      }
      if (val.startsWith("http://") || val.startsWith("https://")) return val;
      const clean = val.replace(/^@/, "").replace(/^\/+/, "").trim();
      return clean ? `https://linkedin.com/in/${clean}` : "";
    }

    case "calendly": {
      const m = val.match(/(?:https?:\/\/)?(?:www\.)?calendly\.com\/([a-zA-Z0-9_-]+)/i);
      if (m && m[1]) return `https://calendly.com/${m[1]}`;
      if (/^https?:\/\/[a-zA-Z0-9_.-]+$/i.test(val)) {
        const user = val.replace(/^https?:\/\//i, "").replace(/\/+$/, "");
        return `https://calendly.com/${user}`;
      }
      if (val.startsWith("http://") || val.startsWith("https://")) return val;
      const clean = val.replace(/^\/+/, "").trim();
      return clean ? `https://calendly.com/${clean}` : "";
    }

    case "whatsapp": {
      const digits = val.replace(/[^0-9]/g, "");
      return digits;
    }

    default:
      return val;
  }
}

function Field({
  label,
  icon: Icon,
  type = "text",
  placeholder,
  value,
  onChange,
  onBlur,
  name,
  readOnly = false,
  disabled = false,
  badge,
  helperText,
}) {
  const isLocked = readOnly || disabled;

  return (
    <div>
      <div className="flex items-center justify-between mb-1.5">
        <label className="block text-xs font-bold uppercase tracking-wider text-[#77716C]">
          {label}
        </label>
        {isLocked ? (
          <span className="inline-flex items-center gap-1 text-[10px] font-bold text-[#8C847E] bg-[#EAE2DB]/70 px-2 py-0.5 rounded-full select-none border border-[#DDD5CD]">
            <Lock size={10} className="text-[#8C847E]" />
            Non-editable
          </span>
        ) : (
          badge || null
        )}
      </div>
      <div
        className={`flex items-center rounded-2xl border transition-all duration-200 overflow-hidden group h-[48px] shadow-2xs ${
          isLocked
            ? "border-[#E2D8CF] bg-[#F4EFEB]/85 cursor-not-allowed opacity-90"
            : "border-[#EAE2DB] bg-[#FAF6F2] focus-within:bg-white focus-within:border-[#D4622C] focus-within:ring-3 focus-within:ring-[#D4622C]/15"
        }`}
      >
        {Icon && (
          <div className="pl-4 pr-2 flex items-center justify-center shrink-0">
            <Icon
              size={18}
              className={`transition-colors ${
                isLocked
                  ? "text-[#A89F97]"
                  : "text-[#77716C] group-focus-within:text-[#D4622C]"
              }`}
            />
          </div>
        )}
        <input
          type={type}
          placeholder={placeholder}
          value={value || ""}
          onChange={isLocked ? undefined : onChange}
          onBlur={isLocked ? undefined : onBlur}
          name={name}
          readOnly={isLocked}
          disabled={isLocked}
          className={`w-full h-full bg-transparent border-none px-3.5 text-sm font-semibold transition-all focus:ring-0 outline-none ${
            isLocked
              ? "text-[#6B635D] cursor-not-allowed select-all"
              : "text-[#191919] placeholder:text-[#77716C]/60"
          }`}
        />
        {isLocked && (
          <div
            className="pr-3.5 flex items-center justify-center shrink-0 text-[#A89F97]"
            title="This account email is permanently linked and cannot be edited."
          >
            <Lock size={15} />
          </div>
        )}
      </div>
      {helperText && (
        <p className="text-[11px] text-[#8C847E] mt-1 pl-1">{helperText}</p>
      )}
    </div>
  );
}

const NETWORKING_OPTIONS = [
  {
    value: "Actively Networking",
    label: "Actively Networking",
    color: "#10b981",
    bg: "rgba(16, 185, 129, 0.12)",
    border: "rgba(16, 185, 129, 0.3)",
    desc: "Open to meeting new peers & opportunities",
    pulse: true,
  },
  {
    value: "Open to Collaborations",
    label: "Open to Collaborations",
    color: "#38bdf8",
    bg: "rgba(56, 189, 248, 0.12)",
    border: "rgba(56, 189, 248, 0.3)",
    desc: "Partnering on exciting projects & ventures",
  },
  {
    value: "Available for Hire",
    label: "Available for Hire",
    color: "#fbbf24",
    bg: "rgba(251, 191, 36, 0.12)",
    border: "rgba(251, 191, 36, 0.3)",
    desc: "Seeking full-time, contract, or advisory roles",
  },
  {
    value: "Looking for Co-founder",
    label: "Looking for Co-founder",
    color: "#c084fc",
    bg: "rgba(192, 132, 252, 0.12)",
    border: "rgba(192, 132, 252, 0.3)",
    desc: "Building a startup & finding leadership",
  },
  {
    value: "Open to Freelance",
    label: "Open to Freelance",
    color: "#2dd4bf",
    bg: "rgba(45, 212, 191, 0.12)",
    border: "rgba(45, 212, 191, 0.3)",
    desc: "Taking on freelance & consulting contracts",
  },
  {
    value: "Seeking Mentorship",
    label: "Seeking Mentorship",
    color: "#fb923c",
    bg: "rgba(251, 146, 60, 0.12)",
    border: "rgba(251, 146, 60, 0.3)",
    desc: "Looking for guidance from experienced leaders",
  },
  {
    value: "Offering Mentorship",
    label: "Offering Mentorship",
    color: "#818cf8",
    bg: "rgba(129, 140, 248, 0.12)",
    border: "rgba(129, 140, 248, 0.3)",
    desc: "Advising and mentoring rising talent",
  },
  {
    value: "Open to Speaking",
    label: "Open to Speaking",
    color: "#fb7185",
    bg: "rgba(251, 113, 133, 0.12)",
    border: "rgba(251, 113, 133, 0.3)",
    desc: "Panels, conferences, podcasts & talks",
  },
  {
    value: "Investor",
    label: "Investor / Angel",
    color: "#facc15",
    bg: "rgba(250, 204, 21, 0.12)",
    border: "rgba(250, 204, 21, 0.3)",
    desc: "Deploying capital & backing founders",
  },
  {
    value: "Building in Stealth",
    label: "Building in Stealth",
    color: "#94a3b8",
    bg: "rgba(148, 163, 184, 0.12)",
    border: "rgba(148, 163, 184, 0.3)",
    desc: "Deep focus on new venture development",
  },
  {
    value: "Not Networking",
    label: "Not Networking",
    color: "#71717a",
    bg: "rgba(113, 113, 122, 0.12)",
    border: "rgba(113, 113, 122, 0.3)",
    desc: "Profile visible, but inbox currently closed",
  },
];

function NetworkingStatusDropdown({ value, onChange }) {
  const [open, setOpen] = useState(false);
  const containerRef = useRef(null);

  const selected =
    NETWORKING_OPTIONS.find((opt) => opt.value === value) ||
    NETWORKING_OPTIONS[0];

  useEffect(() => {
    function handleClickOutside(e) {
      if (containerRef.current && !containerRef.current.contains(e.target)) {
        setOpen(false);
      }
    }
    if (open) {
      document.addEventListener("mousedown", handleClickOutside);
      return () => document.removeEventListener("mousedown", handleClickOutside);
    }
  }, [open]);

  return (
    <div className="relative" ref={containerRef}>
      <label className="block text-xs font-bold uppercase tracking-wider text-[#77716C] mb-1.5">
        Networking Status
      </label>

      {/* Dropdown Trigger Button */}
      <button
        type="button"
        onClick={() => setOpen(!open)}
        className="w-full h-[48px] px-3.5 sm:px-4 rounded-2xl text-left bg-[#FAF6F2] hover:bg-white border border-[#EAE2DB] focus:bg-white focus:border-[#D4622C] focus:ring-3 focus:ring-[#D4622C]/15 transition-all duration-200 flex items-center justify-between shadow-2xs group cursor-pointer"
      >
        <div className="flex items-center gap-2.5 min-w-0">
          <div
            className="w-2.5 h-2.5 rounded-full shrink-0 relative"
            style={{ backgroundColor: selected.color }}
          >
            {selected.pulse && (
              <span
                className="absolute inset-0 rounded-full animate-ping opacity-75"
                style={{ backgroundColor: selected.color }}
              />
            )}
          </div>
          <span className="text-sm font-bold text-[#191919] truncate">
            {selected.label}
          </span>
          <span
            className="hidden sm:inline-block text-[10px] font-bold px-2 py-0.5 rounded-full border truncate"
            style={{
              backgroundColor: selected.bg,
              color: selected.color,
              borderColor: selected.border,
            }}
          >
            Active
          </span>
        </div>

        <ChevronDown
          size={16}
          className={`text-[#77716C] group-hover:text-[#D4622C] transition-transform duration-200 shrink-0 ml-2 ${
            open ? "rotate-180 text-[#D4622C]" : ""
          }`}
        />
      </button>

      {/* Animated Dropdown Menu */}
      <AnimatePresence>
        {open && (
          <motion.div
            initial={{ opacity: 0, y: 6, scale: 0.98 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: 4, scale: 0.98 }}
            transition={{ duration: 0.15, ease: "easeOut" }}
            className="absolute left-0 right-0 top-full mt-2 z-50 rounded-2xl bg-white border border-[#EAE2DB] shadow-[0_16px_40px_-8px_rgba(26,22,20,0.18)] p-2 max-h-[320px] overflow-y-auto space-y-1"
          >
            <div className="px-2.5 py-1 text-[10px] font-black uppercase tracking-wider text-[#A89F97] border-b border-[#EAE2DB]/60 mb-1">
              Select Availability & Goal
            </div>
            {NETWORKING_OPTIONS.map((opt) => {
              const isSelected = opt.value === selected.value;
              return (
                <button
                  key={opt.value}
                  type="button"
                  onClick={() => {
                    onChange(opt.value);
                    setOpen(false);
                  }}
                  className={`w-full text-left px-3 py-2 rounded-xl transition-all duration-150 flex items-center justify-between cursor-pointer group ${
                    isSelected
                      ? "bg-[#FAF2ED] border border-[#D4622C]/30 shadow-2xs"
                      : "hover:bg-[#FAF6F2] border border-transparent"
                  }`}
                >
                  <div className="flex items-center gap-3 min-w-0">
                    <div
                      className="w-2.5 h-2.5 rounded-full shrink-0 relative"
                      style={{ backgroundColor: opt.color }}
                    >
                      {opt.pulse && (
                        <span
                          className="absolute inset-0 rounded-full animate-ping opacity-60"
                          style={{ backgroundColor: opt.color }}
                        />
                      )}
                    </div>
                    <div className="min-w-0">
                      <p
                        className={`text-xs font-bold truncate transition-colors ${
                          isSelected
                            ? "text-[#D4622C]"
                            : "text-[#191919] group-hover:text-[#D4622C]"
                        }`}
                      >
                        {opt.label}
                      </p>
                      <p className="text-[10px] text-[#77716C] truncate">
                        {opt.desc}
                      </p>
                    </div>
                  </div>

                  {isSelected && (
                    <div className="w-5 h-5 rounded-full bg-[#FCE9DF] flex items-center justify-center shrink-0 ml-2">
                      <Check size={12} className="text-[#D4622C] stroke-[2.5]" />
                    </div>
                  )}
                </button>
              );
            })}
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}

export default function ProfilePage() {
  const { userData, refreshUserData } = useAuth();
  const [saving, setSaving] = useState(false);
  const [uploadingAvatar, setUploadingAvatar] = useState(false);
  const [uploadingBanner, setUploadingBanner] = useState(false);
  const [form, setForm] = useState(EMPTY_FORM);
  const [toast, setToast] = useState(null);
  const [showBannerEditor, setShowBannerEditor] = useState(false);
  const [isOverlayOpen, setIsOverlayOpen] = useState(false);
  const [isCardPreviewOpen, setIsCardPreviewOpen] = useState(false);
  const [showFieldError, setShowFieldError] = useState(false);
  const [uploadingResume, setUploadingResume] = useState(false);
  const [uploadingBrochure, setUploadingBrochure] = useState(false);
  const [activeVariant, setActiveVariant] = useState(1);
  const [expandedSections, setExpandedSections] = useState({
    media: false,
    layout: false,
    personal: true,
    professional: false,
    documents: false,
  });
  const isDirtyRef = useRef(false);
  const hasHydratedRef = useRef(false);

  const toggleSection = (section) => {
    setExpandedSections((prev) => ({ ...prev, [section]: !prev[section] }));
  };

  const allExpanded = Object.values(expandedSections).every(Boolean);
  const toggleAllSections = () => {
    const nextState = !allExpanded;
    setExpandedSections({
      media: nextState,
      layout: nextState,
      personal: nextState,
      professional: nextState,
      documents: nextState,
    });
  };

  const showToast = (message, type = "info") => {
    setToast({ message: toUserMessage(message, "Something went wrong"), type });
    setTimeout(() => setToast(null), 4000);
  };

  // Hydrate the form from userData on first load. After the initial
  // hydration, we only pull server-managed fields (like image URLs) back
  // in from userData so user edits aren't wiped, but fresh uploads/saves
  // ARE reflected everywhere.
  useEffect(() => {
    if (!userData) return;

    if (!hasHydratedRef.current) {
      setForm(mapUserDataToForm(userData));
      hasHydratedRef.current = true;
      isDirtyRef.current = false;
      return;
    }

    setForm((prev) => {
      const next = { ...prev };
      const serverAvatar = userData.avatarUrl || "";
      const serverBanner = userData.bannerUrl || "";

      // Re-sync image URLs whenever the server has a newer, non-data URL.
      // This picks up successful uploads + refreshes after save.
      if (serverAvatar && !isDataUrl(serverAvatar)) {
        next.avatarUrl = serverAvatar;
      }
      if (serverBanner && !isDataUrl(serverBanner)) {
        next.bannerUrl = serverBanner;
      }

      // If the user hasn't touched anything locally, pull the rest too.
      if (!isDirtyRef.current) {
        return mapUserDataToForm(userData);
      }

      return next;
    });
  }, [userData]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    isDirtyRef.current = true;
    setForm((f) => ({ ...f, [name]: value }));
  };

  const handleSocialBlur = (e) => {
    const { name, value } = e.target;
    if (
      [
        "instagram",
        "twitter",
        "facebook",
        "github",
        "youtube",
        "linkedin",
        "calendly",
        "whatsapp",
      ].includes(name)
    ) {
      const corrected = autoCorrectSocialInput(name, value);
      if (corrected !== value) {
        setForm((prev) => ({ ...prev, [name]: corrected }));
        isDirtyRef.current = true;
      }
    }
  };

  const handleSave = async () => {
    if (uploadingAvatar || uploadingBanner) {
      showToast("Please wait for image upload to finish.", "info");
      return;
    }

    // Validation: Ensure Full Name is not empty
    if (!form.name || form.name.trim() === "") {
      setShowFieldError(true);
      return;
    }

    setSaving(true);
    try {
      // Never send a data: URL to the profile PATCH endpoint — the server
      // strips those as a safeguard, which would silently wipe the field.
      const safeAvatar = isDataUrl(form.avatarUrl) ? undefined : form.avatarUrl;
      const safeBanner = isDataUrl(form.bannerUrl) ? undefined : form.bannerUrl;

      const payload = {
        fullName: form.name,
        jobTitle: form.title,
        companyName: form.company,
        workEmail: form.email,
        workPhone: form.phone,
        website: form.website,
        linkedin: autoCorrectSocialInput("linkedin", form.linkedin),
        city: form.city,
        country: form.country,
        address: form.address,
        bio: form.bio,
        whatsapp: autoCorrectSocialInput("whatsapp", form.whatsapp),
        instagram: autoCorrectSocialInput("instagram", form.instagram),
        twitter: autoCorrectSocialInput("twitter", form.twitter),
        facebook: autoCorrectSocialInput("facebook", form.facebook),
        github: autoCorrectSocialInput("github", form.github),
        youtube: autoCorrectSocialInput("youtube", form.youtube),
        calendly: autoCorrectSocialInput("calendly", form.calendly),
        networkingStatus: form.networkingStatus,
        focusAreas: form.focusAreas,
        cardStatus: form.cardStatus,
        experience: form.experience,
        cardSlug: form.slug,
        cardLayout: form.cardLayout,
        resumeUrl: form.resumeUrl,
        brochureUrl: form.brochureUrl,
      };
      if (safeAvatar !== undefined) payload.avatarUrl = safeAvatar;
      if (safeBanner !== undefined) payload.bannerUrl = safeBanner;

      const res = await authFetch("/api/user/me", {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      });
      const data = await parseFetchJson(res);

      if (res.ok && data.success !== false) {
        isDirtyRef.current = false;
        await refreshUserData();
        showToast("Profile updated successfully!", "success");
      } else {
        showToast(
          toUserMessage(data.error, "Failed to update profile"),
          "error",
        );
      }
    } catch (err) {
      console.error("Profile save failed:", err);
      showToast(err?.message || "Failed to update profile.", "error");
    } finally {
      setSaving(false);
    }
  };

  const handleStatusToggle = async () => {
    const previousStatus = form.cardStatus;
    const newStatus = previousStatus === "Published" ? "Draft" : "Published";
    setForm((f) => ({ ...f, cardStatus: newStatus }));
    try {
      const res = await authFetch("/api/user/me", {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ cardStatus: newStatus }),
      });
      if (res.ok) {
        await refreshUserData();
        showToast(
          newStatus === "Published" ? "Card is now live" : "Card set to draft",
          "success",
        );
      } else {
        setForm((f) => ({ ...f, cardStatus: previousStatus }));
        showToast("Failed to update status", "error");
      }
    } catch (err) {
      console.error(err);
      setForm((f) => ({ ...f, cardStatus: previousStatus }));
      showToast("Failed to update status", "error");
    }
  };

  const handleImageFieldUpload = async (e, kind) => {
    const file = e.target.files?.[0];
    // Reset the input so the same file can be re-picked after an error.
    if (e.target) e.target.value = "";
    if (!file) return;

    if (!file.type?.startsWith("image/")) {
      showToast("Please choose an image file.", "error");
      return;
    }

    const field = kind === "avatar" ? "avatarUrl" : "bannerUrl";
    const setUploading =
      kind === "avatar" ? setUploadingAvatar : setUploadingBanner;
    const successMessage =
      kind === "avatar" ? "Profile photo updated" : "Cover banner updated";

    const previousUrl = form[field];

    setUploading(true);
    // Immediate local preview — cheap object URL, no base64/compression work.
    const previewUrl = URL.createObjectURL(file);
    setForm((f) => ({ ...f, [field]: previewUrl }));
    try {
      // Stream the raw file via multipart/form-data. No base64 inflation and
      // no client-side resize — what the user picks is what gets uploaded.
      const fd = new FormData();
      fd.append("type", kind);
      fd.append("file", file, file.name || `${kind}.${file.type.split("/")[1] || "bin"}`);

      const res = await authFetch("/api/user/upload", {
        method: "POST",
        body: fd,
      });
      const data = await parseFetchJson(res);

      if (res.ok && data.success && data.data?.url) {
        setForm((f) => ({ ...f, [field]: data.data.url }));
        await refreshUserData();
        showToast(successMessage, "success");
      } else {
        setForm((f) => ({ ...f, [field]: previousUrl }));
        showToast(
          toUserMessage(data.error, `Failed to upload ${kind}.`),
          "error",
        );
      }
    } catch (err) {
      console.error(`${kind} upload failed:`, err);
      setForm((f) => ({ ...f, [field]: previousUrl }));
      showToast(err?.message || `Failed to upload ${kind}.`, "error");
    } finally {
      URL.revokeObjectURL(previewUrl);
      setUploading(false);
    }
  };

  const handleAvatarUpload = (e) => handleImageFieldUpload(e, "avatar");
  const handleBannerUpload = (e) => handleImageFieldUpload(e, "banner");

  const handleDocumentUpload = async (e, docType) => {
    const file = e.target.files?.[0];
    if (e.target) e.target.value = "";
    if (!file) return;

    const allowedTypes = [
      "application/pdf",
      "application/msword",
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    ];
    const isDoc = allowedTypes.includes(file.type) || /\.(pdf|docx?)$/i.test(file.name || "");
    if (!isDoc) {
      showToast("Please upload a PDF, DOC, or DOCX file.", "error");
      return;
    }
    if (file.size > 50 * 1024 * 1024) {
      showToast("File size exceeds 50MB limit.", "error");
      return;
    }

    const field = docType === "resume" ? "resumeUrl" : "brochureUrl";
    const setUploading = docType === "resume" ? setUploadingResume : setUploadingBrochure;
    const label = docType === "resume" ? "Resume" : "Brochure";

    setUploading(true);
    try {
      const fd = new FormData();
      fd.append("type", docType);
      fd.append("file", file, file.name || `${docType}.pdf`);

      const res = await authFetch("/api/user/upload", {
        method: "POST",
        body: fd,
      });
      const data = await parseFetchJson(res);

      if (res.ok && data.success && data.data?.url) {
        setForm((f) => ({ ...f, [field]: data.data.url }));
        isDirtyRef.current = true;
        await refreshUserData();
        showToast(`${label} uploaded successfully!`, "success");
      } else {
        showToast(
          toUserMessage(data.error, `Failed to upload ${label}.`),
          "error",
        );
      }
    } catch (err) {
      console.error(`${docType} upload failed:`, err);
      showToast(err?.message || `Failed to upload ${label}.`, "error");
    } finally {
      setUploading(false);
    }
  };

  const handleRemoveDocument = async (docType) => {
    const field = docType === "resume" ? "resumeUrl" : "brochureUrl";
    const label = docType === "resume" ? "Resume" : "Brochure";
    setForm((f) => ({ ...f, [field]: "" }));
    isDirtyRef.current = true;
    try {
      const res = await authFetch("/api/user/me", {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ [field]: "" }),
      });
      if (res.ok) {
        await refreshUserData();
        showToast(`${label} removed.`, "success");
      }
    } catch (err) {
      showToast(`Failed to remove ${label}.`, "error");
    }
  };



  return (
    <div className="space-y-8 w-full max-w-7xl mx-auto">
      <div className="flex items-center justify-between">
        <div>
          <h1
            className="text-2xl font-black tracking-tight text-[#191919]"
            style={{ fontFamily: "var(--font-display)" }}
          >
            Your Profile
          </h1>
          <p className="text-sm mt-1 text-[#77716C]">
            Manage your digital business card details
          </p>
        </div>
        <div className="flex items-center gap-3">
          <button
            type="button"
            onClick={toggleAllSections}
            className="text-xs font-bold text-[#D4622C] bg-[#FCE9DF] hover:bg-[#D4622C] hover:text-white px-3.5 py-2.5 rounded-2xl border border-[#D4622C]/30 transition-all cursor-pointer shadow-2xs"
          >
            {allExpanded ? "Collapse All" : "Expand All"}
          </button>
          <UiloraBrandButton
            onClick={handleSave}
            disabled={saving || uploadingAvatar || uploadingBanner}
            className={`px-4 sm:px-6 py-2.5 normal-case tracking-normal transition-all duration-300 ${isOverlayOpen ? "opacity-0 pointer-events-none translate-y-2" : "opacity-100"}`}
          >
            {saving ? (
              <Loader2 size={14} className="animate-spin" />
            ) : (
              <Save size={14} />
            )}
            {saving ? "Saving..." : (
              <>
                <span className="hidden sm:inline">Save Changes</span>
                <span className="sm:hidden">Save</span>
              </>
            )}
          </UiloraBrandButton>
        </div>
      </div>

      <div className="flex flex-col lg:flex-row gap-8 xl:gap-16 w-full">
        <div className="flex-1 space-y-6 min-w-0">
          {/* Card Status / Visibility */}
          <div className="rounded-3xl p-4 sm:p-6 flex items-center justify-between bg-white border border-[#EAE2DB] shadow-xs">
            <div>
              <div className="text-base font-black text-[#191919] flex items-center gap-3">
                Card Status
                {form.cardStatus === "Published" && (
                  <button
                    onClick={() => window.open(getCardShareUrl(form.slug), '_blank')}
                    className="text-[10px] bg-[#FCE9DF] text-[#D4622C] border border-[#D4622C]/25 px-2.5 py-1 rounded-full hover:bg-[#D4622C] hover:text-white transition-all uppercase tracking-wider font-bold flex items-center gap-1 cursor-pointer"
                  >
                    View Live ↗
                  </button>
                )}
              </div>
              <p className="text-xs mt-1 text-[#77716C]">
                {form.cardStatus === "Published"
                  ? "Your card is currently Live and public."
                  : "Your card is in Draft mode. Go Live to share it."}
              </p>
            </div>
            <button
              onClick={handleStatusToggle}
              className={`px-4 py-2 rounded-xl text-xs font-bold uppercase tracking-wider transition-all shadow-2xs flex items-center gap-1.5 cursor-pointer ${
                form.cardStatus === "Published"
                  ? "bg-emerald-50 text-emerald-700 border border-emerald-200 hover:bg-emerald-100"
                  : "bg-[#FCE9DF] text-[#D4622C] border border-[#D4622C]/30 hover:bg-[#D4622C] hover:text-white"
              }`}
            >
              <span className={`w-1.5 h-1.5 rounded-full ${form.cardStatus === "Published" ? "bg-emerald-500 animate-pulse" : "bg-[#D4622C]"}`} />
              {form.cardStatus === "Published" ? "Live" : "Draft"}
            </button>
          </div>

          {/* 1. Profile Photo & Cover Banner (Collapsible Dropdown) */}
          <div className="rounded-3xl bg-white border border-[#EAE2DB] overflow-hidden shadow-xs transition-all">
            <button
              type="button"
              onClick={() => toggleSection("media")}
              className="w-full px-5 sm:px-6 py-4 flex items-center justify-between text-left hover:bg-[#FAF6F2] transition-colors cursor-pointer group"
            >
              <div className="flex items-center gap-3.5">
                <div className="w-10 h-10 rounded-xl bg-[#FCE9DF] flex items-center justify-center text-[#D4622C] shrink-0">
                  <Camera size={18} />
                </div>
                <div>
                  <h3 className="text-base font-black text-[#191919] group-hover:text-[#D4622C] transition-colors">
                    Profile Photo & Cover Banner
                  </h3>
                  <p className="text-xs text-[#77716C] mt-0.5">
                    {form.avatarUrl ? "Photo & Banner uploaded" : "Upload avatar & banner imagery"}
                  </p>
                </div>
              </div>
              <div className="flex items-center gap-3">
                {form.avatarUrl && (
                  <div className="w-8 h-8 rounded-lg overflow-hidden border border-[#EAE2DB] shadow-2xs hidden sm:block">
                    <img src={form.avatarUrl} alt="Avatar thumbnail" className="w-full h-full object-cover" />
                  </div>
                )}
                <span className="text-[10px] font-bold uppercase tracking-wider text-[#77716C] px-2.5 py-1 rounded-full bg-[#FAF6F2] border border-[#EAE2DB]">
                  {expandedSections.media ? "Close" : "Edit"}
                </span>
                <div className="w-8 h-8 rounded-full bg-[#FAF6F2] border border-[#EAE2DB] flex items-center justify-center text-[#77716C] group-hover:text-[#D4622C] group-hover:border-[#D4622C]/30 transition-all">
                  <ChevronDown
                    size={16}
                    className={`transition-transform duration-300 ${expandedSections.media ? "rotate-180" : ""}`}
                  />
                </div>
              </div>
            </button>
            <AnimatePresence initial={false}>
              {expandedSections.media && (
                <motion.div
                  initial={{ height: 0, opacity: 0 }}
                  animate={{ height: "auto", opacity: 1 }}
                  exit={{ height: 0, opacity: 0 }}
                  transition={{ duration: 0.25, ease: "easeInOut" }}
                >
                  <div className="px-5 sm:px-6 pb-6 pt-4 border-t border-[#EAE2DB]/60 space-y-6">
                    {/* Avatar Upload */}
                    <div className="p-4 sm:p-5 rounded-2xl flex flex-col sm:flex-row items-center gap-4 sm:gap-6 bg-[#FAF6F2] border border-[#EAE2DB]">
                      <div className="relative shrink-0">
                        <div className="w-20 h-20 rounded-[20px] p-[3px] bg-gradient-to-b from-[#D4642C] via-[#E87A43] to-[#BD5523] shadow-md relative">
                          <div className="w-full h-full rounded-[17px] bg-white overflow-hidden flex items-center justify-center text-2xl font-black text-[#D4642C] border border-black/5 shadow-inner">
                            {form.avatarUrl ? (
                              <img
                                src={form.avatarUrl}
                                alt="Avatar"
                                className="w-full h-full object-cover"
                              />
                            ) : form.name ? (
                              form.name.charAt(0).toUpperCase()
                            ) : (
                              "U"
                            )}
                            {uploadingAvatar && (
                              <div className="absolute inset-0 bg-black/60 flex items-center justify-center rounded-[17px]">
                                <Loader2
                                  size={20}
                                  className="animate-spin text-white"
                                />
                              </div>
                            )}
                          </div>
                        </div>
                        <input
                          type="file"
                          accept="image/*"
                          id="avatar-upload"
                          className="hidden"
                          onChange={handleAvatarUpload}
                          disabled={uploadingAvatar}
                        />
                        <label
                          htmlFor="avatar-upload"
                          className={`absolute -bottom-1 -right-1 w-7 h-7 rounded-lg bg-[#D4622C] text-white hover:bg-[#BD5523] shadow-md flex items-center justify-center border-2 border-white z-10 transition-all duration-300 hover:scale-105 ${
                            uploadingAvatar || isOverlayOpen ? "cursor-wait opacity-0 pointer-events-none" : "cursor-pointer opacity-100"
                          }`}
                          title="Change Photo"
                        >
                          <Camera size={13} />
                        </label>
                      </div>
                      <div className="text-center sm:text-left">
                        <div className="text-sm font-black text-[#191919]">Profile Photo</div>
                        <p className="text-xs text-[#77716C] mt-0.5">
                          Upload a 400×400px image. JPG, PNG, or WebP.
                        </p>
                        {uploadingAvatar && (
                          <p className="text-[11px] mt-1 text-[#D4622C] font-semibold">
                            Uploading…
                          </p>
                        )}
                      </div>
                    </div>

                    {/* Banner Upload */}
                    <div className="p-4 sm:p-5 rounded-2xl bg-[#FAF6F2] border border-[#EAE2DB]">
                      <div className="flex items-center justify-between mb-3">
                        <div>
                          <div className="text-sm font-black text-[#191919]">Cover Banner</div>
                          <p className="text-xs text-[#77716C] mt-0.5">
                            Upload a 1200×400px landscape image. JPG, PNG, or WebP.
                          </p>
                        </div>
                        {uploadingBanner && (
                          <span className="text-[11px] text-[#D4622C] font-semibold flex items-center gap-1.5">
                            <Loader2 size={12} className="animate-spin" />
                            Uploading…
                          </span>
                        )}
                      </div>
                      <div className="relative group">
                        <div className="w-full h-32 sm:h-40 rounded-xl flex items-center justify-center overflow-hidden transition-all border-2 border-dashed border-[#EAE2DB] hover:border-[#D4622C]/40 bg-white">
                          {form.bannerUrl ? (
                            <img
                              src={form.bannerUrl}
                              alt="Banner"
                              className="w-full h-full object-cover"
                            />
                          ) : (
                            <div className="flex flex-col items-center gap-2 text-[#77716C] group-hover:text-[#D4622C] transition-colors">
                              <Image size={28} />
                              <span className="text-xs font-bold">
                                Click to upload banner
                              </span>
                            </div>
                          )}
                          <div className="absolute inset-0 bg-[#D4622C]/5 opacity-0 group-hover:opacity-100 transition-opacity rounded-xl pointer-events-none" />
                          {uploadingBanner && (
                            <div className="absolute inset-0 bg-black/60 flex items-center justify-center rounded-xl z-20">
                              <Loader2
                                size={28}
                                className="animate-spin text-white"
                              />
                            </div>
                          )}
                          
                          {form.bannerUrl && (
                            <div className="absolute bottom-3 right-3 z-30 flex gap-2">
                              <button
                                type="button"
                                onClick={(e) => {
                                  e.stopPropagation();
                                  setShowBannerEditor(true);
                                }}
                                title="Resize Banner"
                                className={`w-9 h-9 rounded-xl bg-white text-[#D4622C] hover:bg-[#D4622C] hover:text-white transition-all duration-300 border border-[#EAE2DB] shadow-md flex items-center justify-center cursor-pointer ${isOverlayOpen ? "opacity-0 pointer-events-none scale-90" : "opacity-100 scale-100"}`}
                              >
                                <Crop size={16} />
                              </button>
                            </div>
                          )}
                        </div>
                        <input
                          type="file"
                          accept="image/*"
                          className="absolute inset-0 opacity-0 cursor-pointer disabled:cursor-wait"
                          onChange={handleBannerUpload}
                          disabled={uploadingBanner}
                        />
                      </div>
                    </div>
                  </div>
                </motion.div>
              )}
            </AnimatePresence>
          </div>

          {/* 2. Card Layout (Collapsible Dropdown) */}
          <div className="rounded-3xl bg-white border border-[#EAE2DB] overflow-hidden shadow-xs transition-all">
            <button
              type="button"
              onClick={() => toggleSection("layout")}
              className="w-full px-5 sm:px-6 py-4 flex items-center justify-between text-left hover:bg-[#FAF6F2] transition-colors cursor-pointer group"
            >
              <div className="flex items-center gap-3.5">
                <div className="w-10 h-10 rounded-xl bg-[#FCE9DF] flex items-center justify-center text-[#D4622C] shrink-0">
                  <Layout size={18} />
                </div>
                <div>
                  <h3 className="text-base font-black text-[#191919] group-hover:text-[#D4622C] transition-colors">
                    Card Layout
                  </h3>
                  <p className="text-xs text-[#77716C] mt-0.5">
                    Composition: <span className="font-bold text-[#191919] capitalize">{form.cardLayout || "editorial"}</span>
                  </p>
                </div>
              </div>
              <div className="flex items-center gap-3">
                <span className="text-[10px] font-bold uppercase tracking-wider text-[#D4622C] px-2.5 py-1 rounded-full bg-[#FCE9DF] border border-[#D4622C]/20 capitalize">
                  {form.cardLayout || "editorial"}
                </span>
                <div className="w-8 h-8 rounded-full bg-[#FAF6F2] border border-[#EAE2DB] flex items-center justify-center text-[#77716C] group-hover:text-[#D4622C] group-hover:border-[#D4622C]/30 transition-all">
                  <ChevronDown
                    size={16}
                    className={`transition-transform duration-300 ${expandedSections.layout ? "rotate-180" : ""}`}
                  />
                </div>
              </div>
            </button>
            <AnimatePresence initial={false}>
              {expandedSections.layout && (
                <motion.div
                  initial={{ height: 0, opacity: 0 }}
                  animate={{ height: "auto", opacity: 1 }}
                  exit={{ height: 0, opacity: 0 }}
                  transition={{ duration: 0.25, ease: "easeInOut" }}
                >
                  <div className="px-5 sm:px-6 pb-6 pt-4 border-t border-[#EAE2DB]/60">
                    <p className="text-xs text-[#77716C] mb-4">
                      Choose the visual composition and avatar placement of your digital business card.
                    </p>
                    <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                      {[
                        { id: "editorial", label: "Editorial", desc: "Left avatar" },
                        { id: "minimal", label: "Centered", desc: "Centered portrait" },
                        { id: "banner-right", label: "Banner Right", desc: "Right avatar" },
                        { id: "wide", label: "Modern Wide", desc: "Wide card" },
                      ].map((opt) => {
                        const isSelected = (form.cardLayout || "editorial") === opt.id;
                        return (
                          <button
                            key={opt.id}
                            type="button"
                            onClick={() => {
                              isDirtyRef.current = true;
                              setForm((f) => ({ ...f, cardLayout: opt.id }));
                            }}
                            className={`p-3 rounded-xl border text-left transition-all cursor-pointer relative flex flex-col justify-between ${
                              isSelected
                                ? "border-[#D4622C] bg-[#FCE9DF]/30 ring-2 ring-[#D4622C]/20"
                                : "border-[#E5E7EB] hover:border-[#D4622C]/40 bg-white"
                            }`}
                          >
                            <div className="flex items-center justify-between mb-1">
                              <span className="text-xs font-bold text-slate-900">
                                {opt.label}
                              </span>
                              {isSelected && (
                                <span className="w-3.5 h-3.5 rounded-full bg-[#D4622C] text-white flex items-center justify-center text-[9px] font-bold">
                                  ✓
                                </span>
                              )}
                            </div>
                            <span className="text-[10px] text-slate-500">
                              {opt.desc}
                            </span>
                          </button>
                        );
                      })}
                    </div>
                  </div>
                </motion.div>
              )}
            </AnimatePresence>
          </div>

          {/* 3. Personal & Contact Details (Combined Left/Right Dropdown) */}
          <div className="rounded-3xl bg-white border border-[#EAE2DB] overflow-hidden shadow-xs transition-all">
            <button
              type="button"
              onClick={() => toggleSection("personal")}
              className="w-full px-5 sm:px-6 py-4 flex items-center justify-between text-left hover:bg-[#FAF6F2] transition-colors cursor-pointer group"
            >
              <div className="flex items-center gap-3.5">
                <div className="w-10 h-10 rounded-xl bg-[#FCE9DF] flex items-center justify-center text-[#D4622C] shrink-0">
                  <User size={18} />
                </div>
                <div>
                  <h3 className="text-base font-black text-[#191919] group-hover:text-[#D4622C] transition-colors">
                    Personal & Contact Details
                  </h3>
                  <p className="text-xs text-[#77716C] mt-0.5">
                    {form.name
                      ? `${form.name}${form.email ? ` • ${form.email}` : form.title ? ` • ${form.title}` : ""}`
                      : "Personal identity, job title & contact channels"}
                  </p>
                </div>
              </div>
              <div className="flex items-center gap-3">
                <span className="text-[10px] font-bold uppercase tracking-wider text-[#77716C] px-2.5 py-1 rounded-full bg-[#FAF6F2] border border-[#EAE2DB]">
                  {expandedSections.personal ? "Close" : "Edit"}
                </span>
                <div className="w-8 h-8 rounded-full bg-[#FAF6F2] border border-[#EAE2DB] flex items-center justify-center text-[#77716C] group-hover:text-[#D4622C] group-hover:border-[#D4622C]/30 transition-all">
                  <ChevronDown
                    size={16}
                    className={`transition-transform duration-300 ${expandedSections.personal ? "rotate-180" : ""}`}
                  />
                </div>
              </div>
            </button>
            <AnimatePresence initial={false}>
              {expandedSections.personal && (
                <motion.div
                  initial={{ height: 0, opacity: 0 }}
                  animate={{ height: "auto", opacity: 1 }}
                  exit={{ height: 0, opacity: 0 }}
                  transition={{ duration: 0.25, ease: "easeInOut" }}
                >
                  <div className="px-5 sm:px-6 pb-6 pt-5 border-t border-[#EAE2DB]/60">
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6 lg:gap-8">
                      {/* Left Column: Personal Details */}
                      <div className="space-y-4">
                        <div className="flex items-center gap-2 pb-2 border-b border-[#EAE2DB]/60">
                          <div className="w-6 h-6 rounded-lg bg-[#FCE9DF] flex items-center justify-center text-[#D4622C]">
                            <User size={13} />
                          </div>
                          <span className="text-xs font-black uppercase tracking-wider text-[#191919]">
                            Personal Details
                          </span>
                        </div>
                        <Field
                          label="Full Name"
                          icon={User}
                          placeholder="Your full name"
                          value={form.name}
                          onChange={handleChange}
                          name="name"
                        />
                        <Field
                          label="Job Title"
                          icon={Briefcase}
                          placeholder="CEO, Head of Design..."
                          value={form.title}
                          onChange={handleChange}
                          name="title"
                        />
                        <Field
                          label="Company"
                          icon={Briefcase}
                          placeholder="Company name"
                          value={form.company}
                          onChange={handleChange}
                          name="company"
                        />
                      </div>

                      {/* Right Column: Contact Information */}
                      <div className="space-y-4">
                        <div className="flex items-center gap-2 pb-2 border-b border-[#EAE2DB]/60">
                          <div className="w-6 h-6 rounded-lg bg-[#FCE9DF] flex items-center justify-center text-[#D4622C]">
                            <Mail size={13} />
                          </div>
                          <span className="text-xs font-black uppercase tracking-wider text-[#191919]">
                            Contact Information
                          </span>
                        </div>
                        <Field
                          label="Email"
                          icon={Mail}
                          type="email"
                          placeholder="name@company.com"
                          value={form.email}
                          name="email"
                          readOnly={true}
                          disabled={true}
                          helperText="Account email is linked to your login and cannot be edited."
                        />
                        <Field
                          label="Phone"
                          icon={Phone}
                          type="tel"
                          placeholder="+1 555-000-0000"
                          value={form.phone}
                          onChange={handleChange}
                          name="phone"
                        />
                        <Field
                          label="Website"
                          icon={Globe}
                          placeholder="yourwebsite.com"
                          value={form.website}
                          onChange={handleChange}
                          name="website"
                        />
                        <Field
                          label="LinkedIn"
                          icon={Linkedin}
                          placeholder="https://linkedin.com/in/username"
                          value={form.linkedin}
                          onChange={handleChange}
                          onBlur={handleSocialBlur}
                          name="linkedin"
                        />
                        <Field
                          label="Custom URL Slug"
                          icon={Zap}
                          placeholder="your-unique-slug"
                          value={form.slug}
                          onChange={handleChange}
                          name="slug"
                        />
                      </div>
                    </div>
                  </div>
                </motion.div>
              )}
            </AnimatePresence>
          </div>

          {/* 4. Professional, Social & Bio Details (Combined Left/Right Dropdown) */}
          <div className="rounded-3xl bg-white border border-[#EAE2DB] overflow-hidden shadow-xs transition-all">
            <button
              type="button"
              onClick={() => toggleSection("professional")}
              className="w-full px-5 sm:px-6 py-4 flex items-center justify-between text-left hover:bg-[#FAF6F2] transition-colors cursor-pointer group"
            >
              <div className="flex items-center gap-3.5">
                <div className="w-10 h-10 rounded-xl bg-[#FCE9DF] flex items-center justify-center text-[#D4622C] shrink-0">
                  <Globe size={18} />
                </div>
                <div>
                  <h3 className="text-base font-black text-[#191919] group-hover:text-[#D4622C] transition-colors">
                    Professional, Social & Bio Details
                  </h3>
                  <p className="text-xs text-[#77716C] mt-0.5">
                    {form.city || form.networkingStatus || form.bio || form.experience
                      ? [form.city, form.country, form.networkingStatus].filter(Boolean).join(" • ") || "Professional matrix, social channels & personal bio"
                      : "Location, networking status, social links, experience & bio"}
                  </p>
                </div>
              </div>
              <div className="flex items-center gap-3">
                <span className="text-[10px] font-bold uppercase tracking-wider text-[#77716C] px-2.5 py-1 rounded-full bg-[#FAF6F2] border border-[#EAE2DB]">
                  {expandedSections.professional ? "Close" : "Edit"}
                </span>
                <div className="w-8 h-8 rounded-full bg-[#FAF6F2] border border-[#EAE2DB] flex items-center justify-center text-[#77716C] group-hover:text-[#D4622C] group-hover:border-[#D4622C]/30 transition-all">
                  <ChevronDown
                    size={16}
                    className={`transition-transform duration-300 ${expandedSections.professional ? "rotate-180" : ""}`}
                  />
                </div>
              </div>
            </button>
            <AnimatePresence initial={false}>
              {expandedSections.professional && (
                <motion.div
                  initial={{ height: 0, opacity: 0 }}
                  animate={{ height: "auto", opacity: 1 }}
                  exit={{ height: 0, opacity: 0 }}
                  transition={{ duration: 0.25, ease: "easeInOut" }}
                >
                  <div className="px-5 sm:px-6 pb-6 pt-5 border-t border-[#EAE2DB]/60">
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6 lg:gap-8">
                      {/* Left Column: Location & Professional + Experience Showcase */}
                      <div className="space-y-6">
                        {/* 1. Location & Professional */}
                        <div className="space-y-4">
                          <div className="flex items-center gap-2 pb-2 border-b border-[#EAE2DB]/60">
                            <div className="w-6 h-6 rounded-lg bg-[#FCE9DF] flex items-center justify-center text-[#D4622C]">
                              <MapPin size={13} />
                            </div>
                            <span className="text-xs font-black uppercase tracking-wider text-[#191919]">
                              Location & Professional
                            </span>
                          </div>
                          <div className="grid grid-cols-2 gap-3 sm:gap-4">
                            <Field
                              label="City"
                              placeholder="City"
                              value={form.city}
                              onChange={handleChange}
                              name="city"
                            />
                            <Field
                              label="Country"
                              placeholder="Country"
                              value={form.country}
                              onChange={handleChange}
                              name="country"
                            />
                          </div>
                          <Field
                            label="Address"
                            icon={MapPin}
                            placeholder="Full office address"
                            value={form.address}
                            onChange={handleChange}
                            name="address"
                          />
                          <NetworkingStatusDropdown
                            value={form.networkingStatus}
                            onChange={(val) => {
                              isDirtyRef.current = true;
                              setForm((f) => ({ ...f, networkingStatus: val }));
                            }}
                          />
                          <Field
                            label="Focus Areas"
                            placeholder="Strategic Planning, UI/UX, Legal..."
                            value={form.focusAreas}
                            onChange={handleChange}
                            name="focusAreas"
                          />
                        </div>

                        {/* 2. Experience Showcase */}
                        <div className="space-y-4">
                          <div className="flex items-center gap-2 pb-2 border-b border-[#EAE2DB]/60">
                            <div className="w-6 h-6 rounded-lg bg-[#FCE9DF] flex items-center justify-center text-[#D4622C]">
                              <Briefcase size={13} />
                            </div>
                            <span className="text-xs font-black uppercase tracking-wider text-[#191919]">
                              Experience Showcase
                            </span>
                          </div>
                          <div className="rounded-2xl border border-[#EAE2DB] bg-[#FAF6F2] focus-within:bg-white focus-within:border-[#D4622C] focus-within:ring-3 focus-within:ring-[#D4622C]/15 transition-all p-3 shadow-2xs">
                            <textarea
                              name="experience"
                              placeholder="Highlight key experiences, achievements, or a professional matrix..."
                              value={form.experience || ""}
                              onChange={handleChange}
                              rows={4}
                              className="w-full bg-transparent border-none text-sm font-medium text-[#191919] placeholder:text-[#77716C]/60 resize-none focus:ring-0 outline-none transition-all custom-scrollbar max-h-[180px] overflow-y-auto"
                            />
                          </div>
                        </div>
                      </div>

                      {/* Right Column: Social Connect + Professional Bio */}
                      <div className="space-y-6">
                        {/* 3. Social Connect */}
                        <div className="space-y-4">
                          <div className="flex items-center gap-2 pb-2 border-b border-[#EAE2DB]/60">
                            <div className="w-6 h-6 rounded-lg bg-[#FCE9DF] flex items-center justify-center text-[#D4622C]">
                              <Share2 size={13} />
                            </div>
                            <span className="text-xs font-black uppercase tracking-wider text-[#191919]">
                              Social Connect
                            </span>
                          </div>
                          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 sm:gap-4">
                            <Field
                              label="WhatsApp"
                              placeholder="7019633010 or +91..."
                              value={form.whatsapp}
                              onChange={handleChange}
                              onBlur={handleSocialBlur}
                              name="whatsapp"
                            />
                            <Field
                              label="Instagram"
                              placeholder="https://instagram.com/username"
                              value={form.instagram}
                              onChange={handleChange}
                              onBlur={handleSocialBlur}
                              name="instagram"
                            />
                            <Field
                              label="Twitter / X"
                              placeholder="https://x.com/username"
                              value={form.twitter}
                              onChange={handleChange}
                              onBlur={handleSocialBlur}
                              name="twitter"
                            />
                            <Field
                              label="Facebook"
                              placeholder="https://facebook.com/username"
                              value={form.facebook}
                              onChange={handleChange}
                              onBlur={handleSocialBlur}
                              name="facebook"
                            />
                            <Field
                              label="GitHub"
                              placeholder="https://github.com/username"
                              value={form.github}
                              onChange={handleChange}
                              onBlur={handleSocialBlur}
                              name="github"
                            />
                            <Field
                              label="YouTube"
                              placeholder="https://youtube.com/@channel"
                              value={form.youtube}
                              onChange={handleChange}
                              onBlur={handleSocialBlur}
                              name="youtube"
                            />
                            <div className="sm:col-span-2">
                              <Field
                                label="Calendly"
                                placeholder="https://calendly.com/your-name"
                                value={form.calendly}
                                onChange={handleChange}
                                onBlur={handleSocialBlur}
                                name="calendly"
                              />
                            </div>
                          </div>
                        </div>

                        {/* 4. Professional Bio */}
                        <div className="space-y-4">
                          <div className="flex items-center gap-2 pb-2 border-b border-[#EAE2DB]/60">
                            <div className="w-6 h-6 rounded-lg bg-[#FCE9DF] flex items-center justify-center text-[#D4622C]">
                              <FileText size={13} />
                            </div>
                            <span className="text-xs font-black uppercase tracking-wider text-[#191919]">
                              Professional Bio
                            </span>
                          </div>
                          <div className="rounded-2xl border border-[#EAE2DB] bg-[#FAF6F2] focus-within:bg-white focus-within:border-[#D4622C] focus-within:ring-3 focus-within:ring-[#D4622C]/15 transition-all p-3 shadow-2xs">
                            <textarea
                              name="bio"
                              placeholder="Write a short professional bio..."
                              value={form.bio || ""}
                              onChange={handleChange}
                              rows={4}
                              className="w-full bg-transparent border-none text-sm font-medium text-[#191919] placeholder:text-[#77716C]/60 resize-none focus:ring-0 outline-none transition-all custom-scrollbar max-h-[180px] overflow-y-auto"
                            />
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </motion.div>
              )}
            </AnimatePresence>
          </div>

          {/* 5. Documents Section (Collapsible Dropdown) */}
          <div className="rounded-3xl bg-white border border-[#EAE2DB] shadow-xs overflow-hidden transition-all">
            <button
              type="button"
              onClick={() => toggleSection("documents")}
              className="w-full px-5 sm:px-6 py-4 flex items-center justify-between text-left hover:bg-[#FAF6F2] transition-colors cursor-pointer group"
            >
              <div className="flex items-center gap-3.5">
                <div className="w-10 h-10 rounded-xl bg-[#FCE9DF] flex items-center justify-center text-[#D4622C] shrink-0">
                  <BookOpen size={18} />
                </div>
                <div>
                  <h3 className="text-base font-black text-[#191919] group-hover:text-[#D4622C] transition-colors">
                    Documents (Resume & Brochure)
                  </h3>
                  <p className="text-xs text-[#77716C] mt-0.5">
                    {form.resumeUrl || form.brochureUrl ? "Documents uploaded" : "Upload Resume / CV and Company Brochure"}
                  </p>
                </div>
              </div>
              <div className="flex items-center gap-3">
                <span className="text-[10px] font-bold uppercase tracking-wider text-[#77716C] px-2.5 py-1 rounded-full bg-[#FAF6F2] border border-[#EAE2DB]">
                  {expandedSections.documents ? "Close" : "Edit"}
                </span>
                <div className="w-8 h-8 rounded-full bg-[#FAF6F2] border border-[#EAE2DB] flex items-center justify-center text-[#77716C] group-hover:text-[#D4622C] group-hover:border-[#D4622C]/30 transition-all">
                  <ChevronDown
                    size={16}
                    className={`transition-transform duration-300 ${expandedSections.documents ? "rotate-180" : ""}`}
                  />
                </div>
              </div>
            </button>
            <AnimatePresence initial={false}>
              {expandedSections.documents && (
                <motion.div
                  initial={{ height: 0, opacity: 0 }}
                  animate={{ height: "auto", opacity: 1 }}
                  exit={{ height: 0, opacity: 0 }}
                  transition={{ duration: 0.25, ease: "easeInOut" }}
                >
                  <div className="px-5 sm:px-6 pb-6 pt-4 border-t border-[#EAE2DB]/60 space-y-4">
                    <p className="text-xs text-[#77716C] leading-relaxed">
                      Upload your resume or company brochure (PDF, DOC, DOCX — max 50MB). These will be visible and downloadable on your public card.
                    </p>

                    {/* Resume Upload Card */}
                    <div className="rounded-2xl bg-[#FAF6F2] border border-[#EAE2DB] p-4 space-y-3 shadow-2xs">
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-2.5">
                          <div className="w-9 h-9 rounded-xl bg-white border border-[#EAE2DB] flex items-center justify-center text-[#D4622C]">
                            <FileText size={16} />
                          </div>
                          <div>
                            <div className="text-sm font-bold text-[#191919]">Resume / CV</div>
                            <p className="text-[10px] text-[#77716C] mt-0.5">
                              {form.resumeUrl ? "File uploaded" : "No file uploaded"}
                            </p>
                          </div>
                        </div>
                        {uploadingResume && (
                          <Loader2 size={16} className="animate-spin text-[#D4622C]" />
                        )}
                      </div>

                      {form.resumeUrl ? (
                        <div className="flex items-center gap-2">
                          <a
                            href={form.resumeUrl}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="flex-1 flex items-center gap-2 px-3 py-2 rounded-xl bg-white border border-[#EAE2DB] text-[#D4622C] text-xs font-semibold hover:bg-[#FCE9DF]/50 hover:border-[#D4622C]/40 transition-colors truncate"
                          >
                            <FileText size={12} />
                            <span className="truncate">{form.resumeUrl.split("/").pop()}</span>
                          </a>
                          <label
                            className="shrink-0 px-3 py-2 rounded-xl bg-white border border-[#EAE2DB] text-xs font-bold text-[#77716C] hover:text-[#D4622C] hover:border-[#D4622C]/40 transition-all cursor-pointer"
                          >
                            <Upload size={12} />
                            <input
                              type="file"
                              accept=".pdf,.doc,.docx"
                              className="hidden"
                              onChange={(e) => handleDocumentUpload(e, "resume")}
                              disabled={uploadingResume}
                            />
                          </label>
                          <button
                            onClick={() => handleRemoveDocument("resume")}
                            className="shrink-0 px-3 py-2 rounded-xl bg-red-500/10 border border-red-500/20 text-red-500 text-xs font-bold hover:bg-red-500/20 transition-all"
                            title="Remove resume"
                          >
                            <Trash2 size={12} />
                          </button>
                        </div>
                      ) : (
                        <label className="flex items-center justify-center gap-2 px-4 py-3 rounded-xl border-2 border-dashed border-[#EAE2DB] hover:border-[#D4622C] bg-white hover:bg-[#FCE9DF]/20 transition-all cursor-pointer group">
                          <Upload size={14} className="text-[#77716C] group-hover:text-[#D4622C] transition-colors" />
                          <span className="text-xs font-semibold text-[#77716C] group-hover:text-[#D4622C] transition-colors">
                            {uploadingResume ? "Uploading..." : "Upload Resume"}
                          </span>
                          <input
                            type="file"
                            accept=".pdf,.doc,.docx"
                            className="hidden"
                            onChange={(e) => handleDocumentUpload(e, "resume")}
                            disabled={uploadingResume}
                          />
                        </label>
                      )}
                    </div>

                    {/* Brochure Upload Card */}
                    <div className="rounded-2xl bg-[#FAF6F2] border border-[#EAE2DB] p-4 space-y-3 shadow-2xs">
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-2.5">
                          <div className="w-9 h-9 rounded-xl bg-white border border-[#EAE2DB] flex items-center justify-center text-[#D4622C]">
                            <BookOpen size={16} />
                          </div>
                          <div>
                            <div className="text-sm font-bold text-[#191919]">Company Brochure</div>
                            <p className="text-[10px] text-[#77716C] mt-0.5">
                              {form.brochureUrl ? "File uploaded" : "No file uploaded"}
                            </p>
                          </div>
                        </div>
                        {uploadingBrochure && (
                          <Loader2 size={16} className="animate-spin text-[#D4622C]" />
                        )}
                      </div>

                      {form.brochureUrl ? (
                        <div className="flex items-center gap-2">
                          <a
                            href={form.brochureUrl}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="flex-1 flex items-center gap-2 px-3 py-2 rounded-xl bg-white border border-[#EAE2DB] text-[#D4622C] text-xs font-semibold hover:bg-[#FCE9DF]/50 hover:border-[#D4622C]/40 transition-colors truncate"
                          >
                            <BookOpen size={12} />
                            <span className="truncate">{form.brochureUrl.split("/").pop()}</span>
                          </a>
                          <label
                            className="shrink-0 px-3 py-2 rounded-xl bg-white border border-[#EAE2DB] text-xs font-bold text-[#77716C] hover:text-[#D4622C] hover:border-[#D4622C]/40 transition-all cursor-pointer"
                          >
                            <Upload size={12} />
                            <input
                              type="file"
                              accept=".pdf,.doc,.docx"
                              className="hidden"
                              onChange={(e) => handleDocumentUpload(e, "brochure")}
                              disabled={uploadingBrochure}
                            />
                          </label>
                          <button
                            onClick={() => handleRemoveDocument("brochure")}
                            className="shrink-0 px-3 py-2 rounded-xl bg-red-500/10 border border-red-500/20 text-red-500 text-xs font-bold hover:bg-red-500/20 transition-all"
                            title="Remove brochure"
                          >
                            <Trash2 size={12} />
                          </button>
                        </div>
                      ) : (
                        <label className="flex items-center justify-center gap-2 px-4 py-3 rounded-xl border-2 border-dashed border-[#EAE2DB] hover:border-[#D4622C] bg-white hover:bg-[#FCE9DF]/20 transition-all cursor-pointer group">
                          <Upload size={14} className="text-[#77716C] group-hover:text-[#D4622C] transition-colors" />
                          <span className="text-xs font-semibold text-[#77716C] group-hover:text-[#D4622C] transition-colors">
                            {uploadingBrochure ? "Uploading..." : "Upload Brochure"}
                          </span>
                          <input
                            type="file"
                            accept=".pdf,.doc,.docx"
                            className="hidden"
                            onChange={(e) => handleDocumentUpload(e, "brochure")}
                            disabled={uploadingBrochure}
                          />
                        </label>
                      )}
                    </div>
                  </div>
                </motion.div>
              )}
            </AnimatePresence>
          </div>

          {/* Bottom Save Button */}
          <div className="pt-4 flex justify-end lg:hidden">
            <UiloraBrandButton
              onClick={handleSave}
              disabled={saving || uploadingAvatar || uploadingBanner}
              className="w-full sm:w-auto px-10 py-4 normal-case tracking-normal"
            >
              {saving ? (
                <Loader2 size={16} className="animate-spin" />
              ) : (
                <Save size={16} />
              )}
              {saving ? "Saving Changes..." : "Save All Changes"}
            </UiloraBrandButton>
          </div>
        </div>

        {/* Profile Card Preview Column (Sticky) */}
        <div className="lg:w-[400px] hidden lg:block shrink-0">
          <div className="sticky top-24 space-y-6">
            <div className="flex items-center justify-between mb-4 px-2">
              <div className="text-xs font-black uppercase tracking-[0.18em] text-[#77716C] flex items-center gap-2">
                <span className="w-2 h-2 rounded-full bg-emerald-500 inline-block animate-pulse" />
                Live Card Preview
              </div>
              <button 
                onClick={() => setActiveVariant(prev => prev === 1 ? 2 : 1)}
                className="text-[10px] bg-[#FCE9DF] text-[#D4622C] border border-[#D4622C]/30 px-3 py-1 rounded-full hover:bg-[#D4622C] hover:text-white transition-all uppercase tracking-wider font-bold"
              >
                Variant {activeVariant === 1 ? "2" : "1"}
              </button>
            </div>
            {activeVariant === 1 ? (
              <ProfileCardPreview data={form} onPopupToggle={setIsOverlayOpen} />
            ) : (
              <ProfileCardVariant2 data={form} onPopupToggle={setIsOverlayOpen} />
            )}

            <div className="p-5 rounded-3xl bg-white border border-[#EAE2DB] shadow-xs space-y-2.5">
              <h4 className="text-sm font-black flex items-center gap-2 text-[#191919]">
                <Zap size={14} className="text-[#D4622C]" /> Professional Edge
              </h4>
              <p className="text-xs leading-relaxed text-[#77716C]">
                Your card is optimized for SEO and professional networking. Make
                sure to link your LinkedIn and WhatsApp for maximum reach.
              </p>
            </div>
          </div>
        </div>
      </div>
      {/* Toast Notification */}
      {toast && (
        <motion.div
          initial={{ opacity: 0, y: 40, scale: 0.95 }}
          animate={{ opacity: 1, y: 0, scale: 1 }}
          exit={{ opacity: 0, y: 40, scale: 0.95 }}
          className={`fixed bottom-8 right-8 z-[200] px-6 py-4 rounded-2xl text-sm font-bold shadow-2xl backdrop-blur-md border ${
            toast.type === "error"
              ? "bg-red-500/20 text-red-300 border-red-500/30"
              : toast.type === "success"
                ? "bg-emerald-500/20 text-emerald-300 border-emerald-500/30"
                : "bg-orange-500/20 text-[#D4622C] border-orange-500/30"
          }`}
        >
          {toast.message}
        </motion.div>
      )}

      {showBannerEditor && (
        <EditBanner
          imageUrl={form.bannerUrl}
          onClose={() => setShowBannerEditor(false)}
          onSave={(newUrl) => {
            setForm((f) => ({ ...f, bannerUrl: newUrl }));
            isDirtyRef.current = true;
          }}
        />
      )}

      {/* Card Preview Modal Overlay (Mobile + Desktop) */}
      <AnimatePresence>
        {isCardPreviewOpen && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-black/80 backdrop-blur-xl overflow-y-auto"
          >
            <motion.div
              initial={{ scale: 0.9, opacity: 0, y: 20 }}
              animate={{ scale: 1, opacity: 1, y: 0 }}
              exit={{ scale: 0.9, opacity: 0, y: 20 }}
              className="relative w-full max-w-[420px] my-auto"
            >
              <button
                onClick={() => setIsCardPreviewOpen(false)}
                className="absolute -top-4 -right-4 w-10 h-10 rounded-full bg-white/10 border border-white/20 text-white flex items-center justify-center hover:bg-white/20 transition-all z-[110] shadow-2xl"
              >
                <X size={20} />
              </button>
              
              <div className="flex flex-col gap-4">
                <div className="flex items-center justify-between px-2">
                   <div className="text-[10px] font-black uppercase tracking-[0.18em] text-[#D4622C] bg-[#FCE9DF] px-3.5 py-1.5 rounded-full border border-[#D4622C]/30">
                    {activeVariant === 1 ? "Modern Aurora" : "Professional Edge"}
                  </div>
                  <button 
                    onClick={() => setActiveVariant(prev => prev === 1 ? 2 : 1)}
                    className="text-[10px] bg-white/10 text-white border border-white/20 px-3.5 py-1.5 rounded-full hover:bg-white/20 transition-all uppercase tracking-widest font-black"
                  >
                    Switch Variant
                  </button>
                </div>

                {activeVariant === 1 ? (
                  <ProfileCardPreview data={form} onPopupToggle={setIsOverlayOpen} />
                ) : (
                  <ProfileCardVariant2 data={form} onPopupToggle={setIsOverlayOpen} />
                )}

                {userData?.cardSlug && (
                  <div className="flex flex-col gap-3">
                    <a
                      href={`/card/${userData.cardSlug}`}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="w-full py-4 rounded-2xl bg-[#D4622C] hover:bg-[#BD5523] text-white text-xs font-black uppercase tracking-widest text-center transition-all shadow-[0_10px_30px_rgba(212,98,44,0.3)] flex items-center justify-center gap-2"
                    >
                      Open Public Page <Globe size={14} />
                    </a>
                    <p className="text-[10px] text-center text-slate-400 font-medium">
                      Public Link: mycardshare.id/card/{userData.cardSlug}
                    </p>
                  </div>
                )}
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
      <FieldRequest 
        isVisible={showFieldError} 
        onClose={() => setShowFieldError(false)} 
        message="Full Name is a required field. Please provide your name to update your profile."
      />
    </div>
  );
}
