"use client";

import React, { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  Users,
  LayoutDashboard,
  Megaphone,
  UserPlus,
  ArrowRight,
  TrendingUp,
  Briefcase,
  History,
  Settings,
  Building2,
  ShieldCheck,
  Clock,
  ChevronRight,
  Plus,
  RefreshCw,
} from "lucide-react";
import Link from "next/link";
import { authFetch } from "@/lib/api";
import { UiloraBrandButton } from "../UIComponents/Button/tsx/UiloraModernButtons";

export default function CorporateDashboard({ userData, onSignOut }) {
  const [activeTab, setActiveTab] = useState("overview");
  const [data, setData] = useState({
    brokerage: null,
    platform: null,
  });
  const [loading, setLoading] = useState(true);
  const isMaster = userData?.role === "super_admin";

  useEffect(() => {
    fetchDashboardData();
  }, [activeTab]);

  const fetchDashboardData = async () => {
    setLoading(true);
    try {
      const res = await authFetch("/api/company/stats");
      const result = await res.json();

      if (result.success) {
        const stats = result.data.stats;
        setData({
          brokerage: {
            totalWorkforce: stats.totalWorkforce || 0,
            activeCampaigns: stats.activeCampaigns || 0,
            totalLeads: stats.totalLeads || 0,
            weeklyEngagement: stats.engagement || 0,
            trend: stats.weeklyEngagementTrends || "+0%",
          },
          platform: stats || null,
        });
      }
    } catch (err) {
      console.error("Failed to load dashboard data", err);
    } finally {
      setLoading(false);
    }
  };

  const renderOverview = () => (
    <div className="space-y-12">
      {/* Stats Grid */}
      <div className="grid grid-cols-4 md:grid-cols-2 lg:grid-cols-4 gap-2 md:gap-6">
        {[
          {
            label: "Brokerage Workforce",
            value: data.brokerage?.totalWorkforce || "0",
            icon: Users,
            color: "text-blue-400",
          },
          {
            label: "Active Campaigns",
            value: data.brokerage?.activeCampaigns || "0",
            icon: Megaphone,
            color: "text-indigo-400",
          },
          {
            label: "Total Leads",
            value: data.brokerage?.totalLeads || "0",
            icon: TrendingUp,
            color: "text-sky-400",
          },
          {
            label: "Engagement",
            value: data.brokerage?.weeklyEngagement || "0%",
            icon: History,
            color: "text-emerald-400",
            trend: data.platform?.weeklyEngagementTrends || "+0%",
          },
        ].map((stat, i) => (
          <motion.div
            key={i}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: i * 0.1 }}
            className="bg-white backdrop-blur-xl border border-blue-100 rounded-xl md:rounded-[2.5rem] p-2 md:p-8 hover:border-blue-200 transition-all group flex flex-col items-center justify-center text-center md:items-start md:text-left aspect-square md:aspect-auto shadow-sm"
          >
            <div className="flex justify-between items-start mb-1.5 md:mb-6 w-full">
              <div
                className={`p-1.5 md:p-4 rounded-lg md:rounded-xl bg-blue-50 ${stat.color} group-hover:scale-110 transition-transform mx-auto md:mx-0`}
              >
                <stat.icon size={12} className="md:w-6 md:h-6" />
              </div>
              <div className="hidden sm:block text-[9px] font-bold text-emerald-400 bg-emerald-400/10 px-2 py-1 rounded-lg">
                {stat.trend || "+0%"}
              </div>
            </div>
            <div className="text-sm md:text-3xl font-black text-blue-900 mb-0.5 md:mb-1 font-display tracking-tight truncate w-full">
              {loading ? "..." : stat.value}
            </div>
            <div className="text-[6px] md:text-xs font-bold text-blue-400 uppercase tracking-tight md:tracking-widest whitespace-nowrap truncate w-full">
              {stat.label}
            </div>
          </motion.div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-12">
        {/* Workforce Activity */}
        <div className="lg:col-span-2 bg-white backdrop-blur-xl border border-blue-100 rounded-[2.5rem] p-6 md:p-10 shadow-sm">
          <div className="flex items-center justify-between mb-10">
            <h3 className="text-lg md:text-2xl font-black text-blue-900 font-display tracking-tight">
              Recent Workforce Activity
            </h3>
            <button className="text-xs font-bold text-blue-500 hover:text-blue-700 transition-colors uppercase tracking-widest flex items-center gap-2">
              All Members <ArrowRight size={14} />
            </button>
          </div>

          <div className="space-y-6">
            {data.platform?.workforce?.map((member, i) => (
              <div
                key={i}
                className="flex items-center justify-between p-6 rounded-2xl bg-blue-50/50 border border-blue-100 hover:bg-blue-50 transition-all group"
              >
                <div className="flex items-center gap-5">
                  <div className="w-14 h-14 rounded-2xl bg-blue-50 border border-blue-100 overflow-hidden shrink-0">
                    {member.avatarUrl ? (
                      <img
                        src={member.avatarUrl}
                        alt={`${member.fullName || "Team member"} profile photo`}
                        className="w-full h-full object-cover"
                      />
                    ) : (
                      <div className="w-full h-full flex items-center justify-center text-xl font-black text-blue-300">
                        {member.fullName?.[0]}
                      </div>
                    )}
                  </div>
                  <div>
                    <div className="font-bold text-blue-900 text-lg group-hover:text-blue-600 transition-colors">
                      {member.fullName}
                    </div>
                    <div className="text-xs text-blue-400 font-medium">
                      {member.jobTitle}
                    </div>
                  </div>
                </div>
                <div className="text-right flex flex-col items-end gap-2">
                  <div className="px-3 py-1 rounded-full bg-emerald-500/10 text-emerald-400 text-[10px] font-black uppercase tracking-widest border border-emerald-500/20">
                    {member.cardStatus || "Active"}
                  </div>
                  <div className="text-[10px] text-blue-400 font-bold uppercase tracking-widest flex items-center gap-1.5">
                    <Clock size={12} />{" "}
                    {member.lastUpdated
                      ? new Date(member.lastUpdated).toLocaleDateString()
                      : "Just Now"}
                  </div>
                </div>
              </div>
            ))}
            {!data.platform?.workforce?.length && !loading && (
              <div className="flex flex-col items-center justify-center py-20 text-blue-400 gap-4">
                <Users size={40} className="opacity-20" />
                <p className="font-bold text-sm tracking-widest uppercase opacity-50">
                  No Workforce Data Found
                </p>
                <Link href="/portal/workforce">
                  <UiloraBrandButton className="px-6 py-3 normal-case tracking-normal">
                    Invite first employee
                  </UiloraBrandButton>
                </Link>
              </div>
            )}
          </div>
        </div>

        {/* System Monitoring */}
        <div className="bg-white backdrop-blur-xl border border-blue-100 rounded-[2.5rem] p-6 md:p-10 shadow-sm">
          <h3 className="text-xl font-black text-blue-900 mb-10 font-display tracking-tight flex items-center gap-3">
            <ShieldCheck size={24} className="text-sky-400" /> System Integrity
          </h3>
          <div className="space-y-10">
            {[
              { label: "API Cluster", value: "Operational", status: "Healthy" },
              { label: "Database sync", value: "Real-time", status: "Active" },
              {
                label: "Security Level",
                value: "Protected",
                status: "Encrypted",
              },
            ].map((item, i) => (
              <div key={i} className="relative pl-8 border-l-2 border-blue-100">
                <div className="absolute left-[-5px] top-0 w-2 h-2 rounded-full bg-emerald-500 shadow-[0_0_12px_#10b981]" />
                <div className="text-[10px] font-black text-blue-400 uppercase tracking-widest mb-1.5">
                  {item.label}
                </div>
                <div className="flex items-center justify-between">
                  <div className="text-2xl font-black text-blue-900 font-display uppercase tracking-tight">
                    {item.value}
                  </div>
                  <div className="text-[10px] font-bold text-emerald-400 px-2.5 py-1 bg-emerald-400/10 rounded-full border border-emerald-400/20">
                    {item.status}
                  </div>
                </div>
              </div>
            ))}
          </div>
          <div className="mt-12 p-6 rounded-2xl bg-blue-50 border border-blue-100 space-y-4">
            <div className="flex justify-between items-center text-[10px] font-black uppercase tracking-widest text-blue-400">
              <span>Server Load</span>
              <span className="text-sky-400">12%</span>
            </div>
            <div className="h-1.5 w-full bg-blue-100 rounded-full overflow-hidden">
              <motion.div
                initial={{ width: 0 }}
                animate={{ width: "12%" }}
                className="h-full bg-sky-500"
              />
            </div>
          </div>
        </div>
      </div>
    </div>
  );

  return (
    <div className="w-full max-w-7xl mx-auto py-6 md:py-8">
      <header className="mb-8 md:mb-16">
        <div className="flex items-center gap-2 text-sky-400 font-bold text-xs uppercase tracking-widest mb-3">
          <div className="w-2 h-2 rounded-full bg-sky-400 animate-pulse" />
          Corporate Control Center
        </div>
        <h1 className="text-3xl md:text-5xl font-black text-blue-900 font-display tracking-tighter leading-none mb-3">
          Admin <span className="text-sky-400">Hub</span>
        </h1>
        <p className="text-blue-400 font-medium text-lg">
          {isMaster ? "Master Control Mode" : "Brokerage Management Mode"} •{" "}
          {data.platform?.totalCompanies || 0} active nodes
        </p>
      </header>

      <AnimatePresence mode="wait">
        <motion.div
          key={activeTab}
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, y: -20 }}
          transition={{ duration: 0.4 }}
        >
          {renderOverview()}
        </motion.div>
      </AnimatePresence>
    </div>
  );
}
