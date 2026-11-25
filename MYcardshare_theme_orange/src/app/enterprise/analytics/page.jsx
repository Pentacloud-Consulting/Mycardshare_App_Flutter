"use client";
import { useState, useEffect, useCallback } from "react";
import { motion } from "framer-motion";
import { Zap, TrendingUp, Users, Eye, Loader2, RefreshCw, BarChart3, PieChart, ArrowUpRight } from "lucide-react";
import { authFetch, parseFetchJson } from "@/lib/api";
import dynamic from "next/dynamic";

const LineChart = dynamic(() => import("recharts").then((m) => m.LineChart), { ssr: false });
const BarChart = dynamic(() => import("recharts").then((m) => m.BarChart), { ssr: false });
const AreaChart = dynamic(() => import("recharts").then((m) => m.AreaChart), { ssr: false });
const Line = dynamic(() => import("recharts").then((m) => m.Line), { ssr: false });
const Bar = dynamic(() => import("recharts").then((m) => m.Bar), { ssr: false });
const Area = dynamic(() => import("recharts").then((m) => m.Area), { ssr: false });
const XAxis = dynamic(() => import("recharts").then((m) => m.XAxis), { ssr: false });
const YAxis = dynamic(() => import("recharts").then((m) => m.YAxis), { ssr: false });
const CartesianGrid = dynamic(() => import("recharts").then((m) => m.CartesianGrid), { ssr: false });
const Tooltip = dynamic(() => import("recharts").then((m) => m.Tooltip), { ssr: false });
const ResponsiveContainer = dynamic(() => import("recharts").then((m) => m.ResponsiveContainer), { ssr: false });

const CustomTooltip = ({ active, payload, label }) => {
  if (!active || !payload?.length) return null;
  return (
    <div className="rounded-xl px-4 py-2.5 shadow-xl text-[10px]" style={{ background: "#ffffff", border: "1px solid #e2e8f0" }}>
      <p className="text-slate-500 mb-1 font-black uppercase tracking-widest">{label}</p>
      {payload.map((p, i) => <p key={i} className="font-black text-[#D4642C] uppercase tracking-widest">{p.name}: {p.value}</p>)}
    </div>
  );
};

