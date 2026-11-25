"use client";

import { useState } from "react";
import Link from "next/link";
import { motion, AnimatePresence } from "framer-motion";
import {
  Mail,
  AlertCircle,
  Loader2,
  CheckCircle2,
  ArrowLeft,
} from "lucide-react";
import { sendPasswordResetEmail } from "firebase/auth";
import { auth } from "@/lib/firebase";
import AuthLayout from "@/components/AuthLayout";

/* ═══════════════════════════════════════════════════════════
   RESET PASSWORD — UILORA Form · Firebase Auth · Next.js
   ═══════════════════════════════════════════════════════════ */

export default function ResetPasswordPage() {
  const [email, setEmail] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const [sent, setSent] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
    setLoading(true);
    try {
      await sendPasswordResetEmail(auth, email);
      setSent(true);
    } catch (err) {
      const map = {
        "auth/user-not-found": "No account found with this email.",
        "auth/invalid-email": "Please enter a valid email address.",
        "auth/too-many-requests": "Too many attempts. Please wait.",
      };
      setError(map[err.code] || "Failed to send reset email.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <AuthLayout>
      {sent ? (
        /* ── Success State ─── */
        <motion.div
          initial={{ opacity: 0, scale: 0.95 }}
          animate={{ opacity: 1, scale: 1 }}
          className="text-center"
        >
          <div
            className="flex items-center justify-center w-16 h-16 rounded-full mx-auto mb-6 bg-[#FAF6F2] border border-[#EFE8E1]"
          >
            <CheckCircle2 size={28} className="text-[#D4642C]" />
          </div>
          <h2
            className="text-2xl font-black tracking-tight text-[#18181B] mb-2"
            style={{ fontFamily: "var(--font-display)" }}
          >
            Check Your Email
          </h2>
          <p
            className="text-sm mb-8 leading-relaxed text-[#78716C]"
          >
            We've sent a password reset link to{" "}
            <strong className="text-[#18181B]">{email}</strong>. Check your inbox
            and follow the instructions.
          </p>
          <Link
            href="/login"
            className="inline-flex items-center gap-2 text-sm font-bold text-[#D4642C] transition-colors hover:text-[#B85323]"
          >
            <ArrowLeft size={14} /> Back to sign in
          </Link>
        </motion.div>
      ) : (
        /* ── Form State ─── */
        <>
          <div
            className="flex items-center justify-center w-12 h-12 rounded-2xl mb-6 bg-[#FAF6F2] border border-[#EFE8E1]"
          >
            <Mail size={20} className="text-[#D4642C]" />
          </div>

          <h2
            className="text-2xl font-black tracking-tight text-[#18181B] mb-1"
            style={{ fontFamily: "var(--font-display)" }}
          >
            Reset Password
          </h2>
          <p className="text-sm mb-8 text-[#78716C]">
            Enter your email and we'll send you a reset link.
          </p>

          <AnimatePresence>
            {error && (
              <motion.div
                initial={{ opacity: 0, y: -8 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -8 }}
                className="flex items-center gap-2 px-4 py-3 rounded-xl mb-6 text-sm font-medium bg-red-50 border border-red-200 text-red-600"
              >
                <AlertCircle size={16} /> {error}
              </motion.div>
            )}
          </AnimatePresence>

          <form onSubmit={handleSubmit} className="space-y-5">
            <div>
              <label
                className="block text-xs font-bold uppercase tracking-[0.12em] mb-2 text-[#78716C]"
              >
                Email Address <span className="text-[#D4642C]">*</span>
              </label>
              <div className="relative flex items-center bg-[#FAF6F2] border border-[#EFE8E1] rounded-2xl p-1 focus-within:border-[#D4642C] focus-within:ring-2 focus-within:ring-[#D4642C]/10 transition-all">
                <span className="pl-4 pr-3 text-[#A8A29E] transition-colors">
                  <Mail size={18} />
                </span>
                <input
                  type="email"
                  placeholder="name@company.com"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                  autoComplete="email"
                  className="flex-1 bg-transparent border-none outline-none py-3 pr-4 text-[14px] font-medium text-[#18181B] placeholder:text-[#A8A29E]"
                />
              </div>
            </div>

            <motion.button
              type="submit"
              disabled={loading}
              whileHover={{ scale: loading ? 1 : 1.015 }}
              whileTap={{ scale: loading ? 1 : 0.985 }}
              className="w-full py-4 rounded-full bg-[#D4642C] text-white text-sm font-bold shadow-[0_8px_20px_rgba(212,100,44,0.25)] hover:bg-[#B85323] transition-all flex items-center justify-center gap-2 cursor-pointer disabled:opacity-50"
            >
              {loading ? (
                <>
                  <Loader2 size={16} className="animate-spin" /> Sending…
                </>
              ) : (
                "Send Reset Link"
              )}
            </motion.button>
          </form>

          <p
            className="text-center text-sm mt-8 text-[#78716C]"
          >
            Remember your password?{" "}
            <Link
              href="/login"
              className="font-bold text-[#D4642C] transition-colors hover:text-[#B85323]"
            >
              Sign in
            </Link>
          </p>
        </>
      )}
    </AuthLayout>
  );
}
