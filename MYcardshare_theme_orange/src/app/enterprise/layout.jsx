"use client";

import { useState, useEffect, useCallback } from "react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { motion, AnimatePresence } from "framer-motion";
import { useAuth } from "@/lib/auth-context";
import { isEnterprise, isMasterAdmin, isApproved } from "@/lib/roles";
import {
  LogOut, Settings, Zap, Megaphone, LayoutDashboard, User,
  ChevronLeft, ChevronRight, Menu, X, Layers, MailPlus, Clock, RefreshCw, Plug
} from "lucide-react";

const ENTERPRISE_NAV = [
  { label: "Dashboard", href: "/enterprise/dashboard", icon: LayoutDashboard },
  { label: "Profile", href: "/enterprise/profile", icon: User },
  { label: "Leads", href: "/enterprise/leads", icon: Megaphone },
  { label: "Workspace", href: "/enterprise/workspace", icon: Layers },
  { label: "Campaign", href: "/enterprise/campaign", icon: MailPlus },
  { label: "Analytics", href: "/enterprise/analytics", icon: Zap },
  { label: "Settings", href: "/enterprise/settings", icon: Settings },
];

function SidebarLink({ label, href, icon: Icon, isActive, collapsed }) {
  return (
    <Link href={href}>
      <motion.div
        whileHover={{ x: collapsed ? 0 : 4, backgroundColor: "var(--color-indigo-dim)" }}
        whileTap={{ scale: 0.98 }}
        className={`flex items-center rounded-[var(--radius-lg)] cursor-pointer relative overflow-hidden group ${
          collapsed ? "justify-center h-12 w-12 mx-auto" : "gap-3 px-4 py-3"
        }`}
        style={
          isActive
            ? {
                backgroundColor: "var(--color-indigo-dim)",
                color: "var(--color-indigo)",
                transition: "all var(--dur-base) var(--ease-premium)",
              }
            : {
                backgroundColor: "transparent",
                color: "var(--color-ink-2)",
                transition: "all var(--dur-base) var(--ease-premium)",
              }
        }
      >
        {/* Left Indicator Bar */}
        {isActive && (
          <div 
            className="absolute left-0 top-1/2 -translate-y-1/2 w-1 h-3/5 rounded-r-full" 
            style={{ backgroundColor: "var(--color-indigo)" }}
          />
        )}
        
        <div 
          className="flex items-center justify-center transition-colors duration-300" 
          style={{ color: isActive ? "var(--color-indigo)" : "var(--color-muted)" }}
        >
             <div className="w-7 h-7 flex items-center justify-center group-hover:text-[var(--color-indigo)] transition-colors duration-300">
               <Icon size={collapsed ? 20 : 18} strokeWidth={isActive ? 2.5 : 2} />
             </div>
        </div>
        
        {!collapsed && (
          <span className="text-sm font-semibold tracking-tight">{label}</span>
        )}
      </motion.div>
    </Link>
  );
}

