"use client";

import { motion } from "framer-motion";
import { User, Building2, Mail, Shield, Calendar, Clock, Copy, CheckCircle2, ChevronRight, Activity } from "lucide-react";
import { useAuth } from "@/lib/auth-context";
import { useState } from "react";

export default function EnterpriseProfilePage() {
  const { userData } = useAuth();
  const [copied, setCopied] = useState(false);

  const formatDate = (dateValue) => {
    if (!dateValue) return "N/A";
    const d = dateValue.seconds ? new Date(dateValue.seconds * 1000) : new Date(dateValue);
    if (isNaN(d.getTime())) return "N/A";
    return new Intl.DateTimeFormat("en-US", { year: "numeric", month: "short", day: "numeric", hour: "2-digit", minute: "2-digit" }).format(d);
  };

  const isApproved = userData?.status === "approved";
  const slug = userData?.slug || userData?.companySlug || userData?.cardSlug || "Not Set";

  const handleCopy = () => {
    navigator.clipboard.writeText(slug);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

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
          <h1 className="text-2xl sm:text-3xl font-black tracking-tight text-slate-900">Organization Profile</h1>
          <p className="text-xs sm:text-sm mt-1 text-slate-500 font-medium">Manage your enterprise identity and administrative settings</p>
        </div>
        <div className="hidden sm:flex items-center gap-2 px-4 py-2 bg-white rounded-xl border border-slate-200 shadow-sm text-sm font-semibold text-slate-700">
           <Activity size={16} className="text-emerald-500" />
           System Normal
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 lg:gap-8">
        
        {/* Left Sidebar (Floating style) */}
        <div className="lg:col-span-4 flex flex-col gap-6">
          <motion.div 
            initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.5, ease: "easeOut" }}
            className="rounded-[2rem] p-8 flex flex-col items-center justify-center text-center relative overflow-hidden bg-white/80 backdrop-blur-xl border border-white shadow-[0_8px_30px_rgb(0,0,0,0.04)] ring-1 ring-slate-200/50 hover:shadow-[0_8px_40px_rgba(212,100,44,0.08)] transition-all duration-500 group"
          >
            {/* Ambient Card Background */}
            <div className="absolute inset-0 bg-gradient-to-br from-[#FFF7ED]/50 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500" />
            
            <div className="relative w-32 h-32 rounded-[2rem] flex items-center justify-center mb-6 z-10 bg-white shadow-xl shadow-[#D4642C]/10 border border-slate-100 group-hover:scale-105 group-hover:-translate-y-1 transition-all duration-500">
              <div className="absolute inset-0 rounded-[2rem] border-2 border-transparent group-hover:border-[#FED7AA] transition-colors duration-500" />
              {userData?.companyLogo ? (
                  <img src={userData.companyLogo} alt="Logo" className="w-full h-full object-contain p-4 drop-shadow-sm" />
              ) : (
                  <User size={48} className="text-[#D4642C]/80" />
              )}
            </div>
            
            <h2 className="text-2xl font-black text-slate-900 tracking-tight w-full mb-1 relative z-10">
              {userData?.displayName || "Enterprise Admin"}
            </h2>
            <p className="text-sm font-medium text-slate-500 w-full mb-8 relative z-10">
              {userData?.email}
            </p>
            
            <div className="inline-flex items-center gap-2 px-5 py-2.5 rounded-xl bg-gradient-to-r from-[#FFF7ED] to-amber-50 border border-[#FED7AA] shadow-sm relative z-10 group-hover:shadow-md transition-shadow">
              <Shield size={16} className="text-[#D4642C]" />
              <span className="text-xs font-black uppercase tracking-[0.15em] text-[#D4642C]">
                Enterprise Admin
              </span>
            </div>
          </motion.div>

          <motion.div 
            initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.5, delay: 0.1, ease: "easeOut" }}
            className="rounded-[2rem] p-6 bg-slate-900 text-white relative overflow-hidden shadow-2xl shadow-slate-900/20 border border-slate-800"
          >
            <div className="absolute -top-24 -right-24 w-48 h-48 bg-[#D4642C]/20 rounded-full blur-[40px]" />
            <div className="relative z-10 flex flex-col gap-4">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-white/10 flex items-center justify-center backdrop-blur-md">
                  <Shield size={20} className="text-[#F28C59]" />
                </div>
                <div>
                  <h4 className="text-sm font-bold text-white">Advanced Security</h4>
                  <p className="text-[10px] text-slate-400 font-medium">SSO & MFA Enabled</p>
                </div>
              </div>
            </div>
          </motion.div>
        </div>

        {/* Right Content Area */}
        <div className="lg:col-span-8 space-y-6">
          
          <motion.div 
            initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.5, delay: 0.2, ease: "easeOut" }}
            className="rounded-[2rem] p-8 relative overflow-hidden bg-white/80 backdrop-blur-xl border border-white shadow-[0_8px_30px_rgb(0,0,0,0.04)] ring-1 ring-slate-200/50 hover:shadow-[0_8px_40px_rgba(212,100,44,0.06)] transition-shadow duration-500"
          >
            <div className="flex items-center justify-between mb-8">
              <h3 className="text-sm font-black text-slate-900 uppercase tracking-widest flex items-center gap-3">
                <div className="w-8 h-8 rounded-lg bg-[#FFF7ED] flex items-center justify-center text-[#D4642C]">
                  <Building2 size={16} />
                </div>
                Organization Details
              </h3>
            </div>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
              <div className="group">
                <p className="text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] mb-2 flex items-center gap-2">
                  Company Name <ChevronRight size={12} className="opacity-0 -ml-2 group-hover:opacity-100 group-hover:ml-0 transition-all text-[#D4642C]" />
                </p>
                <p className="text-lg font-bold text-slate-800 tracking-tight group-hover:text-[#D4642C] transition-colors">
                  {userData?.companyName || "Not Provided"}
                </p>
              </div>

              <div className="group">
                <p className="text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] mb-2 flex items-center gap-2">
                  Workspace Slug <ChevronRight size={12} className="opacity-0 -ml-2 group-hover:opacity-100 group-hover:ml-0 transition-all text-[#D4642C]" />
                </p>
                <div 
                  onClick={handleCopy}
                  className="inline-flex items-center gap-3 px-4 py-2.5 rounded-xl border border-slate-200 bg-slate-50/50 hover:bg-white hover:border-[#FED7AA] hover:shadow-sm cursor-pointer transition-all group-hover:shadow-[#D4642C]/5"
                >
                  <p className="text-sm font-mono font-medium text-slate-600 truncate">
                    {slug}
                  </p>
                  {copied ? <CheckCircle2 size={16} className="text-emerald-500" /> : <Copy size={16} className="text-slate-400 group-hover:text-[#D4642C] transition-colors" />}
                </div>
              </div>

              <div className="group">
                <p className="text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] mb-2 flex items-center gap-2">
                  Account Status <ChevronRight size={12} className="opacity-0 -ml-2 group-hover:opacity-100 group-hover:ml-0 transition-all text-[#D4642C]" />
                </p>
                <div className="inline-flex items-center gap-3 px-4 py-2.5 rounded-xl border border-emerald-100 bg-emerald-50/50">
                  <span className="relative flex h-2.5 w-2.5">
                    {isApproved && <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-50"></span>}
                    <span className={`relative inline-flex rounded-full h-2.5 w-2.5 ${isApproved ? 'bg-emerald-500 shadow-sm shadow-emerald-500/50' : 'bg-amber-500'}`}></span>
                  </span>
                  <span className="text-sm font-black text-emerald-700 uppercase tracking-widest">
                    {userData?.status || "Pending"}
                  </span>
                </div>
              </div>

              <div className="group">
                <p className="text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] mb-2 flex items-center gap-2">
                  Registered On <ChevronRight size={12} className="opacity-0 -ml-2 group-hover:opacity-100 group-hover:ml-0 transition-all text-[#D4642C]" />
                </p>
                <div className="flex items-center gap-3 px-4 py-2.5 rounded-xl border border-slate-200 bg-slate-50/50">
                  <Calendar size={16} className="text-slate-400" />
                  <p className="text-sm font-semibold text-slate-700">
                    {formatDate(userData?.createdAt)}
                  </p>
                </div>
              </div>
            </div>
          </motion.div>

          <motion.div 
            initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.5, delay: 0.3, ease: "easeOut" }}
            className="rounded-[2rem] p-8 relative overflow-hidden bg-white/80 backdrop-blur-xl border border-white shadow-[0_8px_30px_rgb(0,0,0,0.04)] ring-1 ring-slate-200/50 hover:shadow-[0_8px_40px_rgba(99,102,241,0.05)] transition-shadow duration-500"
          >
            <div className="flex items-center justify-between mb-8">
              <h3 className="text-sm font-black text-slate-900 uppercase tracking-widest flex items-center gap-3">
                <div className="w-8 h-8 rounded-lg bg-[#FFF7ED] flex items-center justify-center text-[#D4642C]">
                  <Mail size={16} />
                </div>
                Contact Information
              </h3>
            </div>
            
            <div className="space-y-4">
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 p-6 rounded-2xl border border-slate-200 bg-white hover:border-[#FED7AA] hover:shadow-md hover:shadow-[#D4642C]/5 transition-all duration-300 group">
                <div>
                  <p className="text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] mb-1.5 flex items-center gap-2">
                    Primary Email <ChevronRight size={12} className="opacity-0 -ml-2 group-hover:opacity-100 group-hover:ml-0 transition-all text-[#D4642C]" />
                  </p>
                  <p className="text-base font-bold text-slate-800 tracking-tight">
                    {userData?.email}
                  </p>
                </div>
                <div className="shrink-0 flex items-center">
                  <div className="flex items-center gap-2 px-4 py-2 rounded-xl bg-emerald-50 border border-emerald-100 shadow-sm">
                    <CheckCircle2 size={14} className="text-emerald-500" />
                    <span className="text-[10px] font-black uppercase tracking-[0.2em] text-emerald-700">
                      Verified
                    </span>
                  </div>
                </div>
              </div>
              
              <div className="p-5 rounded-2xl bg-gradient-to-r from-[#FFF7ED] to-amber-50 border border-[#FED7AA] flex gap-4 items-start shadow-inner">
                <div className="w-8 h-8 rounded-full bg-white shadow-sm flex items-center justify-center shrink-0">
                  <Clock size={14} className="text-[#D4642C]" />
                </div>
                <p className="text-xs font-medium leading-relaxed text-slate-600 pt-1.5">
                  Profile settings are currently managed through the central administrative portal. To update your company identity, please contact support or your account manager.
                </p>
              </div>
            </div>
          </motion.div>

        </div>
      </div>
    </div>
  );
}
