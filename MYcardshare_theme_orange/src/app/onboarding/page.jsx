"use client";

import { useState, useEffect, useRef, Suspense } from "react";
import { useSearchParams, useRouter } from "next/navigation";
import Link from "next/link";
import { useAuth } from "@/lib/auth-context";
import { motion, AnimatePresence } from "framer-motion";
import {
  Cloud,
  User,
  Briefcase,
  ShieldCheck,
  ArrowRight,
  CheckCircle2,
  Sparkles,
} from "lucide-react";
import IndividualOnboarding from "@/components/onboarding/IndividualOnboarding";
import EnterpriseOnboarding from "@/components/onboarding/EnterpriseOnboarding";

function OnboardingContent() {
  const searchParams = useSearchParams();
  const router = useRouter();
  const { user, userData, loading, refreshUserData } = useAuth();
  const didInferRole = useRef(false);

  const [role, setRole] = useState(() => {
    const q = searchParams.get("role");
    return q === "enterprise" || q === "employee" || q === "individual"
      ? q
      : "individual";
  });
  const [isCompleted, setIsCompleted] = useState(false);

  const onboardingModeLabel =
    role === "enterprise"
      ? "Corporate organization provisioning"
      : role === "employee"
        ? "Employee profile — company voucher next"
        : "Professional identity creation";

  // Keep flow aligned with URL or stored session context when user lands from signup
  useEffect(() => {
    const q = searchParams.get("role");
    if (q === "enterprise" || q === "employee" || q === "individual") {
      setRole(q);
      return;
    }

    try {
      const raw = sessionStorage.getItem("dbc_signup_context");
      if (raw) {
        const parsed = JSON.parse(raw);
        if (parsed?.role === "enterprise") {
          setRole("enterprise");
          return;
        }
      }
    } catch (_) {}

    if (userData) {
      const uRole = (userData.role || userData.accountType || "").toLowerCase();
      if (uRole.includes("enterprise") || uRole.includes("admin")) {
        setRole("enterprise");
      } else if (uRole === "employee") {
        setRole("employee");
      }
    }
  }, [searchParams, userData]);

  useEffect(() => {
    if (loading) return;
    if (!user) {
      router.replace("/login");
    }
  }, [loading, user, router]);

  if (loading) {
    return (
      <div className="min-h-screen bg-[#F8F4EF] flex items-center justify-center p-6">
        <div className="flex flex-col items-center gap-4">
          <div className="w-16 h-16 border-4 border-[#D4642C]/20 border-t-[#D4642C] rounded-full animate-spin" />
          <p className="text-[#77716C] font-bold text-xs uppercase tracking-widest animate-pulse">
            Configuring Studio...
          </p>
        </div>
      </div>
    );
  }

  if (user && !userData) {
    return (
      <div className="min-h-screen bg-[#F8F4EF] flex items-center justify-center p-6">
        <div className="max-w-md text-center space-y-6 bg-white p-8 rounded-3xl border border-[#EAE4DE] shadow-[0_10px_30px_rgba(28,25,23,0.05)]">
          <p className="text-[#1C1917] font-medium">
            We couldn&apos;t load your profile from the server. Check your connection
            or try again.
          </p>
          <button
            type="button"
            onClick={() => refreshUserData()}
            className="py-3 px-8 rounded-full bg-[#D4642C] text-white font-bold text-sm uppercase tracking-widest hover:bg-[#B85323] transition-all shadow-[0_8px_20px_rgba(212,100,44,0.25)]"
          >
            Retry
          </button>
          <button
            type="button"
            onClick={() => router.push("/login")}
            className="block w-full text-[#77716C] text-sm hover:text-[#1C1917] transition-colors"
          >
            Back to sign in
          </button>
        </div>
      </div>
    );
  }

  if (isCompleted) {
    return (
      <div className="min-h-screen bg-[#F8F4EF] flex items-center justify-center p-6 overflow-hidden relative">
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_50%_50%,rgba(212,100,44,0.1),transparent_70%)]" />
        <motion.div
          initial={{ opacity: 0, scale: 0.9, y: 20 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          className="relative z-10 text-center max-w-md bg-white p-10 rounded-3xl border border-[#EAE4DE] shadow-[0_20px_50px_rgba(28,25,23,0.08)]"
        >
          <div className="w-24 h-24 rounded-3xl bg-[#FAF6F2] border border-[#EAE4DE] flex items-center justify-center mx-auto mb-8 shadow-sm">
            <CheckCircle2 size={48} className="text-[#D4642C]" />
          </div>
          <h1 className="text-3xl sm:text-4xl font-black text-[#1C1917] mb-4 tracking-tight" style={{ fontFamily: "var(--font-display)" }}>
            Card Published!
          </h1>
          <p className="text-[#77716C] font-medium mb-10 leading-relaxed text-sm">
            Your premium digital identity has been activated and provisioned on the network.
          </p>
          <button
            onClick={() => router.push("/portal")}
            className="w-full py-4 px-8 rounded-full bg-[#D4642C] text-white font-black text-sm uppercase tracking-widest hover:bg-[#B85323] transition-all shadow-[0_8px_20px_rgba(212,100,44,0.25)] flex items-center justify-center gap-3 cursor-pointer"
          >
            Launch Card Console <ArrowRight size={18} />
          </button>
        </motion.div>
      </div>
    );
  }

  return (
    <div className="min-h-screen lg:h-screen lg:overflow-hidden bg-[#F8F4EF] text-[#191919] selection:bg-[#D4622C]/20 selection:text-[#191919] relative flex flex-col">
      {/* Spacious Premium Header with MyCardShare logo */}
      <header className="w-full max-w-[1450px] mx-auto px-4 sm:px-6 lg:px-8 py-6 sm:py-7 lg:py-8 flex items-center justify-between shrink-0 z-20">
        <Link href="/" className="inline-flex items-center select-none">
          <img
            src="/logo/mycardshare-logo-tight.png"
            alt="MyCardShare Logo"
            className="h-[38px] sm:h-[42px] w-auto object-contain drop-shadow-2xs"
          />
        </Link>
      </header>

      {/* Main Workspace */}
      <main className="flex-1 w-full lg:overflow-hidden relative z-10 flex flex-col min-h-0">
        {role === "enterprise" ? (
          <div className="max-w-4xl mx-auto w-full p-6 overflow-y-auto">
            <EnterpriseOnboarding
              userData={userData}
              user={user}
              onComplete={async () => {
                await refreshUserData();
                setIsCompleted(true);
              }}
            />
          </div>
        ) : (
          <IndividualOnboarding
            isEmployee={role === "employee"}
            userData={userData}
            user={user}
            onComplete={async () => {
              setIsCompleted(true);
              refreshUserData().catch((err) =>
                console.error("Post-onboarding refresh failed:", err)
              );
            }}
          />
        )}
      </main>
    </div>
  );
}

export default function OnboardingPage() {
  return (
    <Suspense
      fallback={
        <div className="min-h-screen bg-[#FAF6F2] flex items-center justify-center p-6">
          <div className="flex flex-col items-center gap-4">
            <div className="w-16 h-16 border-4 border-[#D4642C]/20 border-t-[#D4642C] rounded-full animate-spin" />
          </div>
        </div>
      }
    >
      <OnboardingContent />
    </Suspense>
  );
}
