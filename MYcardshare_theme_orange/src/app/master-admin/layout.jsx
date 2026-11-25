"use client";

import { useState, useEffect, useCallback } from "react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { motion, AnimatePresence } from "framer-motion";
import { useAuth } from "@/lib/auth-context";
import { isMasterAdmin } from "@/lib/roles";
import {
  LogOut,
  Settings,
  Zap,
  Megaphone,
  ShieldCheck,
  LayoutDashboard,
  User,
  Users,
  UserCircle,
  ChevronLeft,
  ChevronRight,
  Menu,
  X,
  MailPlus,
  Building2,
} from "lucide-react";

const MASTER_NAV = [
  { label: "Dashboard", href: "/master-admin/dashboard", icon: LayoutDashboard },
  { label: "Profile", href: "/master-admin/profile", icon: User },
  { label: "Company", href: "/master-admin/company", icon: Building2 },
  { label: "Individuals", href: "/master-admin/individuals", icon: UserCircle },
  { label: "Approval", href: "/master-admin/approval", icon: ShieldCheck },
  { label: "Workspace", href: "/master-admin/workspace", icon: Users },
  { label: "Analytics", href: "/master-admin/analytics", icon: Zap },
  { label: "Settings", href: "/master-admin/settings", icon: Settings },
];

function SidebarLink({ label, href, icon: Icon, isActive, collapsed }) {
  return (
    <Link href={href}>
      <motion.div
        whileHover={{ x: collapsed ? 0 : 3, scale: collapsed ? 1.04 : 1 }}
        whileTap={{ scale: 0.98 }}
        className={`flex items-center rounded-xl cursor-pointer relative overflow-hidden group transition-all duration-200 select-none ${
          !isActive ? "hover:bg-[#FAF6F2]" : ""
        } ${collapsed ? "justify-center h-10 w-10 mx-auto" : "gap-2.5 px-3 py-2"}`}
        style={
          isActive
            ? {
                background: "#FCE9DF",
                color: "#D4622C",
              }
            : {
                background: "transparent",
                color: "#77716C",
              }
        }
      >
        {isActive && (
          <div
            className="absolute left-0 top-1/2 -translate-y-1/2 w-1.5 h-5 rounded-r-full"
            style={{ background: "#D4622C" }}
          />
        )}
        <div className={`w-7 h-7 flex items-center justify-center shrink-0 transition-colors duration-200 ${isActive ? "text-[#D4622C]" : "group-hover:text-[#D4622C]"}`}>
          <Icon size={collapsed ? 18 : 17} strokeWidth={isActive ? 2.4 : 2} />
        </div>
        {!collapsed && (
          <span className={`text-[13px] tracking-tight truncate flex-1 ${isActive ? "font-bold text-[#D4622C]" : "font-medium group-hover:text-[#191919]"}`}>{label}</span>
        )}
      </motion.div>
    </Link>
  );
}

