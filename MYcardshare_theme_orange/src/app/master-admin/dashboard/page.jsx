"use client";
import { useState, useEffect, useCallback } from "react";
import { motion } from "framer-motion";
import Link from "next/link";
import { Building2, ShieldCheck, Users, Megaphone, Activity, RefreshCw, Loader2, TrendingUp, Clock, CheckCircle, UserPlus, Zap, XCircle, CalendarClock } from "lucide-react";
import { authFetch, parseFetchJson } from "@/lib/api";

const STAT_CONFIG = [
  { key: "totalCompanies", label: "Total Customers", icon: Building2, color: "#D4622C", bg: "#FCE9DF", border: "#F3C5AF", link: "/master-admin/company" },
  { key: "pendingApprovals", label: "Pending Approvals", icon: ShieldCheck, color: "#D97706", bg: "#FEF3C7", border: "#FDE68A", link: "/master-admin/approval" },
  { key: "approvedCompanies", label: "Active Workspaces", icon: Users, color: "#059669", bg: "#DCFCE7", border: "#BBF7D0", link: "/master-admin/workspace" },
  { key: "totalUsers", label: "Total Users", icon: UserPlus, color: "#D4622C", bg: "#FCE9DF", border: "#F3C5AF" },
  { key: "suspendedCompanies", label: "Suspended", icon: XCircle, color: "#DC2626", bg: "#FEE2E2", border: "#FECACA", link: "/master-admin/company?status=suspended" },
  { key: "renewalsThisMonth", label: "Renewals This Month", icon: CalendarClock, color: "#77716C", bg: "#FAF6F2", border: "#EAE2DB", link: "/master-admin/company?filter=renewals" },
];

const ACTIVITY_ICON = {
  company_registered: UserPlus,
  company_approved: CheckCircle,
  lead_created: TrendingUp,
  campaign_created: Zap,
};
const ACTIVITY_COLOR = {
  company_registered: { color: "#D4622C", bg: "#FCE9DF", border: "#F3C5AF" },
  company_approved: { color: "#059669", bg: "#DCFCE7", border: "#BBF7D0" },
  lead_created: { color: "#D97706", bg: "#FEF3C7", border: "#FDE68A" },
  campaign_created: { color: "#D4622C", bg: "#FCE9DF", border: "#F3C5AF" },
};

function StatSkeleton() {
  return (
    <div className="rounded-3xl p-4 sm:p-6 animate-pulse flex flex-col items-center bg-white border border-[#EAE2DB] shadow-xs">
      <div className="w-8 h-8 sm:w-10 sm:h-10 rounded-xl bg-[#FAF6F2] mb-3 sm:mb-4" />
      <div className="h-6 sm:h-8 w-12 sm:w-16 bg-[#FAF6F2] rounded mb-2" />
      <div className="h-2.5 sm:h-3 w-16 sm:w-24 bg-[#FAF6F2] rounded" />
    </div>
  );
}

function timeAgo(ts) {
  if (!ts) return "";
  const diff = Date.now() - new Date(ts).getTime();
  const mins = Math.floor(diff / 60000);
  if (mins < 1) return "Just now";
  if (mins < 60) return `${mins}m ago`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24) return `${hrs}h ago`;
  const days = Math.floor(hrs / 24);
  return `${days}d ago`;
}