function PendingScreen({ onLogout, onRefresh, refreshing }) {
  return (
    <div className="min-h-[100dvh] flex items-center justify-center p-6" style={{ background: "var(--color-aurora-bg, #FAF6F2)" }}>
      <div className="fixed inset-0 pointer-events-none overflow-hidden">
        <div className="absolute top-[-20%] left-[-10%] w-[60vw] h-[60vw] rounded-full bg-[radial-gradient(circle,rgba(212,100,44,0.06)_0%,transparent_70%)] blur-[100px]" />
        <div className="absolute bottom-[-20%] right-[-10%] w-[50vw] h-[50vw] rounded-full bg-[radial-gradient(circle,rgba(232,122,67,0.04)_0%,transparent_70%)] blur-[100px]" />
      </div>
      <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="relative z-10 max-w-lg w-full text-center">
        <div className="flex justify-center mb-10"><img src="/logo/image (4).png" alt="Logo" className="w-56 h-auto object-contain" /></div>
        <div className="rounded-3xl p-10 shadow-2xl" style={{ background: "rgba(255,255,255,0.85)", backdropFilter: "blur(30px)", border: "1px solid rgba(212,100,44,0.12)" }}>
          <motion.div animate={{ rotate: [0, 10, -10, 0] }} transition={{ repeat: Infinity, duration: 4, ease: "easeInOut" }}
            className="w-20 h-20 rounded-3xl mx-auto mb-8 flex items-center justify-center" style={{ background: "rgba(212,100,44,0.08)", border: "1px solid rgba(212,100,44,0.15)" }}>
            <Clock size={40} className="text-[#D4642C]" /></motion.div>
          <h1 className="text-2xl font-black text-[#0F172A] mb-3">Account Pending Approval</h1>
          <p className="text-sm text-slate-500 leading-relaxed mb-8 max-w-sm mx-auto">Your enterprise account is pending approval by the administrator. You will be notified once approved.</p>
          <div className="inline-flex items-center gap-3 px-5 py-3 rounded-2xl mb-8" style={{ background: "rgba(212,100,44,0.06)", border: "1px solid rgba(212,100,44,0.12)" }}>
            <span className="w-2 h-2 rounded-full animate-pulse" style={{ background: "#D4642C", boxShadow: "0 0 10px rgba(212,100,44,0.3)" }} />
            <span className="text-[11px] font-bold uppercase tracking-[0.15em] text-[#D4642C]">Awaiting Review</span></div>
          <div className="flex flex-col gap-3">
            <button onClick={onRefresh} disabled={refreshing} className="w-full py-3.5 rounded-xl bg-[#FFF7ED] border border-[#FED7AA] text-[#D4642C] font-bold text-sm hover:bg-[#FFEDD5] transition-all flex items-center justify-center gap-2 disabled:opacity-50">
              <RefreshCw size={14} className={refreshing ? "animate-spin" : ""} />{refreshing ? "Checking…" : "Check Status"}</button>
            <button onClick={onLogout} className="w-full py-3.5 rounded-xl text-slate-400 hover:text-red-500 font-bold text-sm transition-colors flex items-center justify-center gap-2">
              <LogOut size={14} />Sign Out</button></div>
        </div>
      </motion.div>
    </div>
  );
}