export default function MasterAdminLayout({ children }) {
  const pathname = usePathname();
  const router = useRouter();
  const { user, userData, loading, logout } = useAuth();
  const [collapsed, setCollapsed] = useState(false);
  const [mobileOpen, setMobileOpen] = useState(false);

  useEffect(() => {
    if (!loading && (!user || !isMasterAdmin(userData?.role))) {
      router.push("/login");
    }
  }, [loading, user, userData, router]);

  useEffect(() => {
    setMobileOpen(false);
  }, [pathname]);

  const handleLogout = useCallback(async () => {
    await logout();
    router.push("/login");
  }, [logout, router]);

  if (loading || !user || !userData || !isMasterAdmin(userData?.role)) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[#FAF6F2]">
        <div className="flex flex-col items-center gap-4">
          <div className="w-12 h-12 border-4 border-[#D4622C]/20 border-t-[#D4622C] rounded-full animate-spin" />
          <p className="text-[#77716C] font-bold text-xs uppercase tracking-widest">Loading...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="flex h-[100dvh] overflow-hidden relative bg-[#FAF6F2]">
      {/* ── Soft Floating Blurred Background Shapes ─── */}
      <div className="fixed inset-0 pointer-events-none z-0 overflow-hidden">
        <div className="absolute top-[-20%] left-[-10%] w-[60vw] h-[60vw] rounded-full bg-[radial-gradient(circle,rgba(212,98,44,0.04)_0%,transparent_70%)] blur-[120px] animate-float" />
        <div className="absolute bottom-[-10%] right-[-5%] w-[50vw] h-[50vw] rounded-full bg-[radial-gradient(circle,rgba(243,197,175,0.06)_0%,transparent_70%)] blur-[100px] animate-float-delayed" />
        <div className="absolute top-[40%] left-[30%] w-[40vw] h-[40vw] rounded-full bg-[radial-gradient(circle,rgba(212,98,44,0.02)_0%,transparent_70%)] blur-[100px] animate-float" style={{ animationDelay: '2s' }} />
      </div>

      {/* Desktop Sidebar */}
      <motion.aside
        initial={false}
        animate={{ width: collapsed ? 76 : 244 }}
        transition={{ duration: 0.25, ease: [0.16, 1, 0.3, 1] }}
        className="hidden lg:flex flex-col shrink-0 h-full pt-3 pb-3 px-3 z-40 select-none"
        style={{
          background: "rgba(255,255,255,0.96)",
          backdropFilter: "blur(20px)",
          borderRight: "1px solid #EAE2DB",
        }}
      >
        <div className={`flex items-center mb-1 ${collapsed ? "justify-center" : "justify-center px-1"}`}>
          {collapsed ? (
            <img
              src="/logo/My card Share.svg"
              alt="Logo"
              className="w-10 h-10 object-contain shrink-0 transition-all"
            />
          ) : (
            <img
              src="/logo/image (4).png"
              alt="Logo"
              className="w-44 h-auto object-contain shrink-0 transition-all"
            />
          )}
        </div>

        {!collapsed && (
          <div className="text-center mb-2.5">
            <span className="text-[9px] font-black uppercase tracking-[0.2em] px-3 py-1 rounded-full shadow-2xs inline-block"
              style={{ background: "#FCE9DF", color: "#D4622C", border: "1px solid #F3C5AF" }}>
              Master Admin
            </span>
          </div>
        )}

        <nav className="flex flex-col gap-0.5 pt-1 pb-1">
          {MASTER_NAV.map((item) => (
            <SidebarLink key={item.href} {...item} isActive={pathname === item.href} collapsed={collapsed} />
          ))}
        </nav>

        <div className="flex flex-col gap-0.5 pt-2 mt-auto" style={{ borderTop: "1px solid #EAE2DB" }}>
          <button
            onClick={() => setCollapsed(!collapsed)}
            className={`flex items-center rounded-xl cursor-pointer border-0 transition-all hover:bg-[#FAF6F2] hover:text-[#191919] ${collapsed ? "justify-center h-9 w-9 mx-auto" : "gap-2.5 px-3 py-1.5"
              }`}
            style={{ background: "transparent", color: "#77716C" }}
          >
            {collapsed ? <ChevronRight size={17} /> : <><ChevronLeft size={17} /><span className="text-xs font-semibold">Collapse</span></>}
          </button>
          <button
            onClick={handleLogout}
            className={`flex items-center rounded-xl cursor-pointer border-0 transition-all hover:bg-rose-50 hover:text-rose-600 ${collapsed ? "justify-center h-9 w-9 mx-auto" : "gap-2.5 px-3 py-1.5"
              }`}
            style={{ color: "#77716C" }}
          >
            <LogOut size={17} />
            {!collapsed && <span className="text-xs font-semibold">Logout</span>}
          </button>
        </div>
      </motion.aside>

      {/* Mobile Sidebar */}
      <AnimatePresence>
        {mobileOpen && (
          <>
            <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
              onClick={() => setMobileOpen(false)} className="fixed inset-0 bg-black/60 backdrop-blur-sm z-[50] lg:hidden" />
            <motion.aside initial={{ x: "-100%" }} animate={{ x: 0 }} exit={{ x: "-100%" }}
              transition={{ type: "spring", damping: 25, stiffness: 200 }}
              className="fixed inset-y-0 left-0 w-[280px] bg-white z-[51] p-6 lg:hidden flex flex-col shadow-xl border-r border-[#EAE2DB]">
              <div className="flex items-center justify-between mb-8">
                <img src="/logo/image (4).png" alt="Logo" className="w-48 h-auto object-contain" />
                <button onClick={() => setMobileOpen(false)} className="p-2 text-[#77716C] hover:text-[#D4622C]"><X size={24} /></button>
              </div>
              <nav className="flex flex-col gap-2 flex-1">
                {MASTER_NAV.map((item) => (
                  <SidebarLink key={item.href} {...item} isActive={pathname === item.href} collapsed={false} />
                ))}
              </nav>
            </motion.aside>
          </>
        )}
      </AnimatePresence>

      {/* Main Content */}
      <main className="flex-1 h-full overflow-y-auto w-full min-w-0">
        <div className="sticky top-0 z-30 flex items-center justify-between px-4 md:px-8 py-4 bg-[#FAF6F2]/85 backdrop-blur-md">
          <div className="flex items-center gap-4">
            <button onClick={() => setMobileOpen(true)} className="lg:hidden p-2 -ml-2 text-[#77716C] hover:text-[#D4622C] transition-colors">
              <Menu size={24} />
            </button>
            <div className="text-sm font-black tracking-widest text-[#191919] uppercase">
              {MASTER_NAV.find((i) => i.href === pathname)?.label || "Master Admin"}
            </div>
          </div>
          <div className="flex items-center gap-4">
            <button
              onClick={handleLogout}
              className="p-2 text-[#77716C] hover:text-rose-600 transition-colors cursor-pointer"
              title="Logout"
            >
              <LogOut size={20} />
            </button>
            <div className="h-6 w-[1px] bg-[#EAE2DB]" />
            <div className="flex items-center gap-3">
              <span className="text-[10px] font-black uppercase tracking-[0.2em] text-[#77716C] hidden sm:block">
                Platform Admin
              </span>
              <div className="w-9 h-9 rounded-xl flex items-center justify-center text-xs font-black shadow-2xs"
                style={{ background: "#FCE9DF", color: "#D4622C", border: "1px solid #F3C5AF" }}>
                {userData?.fullName?.[0] || "A"}
              </div>
            </div>
          </div>
        </div>
        <div className="p-6 md:p-8">{children}</div>
      </main>
    </div>
  );
}

// Trigger Next.js recompile
