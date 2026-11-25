"use client";

import { useState, useEffect, useRef } from "react";
import { useSearchParams } from "next/navigation";
import { motion, AnimatePresence } from "framer-motion";
import {
  Building,
  Globe,
  Mail,
  Phone,
  Briefcase,
  ArrowRight,
  ArrowLeft,
  Check,
  Sparkles,
  ShieldCheck,
  CreditCard,
  Ticket,
  Camera,
  AlertCircle,
  X,
  Trash2,
} from "lucide-react";
import { authFetch, parseFetchJson, toUserMessage } from "@/lib/api";
import GlassInput from "./GlassInput";
import FillForm from "../Popup/FillForm";

function slugFromCompanyName(name) {
  const s = String(name || "")
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
  return s.slice(0, 48);
}

export default function EnterpriseOnboarding({ onComplete, userData, user }) {
  const searchParams = useSearchParams();
  const didPrefillRef = useRef(false);
  const [step, setStep] = useState(1);
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState(null);
  const [error, setError] = useState(null);
  const [showInviteField, setShowInviteField] = useState(false);
  const [showPopup, setShowPopup] = useState(false);
  const [popupMessage, setPopupMessage] = useState("");
  const [formData, setFormData] = useState({
    companyName: "",
    slug: "",
    website: "",
    email: "",
    phoneNumber: "",
    adminTitle: "",
    adminBio: "",
    companyLogo: "",
    registrationSecret: "",
  });

  const steps = [
    { id: 1, title: "Organization", icon: Building },
    { id: 2, title: "Leadership", icon: ShieldCheck },
    { id: 3, title: "Finalized", icon: Check },
  ];

  useEffect(() => {
    if (userData) {
      setFormData(prev => ({
        ...prev,
        email: prev.email || userData.workEmail || userData.email || "",
        phoneNumber: prev.phoneNumber || userData.workPhone || userData.phoneNumber || "",
      }));
    }
  }, [userData]);

  useEffect(() => {
    if (didPrefillRef.current) return;
    didPrefillRef.current = true;

    let sessionCtx = null;
    try {
      if (typeof window !== "undefined") {
        const raw = sessionStorage.getItem("dbc_signup_context");
        if (raw) sessionCtx = JSON.parse(raw);
      }
    } catch (_) {
      sessionCtx = null;
    }

    let companyHint = "";
    try {
      const qs = searchParams.get("companyName");
      if (qs) companyHint = decodeURIComponent(qs);
      else if (sessionCtx?.role === "enterprise" && sessionCtx?.companyName) {
        companyHint = String(sessionCtx.companyName);
      }
    } catch (_) {
      /* ignore */
    }

    const emailHint =
      searchParams.get("prefillEmail") ||
      (sessionCtx?.workEmail ? String(sessionCtx.workEmail) : "");

    setFormData((prev) => {
      const next = { ...prev };
      if (companyHint && !prev.companyName.trim()) {
        next.companyName = companyHint;
        if (!prev.slug.trim()) next.slug = slugFromCompanyName(companyHint);
      }
      if (emailHint && !prev.email.trim()) next.email = emailHint;
      return next;
    });

    try {
      if (typeof window !== "undefined") {
        sessionStorage.removeItem("dbc_signup_context");
      }
    } catch (_) {
      /* ignore */
    }
  }, [searchParams]);

  const updateForm = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleNext = () => setStep((s) => s + 1);
  const handleBack = () => setStep((s) => s - 1);

  const handleStep1Next = () => {
    const missing = [];
    if (!formData.companyName) missing.push("Company Name");
    if (!formData.slug) missing.push("Public Slug");

    if (missing.length > 0) {
      setPopupMessage(`Please provide your ${missing.join(" and ")} to continue.`);
      setShowPopup(true);
      return;
    }
    handleNext();
  };

  const handleStep2Submit = () => {
    if (!formData.adminTitle) {
      setPopupMessage("Please provide your Administrative Title to create your organization.");
      setShowPopup(true);
      return;
    }
    handleSubmit();
  };

  const handleImageUpload = async (e) => {
    const file = e.target.files[0];
    if (e.target) e.target.value = "";
    if (!file || !result?.companyId) return;
    if (!file.type?.startsWith("image/")) {
      setError("Please choose an image file.");
      return;
    }

    setLoading(true);
    setError(null);
    try {
      // Multipart upload — no base64 inflation, no client-side compression.
      const fd = new FormData();
      fd.append("type", "logo");
      fd.append("companyId", result.companyId);
      fd.append(
        "file",
        file,
        file.name || `logo.${file.type.split("/")[1] || "bin"}`,
      );

      const res = await authFetch("/api/company/upload", {
        method: "POST",
        body: fd,
      });
      const data = await parseFetchJson(res);
      if (data.success && data.data?.url) {
        setFormData((prev) => ({ ...prev, companyLogo: data.data.url }));
      } else {
        setError(toUserMessage(data.error, "Failed to upload logo."));
      }
    } catch (err) {
      console.error("[enterprise-onboarding] upload failed:", err);
      setError(err?.message || "Network error. Failed to upload logo.");
    } finally {
      setLoading(false);
    }
  };

  const removeLogo = (e) => {
    e.stopPropagation();
    setFormData((prev) => ({ ...prev, companyLogo: "" }));
  };

  const handleSubmit = async () => {
    setLoading(true);
    setError(null);
    try {
      const {
        registrationSecret,
        ...companyFields
      } = formData;
      const res = await authFetch("/api/company/create", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          ...companyFields,
          ...(registrationSecret?.trim()
            ? { registrationSecret: registrationSecret.trim() }
            : {}),
        }),
      });
      const data = await parseFetchJson(res);
      if (data.success) {
        // `existed: true` means the server found an earlier org for this
        // admin and returned it instead of erroring out — treat it as
        // success so the user isn't stuck re-submitting.
        setResult(data.data);
        handleNext();
      } else {
        setError(
          toUserMessage(
            data.error,
            "Failed to create organization. Please check your slug.",
          ),
        );
      }
    } catch (err) {
      console.error("[enterprise-onboarding] create failed:", err);
      setError(err?.message || "Network error. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  const handleFinish = async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await authFetch("/api/user/me", {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ onboardingCompleted: true }),
      });
      const data = await parseFetchJson(res);
      if (data.success) {
        onComplete();
      } else {
        setError(
          toUserMessage(data.error, "Failed to finalize admin setup."),
        );
      }
    } catch (err) {
      console.error("[enterprise-onboarding] finish failed:", err);
      setError(err?.message || "Network error while finalizing. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  const fade = {
    initial: { opacity: 0, x: 20 },
    animate: { opacity: 1, x: 0 },
    exit: { opacity: 0, x: -20 },
  };

  const ErrorMessage = ({ message, onClear }) => (
    <motion.div
      initial={{ opacity: 0, y: -10 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, scale: 0.95 }}
      className="bg-red-50 border border-red-200 rounded-2xl p-4 mb-6 flex items-center justify-between gap-4 group"
    >
      <div className="flex items-center gap-3 text-red-700">
        <AlertCircle size={20} className="shrink-0" />
        <p className="text-xs font-bold uppercase tracking-widest leading-relaxed">
          {typeof message === "string" ? message : toUserMessage(message)}
        </p>
      </div>
      <button
        onClick={onClear}
        className="p-1.5 rounded-lg bg-red-100 text-red-600 hover:bg-red-200 transition-all"
      >
        <X size={14} />
      </button>
    </motion.div>
  );

  return (
    <div className="flex flex-col gap-8">
      {/* Progress Stepper */}
      <div className="flex items-center justify-center px-2 mb-4 gap-8">
        {steps.map((s, i) => (
          <div key={s.id} className="flex items-center gap-3">
            <div
              className={`
              w-12 h-12 rounded-2xl flex items-center justify-center transition-all duration-500
              ${
                step === s.id
                  ? "bg-[#D4642C] text-white shadow-[0_4px_16px_rgba(212,100,44,0.35)] scale-110"
                  : step > s.id
                    ? "bg-[#FAF6F2] text-[#D4642C] border border-[#EFE8E1]"
                    : "bg-[#FAF6F2] text-[#A8A29E] border border-[#EFE8E1]"
              }
            `}
            >
              {step > s.id ? <Check size={20} /> : <s.icon size={20} />}
            </div>
          </div>
        ))}
      </div>

      <div className="bg-white border border-[#EFE8E1] rounded-[2.5rem] p-6 md:p-10 shadow-[0_20px_50px_rgba(212,100,44,0.06)] overflow-hidden relative min-h-[500px]">
        <div className="absolute top-0 right-0 p-10 opacity-5 pointer-events-none rotate-12">
          <Building size={140} className="text-[#D4642C]" />
        </div>

        <AnimatePresence mode="wait">
          {error && (
            <ErrorMessage message={error} onClear={() => setError(null)} />
          )}
          {step === 1 && (
            <motion.div key="step1" {...fade} className="space-y-8">
              <div>
                <h2 className="text-3xl font-black text-[#18181B] mb-2 tracking-tight">
                  Organization Profile
                </h2>
                <p className="text-[#78716C] font-medium">
                  Establish your corporate presence on the My Card Share network.
                </p>
              </div>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <GlassInput
                  label="Company Name"
                  name="companyName"
                  value={formData.companyName}
                  onChange={updateForm}
                  icon={Building}
                  placeholder="Acme Corp"
                />
                <GlassInput
                  label="Public Slug"
                  name="slug"
                  value={formData.slug}
                  onChange={updateForm}
                  icon={Globe}
                  placeholder="acme-corp"
                  suffix=".mycardshare.id"
                />
                <GlassInput
                  label="Official Website"
                  name="website"
                  value={formData.website}
                  onChange={updateForm}
                  icon={Globe}
                  placeholder="https://acme.com"
                />
                <GlassInput
                  label="Corporate Email"
                  name="email"
                  value={formData.email}
                  onChange={updateForm}
                  icon={Mail}
                  placeholder="contact@acme.com"
                />
                <div className="md:col-span-2">
                  <GlassInput
                    label="Business Phone"
                    name="phoneNumber"
                    value={formData.phoneNumber}
                    onChange={updateForm}
                    icon={Phone}
                    placeholder="+971..."
                  />
                </div>
                <div className="md:col-span-2">
                  {!showInviteField ? (
                    <button
                      type="button"
                      onClick={() => setShowInviteField(true)}
                      className="text-[11px] font-bold uppercase tracking-[0.15em] text-[#78716C] hover:text-[#D4642C] transition-colors inline-flex items-center gap-2 cursor-pointer"
                    >
                      <ShieldCheck size={12} />
                      Have an invitation code? (optional)
                    </button>
                  ) : (
                    <>
                      <GlassInput
                        label="Invitation code"
                        name="registrationSecret"
                        value={formData.registrationSecret}
                        onChange={updateForm}
                        icon={ShieldCheck}
                        placeholder="Provided by your My Card Share administrator"
                      />
                      <p className="mt-2 text-[11px] text-[#78716C] font-medium leading-relaxed">
                        Only needed if your workspace was configured with a private invitation
                        code. Most organizations can ignore this field.
                      </p>
                    </>
                  )}
                </div>
              </div>
              <button
                onClick={handleStep1Next}
                className="w-full py-4 rounded-full bg-[#D4642C] text-white font-black text-sm uppercase tracking-wider hover:bg-[#B85323] transition-all flex items-center justify-center gap-2 shadow-[0_8px_20px_rgba(212,100,44,0.25)] cursor-pointer"
              >
                Continue to Leadership <ArrowRight size={16} />
              </button>
            </motion.div>
          )}

          {step === 2 && (
            <motion.div key="step2" {...fade} className="space-y-8">
              <div>
                <h2 className="text-3xl font-black text-[#18181B] mb-2 tracking-tight">
                  Lead Administrator
                </h2>
                <p className="text-[#78716C] font-medium">
                  Define your role within the organization to manage the fleet.
                </p>
              </div>
              <div className="grid gap-6">
                <GlassInput
                  label="Administrative Title"
                  name="adminTitle"
                  value={formData.adminTitle}
                  onChange={updateForm}
                  icon={Briefcase}
                  placeholder="Operations Director"
                />
                <div className="flex flex-col gap-2">
                  <label className="text-[10px] font-black uppercase tracking-[0.2em] text-[#78716C] ml-1">
                    Admin Bio
                  </label>
                  <div className="rounded-2xl border border-[#EFE8E1] bg-[#FAF6F2] overflow-hidden focus-within:ring-2 focus-within:ring-[#D4642C]/15 focus-within:border-[#D4642C] transition-all">
                    <textarea
                      name="adminBio"
                      value={formData.adminBio}
                      onChange={updateForm}
                      className="w-full bg-transparent border-none p-4 text-sm font-semibold text-[#18181B] placeholder:text-[#A8A29E] outline-none h-32"
                      placeholder="Describe your management role..."
                    />
                  </div>
                </div>
              </div>
              <div className="flex gap-4">
                <button
                  onClick={handleBack}
                  className="flex-1 py-4 rounded-full bg-[#FAF6F2] border border-[#EFE8E1] text-[#57534E] font-black text-sm uppercase tracking-wider hover:bg-[#EFE8E1] transition-all flex items-center justify-center gap-2 cursor-pointer"
                >
                  <ArrowLeft size={16} /> Back
                </button>
                <button
                  onClick={handleStep2Submit}
                  disabled={loading}
                  className="flex-[2] py-4 rounded-full bg-[#D4642C] text-white font-black text-sm uppercase tracking-wider hover:bg-[#B85323] transition-all flex items-center justify-center gap-2 shadow-[0_8px_20px_rgba(212,100,44,0.25)] cursor-pointer disabled:opacity-50"
                >
                  {loading
                    ? "Provisioning..."
                    : "Create Organization"}{" "}
                  <Check size={16} />
                </button>
              </div>
            </motion.div>
          )}

          {step === 3 && (
            <motion.div key="step3" {...fade} className="space-y-8">
              <div className="text-center py-4">
                <div className="w-20 h-20 rounded-full bg-[#FAF6F2] border border-[#EFE8E1] flex items-center justify-center mx-auto mb-6 shadow-sm">
                  <Sparkles size={40} className="text-[#D4642C]" />
                </div>
                <h2 className="text-3xl font-black text-[#18181B] mb-2 tracking-tight">
                  Organization Verified
                </h2>
                <p className="text-[#78716C] font-medium">
                  Your corporate entity is live. Upload a logo or share the
                  voucher with your team.
                </p>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="p-8 rounded-3xl bg-[#FAF6F2] border border-[#EFE8E1] flex flex-col items-center gap-4 group hover:border-[#D4642C]/50 transition-all cursor-pointer relative overflow-hidden">
                  <input
                    type="file"
                    className="absolute inset-0 opacity-0 cursor-pointer z-10"
                    accept="image/*"
                    onChange={handleImageUpload}
                  />
                  {formData.companyLogo && (
                    <button
                      type="button"
                      onClick={removeLogo}
                      title="Remove Logo"
                      className="absolute bottom-4 right-4 z-20 w-8 h-8 rounded-lg bg-white text-red-500 hover:bg-red-500 hover:text-white transition-all border border-[#EFE8E1] shadow-sm flex items-center justify-center group/btn cursor-pointer"
                    >
                      <Trash2 size={14} className="group-hover/btn:scale-110 transition-transform" />
                    </button>
                  )}
                  <div className="w-16 h-16 rounded-2xl bg-white border border-[#EFE8E1] flex items-center justify-center overflow-hidden">
                    {formData.companyLogo ? (
                      <img
                        src={formData.companyLogo}
                        alt="Logo"
                        className="w-full h-full object-contain"
                      />
                    ) : (
                      <Camera size={24} className="text-[#A8A29E]" />
                    )}
                  </div>
                  <div className="text-[10px] font-black uppercase tracking-[0.2em] text-[#78716C]">
                    Upload Logo
                  </div>
                </div>

                <div className="p-8 rounded-3xl bg-[#FAF6F2] border border-[#EFE8E1] flex flex-col items-center gap-4 group hover:border-[#D4642C]/50 transition-all">
                  <div className="text-[10px] font-black uppercase tracking-[0.3em] text-[#78716C] flex items-center gap-2">
                    <Ticket size={14} className="text-[#D4642C]" /> Voucher Code
                  </div>
                  <div className="text-2xl font-black text-[#D4642C] tracking-[0.15em] font-mono transition-colors">
                    {result?.voucherCode || "ALPHA-X"}
                  </div>
                </div>
              </div>

              <button
                onClick={handleFinish}
                disabled={loading}
                className="w-full py-5 rounded-full bg-[#D4642C] text-white font-black text-sm uppercase tracking-widest hover:bg-[#B85323] shadow-[0_8px_20px_rgba(212,100,44,0.25)] transition-all flex items-center justify-center gap-3 cursor-pointer disabled:opacity-50"
              >
                {loading ? "Finalizing..." : "Enter Admin Dashboard"}{" "}
                <ArrowRight size={18} />
              </button>
            </motion.div>
          )}
        </AnimatePresence>
      </div>
      <FillForm
        isOpen={showPopup}
        onClose={() => setShowPopup(false)}
        message={popupMessage}
      />
    </div>
  );
}
