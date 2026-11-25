"use client";
import { useEffect, useState, useMemo } from "react";
import { motion } from "framer-motion";
import { ShieldCheck, Check, X, Loader2, Search, AlertCircle, RefreshCw, Clock } from "lucide-react";
import { authFetch, parseFetchJson, toUserMessage } from "@/lib/api";

export default function MasterApprovalPage() {
  const [companies, setCompanies] = useState([]);
  const [query, setQuery] = useState("");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [busyId, setBusyId] = useState(null);

  const fetchData = async () => {
    setLoading(true); setError(null);
    try {
      const res = await authFetch("/api/platform/companies");
      const data = await parseFetchJson(res);
      if (data.success) setCompanies(data.data?.companies || []);
      else setError(toUserMessage(data.error, "Failed to load."));
    } catch (err) { setError(err?.message || "Network error."); } finally { setLoading(false); }
  };

  useEffect(() => { fetchData(); }, []);

  const pending = useMemo(() => {
    const q = query.trim().toLowerCase();
    const list = companies.filter(c => (c.approvalStatus || "pending").toLowerCase() === "pending");
    if (!q) return list;
    return list.filter(c => [c.companyName, c.superAdminEmail].filter(Boolean).some(x => String(x).toLowerCase().includes(q)));
  }, [companies, query]);

  const handleAction = async (companyId, action) => {
    setBusyId(companyId);
    try {
      const res = await authFetch(`/api/platform/companies/${companyId}/approval`, {
        method: "PATCH", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ action })
      });
      const data = await parseFetchJson(res);
      if (data.success) await fetchData();
      else alert(toUserMessage(data.error, `Failed to ${action}.`));
    } catch (err) { alert(err?.message || "Network error."); } finally { setBusyId(null); }
  };

  return (
    <div className="space-y-6 sm:space-y-8 pb-12 max-w-[1400px]">
      <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4">
        <div>
          <h1 className="text-2xl sm:text-3xl font-black tracking-tight text-[#191919]">Approvals</h1>
          <p className="text-xs sm:text-sm mt-1 text-[#77716C] font-medium">{loading ? "Loading…" : `${pending.length} pending approval${pending.length !== 1 ? "s" : ""}`}</p>
        </div>
        <button onClick={fetchData} className="p-2.5 rounded-xl bg-white border border-[#EAE2DB] shadow-2xs text-[#77716C] hover:text-[#D4622C] hover:bg-[#FCE9DF]/50 hover:border-[#D4622C]/30 transition-all w-fit cursor-pointer"><RefreshCw size={16} /></button>
      </div>

      {error && (<div className="flex items-start gap-3 rounded-2xl bg-rose-50 border border-rose-200 shadow-2xs p-4 text-rose-600">
        <AlertCircle size={18} className="mt-0.5 shrink-0" /><p className="text-xs font-bold uppercase tracking-widest">{error}</p></div>)}

      <div className="relative"><Search size={16} className="absolute left-4 top-1/2 -translate-y-1/2 text-[#77716C]" />
        <input type="text" value={query} onChange={(e) => setQuery(e.target.value)} placeholder="Search pending companies…"
          className="w-full md:w-[420px] pl-11 pr-4 py-3 rounded-2xl text-sm bg-white border border-[#EAE2DB] shadow-2xs text-[#191919] placeholder:text-[#77716C]/60 focus:outline-none focus:border-[#D4622C] focus:ring-2 focus:ring-[#D4622C]/20 transition-all" /></div>

      <div className="rounded-3xl overflow-hidden bg-white border border-[#EAE2DB] shadow-xs">
        {loading ? (<div className="py-24 flex items-center justify-center"><Loader2 className="animate-spin text-[#D4622C]" size={32} /></div>
        ) : pending.length === 0 ? (
          <div className="py-24 flex flex-col items-center justify-center gap-3 text-[#77716C]">
            <ShieldCheck size={40} className="text-[#D4622C]/40" />
            <p className="text-[11px] font-bold uppercase tracking-[0.2em] text-[#191919]">No pending approvals</p>
            <p className="text-[11px] font-medium text-[#77716C]">All enterprise registrations have been reviewed</p>
          </div>
        ) : (pending.map((c, i) => (
          <motion.div key={c.companyId} initial={{ opacity: 0, y: 6 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.04 }}
            className="flex flex-col md:flex-row md:items-center justify-between gap-4 px-4 sm:px-6 py-5 border-b border-[#EAE2DB]/60 hover:bg-[#FAF6F2] transition-colors group">
            <div className="flex items-center gap-4 min-w-0">
              <div className="w-10 h-10 sm:w-12 sm:h-12 rounded-2xl flex items-center justify-center shrink-0 shadow-2xs bg-[#FEF3C7] border border-[#FDE68A]">
                <Clock size={16} className="text-[#D97706]" /></div>
              <div className="min-w-0">
                <div className="text-sm font-black tracking-tight text-[#191919] truncate group-hover:text-[#D4622C] transition-colors">{c.companyName || "Unnamed Company"}</div>
                <div className="text-[10px] sm:text-xs font-medium text-[#77716C] truncate mt-0.5">{c.superAdminEmail || "No email"}</div>
              </div>
            </div>
            <div className="flex items-center gap-2 pt-1 md:pt-0">
              <button onClick={() => handleAction(c.companyId, "approve")} disabled={busyId === c.companyId}
                className="flex-1 md:flex-initial inline-flex items-center justify-center gap-2 px-4 py-2 rounded-xl text-[10px] sm:text-[11px] font-black uppercase tracking-[0.15em] bg-emerald-50 border border-emerald-200 text-emerald-700 hover:bg-emerald-100 shadow-2xs disabled:opacity-50 transition-all cursor-pointer">
                {busyId === c.companyId ? <Loader2 size={12} className="animate-spin" /> : <Check size={12} />} Approve</button>
              <button onClick={() => handleAction(c.companyId, "reject")} disabled={busyId === c.companyId}
                className="flex-1 md:flex-initial inline-flex items-center justify-center gap-2 px-4 py-2 rounded-xl text-[10px] sm:text-[11px] font-black uppercase tracking-[0.15em] bg-rose-50 border border-rose-200 text-rose-600 hover:bg-rose-100 shadow-2xs disabled:opacity-50 transition-all cursor-pointer">
                {busyId === c.companyId ? <Loader2 size={12} className="animate-spin" /> : <X size={12} />} Reject</button>
            </div>
          </motion.div>
        )))}
      </div>
    </div>
  );
}
