"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  X,
  Lock,
  Loader2,
  AlertCircle,
  ShieldCheck,
  Eye,
  EyeOff,
} from "lucide-react";
import {
  EmailAuthProvider,
  reauthenticateWithCredential,
  updatePassword,
} from "firebase/auth";
import { auth } from "@/lib/firebase";

export default function ChangePasswordModal({ isVisible, onClose }) {
  const [currentPassword, setCurrentPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [showCurrentPassword, setShowCurrentPassword] = useState(false);
  const [showNewPassword, setShowNewPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState(false);

  const handleClose = () => {
    if (loading) return;
    setError("");
    setCurrentPassword("");
    setNewPassword("");
    setConfirmPassword("");
    setShowCurrentPassword(false);
    setShowNewPassword(false);
    setShowConfirmPassword(false);
    setSuccess(false);
    onClose();
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");

    if (!currentPassword || !newPassword || !confirmPassword) {
      setError("Please fill in all fields.");
      return;
    }

    if (newPassword !== confirmPassword) {
      setError("New passwords do not match.");
      return;
    }

    if (newPassword.length < 8) {
      setError("New password must be at least 8 characters.");
      return;
    }

    const user = auth.currentUser;
    if (!user) {
      setError("You must be logged in to change your password.");
      return;
    }

    setLoading(true);
    try {
      // 1. Re-authenticate user to ensure they have the right to change password
      const credential = EmailAuthProvider.credential(
        user.email,
        currentPassword,
      );
      await reauthenticateWithCredential(user, credential);

      // 2. Update the password
      await updatePassword(user, newPassword);

      setSuccess(true);
      setTimeout(() => {
        handleClose();
      }, 2000);
    } catch (err) {
      console.error(err);
      if (err.code === "auth/invalid-login-credentials") {
        setError("Invalid current password. Please try again.");
      } else if (err.code === "auth/invalid-credential") {
        setError("Invalid current password.");
      } else if (err.code === "auth/requires-recent-login") {
        setError("Please log out and log back in to perform this action.");
      } else {
        setError(err.message || "An error occurred while updating the password.");
      }
    } finally {
      if (!success) setLoading(false);
    }
  };

  return (
    <AnimatePresence>
      {isVisible && (
        <>
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={handleClose}
            className="fixed inset-0 bg-black/40 backdrop-blur-sm z-50"
          />
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4 overflow-y-auto pointer-events-none">
            <motion.div
              initial={{ opacity: 0, scale: 0.95, y: 20 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.95, y: 20 }}
              transition={{ type: "spring", stiffness: 300, damping: 25 }}
              className="w-full max-w-md pointer-events-auto"
            >
            <div className="bg-white border border-slate-200 rounded-3xl overflow-hidden shadow-xl relative">
              {/* Background styling elements */}
              <div className="absolute top-0 right-0 w-[300px] h-[300px] bg-sky-100/60 blur-[80px] pointer-events-none rounded-full" />

              <div className="p-8 relative z-10 text-center">
                <button
                  onClick={handleClose}
                  className="absolute top-6 right-6 text-slate-400 hover:text-slate-700 transition-colors"
                >
                  <X size={20} />
                </button>

                {!success ? (
                  <>
                    <div className="w-16 h-16 rounded-2xl bg-sky-50 border border-sky-200 flex flex-col items-center justify-center mx-auto mb-6 text-sky-500">
                      <Lock size={28} />
                    </div>

                    <h2
                      className="text-2xl font-black text-slate-800 mb-2 tracking-tight"
                      style={{ fontFamily: "var(--font-display)" }}
                    >
                      Change Password
                    </h2>
                    <p className="text-slate-500 text-sm mb-8">
                      Please enter your current password to authorize this change.
                    </p>

                    <form onSubmit={handleSubmit} className="space-y-4 text-left">
                      <div>
                        <label className="block text-[10px] font-bold uppercase tracking-[0.2em] text-slate-500 mb-2 ml-1">
                          Current Password
                        </label>
                        <div className="relative">
                          <input
                            type={showCurrentPassword ? "text" : "password"}
                            value={currentPassword}
                            onChange={(e) => setCurrentPassword(e.target.value)}
                            className="w-full bg-slate-50 border border-slate-200 rounded-2xl p-4 pl-12 pr-12 text-sm text-slate-800 placeholder:text-slate-400 focus:outline-none focus:border-sky-400 focus:ring-1 focus:ring-sky-400/50 transition-all"
                            placeholder="••••••••"
                          />
                          <Lock
                            size={18}
                            className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400"
                          />
                          <button
                            type="button"
                            onClick={() => setShowCurrentPassword(!showCurrentPassword)}
                            className="absolute right-4 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-700 transition-colors cursor-pointer"
                          >
                            {showCurrentPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                          </button>
                        </div>
                      </div>

                      <div className="w-full h-px bg-slate-100 my-6" />

                      <div>
                        <label className="block text-[10px] font-bold uppercase tracking-[0.2em] text-slate-500 mb-2 ml-1">
                          New Password
                        </label>
                        <div className="relative">
                          <input
                            type={showNewPassword ? "text" : "password"}
                            value={newPassword}
                            onChange={(e) => setNewPassword(e.target.value)}
                            className="w-full bg-slate-50 border border-slate-200 rounded-2xl p-4 pl-12 pr-12 text-sm text-slate-800 placeholder:text-slate-400 focus:outline-none focus:border-sky-400 focus:ring-1 focus:ring-sky-400/50 transition-all"
                            placeholder="Min. 8 characters"
                          />
                          <Lock
                            size={18}
                            className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400"
                          />
                          <button
                            type="button"
                            onClick={() => setShowNewPassword(!showNewPassword)}
                            className="absolute right-4 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-700 transition-colors cursor-pointer"
                          >
                            {showNewPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                          </button>
                        </div>
                      </div>

                      <div>
                        <label className="block text-[10px] font-bold uppercase tracking-[0.2em] text-slate-500 mb-2 ml-1">
                          Confirm New Password
                        </label>
                        <div className="relative">
                          <input
                            type={showConfirmPassword ? "text" : "password"}
                            value={confirmPassword}
                            onChange={(e) => setConfirmPassword(e.target.value)}
                            className="w-full bg-slate-50 border border-slate-200 rounded-2xl p-4 pl-12 pr-12 text-sm text-slate-800 placeholder:text-slate-400 focus:outline-none focus:border-sky-400 focus:ring-1 focus:ring-sky-400/50 transition-all"
                            placeholder="••••••••"
                          />
                          <Lock
                            size={18}
                            className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400"
                          />
                          <button
                            type="button"
                            onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                            className="absolute right-4 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-700 transition-colors cursor-pointer"
                          >
                            {showConfirmPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                          </button>
                        </div>
                      </div>

                      {error && (
                        <div className="flex items-center gap-2 p-3 rounded-xl bg-red-50 border border-red-200 text-red-600 text-xs mt-4">
                          <AlertCircle size={14} />
                          <span>{error}</span>
                        </div>
                      )}

                      <button
                        type="submit"
                        disabled={loading}
                        className="w-full mt-6 py-4 rounded-2xl bg-sky-500 font-black text-sm uppercase tracking-widest text-white hover:bg-sky-400 transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
                      >
                        {loading ? (
                          <>
                            <Loader2 size={18} className="animate-spin" />{" "}
                            Updating...
                          </>
                        ) : (
                          "Update Password"
                        )}
                      </button>
                    </form>
                  </>
                ) : (
                  <motion.div
                    initial={{ opacity: 0, scale: 0.9 }}
                    animate={{ opacity: 1, scale: 1 }}
                    className="py-8"
                  >
                    <div className="w-20 h-20 rounded-full bg-emerald-50 border border-emerald-200 flex flex-col items-center justify-center mx-auto mb-6 text-emerald-500">
                      <ShieldCheck size={40} />
                    </div>
                    <h2
                      className="text-2xl font-black text-slate-800 mb-2 tracking-tight"
                      style={{ fontFamily: "var(--font-display)" }}
                    >
                      Password Updated
                    </h2>
                    <p className="text-slate-500 text-sm">
                      Your security credentials have been successfully updated.
                    </p>
                  </motion.div>
                )}
              </div>
            </div>
            </motion.div>
          </div>
        </>
      )}
    </AnimatePresence>
  );
}