export default function MasterDashboard() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const fetchData = useCallback(async () => {
    try {
      const res = await authFetch("/api/platform/dashboard");
      const result = await parseFetchJson(res);
      if (result.success) setData(result.data);
      else setError("Failed to load dashboard data");
    } catch (err) { setError(err?.message || "Network error"); }
    finally { setLoading(false); }
  }, []);

  useEffect(() => { fetchData(); }, [fetchData]);

  // Auto-refresh every 30 seconds
  useEffect(() => {
    const interval = setInterval(() => { fetchData(); }, 30000);
    return () => clearInterval(interval);
  }, [fetchData]);

  const stats = data?.stats || {};

  return (
    <div className="space-y-6 sm:space-y-8">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-black tracking-tight text-[#191919]">Dashboard</h1>
          <p className="text-sm mt-1 text-[#77716C] font-medium">Platform overview and recent activity</p>
        </div>
        <button onClick={() => { setLoading(true); fetchData(); }} disabled={loading}
          className="p-2.5 rounded-xl bg-white border border-[#EAE2DB] text-[#77716C] hover:text-[#D4622C] hover:border-[#D4622C]/30 hover:bg-[#FCE9DF]/50 shadow-2xs transition-all w-fit cursor-pointer disabled:opacity-50">
          <RefreshCw size={16} className={loading ? "animate-spin" : ""} />
        </button>
      </div>

      {error && (
        <div className="rounded-2xl bg-rose-50 border border-rose-200 p-4 text-rose-600 text-xs font-bold uppercase tracking-widest shadow-2xs">{error}</div>
      )}

      {/* Stats */}
      <div className="grid grid-cols-2 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-3 sm:gap-4">
        {loading && !data ? (
          Array.from({ length: 6 }).map((_, i) => <StatSkeleton key={i} />)
        ) : (
          STAT_CONFIG.map((s, i) => {
            const cardContent = (
                <motion.div initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.08 }}
                  className="relative overflow-hidden rounded-3xl p-4 sm:p-6 h-full bg-white border border-[#EAE2DB] shadow-xs hover:shadow-md hover:border-[#D4622C]/40 hover:-translate-y-1 transition-all duration-300 flex flex-col items-center text-center group cursor-pointer">
                  
                  {/* Subtle top brand orange accent line on hover */}
                  <div className="absolute top-0 inset-x-0 h-1 bg-gradient-to-r from-transparent via-[#D4622C] to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
                  
                  <div className="flex items-center justify-center mb-3">
                    <div className="w-10 h-10 sm:w-12 sm:h-12 rounded-2xl flex items-center justify-center relative overflow-hidden group-hover:scale-110 group-hover:rotate-3 transition-all duration-300 shadow-2xs"
                      style={{ background: s.bg, border: `1px solid ${s.border}` }}>
                      <s.icon className="w-4 h-4 sm:w-5 sm:h-5 relative z-10 transition-transform duration-300" style={{ color: s.color }} />
                    </div>
                  </div>
                  <div className="text-2xl sm:text-3xl font-black text-[#191919] tracking-tight">{stats[s.key] ?? 0}</div>
                  <div className="text-[9px] sm:text-[10px] font-black uppercase tracking-[0.15em] text-[#77716C] mt-1.5 leading-tight">{s.label}</div>
                </motion.div>
            );
            return s.link ? (
              <Link key={s.key} href={s.link} className="block cursor-pointer">
                {cardContent}
              </Link>
            ) : (
              <div key={s.key}>{cardContent}</div>
            );
          })
        )}
      </div>

      {/* Recent Activity */}
      <div className="rounded-3xl p-6 sm:p-8 bg-white border border-[#EAE2DB] shadow-xs">
        <div className="flex items-center gap-3 mb-6">
          <div className="w-8 h-8 rounded-lg bg-[#FCE9DF] flex items-center justify-center text-[#D4622C]">
            <Activity size={16} />
          </div>
          <h2 className="text-xs sm:text-sm font-black uppercase tracking-[0.2em] text-[#191919]">Recent Activity</h2>
        </div>
        {loading && !data ? (
          <div className="py-12 flex justify-center"><Loader2 className="animate-spin text-[#D4622C]" size={24} /></div>
        ) : !data?.recentActivity?.length ? (
          <div className="text-center py-16 bg-[#FAF6F2] rounded-2xl border border-[#EAE2DB] border-dashed">
            <Activity size={32} className="mx-auto mb-3 text-[#77716C]/40" />
            <p className="text-[11px] font-bold uppercase tracking-widest text-[#77716C]">No activity yet</p>
          </div>
        ) : (
          <div className="space-y-3 max-h-[400px] overflow-y-auto pr-2 custom-scrollbar">
            {data.recentActivity.map((item, i) => {
              const Icon = ACTIVITY_ICON[item.type] || Activity;
              const cfg = ACTIVITY_COLOR[item.type] || { color: "#D4622C", bg: "#FCE9DF", border: "#F3C5AF" };
              return (
                <motion.div key={i} initial={{ opacity: 0, x: -8 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: i * 0.03 }}
                  className="flex items-center gap-4 sm:gap-5 px-5 py-3.5 rounded-2xl bg-[#FAF6F2]/70 border border-[#EAE2DB]/70 hover:bg-white hover:shadow-xs hover:border-[#EAE2DB] transition-all duration-300 group">
                  <div className="w-10 h-10 rounded-xl flex items-center justify-center shrink-0 shadow-2xs group-hover:scale-105 transition-transform duration-300"
                    style={{ background: cfg.bg, border: `1px solid ${cfg.border}` }}>
                    <Icon size={16} style={{ color: cfg.color }} className="relative z-10" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-xs sm:text-sm font-bold text-[#191919] truncate">{item.message}</p>
                  </div>
                  <div className="text-[10px] font-bold text-[#77716C] shrink-0 flex items-center gap-1.5 uppercase tracking-widest bg-white border border-[#EAE2DB] px-3 py-1.5 rounded-lg">
                    <Clock size={10} className="text-[#D4622C]" />{timeAgo(item.timestamp)}
                  </div>
                </motion.div>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
}
