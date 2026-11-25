"use client";
import { useState, useEffect } from "react";
import { motion } from "framer-motion";
import { Building2, Users, CreditCard, FileText, CheckCircle, Settings, UserPlus, ChevronRight, Crown, Zap, ArrowUpRight, Ticket, Copy, ExternalLink, Sparkles } from "lucide-react";
import { useAuth } from "@/lib/auth-context";
import Link from "next/link";

export default function EnterpriseDashboard() {
  const { userData } = useAuth();
  const [profile, setProfile] = useState(null);
  const [copied, setCopied] = useState("");
  const [statsData, setStatsData] = useState({
    totalEmployees: "—",
    activeCards: "—",
    draftCards: "—",
    workspaceAdmins: "—",
  });

  useEffect(() => {
    async function fetchData() {
      try {
        const { authFetch, parseFetchJson } = await import("@/lib/api");
        const [profileRes, statsRes] = await Promise.all([
          authFetch("/api/enterprise/profile"),
          authFetch("/api/company/stats")
        ]);
        
        const profileData = await parseFetchJson(profileRes);
        if (profileData.success) setProfile(profileData.data);
        
        const statsJson = await parseFetchJson(statsRes);
        if (statsJson.success && statsJson.data?.stats) {
          const s = statsJson.data.stats;
          setStatsData({
            totalEmployees: s.totalWorkforce ?? 0,
            activeCards: s.activeCards ?? 0,
            draftCards: s.draftCards ?? 0,
            workspaceAdmins: s.workspaceAdmins ?? 1,
          });
        }
      } catch (err) { console.error("Failed to fetch dashboard data", err); }
    }
    fetchData();
  }, []);

  const copyToClipboard = (text, type) => {
    navigator.clipboard.writeText(text);
    setCopied(type);
    setTimeout(() => setCopied(""), 2000);
  };

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-black tracking-tight bg-gradient-to-r from-slate-800 to-[#D4642C] bg-clip-text text-transparent">
          Dashboard
        </h1>
        <p className="text-sm mt-1 text-slate-500 font-medium">Company overview and quick actions</p>
      </div>
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5 sm:gap-6">
        {[
          { label: "Total Employees", value: statsData.totalEmployees, icon: Users },
          { label: "Active Cards", value: statsData.activeCards, icon: CreditCard },
          { label: "Draft Cards", value: statsData.draftCards, icon: FileText },
          { label: "Workspace Admins", value: statsData.workspaceAdmins, icon: Building2 },
        ].map((s, i) => (
          <motion.div key={s.label} initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.1, ease: "easeOut" }}
            className="rounded-3xl p-6 bg-gradient-to-b from-white to-slate-50/80 border border-slate-200/60 shadow-[0_8px_30px_rgb(0,0,0,0.04)] hover:shadow-[0_8px_40px_rgba(212,100,44,0.08)] hover:border-[#FED7AA] hover:-translate-y-1 transition-all duration-500 group relative overflow-hidden">
            <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-[#D4642C] to-[#E87A43] opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
            <div className="absolute -right-6 -bottom-6 opacity-[0.02] group-hover:opacity-[0.04] group-hover:scale-110 transition-all duration-700 pointer-events-none text-[#D4642C]">
              <s.icon size={140} />
            </div>
            
            <div className="flex items-center justify-between mb-5 relative">
              <div className="w-12 h-12 rounded-xl flex items-center justify-center bg-white text-[#D4642C] group-hover:bg-gradient-to-br group-hover:from-[#D4642C] group-hover:to-[#BD5523] group-hover:text-white transition-all duration-500 shadow-sm border border-slate-100 group-hover:border-[#D4642C] group-hover:shadow-[#D4642C]/20">
                <s.icon size={22} />
              </div>
              <div className="w-8 h-8 rounded-full bg-slate-50 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-all duration-300 -translate-x-4 group-hover:translate-x-0 border border-slate-200 group-hover:border-[#FED7AA] group-hover:bg-[#FFF7ED]">
                <ArrowUpRight size={14} className="text-[#D4642C]" />
              </div>
            </div>
            
            <div className="text-3xl sm:text-4xl font-black text-slate-800 tracking-tight relative mb-1">{s.value}</div>
            <div className="text-[10px] font-black uppercase tracking-[0.2em] text-slate-400 relative group-hover:text-[#D4642C] transition-colors">{s.label}</div>
          </motion.div>))}
      </div>
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-5 sm:gap-6">
        <div className="rounded-3xl p-6 sm:p-8 bg-gradient-to-b from-white to-slate-50/50 border border-slate-200/60 shadow-[0_8px_30px_rgb(0,0,0,0.04)] relative overflow-hidden">
          <div className="absolute top-0 right-0 w-64 h-64 bg-[#D4642C]/10 rounded-full blur-3xl -translate-y-1/2 translate-x-1/2 pointer-events-none" />
          <div className="absolute bottom-0 left-0 w-64 h-64 bg-amber-500/10 rounded-full blur-3xl translate-y-1/2 -translate-x-1/2 pointer-events-none" />
          
          <div className="flex items-center gap-3 mb-6 relative z-10">
            <div className="w-10 h-10 rounded-xl bg-[#FFF7ED] flex items-center justify-center">
              <Zap size={20} className="text-[#D4642C]" />
            </div>
            <h3 className="text-xs sm:text-sm font-black uppercase tracking-[0.2em] text-slate-400">Quick Actions</h3>
          </div>
          
          <div className="space-y-4">
            <Link href="/enterprise/settings" className="flex items-center justify-between p-5 rounded-2xl bg-white/60 backdrop-blur-sm border border-slate-100 hover:border-[#FED7AA] hover:bg-white hover:shadow-lg hover:shadow-[#D4642C]/10 transition-all duration-300 group relative z-10">
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 rounded-xl bg-slate-50 shadow-inner flex items-center justify-center group-hover:scale-110 group-hover:bg-[#FFF7ED] transition-all duration-300 border border-slate-100 group-hover:border-[#FED7AA]">
                  <Settings size={20} className="text-slate-400 group-hover:text-[#D4642C] transition-colors" />
                </div>
                <div>
                  <div className="text-sm font-black text-slate-700 group-hover:text-[#D4642C] transition-colors mb-0.5">Company Settings</div>
                  <div className="text-[10px] text-slate-500 font-medium">Manage identity and billing</div>
                </div>
              </div>
              <div className="w-8 h-8 rounded-full bg-slate-100 flex items-center justify-center group-hover:bg-[#D4642C] transition-colors">
                <ChevronRight size={14} className="text-slate-400 group-hover:text-white group-hover:translate-x-0.5 transition-all" />
              </div>
            </Link>
            
            <Link href="/enterprise/workspace" className="flex items-center justify-between p-5 rounded-2xl bg-white/60 backdrop-blur-sm border border-slate-100 hover:border-[#FED7AA] hover:bg-white hover:shadow-lg hover:shadow-[#D4642C]/10 transition-all duration-300 group relative z-10">
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 rounded-xl bg-slate-50 shadow-inner flex items-center justify-center group-hover:scale-110 group-hover:bg-[#FFF7ED] transition-all duration-300 border border-slate-100 group-hover:border-[#FED7AA]">
                  <UserPlus size={20} className="text-slate-400 group-hover:text-[#D4642C] transition-colors" />
                </div>
                <div>
                  <div className="text-sm font-black text-slate-700 group-hover:text-[#D4642C] transition-colors mb-0.5">Add Employee</div>
                  <div className="text-[10px] text-slate-500 font-medium">Onboard new team members</div>
                </div>
              </div>
              <div className="w-8 h-8 rounded-full bg-slate-100 flex items-center justify-center group-hover:bg-[#D4642C] transition-colors">
                <ChevronRight size={14} className="text-slate-400 group-hover:text-white group-hover:translate-x-0.5 transition-all" />
              </div>
            </Link>
          </div>
        </div>
        
        <div className="rounded-3xl p-6 sm:p-8 bg-gradient-to-br from-slate-900 via-[#18110c] to-slate-900 border border-slate-800 shadow-[0_20px_40px_rgb(0,0,0,0.15)] relative overflow-hidden flex flex-col justify-center min-h-[240px]">
          <div className="absolute top-0 right-0 w-[400px] h-[400px] bg-[#D4642C]/10 rounded-full blur-[60px] -translate-y-1/2 translate-x-1/3 pointer-events-none" />
          <div className="absolute -bottom-10 -left-10 w-48 h-48 bg-amber-500/10 rounded-full blur-[40px] pointer-events-none" />
          <div className="absolute -top-10 -right-10 opacity-[0.03] rotate-12"><Crown size={200} className="text-white" /></div>
          
          <div className="relative z-10 flex flex-col h-full justify-between">
            <div>
              <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-lg bg-white/5 border border-white/10 text-white/60 text-[10px] font-black uppercase tracking-widest mb-4 backdrop-blur-sm">
                <Crown size={12} /> Plan Status
              </div>
              <div className="text-4xl sm:text-5xl font-black text-white tracking-tight mb-2 flex items-center gap-3">
                Enterprise <CheckCircle size={28} className="text-[#D4642C] drop-shadow-[0_0_15px_rgba(212,100,44,0.3)]" />
              </div>
            </div>
            
            <div className="mt-4 p-5 rounded-2xl bg-white/5 border border-white/10 backdrop-blur-md flex items-center justify-between">
               <div>
                 <div className="text-[10px] text-white/40 uppercase tracking-widest font-black mb-1">Status</div>
                 <div className="text-sm font-bold text-[#D4642C]">Active subscription</div>
               </div>
               <button className="px-5 py-2.5 rounded-xl bg-white/10 hover:bg-white/20 text-white text-[10px] font-black uppercase tracking-widest transition-all">
                 Manage Billing
               </button>
            </div>
          </div>
        </div>
      </div>

      {profile?.voucherCode && (
        <div className="rounded-3xl p-6 sm:p-10 relative overflow-hidden bg-white border border-slate-200/60 shadow-[0_8px_30px_rgb(0,0,0,0.04)] mt-2">
          <div className="absolute top-0 right-0 w-[500px] h-[500px] bg-[#FFF7ED] rounded-full blur-[80px] -translate-y-1/2 translate-x-1/3 pointer-events-none" />
          <div className="absolute bottom-0 left-0 w-64 h-64 bg-amber-50 rounded-full blur-[60px] translate-y-1/2 -translate-x-1/4 pointer-events-none" />
          
          <div className="relative z-10 flex flex-col lg:flex-row gap-8 items-start lg:items-center">
            <div className="flex-1">
              <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-lg bg-[#FFF7ED] text-[#D4642C] text-[10px] font-black uppercase tracking-widest mb-4 border border-[#FED7AA]">
                <Users size={14} /> Team Growth & Sync
              </div>
              <h3 className="text-2xl sm:text-3xl font-black tracking-tight text-slate-800 mb-3">Invite Your Team</h3>
              <p className="text-sm sm:text-base text-slate-500 max-w-lg leading-relaxed font-medium">
                Share your universal workspace link or invite code with team members. They can join instantly via the web portal or mobile app.
              </p>
              <div className="mt-4 flex items-center gap-3">
                <a
                  href={`/join-workspace?enterpriseId=${profile.id}&code=${profile.inviteCode || ''}&voucher=${profile.voucherCode}`}
                  target="_blank"
                  rel="noreferrer"
                  className="inline-flex items-center gap-1.5 text-xs font-bold text-[#D4642C] hover:text-[#BD5523] transition-colors"
                >
                  <ExternalLink size={13} /> Open Join Page Preview
                </a>
              </div>
            </div>
            
            <div className="w-full lg:w-[480px] space-y-3.5">
              {/* Universal Join Link */}
              <div className="bg-slate-50/80 backdrop-blur-xl border border-slate-200 shadow-inner rounded-2xl p-2.5 flex items-center gap-2 group hover:bg-white hover:border-[#FED7AA] hover:shadow-[0_0_15px_rgba(212,100,44,0.1)] transition-all duration-300">
                <div className="flex-1 pl-4 min-w-0 py-1">
                  <div className="text-[10px] font-black uppercase tracking-widest text-slate-400 mb-1 group-hover:text-[#D4642C] transition-colors flex items-center gap-1.5">
                    Universal Invite Link
                  </div>
                  <div className="text-xs sm:text-sm font-bold text-slate-700 truncate pr-2 group-hover:text-slate-900 transition-colors">
                    {(process.env.NEXT_PUBLIC_BASE_URL || "https://mycardshare.com")}/join-workspace?enterpriseId={profile.id}&code={profile.inviteCode || ''}
                  </div>
                </div>
                <button 
                  onClick={() => copyToClipboard(`${process.env.NEXT_PUBLIC_BASE_URL || "https://mycardshare.com"}/join-workspace?enterpriseId=${profile.id}&code=${profile.inviteCode || ''}&voucher=${profile.voucherCode}`, "link")} 
                  className="shrink-0 px-5 py-3 rounded-xl bg-[#D4642C] hover:bg-[#BD5523] text-white shadow-lg shadow-[#D4642C]/20 hover:shadow-[#D4642C]/40 transition-all text-[10px] sm:text-[11px] font-black uppercase tracking-widest active:scale-95"
                >
                  {copied === "link" ? "Copied!" : "Copy Link"}
                </button>
              </div>

              {/* Workspace Invite Code (8-digit App Code matching Mobile App Image 2) */}
              <div className="bg-slate-50/80 backdrop-blur-xl border border-slate-200 shadow-inner rounded-2xl p-3.5 flex items-center justify-between group hover:bg-white hover:border-amber-300 hover:shadow-[0_0_15px_rgba(217,119,6,0.1)] transition-all duration-300">
                <div className="pl-3 flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-[#FEF3C7] flex items-center justify-center shrink-0">
                    <Ticket className="text-[#D97706]" size={20} />
                  </div>
                  <div>
                    <div className="text-[10px] font-black uppercase tracking-widest text-slate-400 mb-0.5 group-hover:text-[#D97706] transition-colors flex items-center gap-1">
                      Workspace Invite Code <span className="text-[9px] px-1.5 py-0.5 rounded bg-amber-100 text-amber-800 font-bold">App & Web</span>
                    </div>
                    <div className="text-xl sm:text-2xl font-black tracking-widest text-slate-800 leading-none group-hover:text-slate-900 transition-colors font-mono">
                      {profile.inviteCode || profile.voucherCode}
                    </div>
                  </div>
                </div>
                <button 
                  onClick={() => copyToClipboard(profile.inviteCode || profile.voucherCode, "inviteCode")} 
                  className="w-11 h-11 rounded-xl bg-white border border-slate-200 text-slate-500 hover:text-white hover:bg-[#D97706] hover:border-[#D97706] hover:shadow-[0_4px_15px_rgba(217,119,6,0.3)] transition-all flex items-center justify-center shrink-0 active:scale-95 shadow-sm"
                  title="Copy 8-digit Workspace Invite Code"
                >
                  {copied === "inviteCode" ? <CheckCircle size={18} /> : <Copy size={18} />}
                </button>
              </div>

              {/* Master Voucher Code */}
              <div className="bg-slate-50/80 backdrop-blur-xl border border-slate-200 shadow-inner rounded-2xl p-3.5 flex items-center justify-between group hover:bg-white hover:border-emerald-200 hover:shadow-[0_0_15px_rgba(16,185,129,0.1)] transition-all duration-300">
                <div className="pl-3">
                  <div className="text-[10px] font-black uppercase tracking-widest text-slate-400 mb-0.5 group-hover:text-emerald-500 transition-colors flex items-center gap-1">
                    Voucher Code <span className="text-[9px] px-1.5 py-0.5 rounded bg-emerald-100 text-emerald-800 font-bold">Master</span>
                  </div>
                  <div className="text-xl sm:text-2xl font-black tracking-widest text-slate-800 leading-none group-hover:text-slate-900 transition-colors font-mono">
                    {profile.voucherCode}
                  </div>
                </div>
                <button 
                  onClick={() => copyToClipboard(profile.voucherCode, "code")} 
                  className="w-11 h-11 rounded-xl bg-white border border-slate-200 text-slate-500 hover:text-white hover:bg-emerald-500 hover:border-emerald-500 hover:shadow-[0_4px_15px_rgba(16,185,129,0.3)] transition-all flex items-center justify-center shrink-0 active:scale-95 shadow-sm"
                  title="Copy Voucher Code"
                >
                  {copied === "code" ? <CheckCircle size={18} /> : <Copy size={18} />}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
