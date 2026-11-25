"use client";
import { useState, useEffect, useCallback } from "react";
import { motion } from "framer-motion";
import { Zap, Users, Megaphone, MailPlus, TrendingUp, Loader2, RefreshCw } from "lucide-react";
import { authFetch, parseFetchJson } from "@/lib/api";
import dynamic from "next/dynamic";

const LineChart = dynamic(() => import("recharts").then((m) => m.LineChart), { ssr: false });
const BarChart = dynamic(() => import("recharts").then((m) => m.BarChart), { ssr: false });
const PieChart = dynamic(() => import("recharts").then((m) => m.PieChart), { ssr: false });
const Line = dynamic(() => import("recharts").then((m) => m.Line), { ssr: false });
const Bar = dynamic(() => import("recharts").then((m) => m.Bar), { ssr: false });
const Pie = dynamic(() => import("recharts").then((m) => m.Pie), { ssr: false });
const Cell = dynamic(() => import("recharts").then((m) => m.Cell), { ssr: false });
const XAxis = dynamic(() => import("recharts").then((m) => m.XAxis), { ssr: false });
const YAxis = dynamic(() => import("recharts").then((m) => m.YAxis), { ssr: false });
const Tooltip = dynamic(() => import("recharts").then((m) => m.Tooltip), { ssr: false });
const ResponsiveContainer = dynamic(() => import("recharts").then((m) => m.ResponsiveContainer), { ssr: false });

const CHART_COLORS = ["#D4622C", "#10B981", "#F59E0B", "#EF4444", "#E3743E", "#D97706", "#EC4899", "#8B5CF6"];
const PIE_COLORS = { active: "#10B981", inactive: "#D4622C", expired: "#EF4444" };
const APPROVAL_COLORS = { approved: "#10B981", pending: "#D4622C", rejected: "#EF4444", suspended: "#77716C" };

const CustomTooltip = ({ active, payload, label }) => {
  if (!active || !payload?.length) return null;
  return (
    <div className="rounded-xl px-4 py-3 shadow-xl text-xs bg-white border border-[#EAE2DB]">
      <p className="text-[#77716C] font-black uppercase tracking-[0.15em] mb-1.5 text-[9px]">{label}</p>
      {payload.map((p, i) => <p key={i} className="font-bold text-sm tracking-tight" style={{ color: p.color }}>{p.name}: {p.value}</p>)}
    </div>
  );
};

