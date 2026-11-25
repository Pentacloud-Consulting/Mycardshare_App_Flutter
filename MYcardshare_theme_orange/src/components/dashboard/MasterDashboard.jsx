"use client";

import { motion } from "framer-motion";
import {
  Building2,
  ShieldCheck,
  Clock,
  Zap,
  LogOut,
  Search,
  CheckCircle2,
  AlertCircle,
  MoreVertical,
  Activity,
  Globe,
  Settings,
  ArrowRight,
} from "lucide-react";
import { useState } from "react";

const fadeUp = {
  hidden: { opacity: 0, y: 10 },
  visible: (i = 0) => ({
    opacity: 1,
    y: 0,
    transition: { duration: 0.4, delay: i * 0.05, ease: [0.16, 1, 0.3, 1] },
  }),
};

export default function MasterDashboard({ userData, refreshUserData }) {
  const [activeTab, setActiveTab] = useState("overview");

  return (
    <div className="min-h-screen bg-[#02040a] text-slate-100 p-8 md:p-12 overflow-x-hidden">
      {/* ── HEADER ── */}
      <header className="flex flex-col md:flex-row md:items-center justify-between gap-8 mb-12">
        <div className="flex items-center gap-6">
          <div className="w-16 h-16 rounded-2xl bg-sky-500/20 flex items-center justify-center text-sky-400 border border-sky-400/20 shadow-[0_0_20px_rgba(56,189,248,0.1)]">
            <ShieldCheck size={32} />
          </div>
          <div>
            <h1 className="text-4xl font-black text-white tracking-tighter mb-1">
              Nexus Master Console
            </h1>
            <p className="text-slate-500 font-bold uppercase tracking-[0.2em] text-[10px] flex items-center gap-2">
              <span className="w-2 h-2 rounded-full bg-sky-400 animate-pulse" />
              Root Guardians Active
            </p>
          </div>
        </div>

        <div className="flex items-center gap-4 h-fit bg-white/[0.02] border border-white/5 p-2 rounded-2xl backdrop-blur-3xl">
          <button className="px-6 py-3 rounded-xl hover:bg-white/5 text-slate-400 hover:text-white transition-all text-xs font-black uppercase tracking-widest flex items-center gap-2">
            <Settings size={16} /> Config
          </button>
          <button className="px-6 py-3 rounded-xl bg-rose-500 text-white shadow-lg shadow-rose-500/20 transition-all text-xs font-black uppercase tracking-widest flex items-center gap-2 hover:bg-rose-600">
            <LogOut size={16} /> Logout
          </button>
        </div>
      </header>

      {/* ── NAVIGATION ── */}
      <div className="flex gap-4 mb-12 overflow-x-auto pb-4 no-scrollbar">
        {[
          "Overview",
          "Companies",
          "Pending Admins",
          "Platform Security",
          "Financials",
        ].map((tab, i) => (
          <button
            key={tab}
            onClick={() => setActiveTab(tab.toLowerCase())}
            className={`px-8 py-4 rounded-2xl text-[10px] font-black uppercase tracking-widest transition-all whitespace-nowrap border ${
              activeTab === tab.toLowerCase()
                ? "bg-sky-500 text-white border-sky-400"
                : "bg-white/[0.02] text-slate-500 border-white/5 hover:border-white/10 hover:text-slate-300"
            }`}
          >
            {tab}
          </button>
        ))}
      </div>

      {/* ── STATS ROW ── */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-12">
        {[
          {
            label: "Active Partners",
            value: "24",
            icon: Building2,
            color: "text-sky-400",
            bg: "bg-sky-400/10",
            trend: "+12%",
          },
          {
            label: "Pending Reviews",
            value: "07",
            icon: Clock,
            color: "text-amber-400",
            bg: "bg-amber-400/10",
            trend: "Action Required",
          },
          {
            label: "Global Users",
            value: "8,402",
            icon: Globe,
            color: "text-emerald-400",
            bg: "bg-emerald-400/10",
            trend: "Secure",
          },
          {
            label: "System Uptime",
            value: "99.9%",
            icon: Zap,
            color: "text-violet-400",
            bg: "bg-violet-400/10",
            trend: "Optimal",
          },
        ].map((stat, i) => (
          <motion.div
            key={stat.label}
            variants={fadeUp}
            initial="hidden"
            animate="visible"
            custom={i}
            className="p-8 rounded-[2rem] bg-white/[0.02] border border-white/5 backdrop-blur-sm relative overflow-hidden group"
          >
            <div className="absolute top-0 right-0 w-32 h-32 bg-sky-500/[0.01] blur-3xl rounded-full" />
            <div className="relative z-10">
              <div className="flex justify-between items-start mb-6">
                <div className={`p-3 rounded-2xl ${stat.bg} ${stat.color}`}>
                  <stat.icon size={28} />
                </div>
                <span className="text-[10px] font-black uppercase tracking-widest text-sky-400">
                  {stat.trend}
                </span>
              </div>
              <div className="text-4xl font-black text-white mb-2">
                {stat.value}
              </div>
              <div className="text-[10px] font-bold text-slate-500 uppercase tracking-[0.25em]">
                {stat.label}
              </div>
            </div>
          </motion.div>
        ))}
      </div>

      {/* ── CONTENT GRID ── */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div className="lg:col-span-2 rounded-[2.5rem] bg-white/[0.02] border border-white/5 p-10">
          <div className="flex items-center justify-between mb-10">
            <h3 className="text-2xl font-black text-white flex items-center gap-4 tracking-tighter">
              <Activity size={24} className="text-sky-400" />
              Partner Admissions
            </h3>
            <div className="relative">
              <Search
                size={16}
                className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-500"
              />
              <input
                type="text"
                placeholder="Lookup partner..."
                className="bg-white/5 border border-white/10 rounded-xl py-2.5 pl-10 pr-4 text-[10px] uppercase font-bold tracking-widest focus:outline-none focus:border-sky-500/50 transition-all text-white w-64"
              />
            </div>
          </div>

          <div className="space-y-4">
            {[
              {
                name: "Lux Equity Realtors",
                admin: "admin@luxequity.re",
                status: "Active",
                date: "Apr 12, 2026",
              },
              {
                name: "Global Wealth Hub",
                admin: "marcus@gwh.com",
                status: "Pending",
                date: "Apr 14, 2026",
              },
              {
                name: "Skyline Partners",
                admin: "elena@skyline.io",
                status: "Active",
                date: "Mar 28, 2026",
              },
              {
                name: "Apex Financial",
                admin: "contact@apex.fin",
                status: "Suspended",
                date: "Feb 15, 2026",
              },
            ].map((partner, i) => (
              <div
                key={i}
                className="flex items-center justify-between p-6 rounded-3xl bg-white/[0.02] border border-white/5 hover:bg-white/[0.04] transition-all group"
              >
                <div className="flex items-center gap-4">
                  <div className="w-12 h-12 rounded-2xl bg-white/5 flex items-center justify-center font-black text-sky-400 border border-white/10">
                    {partner.name[0]}
                  </div>
                  <div>
                    <div className="font-bold text-white text-base group-hover:text-sky-400 transition-colors">
                      {partner.name}
                    </div>
                    <div className="text-[10px] text-slate-500 font-bold uppercase tracking-wider">
                      {partner.admin}
                    </div>
                  </div>
                </div>
                <div className="flex items-center gap-8">
                  <div className="text-right hidden md:block">
                    <div className="text-[10px] text-slate-500 font-bold uppercase tracking-widest mb-1">
                      Joined
                    </div>
                    <div className="text-xs font-bold text-white">
                      {partner.date}
                    </div>
                  </div>
                  <div
                    className={`px-4 py-1.5 rounded-full text-[10px] font-black uppercase tracking-widest border ${
                      partner.status === "Active"
                        ? "bg-emerald-500/10 text-emerald-400 border-emerald-500/20"
                        : partner.status === "Pending"
                          ? "bg-amber-500/10 text-amber-400 border-amber-500/20"
                          : "bg-rose-500/10 text-rose-400 border-rose-500/20"
                    }`}
                  >
                    {partner.status}
                  </div>
                  <button className="text-slate-500 hover:text-white transition-colors">
                    <MoreVertical size={20} />
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="rounded-[2.5rem] bg-white/[0.02] border border-white/5 p-10 flex flex-col gap-8">
          <h3 className="text-2xl font-black text-white tracking-tighter">
            System Commands
          </h3>

          <div className="flex flex-col gap-4">
            {[
              {
                label: "Pending Approvals",
                count: "7",
                icon: Activity,
                color: "text-amber-400",
              },
              {
                label: "Platform Health",
                count: "100%",
                icon: CheckCircle2,
                color: "text-emerald-400",
              },
              {
                label: "Security Threats",
                count: "0",
                icon: AlertCircle,
                color: "text-sky-400",
              },
            ].map((cmd) => (
              <button
                key={cmd.label}
                className="w-full flex items-center justify-between p-6 rounded-3xl bg-white/[0.03] border border-white/5 hover:border-sky-500/30 transition-all group text-left"
              >
                <div className="flex items-center gap-4">
                  <cmd.icon size={24} className={cmd.color} />
                  <div>
                    <div className="text-sm font-black text-white group-hover:text-sky-400">
                      {cmd.label}
                    </div>
                    <div className="text-[10px] font-bold text-slate-500 uppercase tracking-widest">
                      Global Overview
                    </div>
                  </div>
                </div>
                <div className="text-lg font-black text-white">{cmd.count}</div>
              </button>
            ))}
          </div>

          <div className="mt-auto p-8 rounded-[2rem] bg-gradient-to-br from-sky-500/10 to-transparent border border-sky-400/10">
            <h4 className="text-sm font-black text-white uppercase tracking-widest mb-2">
              Master Support
            </h4>
            <p className="text-slate-400 text-xs leading-relaxed mb-6">
              Need assistance with root-level configurations or cluster
              management?
            </p>
            <button className="w-full py-4 rounded-xl bg-sky-500 text-white font-black uppercase text-[10px] tracking-widest shadow-lg shadow-sky-500/20 hover:bg-sky-400 transition-all flex items-center justify-center gap-2">
              Open Support Ticket <ArrowRight size={14} />
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
