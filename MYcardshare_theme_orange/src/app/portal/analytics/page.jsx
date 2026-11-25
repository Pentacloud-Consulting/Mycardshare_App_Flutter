"use client";

import { useEffect, useState } from "react";
import { motion } from "framer-motion";
import {
  Zap,
  Users,
  TrendingUp,
  Megaphone,
  Eye,
  Loader2,
  AlertCircle,
  RefreshCw,
} from "lucide-react";
import { useAuth } from "@/lib/auth-context";
import { authFetch, parseFetchJson, toUserMessage } from "@/lib/api";

/* ═══════════════════════════════════════════════════════════
   ANALYTICS — Aggregate live metrics for admins / masters
   ═══════════════════════════════════════════════════════════ */

function StatCard({ icon: Icon, label, value, color, delta, loading }) {
  return (
    <div className="rounded-2xl p-6 bg-white/[0.02] border border-white/5">
      <div className="flex items-center justify-between mb-3">
        <div
          className="w-10 h-10 rounded-xl flex items-center justify-center"
          style={{ background: `${color}15` }}
        >
          <Icon size={18} style={{ color }} />
        </div>
        {delta && (
          <span className="text-[10px] font-black text-emerald-400 bg-emerald-400/10 px-2 py-1 rounded-lg">
            {delta}
          </span>
        )}
      </div>
      <div className="text-2xl font-black text-white" style={{ fontFamily: "var(--font-display)" }}>
        {loading ? <Loader2 size={18} className="animate-spin text-white/40" /> : value}
      </div>
      <div className="text-xs mt-1 text-white/40">{label}</div>
    </div>
  );
}

export default function PortalAnalyticsPage() {
  const { userData, loading: authLoading } = useAuth();
  const [stats, setStats] = useState(null);
  const [platformStats, setPlatformStats] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const isMaster = userData?.role === "super_admin";
  const hasCompany = Boolean(userData?.companyId);

  const fetchData = async () => {
    setLoading(true);
    setError(null);
    try {
      const tasks = [];
      if (hasCompany) tasks.push(authFetch("/api/company/stats"));
      if (isMaster) tasks.push(authFetch("/api/platform/stats"));
      const results = await Promise.all(tasks);

      let idx = 0;
      if (hasCompany) {
        const data = await parseFetchJson(results[idx++]);
        if (data.success) setStats(data.data?.stats || null);
      }
      if (isMaster) {
        const data = await parseFetchJson(results[idx++]);
        if (data.success) setPlatformStats(data.data?.stats || null);
      }

      if (!hasCompany && !isMaster) {
        setError("Analytics are available once your account is linked to an organization.");
      }
    } catch (err) {
      setError(err?.message || "Network error loading analytics.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (!authLoading) fetchData();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [authLoading, hasCompany, isMaster]);

  if (authLoading) {
    return (
      <div className="min-h-[400px] flex items-center justify-center">
        <Loader2 className="animate-spin text-indigo-500" size={28} />
      </div>
    );
  }

  return (
    <div className="space-y-8">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <Zap size={18} className="text-sky-400" />
            <span className="text-xs font-bold uppercase tracking-[0.15em] text-sky-400">
              Analytics
            </span>
          </div>
          <h1 className="text-2xl font-black tracking-tight text-[#0F172A]" style={{ fontFamily: "var(--font-display)" }}>
            Network Insights
          </h1>
          <p className="text-sm mt-1 text-white/40">
            Live engagement and deployment metrics.
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
        <div className="flex items-start gap-3 rounded-2xl bg-amber-500/10 border border-amber-500/20 p-4 text-amber-300">
          <AlertCircle size={18} className="mt-0.5 shrink-0" />
          <p className="text-xs font-bold uppercase tracking-widest leading-relaxed">{error}</p>
        </div>
      )}

      {hasCompany && (
        <div>
          <h2 className="text-xs font-black uppercase tracking-[0.2em] text-white/40 mb-4">
            Your organization
          </h2>
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
            <StatCard
              icon={Users}
              label="Workforce"
              value={stats?.totalWorkforce ?? 0}
              color="#6366f1"
              loading={loading}
            />
            <StatCard
              icon={Eye}
              label="Card Views"
              value={stats?.engagement ?? 0}
              color="#06b6d4"
              delta={stats?.weeklyEngagementTrends}
              loading={loading}
            />
            <StatCard
              icon={TrendingUp}
              label="Leads Captured"
              value={stats?.totalLeads ?? 0}
              color="#10d9a8"
              loading={loading}
            />
            <StatCard
              icon={Megaphone}
              label="Active Campaigns"
              value={stats?.activeCampaigns ?? 0}
              color="#e8c975"
              loading={loading}
            />
          </div>
        </div>
      )}

      {isMaster && (
        <div>
          <h2 className="text-xs font-black uppercase tracking-[0.2em] text-white/40 mb-4">
            Platform totals
          </h2>
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
            <StatCard
              icon={Users}
              label="Total Users"
              value={platformStats?.totalUsers ?? 0}
              color="#a78bfa"
              loading={loading}
            />
            <StatCard
              icon={Zap}
              label="Active Nodes"
              value={platformStats?.activeNodes ?? 0}
              color="#06b6d4"
              loading={loading}
            />
            <StatCard
              icon={TrendingUp}
              label="Total Companies"
              value={platformStats?.totalCompanies ?? 0}
              color="#10d9a8"
              loading={loading}
            />
            <StatCard
              icon={Megaphone}
              label="Pending Approvals"
              value={platformStats?.pendingApprovals ?? 0}
              color="#e8c975"
              loading={loading}
            />
          </div>
        </div>
      )}
    </div>
  );
}