export default function MasterAnalyticsPage() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  const fetchData = useCallback(async () => {
    setLoading(true);
    try {
      const res = await authFetch("/api/platform/dashboard");
      const result = await parseFetchJson(res);
      if (result.success) setData(result.data);
    } catch (_) {}
    finally { setLoading(false); }
  }, []);

  useEffect(() => { fetchData(); }, [fetchData]);

  if (loading) {
    return (<div className="flex items-center justify-center py-32"><Loader2 className="animate-spin text-[#D4622C]" size={32} /></div>);
  }

  const stats = data?.stats || {};
  const signupTimeline = data?.signupTimeline || [];
  const leadTimeline = data?.leadTimeline || [];
  const topCompanies = data?.topCompaniesByLeads || [];
  const campaignBreakdown = data?.campaignBreakdown || {};
  const approvalBreakdown = data?.approvalBreakdown || {};

  const campaignPieData = [
    { name: "Active", value: campaignBreakdown.active || 0 },
    { name: "Inactive", value: campaignBreakdown.inactive || 0 },
  ].filter((d) => d.value > 0);

  const approvalPieData = [
    { name: "Approved", value: approvalBreakdown.approved || 0 },
    { name: "Pending", value: approvalBreakdown.pending || 0 },
    { name: "Rejected", value: approvalBreakdown.rejected || 0 },
    { name: "Suspended", value: approvalBreakdown.suspended || 0 },
  ].filter((d) => d.value > 0);

  const topStats = [
    { label: "Total Signups", value: stats.totalUsers ?? 0, icon: Users, color: "#D4622C" },
    { label: "Active Companies", value: stats.approvedCompanies ?? 0, icon: TrendingUp, color: "#10B981" },
    { label: "Total Leads", value: stats.totalLeads ?? 0, icon: Megaphone, color: "#E3743E" },
    { label: "Running Campaigns", value: stats.activeCampaigns ?? 0, icon: MailPlus, color: "#F59E0B" },
  ];

  return (
    <div className="space-y-6 sm:space-y-8 pb-12 max-w-[1400px]">
      <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4">
        <div>
          <h1 className="text-2xl sm:text-3xl font-black tracking-tight text-[#191919]">Analytics</h1>
          <p className="text-xs sm:text-sm mt-1 text-[#77716C] font-medium">Platform-wide performance metrics</p>
        </div>
        <button onClick={fetchData} className="p-2.5 rounded-xl bg-white border border-[#EAE2DB] shadow-sm text-[#77716C] hover:text-[#D4622C] hover:bg-[#FCE9DF] hover:border-[#F3C5AF] transition-all w-fit cursor-pointer">
          <RefreshCw size={16} />
        </button>
      </div>

      {/* Top stats */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4">
        {topStats.map((s, i) => (
          <motion.div key={s.label} initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.08 }}
            className="rounded-[1.5rem] p-4 sm:p-6 bg-white border border-[#EAE2DB] shadow-sm hover:shadow-md hover:-translate-y-0.5 transition-all">
            <div className="flex items-center gap-3 mb-3 sm:mb-4">
              <div className="w-10 h-10 sm:w-12 sm:h-12 rounded-xl sm:rounded-2xl flex items-center justify-center shadow-sm" style={{ background: `${s.color}15`, border: `1px solid ${s.color}30` }}>
                <s.icon size={18} sm={22} style={{ color: s.color }} /></div></div>
            <div className="text-2xl sm:text-3xl font-black text-[#191919] tracking-tight">{s.value}</div>
            <div className="text-[9px] sm:text-[10px] font-black uppercase tracking-[0.2em] text-[#77716C] mt-1 leading-tight">{s.label}</div>
          </motion.div>
        ))}
      </div>

      {/* Charts row 1 */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-3 sm:gap-4">
        {/* Signups over time */}
        <div className="rounded-[2rem] p-5 sm:p-7 bg-white border border-[#EAE2DB] shadow-sm">
          <h3 className="text-[10px] sm:text-[11px] font-black uppercase tracking-[0.2em] text-[#77716C] mb-6 sm:mb-8">New Company Registrations</h3>
          {signupTimeline.length > 0 ? (
            <ResponsiveContainer width="100%" height={250}>
              <LineChart data={signupTimeline} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                <defs>
                  <linearGradient id="lineGrad" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#D4622C" stopOpacity={0.25}/>
                    <stop offset="95%" stopColor="#D4622C" stopOpacity={0}/>
                  </linearGradient>
                </defs>
                <XAxis dataKey="date" tick={{ fontSize: 9, fill: "#77716C", fontWeight: 600 }} tickFormatter={(v) => v.slice(5)} axisLine={false} tickLine={false} dy={10} />
                <YAxis tick={{ fontSize: 9, fill: "#77716C", fontWeight: 600 }} axisLine={false} tickLine={false} allowDecimals={false} dx={-10} />
                <Tooltip content={<CustomTooltip />} cursor={{ stroke: '#EAE2DB', strokeWidth: 1, strokeDasharray: '4 4' }} />
                <Line type="monotone" dataKey="count" name="Signups" stroke="#D4622C" strokeWidth={3} dot={{ r: 4, fill: "#D4622C", strokeWidth: 2, stroke: "#ffffff" }} activeDot={{ r: 6, strokeWidth: 0 }} />
              </LineChart>
            </ResponsiveContainer>
          ) : <div className="h-[250px] flex items-center justify-center text-[#77716C] text-sm font-medium">No signup data yet</div>}
        </div>

        {/* Leads over time */}
        <div className="rounded-[2rem] p-5 sm:p-7 bg-white border border-[#EAE2DB] shadow-sm">
          <h3 className="text-[10px] sm:text-[11px] font-black uppercase tracking-[0.2em] text-[#77716C] mb-6 sm:mb-8">Leads Generated</h3>
          {leadTimeline.length > 0 ? (
            <ResponsiveContainer width="100%" height={250}>
              <BarChart data={leadTimeline} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                <defs>
                  <linearGradient id="barGrad" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%" stopColor="#D4622C" stopOpacity={0.9}/>
                    <stop offset="100%" stopColor="#E3743E" stopOpacity={0.6}/>
                  </linearGradient>
                </defs>
                <XAxis dataKey="date" tick={{ fontSize: 9, fill: "#77716C", fontWeight: 600 }} tickFormatter={(v) => v.slice(5)} axisLine={false} tickLine={false} dy={10} />
                <YAxis tick={{ fontSize: 9, fill: "#77716C", fontWeight: 600 }} axisLine={false} tickLine={false} allowDecimals={false} dx={-10} />
                <Tooltip content={<CustomTooltip />} cursor={{ fill: '#FAF6F2' }} />
                <Bar dataKey="count" name="Leads" fill="url(#barGrad)" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          ) : <div className="h-[250px] flex items-center justify-center text-[#77716C] text-sm font-medium">No lead data yet</div>}
        </div>
      </div>

      {/* Charts row 2 */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-3 sm:gap-4">
        {/* Campaign status */}
        <div className="rounded-[2rem] p-5 sm:p-7 bg-white border border-[#EAE2DB] shadow-sm flex flex-col items-center">
          <h3 className="text-[10px] sm:text-[11px] font-black uppercase tracking-[0.2em] text-[#77716C] w-full text-left mb-2">Campaign Status</h3>
          {campaignPieData.length > 0 ? (
            <ResponsiveContainer width="100%" height={180}>
              <PieChart>
                <Pie data={campaignPieData} cx="50%" cy="50%" innerRadius={55} outerRadius={75} dataKey="value" nameKey="name" paddingAngle={4} stroke="none">
                  {campaignPieData.map((entry, i) => (
                    <Cell key={i} fill={PIE_COLORS[entry.name.toLowerCase()] || CHART_COLORS[i]} />
                  ))}
                </Pie>
                <Tooltip content={<CustomTooltip />} />
              </PieChart>
            </ResponsiveContainer>
          ) : <div className="h-[180px] w-full flex items-center justify-center text-[#77716C] text-sm font-medium">No campaigns yet</div>}
          <div className="flex justify-center gap-4 mt-4 w-full">
            {campaignPieData.map((d, i) => (
              <div key={d.name} className="flex items-center gap-2 bg-[#FAF6F2] px-3 py-1.5 rounded-lg border border-[#EAE2DB]">
                <div className="w-2 h-2 rounded-full" style={{ background: PIE_COLORS[d.name.toLowerCase()] || CHART_COLORS[i] }} />
                <span className="text-[9px] font-black text-[#77716C] uppercase tracking-widest">{d.name}: {d.value}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Top companies by leads */}
        <div className="rounded-[2rem] p-5 sm:p-7 bg-white border border-[#EAE2DB] shadow-sm">
          <h3 className="text-[10px] sm:text-[11px] font-black uppercase tracking-[0.2em] text-[#77716C] mb-6">Top Companies by Leads</h3>
          {topCompanies.length > 0 ? (
            <ResponsiveContainer width="100%" height={220}>
              <BarChart data={topCompanies} layout="vertical" margin={{ top: 0, right: 10, left: 10, bottom: 0 }}>
                <XAxis type="number" tick={{ fontSize: 9, fill: "#77716C", fontWeight: 600 }} axisLine={false} tickLine={false} />
                <YAxis type="category" dataKey="companyName" width={100} tick={{ fontSize: 10, fill: "#77716C", fontWeight: 600 }} axisLine={false} tickLine={false} />
                <Tooltip content={<CustomTooltip />} cursor={{ fill: '#FAF6F2' }} />
                <Bar dataKey="leadCount" name="Leads" fill="#D4622C" radius={[0, 4, 4, 0]} barSize={24} />
              </BarChart>
            </ResponsiveContainer>
          ) : <div className="h-[220px] flex items-center justify-center text-[#77716C] text-sm font-medium">No lead data yet</div>}
        </div>

        {/* Approval status */}
        <div className="rounded-[2rem] p-5 sm:p-7 bg-white border border-[#EAE2DB] shadow-sm flex flex-col items-center">
          <h3 className="text-[10px] sm:text-[11px] font-black uppercase tracking-[0.2em] text-[#77716C] w-full text-left mb-2">Approval Status</h3>
          {approvalPieData.length > 0 ? (
            <ResponsiveContainer width="100%" height={180}>
              <PieChart>
                <Pie data={approvalPieData} cx="50%" cy="50%" innerRadius={55} outerRadius={75} dataKey="value" nameKey="name" paddingAngle={4} stroke="none">
                  {approvalPieData.map((entry) => (
                    <Cell key={entry.name} fill={APPROVAL_COLORS[entry.name.toLowerCase()] || "#D4622C"} />
                  ))}
                </Pie>
                <Tooltip content={<CustomTooltip />} />
              </PieChart>
            </ResponsiveContainer>
          ) : <div className="h-[180px] w-full flex items-center justify-center text-[#77716C] text-sm font-medium">No company data yet</div>}
          <div className="flex flex-wrap justify-center gap-2 mt-4 w-full">
            {approvalPieData.map((d) => (
              <div key={d.name} className="flex items-center gap-2 bg-[#FAF6F2] px-2.5 py-1.5 rounded-lg border border-[#EAE2DB]">
                <div className="w-2 h-2 rounded-full" style={{ background: APPROVAL_COLORS[d.name.toLowerCase()] }} />
                <span className="text-[8px] sm:text-[9px] font-black text-[#77716C] uppercase tracking-widest">{d.name}: {d.value}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}