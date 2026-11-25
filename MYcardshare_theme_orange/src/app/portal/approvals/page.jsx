"use client";

import { useEffect, useState } from "react";
import { motion } from "framer-motion";
import {
  ShieldCheck,
  Loader2,
  AlertCircle,
  Check,
  X,
  Crown,
  Mail,
  Building2,
  RefreshCw,
} from "lucide-react";
import { useAuth } from "@/lib/auth-context";
import { authFetch, parseFetchJson, toUserMessage } from "@/lib/api";

export default function PortalApprovalsPage() {
  const { userData, loading: authLoading } = useAuth();
  const [pending, setPending] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [busyId, setBusyId] = useState(null);

  const isMaster = userData?.role === "super_admin";

  const fetchData = async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await authFetch("/api/platform/companies/pending");
      const data = await parseFetchJson(res);
      if (data.success) {
        setPending(data.data?.companies || []);
      } else {
        setError(toUserMessage(data.error, "Failed to load pending approvals."));
      }
    } catch (err) {
      setError(err?.message || "Network error.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (!authLoading && isMaster) fetchData();
  }, [authLoading, isMaster]);

  const handleAction = async (companyId, action) => {
    setBusyId(companyId);
    try {
      const res = await authFetch(`/api/platform/companies/${companyId}/approval`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ action }),
      });
      const data = await parseFetchJson(res);
      if (data.success) {
        setPending((prev) => prev.filter((c) => c.companyId !== companyId));
      } else {
        alert(toUserMessage(data.error, "Action failed."));
      }
    } catch (err) {
      alert(err?.message || "Network error.");
    } finally {
      setBusyId(null);
    }
  };

  if (authLoading) {
    return (
      <div className="min-h-[400px] flex items-center justify-center">
        <Loader2 className="animate-spin text-indigo-500" size={28} />
      </div>
    );
  }

  if (!isMaster) {
    return (
      <div className="min-h-[400px] flex flex-col items-center justify-center gap-4">
        <ShieldCheck size={36} className="text-white/20" />
        <h2 className="text-white font-bold text-lg">Master admin access required</h2>
        <p className="text-slate-500 text-sm text-center max-w-md">
          Approvals are reserved for platform master admins.
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <Crown size={18} style={{ color: "#e8c975" }} />
            <span className="text-xs font-bold uppercase tracking-[0.15em]" style={{ color: "#e8c975" }}>
              Approval queue
            </span>
          </div>
          <h1 className="text-2xl font-black tracking-tight text-[#0F172A]" style={{ fontFamily: "var(--font-display)" }}>
            Pending Companies
          </h1>
          <p className="text-sm mt-1 text-white/40">
            {loading ? "Loading…" : `${pending.length} awaiting review`}
          </p>
        </div>
        <button
          onClick={fetchData}
          className="p-2.5 rounded-xl bg-white/5 border border-white/10 text-white/60 hover:text-white transition-colors w-fit"
          title="Refresh"
        >
          <RefreshCw size={16} />
        </button>
      </div>

      {error && (
        <div className="flex items-start gap-3 rounded-2xl bg-red-500/10 border border-red-500/20 p-4 text-red-400">
          <AlertCircle size={18} className="mt-0.5 shrink-0" />
          <p className="text-xs font-bold uppercase tracking-widest leading-relaxed">{error}</p>
        </div>
      )}

      {loading ? (
        <div className="py-20 flex items-center justify-center">
          <Loader2 className="animate-spin text-indigo-500" size={28} />
        </div>
      ) : pending.length === 0 ? (
        <div className="py-20 flex flex-col items-center justify-center gap-3 rounded-2xl bg-white/[0.02] border border-white/5 text-white/30">
          <ShieldCheck size={40} className="opacity-20" />
          <p className="text-xs font-bold uppercase tracking-widest">Queue clear — nothing to review.</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {pending.map((c, i) => (
            <motion.div
              key={c.companyId}
              initial={{ opacity: 0, y: 6 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: i * 0.04 }}
              className="rounded-2xl p-6 bg-white/[0.02] border border-white/5 hover:border-amber-400/30 transition-all"
            >
              <div className="flex items-start gap-4">
                <div className="w-12 h-12 rounded-xl flex items-center justify-center shrink-0 bg-amber-400/15 border border-amber-400/30">
                  <Building2 size={20} className="text-amber-300" />
                </div>
                <div className="min-w-0 flex-1">
                  <div className="text-base font-bold text-white truncate">
                    {c.companyName || "Unnamed company"}
                  </div>
                  <div className="text-[10px] text-white/30 font-mono truncate mb-2">
                    {c.companyId}
                  </div>
                  <div className="text-xs text-white/50 flex items-center gap-2 truncate">
                    <Mail size={12} className="shrink-0 text-white/30" />
                    {c.superAdminEmail || "—"}
                  </div>
                </div>
              </div>
              <div className="flex gap-3 mt-5">
                <button
                  onClick={() => handleAction(c.companyId, "approve")}
                  disabled={busyId === c.companyId}
                  className="flex-1 py-2.5 rounded-xl bg-emerald-500/15 border border-emerald-500/30 text-emerald-400 font-black text-[11px] uppercase tracking-[0.15em] hover:bg-emerald-500/25 transition-colors flex items-center justify-center gap-2 disabled:opacity-50"
                >
                  {busyId === c.companyId ? (
                    <Loader2 size={14} className="animate-spin" />
                  ) : (
                    <Check size={14} />
                  )}
                  Approve
                </button>
                <button
                  onClick={() => handleAction(c.companyId, "reject")}
                  disabled={busyId === c.companyId}
                  className="flex-1 py-2.5 rounded-xl bg-red-500/10 border border-red-500/25 text-red-400 font-black text-[11px] uppercase tracking-[0.15em] hover:bg-red-500/20 transition-colors flex items-center justify-center gap-2 disabled:opacity-50"
                >
                  <X size={14} />
                  Reject
                </button>
              </div>
            </motion.div>
          ))}
        </div>
      )}
    </div>
  );
}
