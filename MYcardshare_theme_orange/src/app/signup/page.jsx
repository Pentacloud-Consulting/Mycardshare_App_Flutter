"use client";

import React, { useState, useEffect, Suspense } from "react";
import { useSearchParams } from "next/navigation";
import { motion, AnimatePresence } from "framer-motion";
import {
  Eye,
  EyeOff,
  User,
  Mail,
  Lock,
  AlertCircle,
  CheckCircle2,
  Zap,
  Link2,
  BarChart3,
  Building2,
  BadgeCheck,
} from "lucide-react";
import Link from "next/link";
// Assuming auth config is migrated to lib/firebase if keeping strictly frontend components, or using next-auth
// We will mock the firebase import here to avoid crash until the rest of the app wires it up.
import { auth, googleProvider } from "@/lib/firebase";
import {
  createUserWithEmailAndPassword,
  signInWithPopup,
  updateProfile,
} from "firebase/auth";
import { UiloraBrandButton } from "@/components/UIComponents/Button/tsx/UiloraModernButtons";

const validatePassword = (password) => {
  const checks = [
    password.length >= 8,
    /[A-Z]/.test(password),
    /[a-z]/.test(password),
    /[0-9]/.test(password),
    /[!@#$%^&*(),.?":{}|<>_\-+=[\]\\\/~`]/.test(password),
  ];
  return checks.filter(Boolean).length;
};

const validateEmail = (email) =>
  /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/.test(email);

const strengthLabel = ["", "Weak", "Fair", "Good", "Strong"];

const TAB_COPY = {
  individual: {
    headline: "Create account",
    sub: "Personal digital card — share via QR, or link.",
    submit: "Create account",
    googleHint: null,
    nameLabel: "Full name",
    emailLabel: "Email address",
    emailPlaceholder: "you@gmail.com",
  },
  enterprise: {
    headline: "Register your organization",
    sub: "You become the admin; next step is company profile and fleet tools.",
    submit: "Create admin account",
    googleHint:
      "Google: add your organization name below before continuing with Google — we’ll carry it into setup.",
    nameLabel: "Your name (organization admin)",
    emailLabel: "Work email",
    emailPlaceholder: "admin@company.com",
  },
  employee: {
    headline: "Join as team member",
    sub: "After signup you’ll enter your company voucher to link your profile.",
    submit: "Create account",
    googleHint: null,
    nameLabel: "Full name",
    emailLabel: "Work email",
    emailPlaceholder: "you@company.com",
  },
};

const getErrorMessage = (code) => {
  switch (code) {
    case "auth/email-already-in-use":
      return "An account with this email already exists.";
    case "auth/invalid-email":
      return "Please enter a valid email address.";
    case "auth/weak-password":
      return "Password is too weak.";
    case "auth/popup-closed-by-user":
      return "Google sign-up was cancelled.";
    default:
      return "Registration failed. Please try again.";
  }
};

function SignupContent() {
  const searchParams = useSearchParams();
  const [formData, setFormData] = useState({
    fullName: "",
    companyName: "",
    workEmail: "",
    password: "",
    confirmPassword: "",
  });
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [activeTab, setActiveTab] = useState(() => {
    const r = searchParams.get("role");
    return r === "individual" || r === "enterprise" || r === "employee"
      ? r
      : "individual";
  });
  const [voucherFromLink, setVoucherFromLink] = useState(() =>
    searchParams.get("voucher") || searchParams.get("code") || searchParams.get("inviteCode") || "",
  );

  useEffect(() => {
    const voucher = searchParams.get("voucher") || searchParams.get("code") || searchParams.get("inviteCode");
    const workspaceId = searchParams.get("workspaceId") || searchParams.get("enterpriseId");
    if (voucher) {
      setVoucherFromLink(voucher);
      setActiveTab("employee");
      try {
        sessionStorage.setItem("dbc_employee_voucher", voucher);
        if (workspaceId) {
          sessionStorage.setItem("dbc_employee_workspaceId", workspaceId);
        }
        const code = searchParams.get("code") || searchParams.get("inviteCode");
        if (code) sessionStorage.setItem("dbc_employee_inviteCode", code);
        const companyName = searchParams.get("companyName");
        const companySlug = searchParams.get("companySlug");
        if (companyName) sessionStorage.setItem("dbc_employee_companyName", companyName);
        if (companySlug) sessionStorage.setItem("dbc_employee_companySlug", companySlug);
      } catch (_) {
        /* ignore */
      }
    }
  }, [searchParams]);

  const passwordStrength = validatePassword(formData.password || "");
  const tabMeta = TAB_COPY[activeTab] || TAB_COPY.individual;

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const onboardingHrefWithContext = (overrideName, overrideEmail) => {
    const qs = new URLSearchParams();
    qs.set("role", activeTab);
    if (activeTab === "enterprise" && formData.companyName.trim()) {
      qs.set("companyName", formData.companyName.trim());
    }
    const resolvedName = (overrideName || formData.fullName || "").trim();
    if (resolvedName) {
      qs.set("prefillName", resolvedName);
    }
    const resolvedEmail = (overrideEmail || formData.workEmail || "").trim();
    if (resolvedEmail) {
      qs.set("prefillEmail", resolvedEmail);
    }
    const q = qs.toString();
    return q ? `/onboarding?${q}` : `/onboarding?role=${activeTab}`;
  };

  const handleEmailSignUp = async (e) => {
    e.preventDefault();
    setError("");
    setLoading(true);

    if (
      activeTab === "enterprise" &&
      !(formData.companyName && formData.companyName.trim())
    ) {
      setError("Enter your organization name — it distinguishes enterprise signup.");
      setLoading(false);
      return;
    }

    if (!validateEmail(formData.workEmail)) {
      setError("Please enter a valid email address.");
      setLoading(false);
      return;
    }
    const hasUpper = /[A-Z]/.test(formData.password);
    const hasNumber = /[0-9]/.test(formData.password);
    const hasSpecial = /[!@#$%^&*(),.?":{}|<>_\-+=[\]\\\/~`]/.test(
      formData.password,
    );
    const isLongEnough = formData.password.length >= 8;

    if (!isLongEnough || !hasUpper || !hasNumber || !hasSpecial) {
      setError(
        "Password must be at least 8 characters and include at least one uppercase letter, one number, and one special character.",
      );
      setLoading(false);
      return;
    }
    if (formData.password !== formData.confirmPassword) {
      setError("Passwords do not match.");
      setLoading(false);
      return;
    }

    try {
      const cred = await createUserWithEmailAndPassword(
        auth,
        formData.workEmail,
        formData.password,
      );
      await updateProfile(cred.user, { displayName: formData.fullName.trim() });

      // Save for onboarding fallback
      try {
        sessionStorage.setItem(
          "dbc_signup_context",
          JSON.stringify({
            role: activeTab,
            fullName: formData.fullName.trim(),
            companyName: formData.companyName?.trim() || undefined,
            workEmail: formData.workEmail.trim(),
          }),
        );
      } catch (_) {}

      // Immediately patch user profile in backend so Firestore has fullName
      try {
        const idToken = await cred.user.getIdToken(true);
        await fetch("/api/user/me", {
          method: "PATCH",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${idToken}`,
          },
          body: JSON.stringify({
            fullName: formData.fullName.trim(),
            displayName: formData.fullName.trim(),
            workEmail: formData.workEmail.trim(),
            email: formData.workEmail.trim(),
          }),
        });
      } catch (patchErr) {
        console.warn("Could not patch initial user profile:", patchErr);
      }

      // If user signed up via Enterprise tab, provision enterprise workspace and role immediately
      if (activeTab === "enterprise") {
        try {
          const idToken = await cred.user.getIdToken();
          await fetch("/api/sync/enterprise-google-signup", {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              Authorization: `Bearer ${idToken}`,
            },
            body: JSON.stringify({
              companyName: formData.companyName.trim() || undefined,
              email: formData.workEmail.trim(),
              fullName: formData.fullName.trim(),
            }),
          });
        } catch (syncErr) {
          console.warn("Enterprise email auto-provision warning:", syncErr);
        }
      }

      window.location.href = onboardingHrefWithContext();
    } catch (err) {
      setError(getErrorMessage(err.code));
    } finally {
      setLoading(false);
    }
  };

  const handleGoogleSignUp = async () => {
    setError("");
    setLoading(true);
    try {
      const cred = await signInWithPopup(auth, googleProvider);
      
      // If user selected Enterprise tab, immediately synchronize and provision Enterprise workspace
      if (activeTab === "enterprise") {
        try {
          const idToken = await cred.user.getIdToken();
          await fetch("/api/sync/enterprise-google-signup", {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              Authorization: `Bearer ${idToken}`,
            },
            body: JSON.stringify({
              companyName: formData.companyName.trim() || undefined,
              email: cred.user.email,
              fullName: cred.user.displayName,
            }),
          });
        } catch (syncErr) {
          console.warn("Enterprise Google auto-provision warning:", syncErr);
        }
      }

      try {
        sessionStorage.setItem(
          "dbc_signup_context",
          JSON.stringify({
            role: activeTab,
            fullName: cred.user.displayName || formData.fullName.trim(),
            companyName:
              activeTab === "enterprise"
                ? formData.companyName.trim()
                : undefined,
            workEmail: formData.workEmail.trim() || cred.user.email,
          }),
        );
      } catch (_) {
        /* ignore */
      }
      window.location.href = onboardingHrefWithContext(cred.user.displayName, cred.user.email);
    } catch (err) {
      setError(getErrorMessage(err.code));
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="w-full min-h-screen flex bg-[#FAF6F2] overflow-hidden text-slate-800 relative font-sans antialiased">
      {/* Global aurora orb backgrounds */}
      <div className="absolute -top-[15%] -left-[10%] w-[60vw] h-[60vw] rounded-full bg-[radial-gradient(circle,rgba(212,100,44,0.12)_0%,transparent_70%)] pointer-events-none blur-[80px] -z-0" />
      <div className="absolute -bottom-[20%] -right-[10%] w-[50vw] h-[50vw] rounded-full bg-[radial-gradient(circle,rgba(245,158,11,0.08)_0%,transparent_70%)] pointer-events-none blur-[80px] -z-0" />

      {/* LEFT BRANDING PANEL */}
      <div className="hidden lg:flex w-1/2 min-h-screen flex-col justify-center p-12 relative z-10 overflow-hidden flex-shrink-0 bg-[url('/assets/auth_branding.png')] bg-center bg-cover bg-no-repeat">
        {/* Transparent Overlay */}
        <div className="absolute inset-0 bg-gradient-to-br from-[#FAF6F2]/90 via-[#FAF6F2]/75 to-transparent pointer-events-none -z-10" />

        <div className="max-w-[520px] relative z-10 bg-white/90 backdrop-blur-2xl p-10 rounded-[2.5rem] border border-[#EFE8E1] shadow-2xl shadow-stone-900/5 hover:shadow-stone-900/10 transition-all duration-500 hover:-translate-y-2 -mt-56">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.1 }}
            className="flex items-center gap-3 mb-14"
          >
            <Link href="/">
              <img
                src="/logo/image (4).png"
                alt="Logo"
                className="w-48 h-auto object-contain scale-[1.2] origin-left transition-transform duration-500 hover:scale-[1.25]"
              />
            </Link>
          </motion.div>

          <motion.h1
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.2 }}
            className="font-display text-[2.8rem] font-extrabold tracking-tight leading-tight text-slate-800 mb-4"
          >
            Join the
            <br />
            Future of{" "}
            <span className="text-[#D4642C]">
              Networking.
            </span>
          </motion.h1>

          <motion.p
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.3 }}
            className="text-base font-medium text-slate-500 leading-relaxed mb-12 max-w-[400px]"
          >
            Create your digital business card in minutes. Share via QR
            scan, or a simple link. Zero paper. Maximum impact.
          </motion.p>

          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.4 }}
            className="mb-10 space-y-3"
          >
            {[
              {
                Icon: Zap,
                title: "Instant setup",
                desc: "Live in under 2 minutes",
              },
              {
                Icon: Link2,
                title: "Share anywhere",
                desc: "NFC, QR, Link, Email",
              },
              {
                Icon: BarChart3,
                title: "Track engagement",
                desc: "Views, scans, CRM sync",
              },
            ].map(({ Icon, title, desc }) => (
              <div key={title} className="flex items-center gap-4 group p-3 -mx-3 rounded-2xl hover:bg-white/80 transition-all duration-300 cursor-default border border-transparent hover:border-[#EFE8E1]">
                <div className="w-10 h-10 rounded-xl bg-[#FAF6F2] border border-[#EFE8E1] flex items-center justify-center text-lg flex-shrink-0 group-hover:bg-[#D4642C] group-hover:text-white group-hover:shadow-md group-hover:scale-110 transition-all duration-300">
                  <Icon size={18} className="text-[#D4642C] group-hover:text-white transition-colors" />
                </div>
                <div>
                  <div className="text-sm font-bold text-slate-800 font-display tracking-tight">
                    {title}
                  </div>
                  <div className="text-xs font-medium text-slate-500">{desc}</div>
                </div>
              </div>
            ))}
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.5 }}
            className="flex items-center gap-4 flex-wrap"
          >
            {["Free to start", "No credit card", "UAE Based", "Secure"].map(
              (t, i) => (
                <div
                  key={t}
                  className="flex items-center gap-2 text-xs font-semibold text-slate-400 uppercase tracking-widest"
                >
                  {i > 0 && (
                    <span className="w-1 h-1 rounded-full bg-[#D4642C]/50" />
                  )}
                  {t}
                </div>
              ),
            )}
          </motion.div>
        </div>

        {/* Floating Stat Card */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.7 }}
          className="absolute bottom-8 right-8 z-10 bg-white/95 border border-[#EFE8E1] rounded-2xl p-4 px-6 backdrop-blur-[20px] min-w-[220px] shadow-2xl shadow-stone-900/5"
        >
          <div className="flex items-center gap-2 mb-2 text-[11px] font-bold text-[#D4642C] uppercase tracking-widest">
            <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 shadow-[0_0_6px_#10b981] animate-pulse" />
            New signups today
          </div>
          <div className="font-display text-[22px] font-extrabold text-slate-800 tracking-tight mb-1">
            47 accounts
          </div>
          <div className="text-xs text-slate-500">
            Growing across UAE & Gulf
          </div>
        </motion.div>
      </div>

      {/* DIVIDER */}
      <div className="hidden lg:block w-[1px] bg-[#EFE8E1] flex-shrink-0 z-10" />

      {/* RIGHT FORM PANEL */}
      <div className="flex-1 flex flex-col justify-center items-center p-6 lg:p-12 relative z-10 bg-[#FAF6F2] min-h-screen">
        <motion.div
          initial={{ opacity: 0, x: 40 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ duration: 0.6, delay: 0.1 }}
          className="w-full max-w-[460px] py-6"
        >
          <div className="bg-white border border-[#EFE8E1] rounded-[2rem] p-6 lg:p-10 shadow-2xl shadow-stone-900/5 w-full hover:border-[#D4642C]/30 transition-colors duration-500">
            <div className="flex justify-center mb-8">
              <img
                src="/logo/image (4).png"
                alt="Logo"
                className="w-44 md:w-56 h-auto object-contain scale-[1.2]"
              />
            </div>

            <h2 className="font-display text-xl md:text-2xl font-extrabold tracking-tight text-slate-800 text-center mb-1 leading-tight">
              {tabMeta.headline}
            </h2>
            <p className="text-[13px] text-slate-500 text-center font-medium mb-6">
              {tabMeta.sub}
            </p>

            {/* TAB SWITCHER */}
            <div className="flex bg-[#FAF6F2] border border-[#EFE8E1] rounded-2xl p-1 mb-6 relative gap-1">
              <button
                onClick={() => setActiveTab("individual")}
                className={`relative flex-1 py-2.5 rounded-xl text-[13px] font-bold transition-all duration-300 flex items-center justify-center overflow-hidden ${activeTab === "individual" ? "bg-white text-[#D4642C] shadow-sm font-bold" : "text-slate-500 hover:text-slate-800 hover:bg-stone-200/50"}`}
              >
                {activeTab === "individual" && <div className="absolute left-0 top-1/2 -translate-y-1/2 w-1 h-5 rounded-r-full bg-[#D4642C]" />}
                Individual
              </button>
              <button
                onClick={() => setActiveTab("enterprise")}
                className={`relative flex-1 py-2.5 rounded-xl text-[13px] font-bold transition-all duration-300 flex items-center justify-center overflow-hidden ${activeTab === "enterprise" ? "bg-white text-[#D4642C] shadow-sm font-bold" : "text-slate-500 hover:text-slate-800 hover:bg-stone-200/50"}`}
              >
                {activeTab === "enterprise" && <div className="absolute left-0 top-1/2 -translate-y-1/2 w-1 h-5 rounded-r-full bg-[#D4642C]" />}
                Enterprise
              </button>
              <button
                onClick={() => setActiveTab("employee")}
                className={`relative flex-1 py-2.5 rounded-xl text-[13px] font-bold transition-all duration-300 flex items-center justify-center overflow-hidden ${activeTab === "employee" ? "bg-white text-[#D4642C] shadow-sm font-bold" : "text-slate-500 hover:text-slate-800 hover:bg-stone-200/50"}`}
              >
                {activeTab === "employee" && <div className="absolute left-0 top-1/2 -translate-y-1/2 w-1 h-5 rounded-r-full bg-[#D4642C]" />}
                Employee
              </button>
            </div>

            {activeTab === "enterprise" && tabMeta.googleHint && (
              <p className="text-[11px] text-center text-stone-600 font-medium leading-relaxed mb-5 px-1">
                {tabMeta.googleHint}
              </p>
            )}

            {activeTab === "employee" && (
              <div className="mb-5 flex gap-3 rounded-xl border border-emerald-500/30 bg-emerald-50 px-4 py-3">
                <BadgeCheck
                  size={18}
                  className="text-emerald-600 shrink-0 mt-0.5"
                />
                <p className="text-[12px] text-emerald-800 font-medium leading-relaxed">
                  You&apos;ll verify with your company voucher right after this — not on this screen.
                </p>
              </div>
            )}

            <AnimatePresence>
              {error && (
                <motion.div
                  initial={{ opacity: 0, y: -8 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -8 }}
                  className="flex items-center gap-2 bg-red-500/10 border border-red-500/25 rounded-xl p-3 px-4 text-[13px] font-semibold text-red-300 mb-6"
                >
                  <AlertCircle size={16} /> {error}
                </motion.div>
              )}
            </AnimatePresence>

            <form onSubmit={handleEmailSignUp}>
              <motion.div
                key={activeTab}
                initial={{ opacity: 0, y: 6 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.25 }}
              >
                {/* Name */}
                <div className="mb-5">
                  <div className="flex justify-between items-center mb-2">
                    <span className="text-[10px] font-black uppercase tracking-[0.15em] text-slate-400 font-display">
                      {tabMeta.nameLabel}{" "}
                      <span className="text-[#D4642C] ml-[2px]">*</span>
                    </span>
                  </div>
                  <div className="relative flex items-center bg-[#FAF6F2] border border-[#EFE8E1] rounded-xl overflow-hidden focus-within:border-[#D4642C] focus-within:ring-2 focus-within:ring-[#D4642C]/20 focus-within:bg-white shadow-xs transition-all duration-200">
                    <span className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 z-10 pointer-events-none">
                      <User size={16} />
                    </span>
                    <input
                      className="flex-1 bg-transparent border-none outline-none py-3.5 pl-11 pr-4 text-[15px] font-semibold text-slate-800 placeholder:text-slate-400"
                      name="fullName"
                      type="text"
                      placeholder={
                        activeTab === "enterprise"
                          ? "Jane Doe"
                          : "Sarah Khan"
                      }
                      value={formData.fullName}
                      onChange={handleChange}
                      required
                    />
                  </div>
                </div>

                {activeTab === "enterprise" && (
                  <div className="mb-5">
                    <div className="flex justify-between items-center mb-2">
                      <span className="text-[10px] font-black uppercase tracking-[0.15em] text-slate-400 font-display">
                        Organization name{" "}
                        <span className="text-[#D4642C] ml-[2px]">*</span>
                      </span>
                    </div>
                    <div className="relative flex items-center bg-[#FAF6F2] border border-[#EFE8E1] rounded-xl overflow-hidden focus-within:border-[#D4642C] focus-within:ring-2 focus-within:ring-[#D4642C]/20 focus-within:bg-white shadow-xs transition-all duration-200">
                      <span className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 z-10 pointer-events-none">
                        <Building2 size={16} />
                      </span>
                      <input
                        className="flex-1 bg-transparent border-none outline-none py-3.5 pl-11 pr-4 text-[15px] font-semibold text-slate-800 placeholder:text-slate-400"
                        name="companyName"
                        type="text"
                        placeholder="Acme Corp"
                        value={formData.companyName}
                        onChange={handleChange}
                        required
                      />
                    </div>
                  </div>
                )}

                {/* Email */}
                <div className="mb-5">
                  <div className="flex justify-between items-center mb-2">
                    <span className="text-[10px] font-black uppercase tracking-[0.15em] text-slate-400 font-display">
                      {tabMeta.emailLabel}{" "}
                      <span className="text-[#D4642C] ml-[2px]">*</span>
                    </span>
                  </div>
                  <div className="relative flex items-center bg-[#FAF6F2] border border-[#EFE8E1] rounded-xl overflow-hidden focus-within:border-[#D4642C] focus-within:ring-2 focus-within:ring-[#D4642C]/20 focus-within:bg-white shadow-xs transition-all duration-200">
                    <span className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 z-10 pointer-events-none">
                      <Mail size={16} />
                    </span>
                    <input
                      className="flex-1 bg-transparent border-none outline-none py-3.5 pl-11 pr-4 text-[15px] font-semibold text-slate-800 placeholder:text-slate-400"
                      name="workEmail"
                      type="email"
                      placeholder={tabMeta.emailPlaceholder}
                      value={formData.workEmail}
                      onChange={handleChange}
                      required
                    />
                  </div>
                </div>

              {/* Password */}
              <div className="mb-5">
                <div className="flex justify-between items-center mb-2">
                  <span className="text-[10px] font-black uppercase tracking-[0.15em] text-slate-400 font-display">
                    Password <span className="text-[#D4642C] ml-[2px]">*</span>
                  </span>
                </div>
                <div className="relative flex items-center bg-[#FAF6F2] border border-[#EFE8E1] rounded-xl overflow-hidden focus-within:border-[#D4642C] focus-within:ring-2 focus-within:ring-[#D4642C]/20 focus-within:bg-white shadow-xs transition-all duration-200">
                  <span className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 z-10 pointer-events-none">
                    <Lock size={16} />
                  </span>
                  <input
                    className="flex-1 bg-transparent border-none outline-none py-3.5 pl-11 text-[15px] font-semibold text-slate-800 placeholder:text-slate-400"
                    name="password"
                    type={showPassword ? "text" : "password"}
                    placeholder="Min. 8 characters"
                    value={formData.password}
                    onChange={handleChange}
                    required
                  />
                  <button
                    type="button"
                    className="px-4 text-slate-400 hover:text-slate-600 transition-colors"
                    onClick={() => setShowPassword(!showPassword)}
                  >
                    {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
                  </button>
                </div>
                {formData.password.length > 0 && (
                  <div className="mt-2">
                    <div className="flex gap-1 mb-1">
                      {[1, 2, 3, 4, 5].map((n) => (
                        <div
                          key={n}
                          className={`flex-1 h-[3px] rounded-full transition-colors duration-300 ${passwordStrength >= n ? (n <= 2 ? "bg-red-500" : n <= 4 ? "bg-amber-500" : "bg-emerald-500") : "bg-stone-200"}`}
                        />
                      ))}
                    </div>
                    <span
                      className={`text-[11px] font-semibold ${passwordStrength <= 1 ? "text-red-400" : passwordStrength === 2 ? "text-amber-500" : "text-emerald-500"}`}
                    >
                      {strengthLabel[passwordStrength]}
                    </span>
                  </div>
                )}
              </div>

              {/* Confirm Password */}
              <div className="mb-6">
                <div className="flex justify-between items-center mb-2">
                  <span className="text-[10px] font-black uppercase tracking-[0.15em] text-slate-400 font-display flex items-center gap-2">
                    Confirm Password{" "}
                    <span className="text-[#D4642C] -ml-1">*</span>
                    {formData.confirmPassword &&
                      formData.password === formData.confirmPassword && (
                        <CheckCircle2 size={14} className="text-emerald-500" />
                      )}
                  </span>
                </div>
                <div className="relative flex items-center bg-[#FAF6F2] border border-[#EFE8E1] rounded-xl overflow-hidden focus-within:border-[#D4642C] focus-within:ring-2 focus-within:ring-[#D4642C]/20 focus-within:bg-white shadow-xs transition-all duration-200">
                  <span className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 z-10 pointer-events-none">
                    <Lock size={16} />
                  </span>
                  <input
                    className="flex-1 bg-transparent border-none outline-none py-3.5 pl-11 text-[15px] font-semibold text-slate-800 placeholder:text-slate-400"
                    name="confirmPassword"
                    type={showConfirmPassword ? "text" : "password"}
                    placeholder="Repeat your password"
                    value={formData.confirmPassword}
                    onChange={handleChange}
                    required
                  />
                  <button
                    type="button"
                    className="px-4 text-slate-400 hover:text-slate-600 transition-colors"
                    onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                  >
                    {showConfirmPassword ? (
                      <EyeOff size={16} />
                    ) : (
                      <Eye size={16} />
                    )}
                  </button>
                </div>
              </div>

              {/* Submit */}
              <UiloraBrandButton
                type="submit"
                disabled={loading}
                className="w-full py-4 text-sm normal-case tracking-normal mb-6 font-bold"
              >
                {loading ? (
                  <span className="flex items-center justify-center gap-2">
                    <span className="w-4 h-4 border-2 border-white/25 border-t-white rounded-full animate-spin flex-shrink-0" />{" "}
                    Creating account...
                  </span>
                ) : (
                  tabMeta.submit
                )}
              </UiloraBrandButton>
              </motion.div>
            </form>

            <div className="flex items-center gap-3 mb-6">
              <div className="flex-1 h-[1px] bg-slate-200" />
              <span className="text-[10px] font-black text-slate-400 uppercase tracking-[0.15em] whitespace-nowrap">
                or sign up with
              </span>
              <div className="flex-1 h-[1px] bg-slate-200" />
            </div>

            <motion.button
              onClick={handleGoogleSignUp}
              disabled={loading}
              whileHover={{ scale: loading ? 1 : 1.015 }}
              whileTap={{ scale: loading ? 1 : 0.985 }}
              className="w-full flex items-center justify-center gap-2 py-3.5 px-6 rounded-xl border border-[#EFE8E1] bg-white text-slate-700 font-sans text-[15px] font-bold hover:bg-[#FAF6F2] transition-all duration-300 relative overflow-hidden group mb-8 shadow-xs disabled:opacity-50"
            >
              <div className="absolute inset-0 bg-[#FAF6F2] opacity-0 group-hover:opacity-100 transition-opacity duration-200 rounded-[inherit]" />
              <svg className="w-5 h-5 flex-shrink-0 relative z-10" viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path fill="#FFC107" d="M43.611,20.083H42V20H24v8h11.303c-1.649,4.657-6.08,8-11.303,8c-6.627,0-12-5.373-12-12c0-6.627,5.373-12,12-12c3.059,0,5.842,1.154,7.961,3.039l5.657-5.657C34.046,6.053,29.268,4,24,4C12.955,4,4,12.955,4,24c0,11.045,8.955,20,20,20c11.045,0,20-8.955,20-20C44,22.659,43.862,21.35,43.611,20.083z"/>
                <path fill="#FF3D00" d="M6.306,14.691l6.571,4.819C14.655,15.108,18.961,12,24,12c3.059,0,5.842,1.154,7.961,3.039l5.657-5.657C34.046,6.053,29.268,4,24,4C16.318,4,9.656,8.337,6.306,14.691z"/>
                <path fill="#4CAF50" d="M24,44c5.166,0,9.86-1.977,13.409-5.192l-6.19-5.238C29.211,35.091,26.715,36,24,36c-5.202,0-9.619-3.317-11.283-7.946l-6.522,5.025C9.505,39.556,16.227,44,24,44z"/>
                <path fill="#1976D2" d="M43.611,20.083H42V20H24v8h11.303c-0.792,2.237-2.231,4.166-4.087,5.571c0.001-0.001,0.002-0.001,0.003-0.002l6.19,5.238C36.971,39.205,44,34,44,24C44,22.659,43.862,21.35,43.611,20.083z"/>
              </svg>
              <span className="relative z-10">Continue with Google</span>
            </motion.button>

            <div className="text-center text-[13px] font-semibold text-slate-500 mt-6">
              Already have an account?
              <Link
                href={`/login?role=${activeTab}`}
                className="font-bold text-[#D4642C] hover:text-[#BD5523] ml-1 transition-colors"
              >
                Sign in
              </Link>
            </div>
          </div>
        </motion.div>
      </div>
    </div>
  );
}

export default function SignupPage() {
  return (
    <Suspense
      fallback={
        <div className="min-h-screen bg-[#FAF6F2] flex items-center justify-center">
          <div className="w-12 h-12 border-4 border-[#D4642C]/20 border-t-[#D4642C] rounded-full animate-spin" />
        </div>
      }
    >
      <SignupContent />
    </Suspense>
  );
}
