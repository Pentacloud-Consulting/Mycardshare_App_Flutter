"use client";

import { motion } from "framer-motion";
import {
  LayoutGrid,
  Users,
  Megaphone,
  Filter,
  Link as LinkIcon,
  FileText,
  Settings,
  LogOut,
  Download,
  Moon,
  Bell,
  Cloud,
  ChevronRight,
  TrendingUp,
  Activity,
  Clock,
} from "lucide-react";
import { useState } from "react";
import { UiloraBrandButton } from "../UIComponents/Button/tsx/UiloraModernButtons";

const fadeUp = {
  hidden: { opacity: 0, y: 10 },
  visible: (i = 0) => ({
    opacity: 1,
    y: 0,
    transition: { duration: 0.4, delay: i * 0.05, ease: [0.16, 1, 0.3, 1] },
  }),
};

export default function EnterpriseDashboard({ userData, refreshUserData }) {
  const [activeTab, setActiveTab] = useState("dashboard");

  const menuItems = [
    { id: "dashboard", label: "Overview", icon: LayoutGrid },
    { id: "employees", label: "Workforce", icon: Users },
    { id: "campaigns", label: "Campaigns", icon: Megaphone },
    { id: "leads", label: "Leads", icon: Filter },
    { id: "crm", label: "Integrations", icon: LinkIcon },
    { id: "crm-logs", label: "Audit Logs", icon: FileText },
    { id: "settings", label: "Configuration", icon: Settings },
  ];

  return (
    <div className="flex min-h-screen bg-[#05091a] text-slate-100 overflow-hidden">
      {/* ── SIDEBAR ── */}
      <aside className="w-64 border-r border-white/5 bg-white/[0.02] backdrop-blur-3xl flex flex-col p-6 gap-8 relative z-20">
        <div className="flex items-center gap-3 px-2">
          <img
            src="/logo/image (4).png"
            alt="My Card Share Logo"
            className="w-44 h-auto object-contain scale-[1.15] origin-left"
          />
          <div className="hidden">
            <div className="font-black text-white tracking-widest text-sm italic">
              My Card Share
            </div>
            <div className="text-[10px] text-sky-400 font-bold tracking-widest uppercase">
              Console
            </div>
          </div>
        </div>

        <nav className="flex-1 flex flex-col gap-1">
          {menuItems.map((item) => (
            <button
              key={item.id}
              onClick={() => setActiveTab(item.id)}
              className={`flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-bold transition-all relative group ${
                activeTab === item.id
                  ? "bg-sky-500/10 text-sky-400 border border-sky-500/20"
                  : "text-slate-400 hover:text-white hover:bg-white/5"
              }`}
            >
              <item.icon size={18} />
              {item.label}
              {activeTab === item.id && (
                <motion.div
                  layoutId="nav-glow"
                  className="absolute left-0 w-1 h-6 bg-sky-400 rounded-full shadow-[0_0_8px_#38bdf8]"
                />
              )}
            </button>
          ))}
        </nav>

        <button className="flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-bold text-rose-400 hover:bg-rose-500/10 transition-all border border-transparent hover:border-rose-500/20 mt-auto">
          <LogOut size={18} />
          Exit Console
        </button>
      </aside>

      {/* ── MAIN CONTENT ── */}
      <main className="flex-1 overflow-y-auto p-6 md:p-10 flex flex-col gap-8 md:gap-10">
        <header className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl md:text-3xl font-black text-white tracking-tight mb-2">
              Overview, {userData.companyName || "Corporate"}
            </h1>
            <div className="flex items-center gap-2 text-xs font-bold text-slate-500 uppercase tracking-widest">
              <Clock size={14} />
              {new Date().toLocaleDateString("en-US", {
                weekday: "short",
                year: "numeric",
                month: "short",
                day: "numeric",
              })}
            </div>
          </div>

          <div className="flex items-center gap-4">
            <div className="flex bg-white/5 border border-white/10 rounded-2xl p-1">
              <button className="p-2 text-slate-400 hover:text-white transition-all">
                <Download size={20} />
              </button>
              <button className="p-2 text-slate-400 hover:text-white transition-all">
                <Moon size={20} />
              </button>
              <button className="p-2 text-slate-400 hover:text-white transition-all relative">
                <Bell size={20} />
                <span className="absolute top-2 right-2 w-2 h-2 bg-rose-500 rounded-full" />
              </button>
            </div>

            <div className="flex items-center gap-3 pl-4 border-l border-white/10">
              <div className="text-right">
                <div className="text-sm font-bold text-white leading-none mb-1">
                  {userData.fullName || "Admin"}
                </div>
                <div className="text-[10px] font-bold text-sky-400 uppercase tracking-widest">
                  System Admin
                </div>
              </div>
              <div className="w-10 h-10 rounded-xl bg-sky-500/20 flex items-center justify-center text-sky-400 font-black border border-sky-500/30">
                {userData.fullName?.[0] || "A"}
              </div>
            </div>
          </div>
        </header>

        {/* ── STATS GRID ── */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3 md:gap-6">
          {[
            {
              label: "Total Workforce",
              value: "148",
              icon: Users,
              color: "text-sky-400",
              bg: "bg-sky-400/10",
              trend: "+12%",
            },
            {
              label: "Leads Captured",
              value: "2,491",
              icon: Filter,
              color: "text-emerald-400",
              bg: "bg-emerald-400/10",
              trend: "+24%",
            },
            {
              label: "Campaign Reach",
              value: "48.2k",
              icon: Megaphone,
              color: "text-amber-400",
              bg: "bg-amber-400/10",
              trend: "Optimal",
            },
            {
              label: "Sync Status",
              value: "100%",
              icon: Activity,
              color: "text-violet-400",
              bg: "bg-violet-400/10",
              trend: "Live",
            },
          ].map((stat, i) => (
            <motion.div
              key={stat.label}
              variants={fadeUp}
              initial="hidden"
              animate="visible"
              custom={i}
              className="p-3 md:p-6 rounded-2xl md:rounded-3xl bg-white/[0.03] border border-white/5 backdrop-blur-sm hover:border-white/10 transition-all"
            >
              <div className="flex justify-between items-start mb-4">
                <div className={`p-1.5 md:p-2.5 rounded-lg md:rounded-xl ${stat.bg} ${stat.color}`}>
                  <stat.icon size={16} className="md:w-[22px] md:h-[22px]" />
                </div>
                <span className="hidden sm:block text-[9px] md:text-[10px] font-bold text-sky-400 bg-sky-400/10 px-2 py-0.5 md:px-2.5 md:py-1 rounded-full uppercase tracking-widest">
                  {stat.trend}
                </span>
              </div>
              <div className="text-lg md:text-3xl font-black text-white mb-0.5 md:mb-1 truncate">
                {stat.value}
              </div>
              <div className="text-[7px] md:text-[10px] font-bold text-slate-500 uppercase tracking-[0.05em] md:tracking-[0.2em] truncate">
                {stat.label}
              </div>
            </motion.div>
          ))}
        </div>

        {/* ── RECENT ACTIVITY TABLE ── */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 flex-1">
          <div className="lg:col-span-2 rounded-[2rem] md:rounded-[2.5rem] bg-white/[0.02] border border-white/5 p-6 md:p-8 flex flex-col">
            <div className="flex items-center justify-between mb-8">
              <h3 className="text-xl font-bold text-white flex items-center gap-3">
                <TrendingUp size={22} className="text-sky-400" />
                Workforce Activity
              </h3>
              <button className="text-xs font-bold text-sky-400 uppercase tracking-widest hover:text-sky-300 flex items-center gap-1">
                View All <ChevronRight size={14} />
              </button>
            </div>

            <div className="overflow-x-auto">
              <table className="w-full text-left">
                <thead>
                  <tr className="border-b border-white/5">
                    <th className="pb-4 text-[10px] font-bold text-slate-500 uppercase tracking-widest">
                      Employee
                    </th>
                    <th className="pb-4 text-[10px] font-bold text-slate-500 uppercase tracking-widest">
                      Leads
                    </th>
                    <th className="pb-4 text-[10px] font-bold text-slate-500 uppercase tracking-widest">
                      Impressions
                    </th>
                    <th className="pb-4 text-[10px] font-bold text-slate-500 uppercase tracking-widest">
                      Status
                    </th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-white/[0.02]">
                  {[
                    {
                      name: "Sarah Jenkins",
                      role: "Real Estate Agent",
                      leads: 42,
                      views: "1.2k",
                      status: "Active",
                    },
                    {
                      name: "Michael Chen",
                      role: "Portfolio Manager",
                      leads: 28,
                      views: "840",
                      status: "Active",
                    },
                    {
                      name: "Aarav Gupta",
                      role: "Broker Partner",
                      leads: 64,
                      views: "2.5k",
                      status: "Top Performer",
                    },
                    {
                      name: "Elena Rossi",
                      role: "Client Advisor",
                      leads: 15,
                      views: "340",
                      status: "Active",
                    },
                  ].map((row, i) => (
                    <tr
                      key={i}
                      className="group hover:bg-white/[0.01] transition-all"
                    >
                      <td className="py-4">
                        <div className="flex items-center gap-3">
                          <div className="w-9 h-9 rounded-xl bg-white/5 flex items-center justify-center font-bold text-xs">
                            {row.name
                              .split(" ")
                              .map((n) => n[0])
                              .join("")}
                          </div>
                          <div>
                            <div className="text-sm font-bold text-white">
                              {row.name}
                            </div>
                            <div className="text-[10px] text-slate-500 font-medium uppercase tracking-wider">
                              {row.role}
                            </div>
                          </div>
                        </div>
                      </td>
                      <td className="py-4 text-sm font-bold text-white">
                        {row.leads}
                      </td>
                      <td className="py-4 text-sm font-bold text-white">
                        {row.views}
                      </td>
                      <td className="py-4">
                        <span
                          className={`text-[10px] font-bold px-2.5 py-1 rounded-lg uppercase tracking-widest ${row.status === "Top Performer" ? "bg-sky-500/10 text-sky-400" : "bg-white/5 text-slate-400"}`}
                        >
                          {row.status}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>

          <div className="rounded-[2rem] md:rounded-[2.5rem] bg-white/[0.02] border border-white/5 p-6 md:p-8">
            <h3 className="text-xl font-bold text-white mb-8 flex items-center gap-3">
              <Activity size={22} className="text-sky-400" />
              Quick Actions
            </h3>
            <div className="flex flex-col gap-3">
              {[
                {
                  label: "Invite Workforce",
                  icon: Users,
                  desc: "Add agents to brokerage",
                },
                {
                  label: "System Config",
                  icon: Settings,
                  desc: "Manage billing & API",
                },
                {
                  label: "Sync CRM",
                  icon: LinkIcon,
                  desc: "Instant leads push",
                },
                {
                  label: "Brand Asset",
                  icon: Cloud,
                  desc: "Logo & Banner setup",
                },
              ].map((action) => (
                <UiloraBrandButton
                  key={action.label}
                  variant="outline"
                  className="p-4 sm:py-8 rounded-2xl bg-white/[0.03] border border-white/5 hover:border-sky-500/30 transition-all flex items-center justify-start gap-4 group text-left normal-case tracking-normal"
                >
                  <div className="w-10 h-10 rounded-xl bg-white/5 flex items-center justify-center text-slate-400 group-hover:text-sky-400 transition-colors">
                    <action.icon size={20} />
                  </div>
                  <div>
                    <div className="text-sm font-bold text-white group-hover:text-sky-400 transition-colors">
                      {action.label}
                    </div>
                    <div className="text-[10px] text-slate-500 font-medium">
                      {action.desc}
                    </div>
                  </div>
                </UiloraBrandButton>
              ))}
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
