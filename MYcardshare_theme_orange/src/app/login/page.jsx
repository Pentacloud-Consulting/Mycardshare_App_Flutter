"use client";

import React, { useState, useEffect, Suspense } from "react";
import { useSearchParams } from "next/navigation";
import { motion, AnimatePresence } from "framer-motion";
import {
  Eye,
  EyeOff,
  Mail,
  Lock,
  AlertCircle,
  Zap,
  Link2,
  BarChart3,
} from "lucide-react";
import Link from "next/link";
import { signInWithEmailAndPassword, signInWithPopup } from "firebase/auth";
import { auth, googleProvider } from "@/lib/firebase";
import { UiloraBrandButton } from "@/components/UIComponents/Button/tsx/UiloraModernButtons";
import { parseFetchJson, toUserMessage } from "@/lib/api";
import { isMasterAdmin, isEnterprise, isApproved } from "@/lib/roles";

function postAuthDestination(userData) {
  const role = userData?.role || "standard";

  // Master admin → always to master-admin dashboard
  if (isMasterAdmin(role)) {
    return "/master-admin/dashboard";
  }

  // Enterprise approved → enterprise dashboard
  if (isEnterprise(role) && isApproved(userData?.status)) {
    return "/enterprise/dashboard";
  }

  // Enterprise pending → should have been blocked before reaching here
  if (isEnterprise(role)) {
    return null; // signals "blocked"
  }

  // Onboarding not completed
  if (userData?.onboardingCompleted === false) {
    const r = role.toLowerCase();
    let tabRole = "individual";
    if (r === "employee") tabRole = "employee";
    return `/onboarding?role=${tabRole}`;
  }

  return "/portal";
}

const validateEmail = (email) =>
  /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/.test(String(email || "").trim());

const getErrorMessage = (code) => {
  switch (code) {
    case "auth/user-not-found":
      return "No account found for that sign-in. Check the email or create an account.";
    case "auth/wrong-password":
      return "Incorrect password. Try again or use Forgot password.";
    case "auth/invalid-email":
      return "That email doesn’t look valid. Use the format name@domain.com.";
    case "auth/too-many-requests":
      return "Too many attempts. Wait a minute and try again.";
    case "auth/invalid-credential":
      return "Sign-in didn’t work. Check email and password, or use Google if you registered that way.";
    case "auth/account-exists-with-different-credential":
      return "This email is already registered with another sign-in method. Try email/password or the other provider you used.";
    case "auth/popup-closed-by-user":
    case "auth/cancelled-popup-request":
      return "Google sign-in was closed before it finished. Try again.";
    case "auth/popup-blocked":
      return "Your browser blocked the Google popup. Allow popups for this site and try again.";
    case "auth/network-request-failed":
      return "Network error. Check your connection and try again.";
    default:
      return "Sign in failed. Please try again.";
  }
};

function friendlyCatchMessage(err) {
  if (err?.code) return getErrorMessage(err.code);
  const raw = String(err?.message || "").trim();
  if (!raw) return "Something went wrong. Try again.";
  if (/failed to fetch|networkerror|load failed/i.test(raw)) {
    return "Network error. Check your connection and try again.";
  }
  if (raw.length > 160) return "Something went wrong. Try again.";
  return raw;
}

