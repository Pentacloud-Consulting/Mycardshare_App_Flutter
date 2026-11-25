"use client";

import React, { useState, useEffect, Suspense, useCallback } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Link2, Building, AlertCircle, ArrowRight, Zap, CheckCircle2, KeyRound } from "lucide-react";
import Link from "next/link";
import { useSearchParams, useRouter } from "next/navigation";

function JoinWorkspaceContent() {
  const searchParams = useSearchParams();
  const router = useRouter();
  
  const [inviteUrl, setInviteUrl] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const [successData, setSuccessData] = useState(null);

  const extractParams = useCallback((input) => {
    const trimmed = (input || "").trim();
    if (!trimmed) return null;

    // Check if it's a full or partial URL
    try {
      const urlStr = trimmed.startsWith("http://") || trimmed.startsWith("https://") 
        ? trimmed 
        : (trimmed.includes("/") || trimmed.includes("?")) 
          ? `https://${trimmed}` 
          : null;

      if (urlStr) {
        const url = new URL(urlStr);
        const workspaceId = url.searchParams.get("workspaceId") || url.searchParams.get("enterpriseId");
        const code = url.searchParams.get("code") || url.searchParams.get("voucher") || url.searchParams.get("inviteCode");
        if (workspaceId || code) {
          return { workspaceId, code, voucher: code };
        }
      }
    } catch (_) {
      // Not a standard URL
    }
    
    // Check if it's query parameters like "enterpriseId=...&code=..."
    if (trimmed.includes("=") && (trimmed.includes("enterpriseId") || trimmed.includes("workspaceId") || trimmed.includes("code") || trimmed.includes("voucher"))) {
      const qs = trimmed.includes("?") ? trimmed.split("?")[1] : trimmed;
      const params = new URLSearchParams(qs);
      const workspaceId = params.get("workspaceId") || params.get("enterpriseId");
      const code = params.get("code") || params.get("voucher") || params.get("inviteCode");
      if (workspaceId || code) {
        return { workspaceId, code, voucher: code };
      }
    }

    // Direct standalone code entry: e.g. "83063542" or "ZUH608"
    return { rawCode: trimmed, code: trimmed, voucher: trimmed };
  }, []);

  const runVerification = useCallback(async (params) => {
    setLoading(true);
    setError("");

    try {
      const query = new URLSearchParams();
      if (params.workspaceId) query.set("workspaceId", params.workspaceId);
      if (params.code) query.set("code", params.code);
      if (params.voucher) query.set("voucher", params.voucher);
      if (params.rawCode) query.set("code", params.rawCode);

      const res = await fetch(`/api/invite/verify?${query.toString()}`);
      const json = await res.json();

      if (json.success && json.data?.valid) {
        const data = json.data;
        setSuccessData({
          workspaceId: data.workspaceId,
          companyName: data.companyName,
          voucher: data.voucherCode,
          inviteCode: data.inviteCode,
        });

        // Save session storage for signup and onboarding
        try {
          sessionStorage.setItem("dbc_employee_voucher", data.voucherCode || data.inviteCode || "");
          sessionStorage.setItem("dbc_employee_inviteCode", data.inviteCode || "");
          sessionStorage.setItem("dbc_employee_workspaceId", data.workspaceId || "");
          sessionStorage.setItem("dbc_employee_companyName", data.companyName || "");
          sessionStorage.setItem("dbc_employee_companySlug", data.companySlug || "");
        } catch (_) {}

        // Auto redirect to signup page carrying all parameters
        setTimeout(() => {
          const qs = new URLSearchParams({
            workspaceId: data.workspaceId,
            enterpriseId: data.workspaceId,
            voucher: data.voucherCode || data.inviteCode || "",
            code: data.inviteCode || "",
            role: "employee",
            companyName: data.companyName || "",
            companySlug: data.companySlug || "",
          });
          router.push(`/signup?${qs.toString()}`);
        }, 1200);
      } else {
        setError(json.error || "The invitation link or code is invalid or has expired.");
      }
    } catch (err) {
      console.error("[Join Workspace]", err);
      setError("Network error. Please try again.");
    } finally {
      setLoading(false);
    }
  }, [router]);

  // Auto-verify on direct arrival with search parameters
  useEffect(() => {
    const wid = searchParams.get("workspaceId") || searchParams.get("enterpriseId");
    const code = searchParams.get("code") || searchParams.get("voucher") || searchParams.get("inviteCode");

    if (wid || code) {
      const displayVal = wid && code 
        ? `${typeof window !== "undefined" ? window.location.origin : ""}/join-workspace?enterpriseId=${wid}&code=${code}`
        : (code || wid);
      setInviteUrl(displayVal);
      runVerification({ workspaceId: wid, code, voucher: code });
    }
  }, [searchParams, runVerification]);

  const handleVerify = (e) => {
    e.preventDefault();
    setError("");
    const input = inviteUrl.trim();
    
    if (!input) {
      setError("Please enter your invitation link or workspace invite code.");
      return;
    }

    const params = extractParams(input);
    if (!params) {
      setError("Please enter a valid link or invite code.");
      return;
    }

    runVerification(params);
  };

  return (
    <div className="w-full min-h-screen flex items-center justify-center bg-[#FAF6F2] overflow-hidden text-[#18181B] relative font-sans antialiased p-6">
      {/* Warm ambient glows */}
      <div className="absolute -top-[15%] -left-[10%] w-[60vw] h-[60vw] rounded-full bg-[radial-gradient(circle,rgba(212,100,44,0.1)_0%,transparent_70%)] pointer-events-none blur-[90px] -z-0" />
      <div className="absolute -bottom-[20%] -right-[10%] w-[50vw] h-[50vw] rounded-full bg-[radial-gradient(circle,rgba(245,158,11,0.06)_0%,transparent_70%)] pointer-events-none blur-[90px] -z-0" />

      <motion.div
        initial={{ opacity: 0, y: 30 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6 }}
        className="w-full max-w-[480px] relative z-10"
      >
        <div className="bg-white rounded-3xl p-8 lg:p-10 border border-[#EFE8E1] shadow-[0_20px_50px_rgba(212,100,44,0.06)] w-full transition-all">
          <div className="flex justify-center mb-8">
            <img src="/logo/image (4).png" alt="Logo" className="w-48 h-auto object-contain" />
          </div>

          {!successData ? (
            <>
              <h2 className="font-display text-2xl font-black tracking-tight text-[#18181B] text-center mb-2 leading-tight">
                Join your workspace
              </h2>
              <p className="text-[13px] text-[#78716C] text-center font-medium mb-8">
                Enter the invitation link, 8-digit invite code, or voucher code provided by your organization.
              </p>

              <AnimatePresence>
                {error && (
                  <motion.div
                    initial={{ opacity: 0, y: -8 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: -8 }}
                    className="flex items-center gap-2 bg-red-50 border border-red-200 rounded-2xl p-3 px-4 text-[13px] font-semibold text-red-600 mb-6"
                  >
                    <AlertCircle size={16} /> {error}
                  </motion.div>
                )}
              </AnimatePresence>

              <form onSubmit={handleVerify}>
                <div className="mb-6">
                  <div className="flex justify-between items-center mb-2">
                    <span className="text-[11px] font-bold uppercase tracking-[0.08em] text-[#78716C] font-display">
                      Invite Link or Code <span className="text-[#D4642C] ml-[2px]">*</span>
                    </span>
                  </div>
                  <div className="relative flex items-center bg-[#FAF6F2] border border-[#EFE8E1] rounded-2xl overflow-hidden focus-within:border-[#D4642C] focus-within:ring-2 focus-within:ring-[#D4642C]/10 transition-all duration-200">
                    <span className="pl-4 pr-3 text-[#A8A29E] transition-colors">
                      <KeyRound size={18} />
                    </span>
                    <input
                      className="flex-1 bg-transparent border-none outline-none py-3.5 pr-4 text-[14px] font-medium text-[#18181B] placeholder:text-[#A8A29E]"
                      name="inviteUrl"
                      type="text"
                      autoComplete="off"
                      spellCheck={false}
                      placeholder="e.g. 83063542, ZUH608, or full invite link"
                      value={inviteUrl}
                      onChange={(e) => setInviteUrl(e.target.value)}
                    />
                  </div>
                </div>

                <button
                  type="submit"
                  disabled={loading}
                  className="w-full py-4 rounded-full bg-[#D4642C] text-white text-sm font-bold shadow-[0_8px_20px_rgba(212,100,44,0.25)] hover:bg-[#B85323] transition-all flex items-center justify-center gap-2 cursor-pointer disabled:opacity-50 mb-6 active:scale-[0.99]"
                >
                  {loading ? (
                    <span className="flex items-center justify-center gap-2">
                      <span className="w-4 h-4 border-2 border-white/25 border-t-white rounded-full animate-spin flex-shrink-0" />{" "}
                      Verifying workspace...
                    </span>
                  ) : (
                    <span className="flex items-center justify-center gap-2">
                      Join Workspace <ArrowRight size={16} />
                    </span>
                  )}
                </button>
              </form>
            </>
          ) : (
            <motion.div 
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              className="text-center py-4"
            >
              <div className="w-16 h-16 rounded-full bg-[#FAF6F2] border border-[#EFE8E1] flex items-center justify-center mx-auto mb-6 shadow-sm">
                <CheckCircle2 size={32} className="text-[#D4642C]" />
              </div>
              <h3 className="text-xl font-black text-[#18181B] mb-2 font-display">Workspace Verified!</h3>
              <p className="text-[#78716C] text-sm mb-6">
                You are joining <span className="font-bold text-[#18181B]">{successData.companyName}</span>
              </p>
              
              <div className="flex justify-center items-center gap-2 text-[#D4642C] text-xs font-bold uppercase tracking-widest animate-pulse">
                <Zap size={14} /> Redirecting to employee signup...
              </div>
            </motion.div>
          )}

          <div className="mt-4 pt-6 border-t border-[#EFE8E1] text-center text-[13px] text-[#78716C] font-medium">
            <Link href="/login" className="hover:text-[#D4642C] transition-colors">
              Back to Login
            </Link>
          </div>
        </div>
      </motion.div>
    </div>
  );
}

export default function JoinWorkspacePage() {
  return (
    <Suspense fallback={<div className="min-h-screen bg-[#FAF6F2]" />}>
      <JoinWorkspaceContent />
    </Suspense>
  );
}
