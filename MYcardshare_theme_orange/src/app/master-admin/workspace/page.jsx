"use client";
import { useState, useEffect, useMemo, useCallback } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Users, Search, RefreshCw, Building2, Eye, ShieldCheck, XCircle, Loader2, Plus, ArrowUpRight, CheckCircle, AlertCircle, Sparkles } from "lucide-react";
import { authFetch, parseFetchJson } from "@/lib/api";

function WorkspaceRow({ workspace, i }) {
  const status = workspace.isSuspended ? "Suspended" : (workspace.approvalStatus || "Pending");
  const statusColor = workspace.isSuspended ? "text-red-600 bg-red-50 border-red-100 shadow-sm" : 
                     status === "approved" ? "text-emerald-600 bg-emerald-50 border-emerald-100 shadow-sm" : 
                     "text-amber-600 bg-amber-50 border-amber-100 shadow-sm";

  return (
    <motion.div initial={{ opacity: 0, y: 4 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.02 }}
      className="flex flex-col lg:grid lg:grid-cols-12 gap-4 lg:gap-4 px-4 sm:px-6 py-5 lg:py-4 items-start lg:items-center hover:bg-slate-50 transition-colors border-b border-slate-100 group">
      
      {/* Mobile Header: Logo + Name + Status */}
      <div className="flex items-start justify-between lg:contents w-full">
        <div className="lg:col-span-4 flex items-center gap-4 min-w-0">
          <div className="w-10 h-10 rounded-xl bg-white border border-[#EAE2DB] shadow-2xs flex items-center justify-center shrink-0">
            {workspace.companyLogo ? <img src={workspace.companyLogo} alt="" className="w-full h-full object-contain p-1" /> : <Building2 size={16} className="text-[#77716C]" />}
          </div>
          <div className="min-w-0">
            <h3 className="text-sm font-black tracking-tight text-[#191919] truncate group-hover:text-[#D4622C] transition-colors">{workspace.companyName}</h3>
            <p className="text-[10px] font-medium text-[#77716C] font-mono truncate mt-0.5">{workspace.slug}</p>
          </div>
        </div>
        <div className="lg:hidden">
          <span className={`px-2 py-0.5 rounded-md text-[8px] font-black uppercase tracking-widest border ${statusColor}`}>
            {status}</span>
        </div>
      </div>

      {/* Stats Grid for Mobile */}
      <div className="grid grid-cols-2 lg:contents gap-4 w-full">
        <div className="lg:col-span-2 text-left lg:text-center min-w-0">
          <div className="text-[8px] font-black uppercase tracking-[0.15em] text-[#77716C] lg:hidden mb-1">Workforce</div>
          <div className="text-sm font-bold text-[#191919]">{workspace.memberCount || 0}</div>
          <div className="hidden lg:block text-[9px] text-[#77716C] font-black uppercase tracking-[0.15em]">Total Members</div>
        </div>
        <div className="lg:col-span-2 text-left lg:text-center min-w-0">
          <div className="text-[8px] font-black uppercase tracking-[0.15em] text-[#77716C] lg:hidden mb-1">Deployment</div>
          <div className="text-sm font-bold text-[#D4622C]">{workspace.activeCards || 0}</div>
          <div className="hidden lg:block text-[9px] text-[#77716C] font-black uppercase tracking-[0.15em]">Active Cards</div>
        </div>
      </div>

      {/* Desktop Status Badge */}
      <div className="hidden lg:flex lg:col-span-2 justify-center">
        <span className={`px-2.5 py-1 rounded-lg text-[9px] font-black uppercase tracking-[0.15em] border ${statusColor}`}>
          {status}</span>
      </div>

      {/* Action */}
      <div className="lg:col-span-2 w-full lg:text-right flex lg:justify-end mt-2 lg:mt-0 pt-3 lg:pt-0 border-t border-slate-100 lg:border-t-0">
        <button className="w-full lg:w-auto p-2.5 rounded-xl bg-white border border-slate-200 text-slate-500 hover:bg-slate-800 hover:text-white hover:border-slate-800 shadow-sm transition-all flex items-center justify-center gap-2 lg:block group-hover:border-slate-300">
          <span className="lg:hidden text-[10px] font-black uppercase tracking-widest">Details</span>
          <ArrowUpRight size={14} />
        </button>
      </div>
    </motion.div>
  );
}