function LoginContent() {
  const searchParams = useSearchParams();
  const [formData, setFormData] = useState({ workEmail: "", password: "" });
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [activeTab, setActiveTab] = useState(() => {
    const r = searchParams.get("role");
    return r === "individual" || r === "enterprise" || r === "employee"
      ? r
      : "individual";
  });

  useEffect(() => {
    setError("");
  }, [activeTab]);

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleEmailLogin = async (e) => {
    e.preventDefault();
    setError("");
    const email = String(formData.workEmail || "").trim();
    if (!validateEmail(email)) {
      setError("Enter a valid email (example: you@company.com).");
      return;
    }
    if (!formData.password) {
      setError("Enter your password.");
      return;
    }
    setLoading(true);

    try {
      const cred = await signInWithEmailAndPassword(auth, email, formData.password);

      // 1. Fetch user role for validation
      const token = await cred.user.getIdToken(true);
      const res = await fetch("/api/user/me", {
        headers: { Authorization: `Bearer ${token}` },
      });
      const result = await parseFetchJson(res);

      if (result.success) {
        const userData = result.data;
        const role = userData.role || "standard";

        // Master admin → always allowed, route to master-admin
        if (isMasterAdmin(role)) {
          window.location.href = "/master-admin/dashboard";
          return;
        }

        // Enterprise user checks
        if (isEnterprise(role)) {
          if (!isApproved(userData.status)) {
            await auth.signOut();
            setError("Your account is pending approval by the administrator. You will be notified once approved.");
            setLoading(false);
            return;
          }
          window.location.href = "/enterprise/dashboard";
          return;
        }

        // Tab validation for individual/employee
        if (activeTab === "enterprise") {
          await auth.signOut();
          setError("This account is not registered as an Enterprise admin.");
          setLoading(false);
          return;
        }
        if (activeTab === "employee" && role !== "employee") {
          await auth.signOut();
          setError("This account is not registered as an Employee.");
          setLoading(false);
          return;
        }

        window.location.href = postAuthDestination(userData);
      } else {
        console.error("Profile load failed:", result);
        setError(
          toUserMessage(result.error, "Could not load your profile. Try again in a moment."),
        );
        await auth.signOut();
      }
    } catch (err) {
      setError(friendlyCatchMessage(err));
    } finally {
      setLoading(false);
    }
  };

  const handleGoogleLogin = async () => {
    setError("");
    setLoading(true);
    try {
      const cred = await signInWithPopup(auth, googleProvider);

      // 1. Fetch user role for validation
      const token = await cred.user.getIdToken(true);
      const res = await fetch("/api/user/me", {
        headers: { Authorization: `Bearer ${token}` },
      });
      const result = await parseFetchJson(res);

      if (result.success) {
        const userData = result.data;
        const role = userData.role || "standard";

        // Master admin → always route to master-admin
        if (isMasterAdmin(role)) {
          window.location.href = "/master-admin/dashboard";
          return;
        }

        // Enterprise user checks
        if (isEnterprise(role)) {
          if (!isApproved(userData.status)) {
            await auth.signOut();
            setError("Your account is pending approval by the administrator.");
            setLoading(false);
            return;
          }
          window.location.href = "/enterprise/dashboard";
          return;
        }

        // Tab validation for individual/employee
        let isAllowed = true;
        let errorMessage = "";

        if (activeTab === "enterprise") {
          // If user logged in via Enterprise tab with Google, allow them to complete enterprise onboarding or auto-promote
          if (role !== "enterprise" && !role.includes("admin")) {
            // Check if user already created an enterprise or should be routed to onboarding
            window.location.href = "/onboarding?role=enterprise";
            return;
          }
        } else if (activeTab === "employee") {
          if (role !== "employee") {
            isAllowed = false;
            errorMessage = "This account is not registered as an Employee.";
          }
        } else {
          // Individual Tab
          if (role.includes("admin")) {
            errorMessage =
              "Admins must log in through the Enterprise tab for secure access.";
          } else {
            isAllowed = true;
          }
        }

        if (!isAllowed) {
          await auth.signOut();
          setError(errorMessage);
          setLoading(false);
          return;
        }

        window.location.href = postAuthDestination(userData);
      } else {
        console.error("Profile load failed:", result);
        setError(
          toUserMessage(result.error, "Could not load your profile. Try again in a moment."),
        );
        await auth.signOut();
      }
    } catch (err) {
      setError(friendlyCatchMessage(err));
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
        <div className="absolute inset-0 bg-gradient-to-br from-[#FAF6F2]/90 via-[#FAF6F2]/75 to-transparent pointer-events-none -z-10" />

        <div className="max-w-[520px] relative z-10 bg-white/90 backdrop-blur-2xl p-10 rounded-[2.5rem] border border-[#EFE8E1] shadow-2xl shadow-stone-900/5 hover:shadow-stone-900/10 transition-all duration-500 hover:-translate-y-2 -mt-40">
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
            Welcome <br />
            Back to the{" "}
            <span className="text-[#D4642C]">
              Future.
            </span>
          </motion.h1>

          <motion.p
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.3 }}
            className="text-base font-medium text-slate-500 leading-relaxed mb-12 max-w-[400px]"
          >
            Log in to manage your digital identity, analyze your leads in
            real-time, and access your network seamlessly.
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
        </div>
      </div>

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
              <Link href="/">
                <img
                  src="/logo/image (4).png"
                  alt="Logo"
                  className="w-44 md:w-56 h-auto object-contain scale-[1.2] cursor-pointer"
                />
              </Link>
            </div>

            <h2 className="font-display text-xl md:text-2xl font-black tracking-tight text-slate-800 text-center mb-1 leading-tight">
              Welcome back
            </h2>
            <p className="text-[13px] font-medium text-slate-500 text-center mb-8">
              Enter your details to sign in
            </p>

            <div className="flex bg-[#FAF6F2] border border-[#EFE8E1] rounded-2xl p-1 mb-8 relative gap-1">
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

            <AnimatePresence>
              {error && (
                <motion.div
                  initial={{ opacity: 0, y: -8 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -8 }}
                  className="flex items-center gap-2 bg-red-50 border border-red-100 rounded-xl p-3 px-4 text-[13px] font-semibold text-red-600 mb-6 shadow-sm"
                >
                  <AlertCircle size={16} /> {error}
                </motion.div>
              )}
            </AnimatePresence>

            <form noValidate onSubmit={handleEmailLogin}>
              <div className="mb-5">
                <div className="flex justify-between items-center mb-2">
                  <span className="text-[10px] font-black uppercase tracking-[0.15em] text-slate-400 font-display">
                    Email Address{" "}
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
                    type="text"
                    inputMode="email"
                    autoComplete="email"
                    spellCheck={false}
                    placeholder="you@company.com"
                    value={formData.workEmail}
                    onChange={handleChange}
                  />
                </div>
              </div>

              <div className="mb-8">
                <div className="flex justify-between items-center mb-2">
                  <span className="text-[10px] font-black uppercase tracking-[0.15em] text-slate-400 font-display">
                    Password <span className="text-[#D4642C] ml-[2px]">*</span>
                  </span>
                  <Link
                    href="/reset-password"
                    className="text-[10px] font-black text-[#D4642C] hover:text-[#BD5523] transition-colors uppercase tracking-widest"
                  >
                    Forgot?
                  </Link>
                </div>
                <div className="relative flex items-center bg-[#FAF6F2] border border-[#EFE8E1] rounded-xl overflow-hidden focus-within:border-[#D4642C] focus-within:ring-2 focus-within:ring-[#D4642C]/20 focus-within:bg-white shadow-xs transition-all duration-200">
                  <span className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 z-10 pointer-events-none">
                    <Lock size={16} />
                  </span>
                  <input
                    className="flex-1 bg-transparent border-none outline-none py-3.5 pl-11 text-[15px] font-semibold text-slate-800 placeholder:text-slate-400"
                    name="password"
                    type={showPassword ? "text" : "password"}
                    autoComplete="current-password"
                    placeholder="Enter your password"
                    value={formData.password}
                    onChange={handleChange}
                  />
                  <button
                    type="button"
                    className="px-4 text-slate-400 hover:text-slate-600 transition-colors"
                    onClick={() => setShowPassword(!showPassword)}
                  >
                    {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
                  </button>
                </div>
              </div>

              <UiloraBrandButton
                type="submit"
                disabled={loading}
                className="w-full py-4 text-sm normal-case tracking-normal mb-6 font-bold"
              >
                {loading ? (
                  <span className="flex items-center justify-center gap-2">
                    <span className="w-4 h-4 border-2 border-white/25 border-t-white rounded-full animate-spin flex-shrink-0" />{" "}
                    Signing in...
                  </span>
                ) : (
                  "Sign In"
                )}
              </UiloraBrandButton>
            </form>

            <div className="flex items-center gap-3 mb-6">
              <div className="flex-1 h-[1px] bg-slate-200" />
              <span className="text-[10px] font-black text-slate-400 uppercase tracking-[0.15em] whitespace-nowrap">
                or continue with
              </span>
              <div className="flex-1 h-[1px] bg-slate-200" />
            </div>

            <motion.button
              onClick={handleGoogleLogin}
              disabled={loading}
              whileHover={{ scale: loading ? 1 : 1.015 }}
              whileTap={{ scale: loading ? 1 : 0.985 }}
              className="w-full flex items-center justify-center gap-3 py-3.5 px-6 rounded-xl border border-[#EFE8E1] bg-white text-slate-700 font-sans text-sm font-bold hover:bg-[#FAF6F2] transition-all duration-300 relative overflow-hidden group mb-8 shadow-xs disabled:opacity-50"
            >
              <svg className="w-5 h-5 flex-shrink-0" viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path fill="#FFC107" d="M43.611,20.083H42V20H24v8h11.303c-1.649,4.657-6.08,8-11.303,8c-6.627,0-12-5.373-12-12c0-6.627,5.373-12,12-12c3.059,0,5.842,1.154,7.961,3.039l5.657-5.657C34.046,6.053,29.268,4,24,4C12.955,4,4,12.955,4,24c0,11.045,8.955,20,20,20c11.045,0,20-8.955,20-20C44,22.659,43.862,21.35,43.611,20.083z"/>
                <path fill="#FF3D00" d="M6.306,14.691l6.571,4.819C14.655,15.108,18.961,12,24,12c3.059,0,5.842,1.154,7.961,3.039l5.657-5.657C34.046,6.053,29.268,4,24,4C16.318,4,9.656,8.337,6.306,14.691z"/>
                <path fill="#4CAF50" d="M24,44c5.166,0,9.86-1.977,13.409-5.192l-6.19-5.238C29.211,35.091,26.715,36,24,36c-5.202,0-9.619-3.317-11.283-7.946l-6.522,5.025C9.505,39.556,16.227,44,24,44z"/>
                <path fill="#1976D2" d="M43.611,20.083H42V20H24v8h11.303c-0.792,2.237-2.231,4.166-4.087,5.571c0.001-0.001,0.002-0.001,0.003-0.002l6.19,5.238C36.971,39.205,44,34,44,24C44,22.659,43.862,21.35,43.611,20.083z"/>
              </svg>
              Continue with Google
            </motion.button>

            <div className="text-center text-[13px] font-medium text-slate-500">
              Don't have an account?
              <Link
                href={`/signup?role=${activeTab}`}
                className="font-bold text-[#D4642C] hover:text-[#BD5523] ml-1.5 transition-colors"
              >
                Sign up
              </Link>
            </div>
            
            <div className="mt-4 pt-4 border-t border-slate-100 text-center text-[13px] font-medium text-slate-500">
              New Employee?
              <Link
                href="/join-workspace"
                className="font-bold text-[#D4642C] hover:text-[#BD5523] ml-1.5 transition-colors"
              >
                Join Workspace
              </Link>
            </div>
          </div>
        </motion.div>
      </div>
    </div>
  );
}

export default function LoginPage() {
  return (
    <Suspense
      fallback={
        <div className="min-h-screen bg-[#FAF6F2] flex items-center justify-center">
          <div className="w-12 h-12 border-4 border-[#D4642C]/20 border-t-[#D4642C] rounded-full animate-spin" />
        </div>
      }
    >
      <LoginContent />
    </Suspense>
  );
}
