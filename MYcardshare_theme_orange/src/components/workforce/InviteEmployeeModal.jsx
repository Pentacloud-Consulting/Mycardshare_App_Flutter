"use client";

import { useEffect, useMemo, useState } from "react";
import { AnimatePresence, motion } from "framer-motion";
import {
  X,
  Mail,
  Copy,
  CheckCircle2,
  Ticket,
  Link as LinkIcon,
  Loader2,
  AlertCircle,
  Send,
} from "lucide-react";
import { authFetch, parseFetchJson, toUserMessage } from "@/lib/api";
import { getSignupUrl, getWorkspaceJoinUrl } from "@/lib/urls";

/**
 * InviteEmployeeModal
 * Shares the company voucher + 8-digit invite code + universal join link to signup, and optionally records
 * an invitation row in Firestore (and triggers email transport if configured).
 */
export default function InviteEmployeeModal({
  open,
  onClose,
  companyId,
  voucherCode,
  companyName,
  inviteCode,
}) {
  const [email, setEmail] = useState("");
  const [sending, setSending] = useState(false);
  const [sentTo, setSentTo] = useState(null);
  const [error, setError] = useState(null);
  const [copiedKey, setCopiedKey] = useState(null);

  const universalJoinUrl = useMemo(
    () => getWorkspaceJoinUrl(companyId, inviteCode, voucherCode),
    [companyId, inviteCode, voucherCode]
  );

  useEffect(() => {
    if (!open) {
      setEmail("");
      setSending(false);
      setSentTo(null);
      setError(null);
      setCopiedKey(null);
    }
  }, [open]);

  const copy = async (text, key) => {
    try {
      await navigator.clipboard.writeText(text);
      setCopiedKey(key);
      setTimeout(() => setCopiedKey(null), 1500);
    } catch (_) {
      setError("Couldn't copy to clipboard in this browser.");
    }
  };

  const handleSend = async () => {
    const clean = email.trim().toLowerCase();
    if (!clean || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(clean)) {
      setError("Enter a valid work email.");
      return;
    }
    if (!companyId) {
      setError("Company isn't ready yet. Try refreshing.");
      return;
    }
    setSending(true);
    setError(null);
    try {
      const res = await authFetch(`/api/company/${companyId}/invite`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email: clean }),
      });
      const data = await parseFetchJson(res);
      if (data.success) {
        setSentTo(clean);
        setEmail("");
      } else {
        setError(toUserMessage(data.error, "Failed to record invitation."));
      }
    } catch (err) {
      setError(err?.message || "Network error sending invitation.");
    } finally {
      setSending(false);
    }
  };

  return (
    <AnimatePresence>
      {open && (
        <>
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
            className="fixed inset-0 bg-black/70 backdrop-blur-sm z-[60]"
          />
          <motion.div
            initial={{ opacity: 0, y: 20, scale: 0.98 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: 10, scale: 0.98 }}
            transition={{ type: "spring", damping: 28, stiffness: 260 }}
            className="fixed inset-0 z-[61] flex items-center justify-center p-4"
          >
            <div className="w-full max-w-lg rounded-[2rem] bg-[#0d1424] border border-white/10 shadow-2xl overflow-hidden">
              <div className="flex items-center justify-between px-6 py-5 border-b border-white/5">
                <div>
                  <div className="text-[10px] font-black uppercase tracking-[0.2em] text-sky-400">
                    Invite teammate
                  </div>
                  <h3 className="text-lg font-bold text-white mt-1">
                    Onboard to {companyName || "your organization"}
                  </h3>
                </div>
                <button
                  onClick={onClose}
                  className="p-2 rounded-lg bg-white/5 border border-white/10 text-white/60 hover:text-white transition-colors"
                >
                  <X size={16} />
                </button>
              </div>

              <div className="p-6 space-y-5">
                {/* Workspace Invite Code (App & Web) */}
                <div className="rounded-2xl p-5 bg-amber-500/10 border border-amber-500/20">
                  <div className="flex items-center justify-between text-[10px] font-black uppercase tracking-[0.2em] text-amber-400 mb-2">
                    <span className="flex items-center gap-1.5"><Ticket size={12} /> Workspace Invite Code</span>
                    <span className="px-1.5 py-0.5 rounded bg-amber-400/20 text-amber-300 text-[9px] font-bold">App & Web</span>
                  </div>
                  <div className="flex items-center justify-between gap-3">
                    <div className="font-mono text-2xl font-black text-white tracking-[0.2em]">
                      {inviteCode || voucherCode || "—"}
                    </div>
                    <button
                      disabled={!inviteCode && !voucherCode}
                      onClick={() => copy(inviteCode || voucherCode || "", "inviteCode")}
                      className="px-3 py-2 rounded-lg bg-white/5 border border-white/10 text-white/70 hover:text-white hover:bg-white/10 transition-colors text-xs font-bold flex items-center gap-1.5 disabled:opacity-50"
                    >
                      {copiedKey === "inviteCode" ? (
                        <>
                          <CheckCircle2 size={12} className="text-emerald-400" /> Copied
                        </>
                      ) : (
                        <>
                          <Copy size={12} /> Copy
                        </>
                      )}
                    </button>
                  </div>
                  <p className="text-[11px] text-white/50 mt-2 leading-relaxed">
                    Share this 8-digit invite code with team members to let them join your organization workspace directly from the mobile app or web portal.
                  </p>
                </div>

                {/* Master Voucher Code */}
                {voucherCode && (
                  <div className="rounded-2xl p-4 bg-emerald-500/5 border border-emerald-500/20 flex items-center justify-between">
                    <div>
                      <div className="text-[10px] font-black uppercase tracking-[0.2em] text-emerald-400 mb-0.5">
                        Master Voucher Code
                      </div>
                      <div className="font-mono text-lg font-black text-white tracking-widest">
                        {voucherCode}
                      </div>
                    </div>
                    <button
                      onClick={() => copy(voucherCode, "voucher")}
                      className="px-3 py-2 rounded-lg bg-white/5 border border-white/10 text-white/70 hover:text-white hover:bg-white/10 transition-colors text-xs font-bold flex items-center gap-1.5"
                    >
                      {copiedKey === "voucher" ? (
                        <>
                          <CheckCircle2 size={12} className="text-emerald-400" /> Copied
                        </>
                      ) : (
                        <>
                          <Copy size={12} /> Copy
                        </>
                      )}
                    </button>
                  </div>
                )}

                {/* Universal Join link */}
                <div className="rounded-2xl p-5 bg-white/[0.02] border border-white/5">
                  <div className="flex items-center gap-2 text-[10px] font-black uppercase tracking-[0.2em] text-white/50 mb-3">
                    <LinkIcon size={12} /> Universal Join Link
                  </div>
                  <div className="flex items-center justify-between gap-3">
                    <code className="text-xs text-white/70 truncate flex-1 font-mono">
                      {universalJoinUrl}
                    </code>
                    <button
                      onClick={() => copy(universalJoinUrl, "link")}
                      className="px-3 py-2 rounded-lg bg-white/5 border border-white/10 text-white/70 hover:text-white hover:bg-white/10 transition-colors text-xs font-bold flex items-center gap-1.5"
                    >
                      {copiedKey === "link" ? (
                        <>
                          <CheckCircle2 size={12} className="text-emerald-400" /> Copied
                        </>
                      ) : (
                        <>
                          <Copy size={12} /> Copy
                        </>
                      )}
                    </button>
                  </div>
                </div>

                {/* Email invite */}
                <div className="rounded-2xl p-5 bg-white/[0.02] border border-white/5 space-y-3">
                  <div className="flex items-center gap-2 text-[10px] font-black uppercase tracking-[0.2em] text-white/50">
                    <Mail size={12} /> Send invitation email
                  </div>
                  <div className="flex gap-2">
                    <input
                      type="email"
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      placeholder="teammate@company.com"
                      className="flex-1 px-4 py-2.5 rounded-xl bg-white/5 border border-white/10 text-white text-sm placeholder:text-white/20 focus:outline-none focus:ring-2 focus:ring-sky-500/40"
                      onKeyDown={(e) => e.key === "Enter" && handleSend()}
                    />
                    <button
                      onClick={handleSend}
                      disabled={sending || !email.trim()}
                      className="px-4 py-2.5 rounded-xl bg-sky-500 text-white font-bold text-xs uppercase tracking-widest hover:bg-sky-400 transition-colors disabled:opacity-50 flex items-center gap-2"
                    >
                      {sending ? (
                        <Loader2 size={14} className="animate-spin" />
                      ) : (
                        <Send size={14} />
                      )}
                      Send
                    </button>
                  </div>
                  {sentTo && (
                    <div className="flex items-center gap-2 text-[11px] font-bold text-emerald-400">
                      <CheckCircle2 size={12} /> Invitation recorded for {sentTo}.
                    </div>
                  )}
                  <p className="text-[10px] text-white/30 leading-relaxed">
                    Invitations are saved to your company record. Email delivery requires an email provider to be configured on the server; in the meantime, share the voucher or link above.
                  </p>
                </div>

                {error && (
                  <div className="flex items-start gap-2 rounded-xl bg-red-500/10 border border-red-500/20 p-3 text-red-400">
                    <AlertCircle size={14} className="mt-0.5 shrink-0" />
                    <p className="text-xs font-bold leading-relaxed">{error}</p>
                  </div>
                )}
              </div>

              <div className="px-6 py-4 border-t border-white/5 flex items-center justify-end gap-3">
                <button
                  onClick={onClose}
                  className="px-4 py-2 rounded-lg text-xs font-bold uppercase tracking-widest text-white/60 hover:text-white"
                >
                  Done
                </button>
              </div>
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
}
