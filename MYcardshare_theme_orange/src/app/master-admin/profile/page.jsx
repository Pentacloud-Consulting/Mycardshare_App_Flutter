"use client";
import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { User, Lock, Mail, Shield, Clock, CheckCircle, Save, Loader2, Eye, EyeOff, X, AlertCircle } from "lucide-react";
import { useAuth } from "@/lib/auth-context";
import { authFetch, parseFetchJson } from "@/lib/api";

function Toast({ message, type, onClose }) {
  const [,] = useState(setTimeout(onClose, 4000));
  const color = type === "success" ? "#10b981" : "#ef4444";
  const Icon = type === "success" ? CheckCircle : AlertCircle;
  return (
    <motion.div initial={{ opacity: 0, y: -20 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -20 }}
      className="fixed top-20 right-6 z-[100] flex items-center gap-3 px-5 py-3.5 rounded-xl shadow-2xl bg-white border border-[#EAE2DB]">
      <Icon size={16} style={{ color }} /><span className="text-sm font-semibold" style={{ color }}>{message}</span>
    </motion.div>
  );
}

function ChangePasswordModal({ onClose, onSuccess }) {
  const [currentPassword, setCurrentPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [showCurrent, setShowCurrent] = useState(false);
  const [showNew, setShowNew] = useState(false);
  const [showConfirm, setShowConfirm] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState(null);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError(null);
    if (newPassword.length < 6) { setError("Password must be at least 6 characters"); return; }
    if (newPassword !== confirmPassword) { setError("Passwords do not match"); return; }
    setBusy(true);
    try {
      const res = await authFetch("/api/profile/change-password", {
        method: "POST", headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ currentPassword, newPassword }),
      });
      const data = await parseFetchJson(res);
      if (data.success) { onSuccess(); onClose(); }
      else { setError(typeof data.error === "string" ? data.error : data.error?.message || "Failed to change password"); }
    } catch (err) { setError(err?.message || "Network error"); }
    finally { setBusy(false); }
  };

  const inputCls = "w-full pl-4 pr-12 py-3 rounded-xl text-sm bg-[#FAF6F2] border border-[#EAE2DB] text-[#191919] placeholder:text-[#77716C] focus:outline-none focus:ring-2 focus:ring-[#D4622C]/30 focus:border-[#D4622C] transition-all shadow-inner";

  return (
    <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
      className="fixed inset-0 bg-stone-900/40 backdrop-blur-sm z-[60] flex items-center justify-center p-4" onClick={onClose}>
      <motion.div initial={{ scale: 0.9, opacity: 0 }} animate={{ scale: 1, opacity: 1 }} exit={{ scale: 0.9, opacity: 0 }}
        className="w-full max-w-md rounded-[2rem] p-8 shadow-2xl bg-white border border-[#EAE2DB]"
        onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center justify-between mb-8">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl flex items-center justify-center shadow-sm bg-[#FCE9DF] border border-[#F3C5AF]">
              <Lock size={18} className="text-[#D4622C]" />
            </div>
            <h3 className="text-lg font-black text-[#191919] tracking-tight">Change Password</h3>
          </div>
          <button onClick={onClose} className="p-2 text-[#77716C] hover:text-[#191919] hover:bg-[#FAF6F2] rounded-xl transition-all cursor-pointer"><X size={18} /></button>
        </div>

        {error && (
          <div className="flex items-center gap-2 p-3 mb-6 rounded-xl bg-red-500/10 border border-red-500/20 text-red-600 text-xs font-bold">
            <AlertCircle size={14} /> {error}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-5">
          <div>
            <label className="text-[9px] font-black uppercase tracking-[0.15em] text-[#77716C] block mb-2 ml-1">Current Password</label>
            <div className="relative">
              <input type={showCurrent ? "text" : "password"} value={currentPassword} onChange={(e) => setCurrentPassword(e.target.value)} className={inputCls} placeholder="Enter current password" required />
              <button type="button" onClick={() => setShowCurrent(!showCurrent)} className="absolute right-4 top-1/2 -translate-y-1/2 text-[#77716C] hover:text-[#191919] transition-colors cursor-pointer">
                {showCurrent ? <EyeOff size={16} /> : <Eye size={16} />}
              </button>
            </div>
          </div>
          <div>
            <label className="text-[9px] font-black uppercase tracking-[0.15em] text-[#77716C] block mb-2 ml-1">New Password</label>
            <div className="relative">
              <input type={showNew ? "text" : "password"} value={newPassword} onChange={(e) => setNewPassword(e.target.value)} className={inputCls} placeholder="Min 6 characters" required />
              <button type="button" onClick={() => setShowNew(!showNew)} className="absolute right-4 top-1/2 -translate-y-1/2 text-[#77716C] hover:text-[#191919] transition-colors cursor-pointer">
                {showNew ? <EyeOff size={16} /> : <Eye size={16} />}
              </button>
            </div>
          </div>
          <div>
            <label className="text-[9px] font-black uppercase tracking-[0.15em] text-[#77716C] block mb-2 ml-1">Confirm Password</label>
            <div className="relative">
              <input type={showConfirm ? "text" : "password"} value={confirmPassword} onChange={(e) => setConfirmPassword(e.target.value)} className={inputCls} placeholder="Re-enter new password" required />
              <button type="button" onClick={() => setShowConfirm(!showConfirm)} className="absolute right-4 top-1/2 -translate-y-1/2 text-[#77716C] hover:text-[#191919] transition-colors cursor-pointer">
                {showConfirm ? <EyeOff size={16} /> : <Eye size={16} />}
              </button>
            </div>
          </div>
          <div className="flex gap-3 pt-4">
            <button type="button" onClick={onClose} disabled={busy}
              className="flex-1 py-3.5 rounded-xl bg-white border border-[#EAE2DB] text-[#77716C] hover:text-[#191919] font-bold text-sm hover:bg-[#FAF6F2] transition-all disabled:opacity-50 shadow-sm cursor-pointer">Cancel</button>
            <button type="submit" disabled={busy}
              className="flex-1 py-3.5 rounded-xl bg-gradient-to-r from-[#D4622C] to-[#E3743E] hover:from-[#BF5321] hover:to-[#D4622C] text-white font-bold text-sm shadow-lg shadow-[#D4622C]/20 transition-all flex items-center justify-center gap-2 disabled:opacity-50 cursor-pointer">
              {busy ? <Loader2 size={14} className="animate-spin" /> : <Lock size={14} />} Update Password
            </button>
          </div>
        </form>
      </motion.div>
    </motion.div>
  );
}

export default function MasterProfilePage() {
  const { userData, refreshUserData } = useAuth();
  const [toast, setToast] = useState(null);
  const [saving, setSaving] = useState(false);
  const [displayName, setDisplayName] = useState(userData?.displayName || userData?.fullName || "Master Admin");
  const [showPasswordModal, setShowPasswordModal] = useState(false);

  const handleSave = async () => {
    setSaving(true);
    try {
      const res = await authFetch("/api/profile", {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ displayName }),
      });
      const data = await parseFetchJson(res);
      if (data.success) {
        setToast({ message: "Profile updated successfully", type: "success" });
        await refreshUserData?.();
      } else {
        setToast({ message: data.error || "Failed to update profile", type: "error" });
      }
    } catch (err) {
      setToast({ message: "Network error", type: "error" });
    } finally {
      setSaving(false);
    }
  };

  const createdAt = userData?.createdAt;
  const formattedDate = createdAt
    ? (typeof createdAt === "object" && createdAt.seconds
      ? new Date(createdAt.seconds * 1000).toLocaleDateString("en-US", { year: "numeric", month: "long", day: "numeric" })
      : new Date(createdAt).toLocaleDateString("en-US", { year: "numeric", month: "long", day: "numeric" }))
    : "—";

  return (
    <div className="space-y-6 sm:space-y-8 max-w-7xl mx-auto pb-12">
      <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4">
        <div>
          <h1 className="text-2xl sm:text-3xl font-black tracking-tight text-[#191919]">Profile</h1>
          <p className="text-xs sm:text-sm mt-1 text-[#77716C] font-medium">Master admin account details</p>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 sm:gap-8 items-start">
        {/* Left Column: Avatar & Identity */}
        <div className="lg:col-span-1">
          <motion.div initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} 
            className="rounded-[2rem] p-6 sm:p-10 flex flex-col items-center text-center relative overflow-hidden bg-white border border-[#EAE2DB] shadow-sm">
            <div className="absolute top-0 left-0 w-full h-32 pointer-events-none" 
              style={{ background: "linear-gradient(to bottom, rgba(212,98,44,0.06) 0%, transparent 100%)" }} />
            
            <div className="w-20 h-20 sm:w-28 sm:h-28 rounded-3xl flex items-center justify-center shrink-0 mb-6 relative z-10 shadow-sm bg-[#FAF6F2] border border-[#F3C5AF]">
              <span className="text-3xl sm:text-4xl font-black text-[#D4622C]">{(userData?.displayName || "A")[0]}</span>
            </div>
            
            <div className="relative z-10 w-full">
              <h2 className="text-xl sm:text-2xl font-black text-[#191919] mb-1 truncate tracking-tight">{userData?.displayName || "Master Admin"}</h2>
              <p className="text-[11px] sm:text-sm font-medium text-[#77716C] mb-6 truncate">{userData?.email || "admin@pentcloud.me"}</p>
              
              <span className="inline-flex items-center gap-2 text-[9px] font-black uppercase tracking-[0.2em] px-4 py-2 rounded-full bg-[#FCE9DF] text-[#D4622C] border border-[#F3C5AF] shadow-sm">
                <Shield size={12} /> Master Admin
              </span>
            </div>

            <div className="w-full mt-8 pt-8 border-t border-[#EAE2DB] text-left">
              <label className="text-[9px] font-black uppercase tracking-[0.15em] text-[#77716C] block mb-3 ml-1">Display Name</label>
              <input type="text" value={displayName} onChange={(e) => setDisplayName(e.target.value)}
                className="w-full px-4 py-3 rounded-xl text-sm bg-[#FAF6F2] border border-[#EAE2DB] text-[#191919] placeholder:text-[#77716C] focus:outline-none focus:ring-2 focus:ring-[#D4622C]/30 focus:border-[#D4622C] transition-all shadow-inner" />
            </div>
          </motion.div>
        </div>

        {/* Right Column: Account Details & Security */}
        <div className="lg:col-span-2 space-y-6 sm:space-y-8">
          {/* Account Details */}
          <motion.div initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 }} 
            className="rounded-[2rem] p-6 sm:p-8 bg-white border border-[#EAE2DB] shadow-sm">
            <h3 className="text-[10px] sm:text-xs font-black uppercase tracking-[0.2em] text-[#77716C] mb-6 sm:mb-8 flex items-center gap-3">
              <User size={16} className="text-[#D4622C]" /> Account Information
            </h3>
            
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              {[
                { icon: Mail, label: "Email Address", value: userData?.email || "admin@pentcloud.me" },
                { icon: Shield, label: "Role", value: "Platform Master Administrator" },
                { icon: CheckCircle, label: "Status", value: "Always Active", statusColor: "#10B981" },
                { icon: Clock, label: "Account Created", value: formattedDate },
              ].map((item) => (
                <div key={item.label} className="flex items-center gap-4 p-4 rounded-2xl bg-[#FAF6F2]/60 border border-[#EAE2DB] hover:bg-white transition-all cursor-default">
                  <div className="w-10 h-10 rounded-xl flex items-center justify-center shrink-0 bg-white border border-[#EAE2DB] shadow-sm">
                    <item.icon size={16} className="text-[#D4622C]" />
                  </div>
                  <div className="min-w-0">
                    <div className="text-[9px] font-black uppercase tracking-[0.15em] text-[#77716C] mb-1">{item.label}</div>
                    <div className="text-xs sm:text-sm font-bold text-[#191919] truncate" style={item.statusColor ? { color: item.statusColor } : undefined}>{item.value}</div>
                  </div>
                </div>
              ))}
            </div>
          </motion.div>

          {/* Security */}
          <motion.div initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.2 }} 
            className="rounded-[2rem] p-6 sm:p-8 bg-white border border-[#EAE2DB] shadow-sm">
            <h3 className="text-[10px] sm:text-xs font-black uppercase tracking-[0.2em] text-[#77716C] mb-6 sm:mb-8 flex items-center gap-3">
              <Shield size={16} className="text-[#D4622C]" /> Security
            </h3>
            
            <div className="p-5 rounded-2xl flex items-center justify-between gap-4 bg-[#FAF6F2]/60 border border-[#EAE2DB] shadow-sm">
              <div className="flex items-center gap-4">
                <div className="w-10 h-10 rounded-xl flex items-center justify-center bg-white border border-[#EAE2DB] shadow-sm">
                  <Lock size={16} className="text-[#D4622C]" />
                </div>
                <div>
                  <div className="text-sm font-bold text-[#191919]">Password</div>
                  <div className="text-[10px] text-[#77716C] font-black uppercase tracking-widest mt-1">Last changed: {(() => {
                    const val = userData?.passwordLastChanged;
                    if (!val) return "Never";
                    let d;
                    if (typeof val === "object" && (val._seconds || val.seconds)) {
                      d = new Date((val._seconds || val.seconds) * 1000);
                    } else if (typeof val === "number") {
                      d = new Date(val);
                    } else {
                      d = new Date(val);
                    }
                    return isNaN(d.getTime()) ? "Never" : d.toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" });
                  })()}</div>
                </div>
              </div>
              <button onClick={() => setShowPasswordModal(true)} className="px-5 py-2.5 rounded-xl text-[10px] font-black uppercase tracking-[0.15em] bg-[#FCE9DF] border border-[#F3C5AF] text-[#D4622C] hover:bg-[#D4622C] hover:text-white shadow-sm active:scale-95 transition-all shrink-0 cursor-pointer">Change</button>
            </div>
          </motion.div>

          {/* Save Button */}
          <div className="flex justify-center sm:justify-end pt-4">
            <button onClick={handleSave} disabled={saving}
              className="w-full sm:w-auto inline-flex items-center justify-center gap-2 px-10 py-4 rounded-xl bg-gradient-to-r from-[#D4622C] to-[#E3743E] hover:from-[#BF5321] hover:to-[#D4622C] text-white font-black text-[10px] uppercase tracking-[0.2em] shadow-lg shadow-[#D4622C]/25 hover:-translate-y-0.5 transition-all disabled:opacity-50 active:scale-95 cursor-pointer">
              {saving ? <Loader2 size={16} className="animate-spin" /> : <Save size={16} />} Save Profile</button>
          </div>
        </div>
      </div>

      <AnimatePresence>
        {toast && <Toast {...toast} onClose={() => setToast(null)} />}
        {showPasswordModal && (
          <ChangePasswordModal
            onClose={() => setShowPasswordModal(false)}
            onSuccess={() => { setToast({ message: "Password changed successfully", type: "success" }); refreshUserData?.(); }}
          />
        )}
      </AnimatePresence>
    </div>
  );
}