export default function EnterpriseLayout({ children }) {
  const pathname = usePathname();
  const router = useRouter();
  const { user, userData, loading, logout, refreshUserData } = useAuth();
  const [collapsed, setCollapsed] = useState(false);
  const [mobileOpen, setMobileOpen] = useState(false);
  const [refreshing, setRefreshing] = useState(false);

  useEffect(() => {
    if (!loading) {
      if (!user) { router.push("/login"); return; }
      if (isMasterAdmin(userData?.role)) { router.push("/master-admin/dashboard"); return; }
      if (!isEnterprise(userData?.role)) { router.push("/login"); return; }
    }
  }, [loading, user, userData, router]);

  useEffect(() => { setMobileOpen(false); }, [pathname]);

  const pending = userData && isEnterprise(userData?.role) && !isApproved(userData?.status);

  useEffect(() => {
    if (!pending) return;
    const interval = setInterval(() => { refreshUserData?.(); }, 30000);
    return () => clearInterval(interval);
  }, [pending, refreshUserData]);

  const handleRefresh = useCallback(async () => {
    setRefreshing(true);
    try { await refreshUserData?.(); } finally { setTimeout(() => setRefreshing(false), 800); }
  }, [refreshUserData]);

  const handleLogout = useCallback(async () => {
    await logout();
    router.push("/login");
  }, [logout, router]);

  if (loading || !user || !userData) {
    return (<div className="min-h-screen flex items-center justify-center" style={{ background: "var(--color-aurora-bg, #FAF6F2)" }}>
      <div className="flex flex-col items-center gap-4"><div className="w-12 h-12 border-4 border-[#D4642C]/20 border-t-[#D4642C] rounded-full animate-spin" />
        <p className="text-[#D4642C] font-bold text-xs uppercase tracking-widest">Loading...</p></div></div>);
  }

  if (pending) return <PendingScreen onLogout={handleLogout} onRefresh={handleRefresh} refreshing={refreshing} />;

  return (
    <div className="flex h-[100dvh] overflow-hidden" style={{ background: "var(--color-aurora-bg, #FAF6F2)" }}>
      <motion.aside initial={false} animate={{ width: collapsed ? 72 : 260 }} transition={{ duration: 0.3, ease: [0.16, 1, 0.3, 1] }}
        className="hidden lg:flex flex-col shrink-0 h-full pt-1 pb-6 px-3 z-40 select-none"
        style={{ background: "rgba(255,255,255,0.95)", backdropFilter: "blur(20px)", borderRight: "1px solid rgba(212,100,44,0.1)" }}>
        {userData?.companyName || userData?.companyLogo ? (
          <div className={`flex items-center mb-6 mt-2 ${collapsed ? "justify-center px-3" : "gap-3 px-4"}`}>
            {userData.companyLogo ? (
              <div className={`shrink-0 rounded-full bg-white flex items-center justify-center overflow-hidden border border-slate-200 transition-all shadow-sm ${collapsed ? "w-10 h-10" : "w-12 h-12"}`}>
                <img src={userData.companyLogo} alt="Logo" className="w-full h-full object-contain p-1" />
              </div>
            ) : (
              <div className={`shrink-0 rounded-full bg-[#FFF7ED] text-[#D4642C] border border-[#FED7AA] flex items-center justify-center font-bold transition-all ${collapsed ? "w-10 h-10 text-sm" : "w-12 h-12 text-lg"}`}>
                {userData.companyName?.[0] || "C"}
              </div>
            )}
            
            {!collapsed && (
              <div className="flex flex-col min-w-0 flex-1">
                <span className="text-sm font-bold text-slate-800 leading-tight break-words line-clamp-2">
                  {userData.companyName || "Enterprise"}
                </span>
                <span className="text-[10px] font-bold text-[#D4642C] uppercase tracking-wider mt-1">
                  Enterprise
                </span>
              </div>
            )}
          </div>
        ) : (
          <>
            <div className={`flex items-center mb-2 ${collapsed ? "justify-center px-3" : "justify-center px-0"}`}>
              <img src="/logo/image (4).png" alt="Logo" className={`object-contain shrink-0 transition-all ${collapsed ? "w-12 h-12" : "w-52 h-auto scale-[1.3]"}`} />
            </div>
            {!collapsed && (
              <div className="text-center mb-6">
                <span className="text-[9px] font-black uppercase tracking-[0.25em] px-3 py-1 rounded-full bg-[#FFF7ED] text-[#D4642C] border border-[#FED7AA]">
                  Enterprise
                </span>
              </div>
            )}
          </>
        )}
        <nav className="flex flex-col gap-1">
          {ENTERPRISE_NAV.map((item) => (<SidebarLink key={item.href} {...item} isActive={pathname === item.href} collapsed={collapsed} />))}
          {userData?.isIntegrationEnabled && (
            <SidebarLink href="/enterprise/connectors" label="Connectors Objects" icon={Plug} isActive={pathname === "/enterprise/connectors"} collapsed={collapsed} />
          )}
        </nav>
        <div className="flex flex-col gap-1 pt-4 mt-auto" style={{ borderTop: "1px solid rgba(212,100,44,0.1)" }}>
          <button onClick={() => setCollapsed(!collapsed)} className={`flex items-center rounded-xl cursor-pointer border-0 transition-all ${collapsed ? "justify-center h-12 w-12 mx-auto" : "gap-3 px-4 py-3"}`}
            style={{ background: "transparent", color: "#94a3b8" }}>
            {collapsed ? <ChevronRight size={24} /> : <><ChevronLeft size={18} /><span className="text-sm font-medium">Collapse</span></>}</button>
          <button onClick={handleLogout} className={`flex items-center rounded-xl cursor-pointer border-0 transition-all hover:bg-red-50 hover:text-red-600 ${collapsed ? "justify-center h-12 w-12 mx-auto" : "gap-3 px-4 py-3"}`}
            style={{ color: "#94a3b8" }}><LogOut size={collapsed ? 24 : 18} />{!collapsed && <span className="text-sm font-medium">Logout</span>}</button>
        </div>
      </motion.aside>

      <AnimatePresence>
        {mobileOpen && (<><motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} onClick={() => setMobileOpen(false)}
          className="fixed inset-0 bg-black/30 backdrop-blur-sm z-[50] lg:hidden" />
          <motion.aside initial={{ x: "-100%" }} animate={{ x: 0 }} exit={{ x: "-100%" }} transition={{ type: "spring", damping: 25, stiffness: 200 }}
            className="fixed inset-y-0 left-0 w-[280px] bg-white z-[51] pt-1 px-6 pb-6 lg:hidden flex flex-col shadow-xl">
            <div className="flex items-center justify-between mb-8 pr-2">
              <img src="/logo/image (4).png" alt="Logo" className="w-48 h-auto object-contain scale-[1.25] origin-left -ml-2" />
              <button onClick={() => setMobileOpen(false)} className="p-2 text-slate-400 hover:text-slate-700"><X size={24} /></button>
            </div>
            {userData?.companyName && (
              <div className="flex items-center gap-3 mb-6">
                 {userData.companyLogo ? (
                    <div className="shrink-0 rounded-full bg-white flex items-center justify-center overflow-hidden border border-slate-200 w-12 h-12 shadow-sm">
                      <img src={userData.companyLogo} alt="Logo" className="w-full h-full object-contain p-1" />
                    </div>
                  ) : (
                    <div className="shrink-0 rounded-full bg-[#FFF7ED] text-[#D4642C] border border-[#FED7AA] flex items-center justify-center font-bold w-12 h-12 text-lg">
                      {userData.companyName?.[0] || "C"}
                    </div>
                  )}
                  <div className="flex flex-col min-w-0 flex-1">
                    <span className="text-sm font-bold text-slate-800 leading-tight break-words line-clamp-2">
                      {userData.companyName || "Enterprise"}
                    </span>
                    <span className="text-[10px] font-bold text-[#D4642C] uppercase tracking-wider mt-1">
                      Enterprise
                    </span>
                  </div>
              </div>
            )}
            <nav className="flex flex-col gap-2 flex-1">
              {ENTERPRISE_NAV.map((item) => (<SidebarLink key={item.href} {...item} isActive={pathname === item.href} collapsed={false} />))}
              {userData?.isIntegrationEnabled && (
                <SidebarLink href="/enterprise/connectors" label="Connectors Objects" icon={Plug} isActive={pathname === "/enterprise/connectors"} collapsed={false} />
              )}
            </nav>
            <div className="flex flex-col gap-1 pt-4 mt-auto border-t border-slate-100">
               <button onClick={handleLogout} className="flex items-center gap-3 px-4 py-3 rounded-xl cursor-pointer transition-all hover:bg-red-50 hover:text-red-600 text-slate-400 font-medium text-sm">
                 <LogOut size={18} />Logout
               </button>
            </div>
          </motion.aside></>)}
      </AnimatePresence>

      <main className="flex-1 h-full overflow-y-auto w-full min-w-0">
        <div className="sticky top-0 z-40 flex items-center justify-between px-4 md:px-6 py-4 bg-white/95 backdrop-blur-md border-b border-slate-200/80 shadow-sm">
          <div className="flex items-center gap-4">
            <button onClick={() => setMobileOpen(true)} className="lg:hidden p-2 -ml-2 text-slate-500 hover:text-slate-800 transition-colors"><Menu size={24} /></button>
            <div className="text-sm font-black tracking-tight text-slate-400 uppercase">
              {ENTERPRISE_NAV.find((i) => i.href === pathname)?.label || (pathname === "/enterprise/connectors" ? "Connectors Objects" : "Enterprise")}
            </div>
          </div>
          <div className="flex items-center gap-3">
            <span className="text-[10px] font-black uppercase tracking-[0.15em] text-[#D4642C] hidden sm:block bg-[#FFF7ED] px-2 py-1 rounded-md border border-[#FED7AA]">Enterprise</span>
            <div className="w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold bg-[#FFEDD5] text-[#D4642C] shadow-sm border border-[#FED7AA]">
              {userData?.displayName?.[0] || "E"}</div></div>
        </div>
        <div className="p-6 md:p-8">{children}</div>
      </main>
    </div>
  );
}