export default function EnterpriseAnalyticsPage() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  const fetchData = useCallback(async () => {
    setLoading(true);
    try {
      const res = await authFetch("/api/enterprise/analytics");
      const result = await parseFetchJson(res);
      if (result.success) setData(result.data);
    } catch (_) {}
    finally { setLoading(false); }
  }, []);

  useEffect(() => { fetchData(); }, [fetchData]);

  if (loading) {
    return (<div className="flex items-center justify-center py-32"><Loader2 className="animate-spin text-[#D4642C]" size={32} /></div>);
  }

  const topStats = [
    { label: "Views", value: data?.totalViews ?? 0, icon: Eye, color: "#D4642C" },
    { label: "Leads", value: data?.totalLeads ?? 0, icon: TrendingUp, color: "#f87171" },
    { label: "Conversion", value: data?.totalViews ? ((data.totalLeads / data.totalViews) * 100).toFixed(1) + "%" : "0%", icon: Zap, color: "#10d9a8" },
    { 
      label: "Top Performer", 
      value: (data?.topEmployees?.[0]?.views > 0 || data?.topEmployees?.length === 1)
        ? (data?.topEmployees?.[0]?.fullName || data?.topEmployees?.[0]?.name || "—")
        : "—", 
      icon: Users, 
      color: "#D4642C" 
    },
  ];

  return (
    <div className="max-w-7xl w-full mx-auto pb-12 font-sans relative">
      {/* Subtle Background Mesh for the whole page */}
      <div className="fixed inset-0 pointer-events-none -z-10 bg-slate-50">
        <div className="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] rounded-full bg-[#D4642C]/10 blur-[120px]" />
        <div className="absolute bottom-[-10%] right-[-10%] w-[40%] h-[40%] rounded-full bg-amber-500/10 blur-[120px]" />
      </div>

      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-8">
        <div>
          <h1 className="text-2xl sm:text-3xl font-black tracking-tight text-slate-900">Analytics</h1>
          <p className="text-xs sm:text-sm mt-1 text-slate-500 font-medium">Enterprise performance metrics</p>
        </div>
        <div className="flex items-center gap-3">
          <div className="hidden sm:flex items-center gap-2 px-4 py-2 bg-white rounded-xl border border-slate-200 shadow-sm text-sm font-semibold text-slate-700">
             <span className="relative flex h-2 w-2">
               <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
               <span className="relative inline-flex rounded-full h-2 w-2 bg-emerald-500"></span>
             </span>
             Live Data
          </div>
          <button onClick={fetchData} className="flex items-center gap-2 px-4 py-2 rounded-xl bg-white border border-slate-200 text-slate-600 hover:bg-slate-50 hover:text-[#D4642C] transition-colors shadow-sm font-bold text-sm group">
            <RefreshCw size={16} className="group-active:animate-spin" /> Sync
          </button>
        </div>
      </div>

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6 lg:gap-8 mb-8">
        {topStats.map((s, i) => (
          <motion.div key={s.label} initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.1, duration: 0.5, ease: "easeOut" }}
            className="rounded-[2rem] p-6 sm:p-8 bg-white/80 backdrop-blur-xl border border-white shadow-[0_8px_30px_rgb(0,0,0,0.04)] ring-1 ring-slate-200/50 hover:shadow-[0_8px_40px_rgba(212,100,44,0.08)] hover:-translate-y-1 transition-all duration-500 relative overflow-hidden group">
            <div className="absolute inset-0 bg-gradient-to-br from-white/50 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500" />
            <div className="absolute top-0 right-0 p-4 opacity-5 group-hover:opacity-10 transition-opacity duration-500 transform group-hover:scale-110 group-hover:rotate-12"><s.icon size={80} style={{ color: s.color }} /></div>
            <div className="relative z-10 flex items-center gap-3 mb-6">
              <div className="w-12 h-12 rounded-2xl flex items-center justify-center bg-white border border-slate-100 shadow-sm group-hover:scale-110 transition-transform duration-500" style={{ boxShadow: `0 4px 20px ${s.color}20` }}>
                <s.icon size={22} style={{ color: s.color }} />
              </div>
            </div>
            <div className="relative z-10 text-3xl sm:text-4xl font-black text-slate-800 tracking-tight leading-none mb-2">{s.value}</div>
            <div className="relative z-10 text-[10px] sm:text-xs font-black uppercase tracking-[0.2em] text-slate-400 group-hover:text-slate-600 transition-colors">{s.label}</div>
          </motion.div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 lg:gap-8">
        <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.4, duration: 0.5, ease: "easeOut" }} className="lg:col-span-7 rounded-[2rem] p-6 sm:p-8 bg-white/80 backdrop-blur-xl border border-white shadow-[0_8px_30px_rgb(0,0,0,0.04)] ring-1 ring-slate-200/50 relative overflow-hidden group">
          <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-[#D4642C] to-[#E87A43] opacity-50 group-hover:opacity-100 transition-opacity" />
          <div className="absolute -top-24 -left-24 w-48 h-48 bg-[#FFF7ED] rounded-full blur-[50px] opacity-50 pointer-events-none" />
          
          <div className="flex items-center justify-between mb-8 relative z-10">
            <div>
              <h3 className="text-sm font-black uppercase tracking-widest text-slate-900 flex items-center gap-3 mb-1">
                <div className="w-8 h-8 rounded-lg bg-[#FFF7ED] border border-[#FED7AA] flex items-center justify-center text-[#D4642C] shadow-sm"><BarChart3 size={16} /></div> Lead Acquisition
              </h3>
              <p className="text-[10px] text-slate-400 font-bold uppercase tracking-[0.15em] ml-11">30 Day Performance</p>
            </div>
            <div className="px-3 py-1.5 bg-emerald-50 text-emerald-600 rounded-lg border border-emerald-100 text-[10px] font-black uppercase tracking-widest flex items-center gap-1.5 shadow-sm">
              <TrendingUp size={12} /> +12% 
            </div>
          </div>
          
          {data?.leadTimeline?.length > 0 ? (
            <div className="relative z-10 w-full mt-4 -ml-2">
              <ResponsiveContainer width="100%" height={300}>
                <AreaChart data={data.leadTimeline} margin={{ top: 20, right: 10, left: -20, bottom: 0 }}>
                  <defs>
                    <linearGradient id="colorLeadsArea" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#D4642C" stopOpacity={0.3}/>
                      <stop offset="95%" stopColor="#D4642C" stopOpacity={0}/>
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                  <XAxis dataKey="date" tick={{ fontSize: 10, fill: "#94a3b8", fontWeight: '800' }} tickFormatter={(v) => v ? String(v).split('-').slice(1).join('/') : ''} axisLine={false} tickLine={false} dy={15} />
                  <YAxis tick={{ fontSize: 10, fill: "#94a3b8", fontWeight: '800' }} axisLine={false} tickLine={false} allowDecimals={false} dx={-15} />
                  <Tooltip content={<CustomTooltip />} cursor={{ stroke: '#cbd5e1', strokeWidth: 1, strokeDasharray: '5 5' }} />
                  <Area type="monotone" dataKey="count" name="Leads" stroke="#D4642C" strokeWidth={3} fill="url(#colorLeadsArea)" activeDot={{ r: 6, fill: '#D4642C', stroke: '#fff', strokeWidth: 2 }} />
                </AreaChart>
              </ResponsiveContainer>
            </div>
          ) : <div className="h-[300px] flex items-center justify-center rounded-2xl bg-slate-50 border border-slate-100 border-dashed text-slate-400 uppercase font-black tracking-widest text-[10px]">No data recorded</div>}
        </motion.div>

        <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.5, duration: 0.5, ease: "easeOut" }} className="lg:col-span-5 rounded-[2rem] p-6 sm:p-8 bg-white/80 backdrop-blur-xl border border-white shadow-[0_8px_30px_rgb(0,0,0,0.04)] ring-1 ring-slate-200/50">
          <div className="flex items-center justify-between mb-8">
            <h3 className="text-sm font-black uppercase tracking-widest text-slate-900 flex items-center gap-3">
              <div className="w-8 h-8 rounded-lg bg-[#FFF7ED] flex items-center justify-center text-[#D4642C]"><Users size={16} /></div> Top Performers
            </h3>
          </div>
          <div className="space-y-4">
            {data?.topEmployees?.length > 0 ? data.topEmployees.map((e, i) => (
              <div key={e._id} className="flex items-center justify-between p-4 rounded-[1.25rem] bg-white border border-slate-200 hover:border-[#FED7AA] hover:shadow-lg hover:shadow-[#D4642C]/5 transition-all duration-300 group relative overflow-hidden">
                <div className="absolute inset-0 bg-gradient-to-r from-[#FFF7ED]/50 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
                <div className="flex items-center gap-4 min-w-0 relative z-10">
                  <div className={`w-8 text-center font-black text-sm sm:text-base ${i === 0 ? 'text-[#D4642C]' : i === 1 ? 'text-slate-400' : i === 2 ? 'text-amber-700' : 'text-slate-300'}`}>
                    #{i + 1}
                  </div>
                  <div className={`w-12 h-12 rounded-2xl flex items-center justify-center overflow-hidden shrink-0 border-2 ${i === 0 ? 'border-[#D4642C]/50 shadow-sm shadow-[#D4642C]/20' : 'border-slate-100 shadow-sm'} bg-slate-50 group-hover:scale-105 transition-transform duration-300`}>
                    {e.avatarUrl && e.avatarUrl.startsWith('http') ? (
                      <img src={e.avatarUrl} className="w-full h-full object-cover" />
                    ) : (
                      <span className="font-black text-slate-400 text-lg uppercase">{e.fullName?.[0] || '?'}</span>
                    )}
                  </div>
                  <div className="min-w-0">
                    <h4 className="text-sm sm:text-base font-black text-slate-800 tracking-tight truncate leading-none mb-1.5 group-hover:text-[#D4642C] transition-colors">{e.fullName || 'Unknown'}</h4>
                    <p className="text-[10px] text-slate-500 uppercase font-bold tracking-[0.15em] truncate">{e.jobTitle || 'Team Member'}</p>
                  </div>
                </div>
                <div className="text-right shrink-0 relative z-10 bg-slate-50/80 px-4 py-2 rounded-xl border border-slate-100 group-hover:bg-white group-hover:border-[#FED7AA] transition-colors">
                  <div className="text-lg sm:text-xl font-black text-slate-800 leading-none group-hover:text-[#D4642C] transition-colors">{e.views?.toLocaleString() || 0}</div>
                  <div className="text-[8px] text-slate-400 uppercase font-black tracking-widest mt-1.5">Views</div>
                </div>
              </div>
            )) : <div className="py-20 text-center rounded-2xl bg-slate-50 border border-slate-100 border-dashed text-slate-400 uppercase font-black tracking-widest text-[10px]">No activity yet</div>}
          </div>
        </motion.div>
      </div>
    </div>
  );
}
