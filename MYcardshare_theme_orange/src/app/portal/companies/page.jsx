"use client";

import { useEffect, useMemo, useState } from "react";
import { motion } from "framer-motion";
import {
  Building2,
  Search,
  Loader2,
  AlertCircle,
  ShieldCheck,
  XCircle,
  Crown,
  Mail,
  RefreshCw,
} from "lucide-react";
import { useAuth } from "@/lib/auth-context";
import { authFetch, parseFetchJson, toUserMessage } from "@/lib/api";

/* ═══════════════════════════════════════════════════════════
   PLATFORM COMPANIES — Master admin registry (read)
   ═══════════════════════════════════════════════════════════ */

const STATUS_COLOR = {
  approved: { bg: "rgba(16,217,168,0.1)", border: "rgba(16,217,168,0.25)", text: "#10d9a8" },
  pending: { bg: "rgba(232,201,117,0.1)", border: "rgba(232,201,117,0.25)", text: "#e8c975" },
  rejected: { bg: "rgba(239,68,68,0.1)", border: "rgba(239,68,68,0.25)", text: "#ef4444" },
};

export default function PortalCompaniesPage() {
  const { userData, loading: authLoading } = useAuth();
  const [companies, setCompanies] = useState([]);
  const [query, setQuery] = useState("");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [busyId, setBusyId] = useState(null);

  const isMaster = userData?.role === "super_admin";

  const fetchData = async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await authFetch("/api/platform/companies");
      const data = await parseFetchJson(res);
      if (data.success) {
        setCompanies(data.data?.companies || []);
      } else {
        setError(toUserMessage(data.error, "Failed to load companies."));
      }
    } catch (err) {
      setError(err?.message || "Network error loading companies.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (!authLoading && isMaster) fetchData();
  }, [authLoading, isMaster]);

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    if (!q) return companies;
    return companies.filter((c) =>
      [c.companyName, c.superAdminEmail, c.companyId]
        .filter(Boolean)
        .some((x) => String(x).toLowerCase().includes(q)),
    );
  }, [companies, query]);

  const suspendCompany = async (companyId, currentlySuspended) => {
    setBusyId(companyId);
    try {
      const res = await authFetch(`/api/platform/companies/${companyId}/suspend`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ isSuspended: !currentlySuspended }),
      });
      const data = await parseFetchJson(res);
      if (data.success) {
        await fetchData();
      } else {
        alert(toUserMessage(data.error, "Failed to update company."));
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
          This console is reserved for platform master admins. If you believe this is in
          error, contact platform operations.
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
              Platform registry
            </span>
          </div>
          <h1 className="text-2xl font-black tracking-tight text-[#0F172A]" style={{ fontFamily: "var(--font-display)" }}>
            All Companies
          </h1>
          <p className="text-sm mt-1 text-white/40">
            {loading ? "Loading…" : `${companies.length} organizations on the network`}
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

      <div className="relative">
        <Search size={14} className="absolute left-4 top-1/2 -translate-y-1/2 text-white/30" />
        <input
          type="text"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Search companies, admins, IDs…"
          className="w-full md:w-[420px] pl-10 pr-4 py-2.5 rounded-xl text-sm bg-white/5 border border-white/10 text-white placeholder:text-white/20 focus:outline-none focus:ring-2 focus:ring-indigo-500/40"
        />
      </div>

      <div className="rounded-2xl overflow-hidden bg-white/[0.02] border border-white/5">
        <div className="hidden md:grid grid-cols-12 gap-4 px-6 py-3 text-[11px] font-bold uppercase tracking-[0.12em] text-white/20 bg-white/[0.01]">
          <div className="col-span-4">Company</div>
          <div className="col-span-4">Admin contact</div>
          <div className="col-span-2">Status</div>
          <div className="col-span-2 text-right">Actions</div>
        </div>

        {loading ? (
          <div className="py-20 flex items-center justify-center">
            <Loader2 className="animate-spin text-indigo-500" size={28} />
          </div>
        ) : filtered.length === 0 ? (
          <div className="py-20 flex flex-col items-center justify-center gap-2 text-white/30">
            <Building2 size={36} className="opacity-20" />
            <p className="text-xs font-bold uppercase tracking-widest">
              {companies.length === 0 ? "No companies yet" : "No matches"}
            </p>
          </div>
        ) : (
          filtered.map((c, i) => {
            const statusKey = (c.approvalStatus || "pending").toLowerCase();
            const sc = STATUS_COLOR[statusKey] || STATUS_COLOR.pending;
            return (
              <motion.div
                key={c.companyId}
                initial={{ opacity: 0, y: 6 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: i * 0.03 }}
                className="grid grid-cols-1 md:grid-cols-12 gap-4 px-6 py-4 items-center hover:bg-white/[0.02] transition-colors border-b border-white/[0.03]"
              >
                <div className="col-span-4 min-w-0">
                  <div className="text-sm font-semibold text-white truncate">
                    {c.companyName || "Unnamed company"}
                  </div>
                  <div className="text-[10px] text-white/30 font-mono truncate">{c.companyId}</div>
                </div>
                <div className="col-span-4 min-w-0">
                  <div className="text-xs text-white/60 truncate flex items-center gap-2">
                    <Mail size={12} className="shrink-0 text-white/30" />
                    {c.superAdminEmail || "—"}
                  </div>
                  <div className="text-[10px] text-white/30">
                    {c.superAdminPhoneNumber || ""}
                  </div>
                </div>
                <div className="col-span-2 flex items-center gap-2">
                  <span
                    className="px-2.5 py-1 rounded-lg text-[10px] font-bold uppercase tracking-widest"
                    style={{ background: sc.bg, border: `1px solid ${sc.border}`, color: sc.text }}
                  >
                    {statusKey}
                  </span>
                  {c.isSuspended && (
                    <span className="px-2.5 py-1 rounded-lg text-[10px] font-bold uppercase tracking-widest bg-red-500/10 border border-red-500/20 text-red-400">
                      Suspended
                    </span>
                  )}
                </div>
                <div className="col-span-2 text-right">
                  <button
                    onClick={() => suspendCompany(c.companyId, c.isSuspended)}
                    disabled={busyId === c.companyId}
                    className="inline-flex items-center gap-2 px-3 py-1.5 rounded-lg text-[10px] font-black uppercase tracking-widest bg-white/5 border border-white/10 text-white/70 hover:text-white disabled:opacity-50"
                  >
                    {busyId === c.companyId ? (
                      <Loader2 size={12} className="animate-spin" />
                    ) : c.isSuspended ? (
                      <ShieldCheck size={12} />
                    ) : (
                      <XCircle size={12} />
                    )}
                    {c.isSuspended ? "Reinstate" : "Suspend"}
                  </button>
                </div>
              </motion.div>
            );
          })
        )}
      </div>
    </div>
  );
}