export default function MasterWorkspacePage() {
  const [workspaces, setWorkspaces] = useState([]);
  const [loading, setLoading] = useState(true);
  const [query, setQuery] = useState("");

  const fetchData = useCallback(async () => {
    setLoading(true);
    try {
      const res = await authFetch("/api/platform/workspaces");
      const data = await parseFetchJson(res);
      if (data.success) setWorkspaces(data.data || []);
    } catch (_) {}
    finally { setLoading(false); }
  }, []);

  useEffect(() => { fetchData(); }, [fetchData]);

  const filtered = useMemo(() => {
    if (!query.trim()) return workspaces;
    const q = query.toLowerCase();
    return workspaces.filter(w => [w.companyName, w.slug, w.superAdminEmail].some(v => String(v).toLowerCase().includes(q)));
  }, [workspaces, query]);

  return (
    <div className="space-y-6 sm:space-y-8 pb-20 max-w-[1400px]">
      <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4">
        <div>
          <h1 className="text-2xl sm:text-3xl font-black tracking-tight text-[#191919]">Workspaces</h1>
          <p className="text-xs sm:text-sm mt-1 text-[#77716C] font-medium">{loading ? "Scanning network..." : `${workspaces.length} enterprise nodes online`}</p>
        </div>
        <button onClick={fetchData} className="p-2.5 rounded-xl bg-white border border-[#EAE2DB] shadow-2xs text-[#77716C] hover:text-[#D4622C] hover:bg-[#FCE9DF]/50 hover:border-[#D4622C]/30 transition-all w-fit cursor-pointer"><RefreshCw size={16} /></button>
      </div>

      <div className="relative">
        <Search size={16} className="absolute left-4 top-1/2 -translate-y-1/2 text-[#77716C]" />
        <input type="text" value={query} onChange={(e) => setQuery(e.target.value)} placeholder="Search workspaces by name, slug or admin..." 
          className="w-full pl-11 pr-4 py-3 rounded-2xl text-sm bg-white border border-[#EAE2DB] shadow-2xs text-[#191919] placeholder:text-[#77716C]/60 focus:outline-none focus:border-[#D4622C] focus:ring-2 focus:ring-[#D4622C]/20 transition-all" />
      </div>

      <div className="rounded-3xl overflow-hidden bg-white border border-[#EAE2DB] shadow-xs">
        <div className="hidden lg:grid grid-cols-12 gap-4 px-6 py-4 text-[10px] font-black uppercase tracking-[0.2em] text-[#77716C] bg-[#FAF6F2] border-b border-[#EAE2DB]">
          <div className="col-span-4">Enterprise Node</div>
          <div className="col-span-2 text-center">Workforce</div>
          <div className="col-span-2 text-center">Deployment</div>
          <div className="col-span-2 text-center">Cloud Status</div>
          <div className="col-span-2 text-right">Action</div>
        </div>

        {loading ? (
          <div className="py-32 flex flex-col items-center justify-center gap-4 text-[#77716C]">
            <Loader2 className="animate-spin text-[#D4622C]" size={32} />
            <p className="text-[11px] font-bold uppercase tracking-[0.2em]">Synchronizing Registry</p>
          </div>
        ) : filtered.length === 0 ? (
          <div className="py-32 flex flex-col items-center justify-center gap-4 text-[#77716C]">
            <Users size={48} className="text-[#D4622C]/40" />
            <p className="text-[11px] font-bold uppercase tracking-[0.2em] text-[#191919]">No workspaces found</p>
          </div>
        ) : (
          <div>
            {filtered.map((w, i) => (
              <WorkspaceRow key={w.id} workspace={w} i={i} />
            ))}
          </div>
        )}
      </div>

      <div className="grid grid-cols-3 gap-3 sm:gap-6">
        <div className="p-4 sm:p-8 rounded-3xl bg-[#FCE9DF] border border-[#F3C5AF] flex flex-col gap-2 sm:gap-4 shadow-xs hover:-translate-y-1 transition-all">
          <div className="w-10 h-10 sm:w-12 sm:h-12 rounded-2xl bg-white flex items-center justify-center text-[#D4622C] shrink-0 shadow-2xs"><Users size={20} /></div>
          <div><h3 className="text-[9px] sm:text-xs font-black text-[#D4622C] uppercase tracking-[0.15em]">Global Workforce</h3><p className="text-xl sm:text-3xl font-black text-[#191919] tracking-tight mt-0.5 sm:mt-1">{workspaces.reduce((acc, w) => acc + (w.memberCount || 0), 0)}</p></div>
        </div>
        <div className="p-4 sm:p-8 rounded-3xl bg-emerald-50 border border-emerald-200 flex flex-col gap-2 sm:gap-4 shadow-xs hover:-translate-y-1 transition-all">
          <div className="w-10 h-10 sm:w-12 sm:h-12 rounded-2xl bg-emerald-100 flex items-center justify-center text-emerald-600 shrink-0 shadow-2xs"><CheckCircle size={20} /></div>
          <div><h3 className="text-[9px] sm:text-xs font-black text-emerald-700 uppercase tracking-[0.15em]">Active Cards</h3><p className="text-xl sm:text-3xl font-black text-emerald-800 tracking-tight mt-0.5 sm:mt-1">{workspaces.reduce((acc, w) => acc + (w.activeCards || 0), 0)}</p></div>
        </div>
        <div className="p-4 sm:p-8 rounded-3xl bg-white border border-[#EAE2DB] flex flex-col gap-2 sm:gap-4 shadow-xs hover:-translate-y-1 transition-all">
          <div className="w-10 h-10 sm:w-12 sm:h-12 rounded-2xl bg-[#FAF6F2] border border-[#EAE2DB] flex items-center justify-center text-[#77716C] shrink-0 shadow-2xs"><Building2 size={20} /></div>
          <div><h3 className="text-[9px] sm:text-xs font-black text-[#77716C] uppercase tracking-[0.15em]">Market Reach</h3><p className="text-xl sm:text-3xl font-black text-[#191919] tracking-tight mt-0.5 sm:mt-1">{workspaces.length} Nodes</p></div>
        </div>
      </div>
    </div>
  );
}
