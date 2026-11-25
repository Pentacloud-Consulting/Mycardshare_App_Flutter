"use client";

import { useState, useEffect, useCallback } from "react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { motion, AnimatePresence } from "framer-motion";
import { useAuth } from "@/lib/auth-context";
import {
  isMasterAdmin,
  isEnterprise,
  isPendingApproval,
} from "@/lib/roles";
import {
  LogOut,
  Settings,
  Zap,
  Megaphone,
  ShieldCheck,
  LayoutDashboard,
  User,
  ScanLine,
  Archive,
  Users,
  ChevronLeft,
  ChevronRight,
  Menu,
  X,
  Layers,
  MailPlus,
  Clock,
  RefreshCw,
  Building2,
  Plug,
} from "lucide-react";

/* ═══════════════════════════════════════════════════════════
   PORTAL LAYOUT — UILORA Sidebar · Next.js App Router
   Glassmorphic collapsible sidebar · Aurora accents
   Role-based navigation with strict RBAC separation
   ═══════════════════════════════════════════════════════════ */

/* ── Navigation definitions (never merge these) ──────────── */

const MASTER_ADMIN_NAV = [
  { label: "Dashboard", href: "/portal", icon: LayoutDashboard },
  { label: "Profile", href: "/portal/profile", icon: User },
  { label: "Companies", href: "/portal/companies", icon: Building2 },
  { label: "Approvals", href: "/portal/approvals", icon: ShieldCheck },
  { label: "Workforce", href: "/portal/workforce", icon: Users },
  { label: "Leads", href: "/portal/leads", icon: Megaphone },
  { label: "Campaign", href: "/portal/campaign", icon: MailPlus },
  { label: "Analytics", href: "/portal/analytics", icon: Zap },
];

const ENTERPRISE_NAV = [
  { label: "Dashboard", href: "/portal", icon: LayoutDashboard },
  { label: "Profile", href: "/portal/profile", icon: User },
  { label: "Leads", href: "/portal/leads", icon: Megaphone },
  { label: "Workspace", href: "/portal/workforce", icon: Layers },
  { label: "Campaign", href: "/portal/campaign", icon: MailPlus },
  { label: "Analytics", href: "/portal/analytics", icon: Zap },
];

const INDIVIDUAL_NAV = [
  { label: "Dashboard", href: "/portal", icon: LayoutDashboard },
  { label: "Profile", href: "/portal/profile", icon: User },
  { label: "Scanner", href: "/portal/scanner", icon: ScanLine },
  { label: "Contact Vault", href: "/portal/vault", icon: Archive },
  { label: "Leads", href: "/portal/leads", icon: Megaphone },
];

const EMPLOYEE_NAV = [
  { label: "Dashboard", href: "/portal", icon: LayoutDashboard },
  { label: "Profile", href: "/portal/profile", icon: User },
  { label: "Scanner", href: "/portal/scanner", icon: ScanLine },
  { label: "Contact Vault", href: "/portal/vault", icon: Archive },
  { label: "Leads", href: "/portal/leads", icon: Megaphone },
  { label: "Team Workforce", href: "/portal/workforce", icon: Building2 },
];

/**
 * Strict role-based nav resolution.
 * NEVER merges menus — each role gets exactly one sidebar.
 */
function getNavForRole(role, userData) {
  if (isMasterAdmin(role)) return MASTER_ADMIN_NAV;
  if (isEnterprise(role)) {
    const nav = [...ENTERPRISE_NAV];
    if (userData?.isIntegrationEnabled) {
      // Insert right before Analytics or at the end
      nav.splice(nav.length - 1, 0, { label: "Connectors Objects", href: "/portal/connectors", icon: Plug });
    }
    return nav;
  }
  if (role === "employee" || userData?.companyId || userData?.enterpriseUid) {
    return EMPLOYEE_NAV;
  }
  return INDIVIDUAL_NAV;
}

/* ── Sidebar link component ──────────────────────────────── */

function SidebarLink({ icon: Icon, label, href, isActive, collapsed }) {
  return (
    <Link href={href} className="block">
      <motion.div
        whileHover={{ x: collapsed ? 0 : 2 }}
        whileTap={{ scale: 0.98 }}
        className={`flex items-center rounded-xl cursor-pointer relative group transition-all duration-200 ${
          collapsed ? "justify-center h-10 w-10 mx-auto" : "gap-3 px-3.5 py-2.5"
        } ${
          isActive
            ? "bg-[#FCE9DF] text-[#D4622C] font-bold shadow-2xs border border-[#D4622C]/25"
            : "text-[#6A635E] hover:text-[#191919] hover:bg-[#F8F4EF] font-medium border border-transparent"
        }`}
      >
        <div
          className={`flex items-center justify-center transition-colors duration-200 shrink-0 ${
            isActive ? "text-[#D4622C]" : "text-[#8C847E] group-hover:text-[#D4622C]"
          }`}
        >
          <Icon size={collapsed ? 20 : 18} strokeWidth={isActive ? 2.4 : 2} />
        </div>

        {!collapsed && (
          <span className="text-[13px] tracking-tight flex-1 truncate">
            {label}
          </span>
        )}

        {/* Right active indicator dot */}
        {isActive && !collapsed && (
          <span className="w-1.5 h-1.5 rounded-full bg-[#D4622C] shrink-0" />
        )}
      </motion.div>
    </Link>
  );
}

/* ── Pending Approval Screen ─────────────────────────────── */

function PendingApprovalScreen({ onLogout, onRefresh, refreshing }) {
  return (
    <div
      className="min-h-[100dvh] flex items-center justify-center p-6"
      style={{ background: "var(--color-aurora-bg, #f0f6ff)" }}
    >
      {/* Background orbs */}
      <div className="fixed inset-0 pointer-events-none overflow-hidden">
        <div className="absolute top-[-20%] left-[-10%] w-[60vw] h-[60vw] rounded-full bg-[radial-gradient(circle,rgba(59,130,246,0.06)_0%,transparent_70%)] blur-[100px]" />
        <div className="absolute bottom-[-20%] right-[-10%] w-[50vw] h-[50vw] rounded-full bg-[radial-gradient(circle,rgba(14,165,233,0.04)_0%,transparent_70%)] blur-[100px]" />
      </div>

      <motion.div
        initial={{ opacity: 0, y: 20, scale: 0.95 }}
        animate={{ opacity: 1, y: 0, scale: 1 }}
        transition={{ type: "spring", damping: 25, stiffness: 120 }}
        className="relative z-10 max-w-lg w-full text-center"
      >
        {/* Logo */}
        <div className="flex justify-center mb-10">
          <img
            src="/logo/image (4).png"
            alt="Logo"
            className="w-56 h-auto object-contain"
          />
        </div>

        {/* Card */}
        <div
          className="rounded-3xl p-10 shadow-2xl"
          style={{
            background: "rgba(255,255,255,0.85)",
            backdropFilter: "blur(30px)",
            border: "1px solid rgba(59,130,246,0.12)",
          }}
        >
          {/* Animated clock icon */}
          <motion.div
            animate={{ rotate: [0, 10, -10, 0] }}
            transition={{ repeat: Infinity, duration: 4, ease: "easeInOut" }}
            className="w-20 h-20 rounded-3xl mx-auto mb-8 flex items-center justify-center"
            style={{
              background: "rgba(217,119,6,0.08)",
              border: "1px solid rgba(217,119,6,0.15)",
            }}
          >
            <Clock size={40} className="text-amber-400" />
          </motion.div>

          <h1
            className="text-2xl font-black text-[#0F172A] mb-3 tracking-tight"
            style={{ fontFamily: "var(--font-display)" }}
          >
            Account Pending Approval
          </h1>
          <p className="text-sm text-blue-400 leading-relaxed mb-8 max-w-sm mx-auto">
            Your enterprise account has been submitted for review. A platform
            administrator will approve your registration shortly.
          </p>

          {/* Status indicator */}
          <div
            className="inline-flex items-center gap-3 px-5 py-3 rounded-2xl mb-8"
            style={{
              background: "rgba(217,119,6,0.06)",
              border: "1px solid rgba(217,119,6,0.12)",
            }}
          >
            <span
              className="w-2 h-2 rounded-full animate-pulse"
              style={{
                background: "#d97706",
                boxShadow: "0 0 10px rgba(217,119,6,0.3)",
              }}
            />
            <span className="text-[11px] font-bold uppercase tracking-[0.15em] text-amber-400/80">
              Awaiting Review
            </span>
          </div>

          {/* Actions */}
          <div className="flex flex-col gap-3">
            <button
              onClick={onRefresh}
              disabled={refreshing}
              className="w-full py-3.5 rounded-xl bg-blue-50 border border-blue-200 text-blue-700 font-bold text-sm hover:bg-blue-100 transition-all flex items-center justify-center gap-2 disabled:opacity-50"
            >
              <RefreshCw
                size={14}
                className={refreshing ? "animate-spin" : ""}
              />
              {refreshing ? "Checking…" : "Check Status"}
            </button>
            <button
              onClick={onLogout}
              className="w-full py-3.5 rounded-xl text-blue-400 hover:text-red-500 font-bold text-sm transition-colors flex items-center justify-center gap-2"
            >
              <LogOut size={14} />
              Sign Out
            </button>
          </div>
        </div>

        <p className="text-[10px] text-blue-400 mt-6 font-bold uppercase tracking-[0.2em]">
          You&apos;ll get full access once approved
        </p>
      </motion.div>
    </div>
  );
}

/* ── Main Portal Layout ──────────────────────────────────── */

export default function PortalLayout({ children }) {
  const pathname = usePathname();
  const router = useRouter();
  const { user, userData, loading, logout, refreshUserData } = useAuth();
  const [collapsed, setCollapsed] = useState(false);
  const [mobileOpen, setMobileOpen] = useState(false);
  const [refreshing, setRefreshing] = useState(false);

  // Auth guard — redirect to login if not authenticated
  useEffect(() => {
    if (!loading && !user) {
      router.push("/login");
    } else if (!loading && userData && isEnterprise(userData?.role) && isApproved(userData?.status)) {
      if (pathname === "/portal") {
        router.push("/enterprise/dashboard");
      }
    }
  }, [loading, user, userData, pathname, router]);

  // Close mobile sidebar on route change
  useEffect(() => {
    setMobileOpen(false);
  }, [pathname]);

  // Auto-poll for approval status (every 30s when pending)
  const userRole = userData?.role || "";
  const userStatus = userData?.status || "";
  const pending = isPendingApproval(userRole, userStatus);

  useEffect(() => {
    if (!pending) return;
    const interval = setInterval(() => {
      refreshUserData?.();
    }, 30000);
    return () => clearInterval(interval);
  }, [pending, refreshUserData]);

  const handleRefreshStatus = useCallback(async () => {
    setRefreshing(true);
    try {
      await refreshUserData?.();
    } finally {
      setTimeout(() => setRefreshing(false), 800);
    }
  }, [refreshUserData]);

  const handleLogout = useCallback(async () => {
    if (window.confirm("Are you sure you want to sign out?")) {
      await logout();
      router.push("/login");
    }
  }, [logout, router]);

  // Show loading while checking auth
  if (loading || !user) {
    return (
      <div
        className="min-h-screen flex items-center justify-center"
        style={{ background: "#F8F4EF" }}
      >
        <div className="flex flex-col items-center gap-4">
          <div className="w-12 h-12 border-4 border-[#FCE9DF] border-t-[#D4622C] rounded-full animate-spin" />
          <p className="text-[#77716C] font-bold text-xs uppercase tracking-widest">
            Authenticating...
          </p>
        </div>
      </div>
    );
  }

  // ── PENDING APPROVAL GATE ──
  // Enterprise admins who haven't been approved yet see ONLY this screen.
  if (pending) {
    return (
      <PendingApprovalScreen
        onLogout={handleLogout}
        onRefresh={handleRefreshStatus}
        refreshing={refreshing}
      />
    );
  }

  // ── STRICT role-based navigation ──
  const navItems = getNavForRole(userRole, userData);

  return (
    <div
      className="flex h-[100dvh] overflow-hidden relative bg-[#F8F4EF]"
    >
      {/* ── Soft Floating Blurred Background Shapes ─── */}
      <div className="fixed inset-0 pointer-events-none z-0 overflow-hidden">
        <div className="absolute top-[-20%] left-[-10%] w-[60vw] h-[60vw] rounded-full bg-[radial-gradient(circle,rgba(212,98,44,0.04)_0%,transparent_70%)] blur-[120px] animate-float" />
        <div className="absolute bottom-[-10%] right-[-5%] w-[50vw] h-[50vw] rounded-full bg-[radial-gradient(circle,rgba(245,214,198,0.25)_0%,transparent_70%)] blur-[100px] animate-float-delayed" />
        <div className="absolute top-[40%] left-[30%] w-[40vw] h-[40vw] rounded-full bg-[radial-gradient(circle,rgba(212,98,44,0.02)_0%,transparent_70%)] blur-[100px] animate-float" style={{ animationDelay: '2s' }} />
      </div>
      {/* ── Desktop/Tablet Sidebar ─── */}
      <motion.aside
        initial={false}
        animate={{ width: collapsed ? 76 : 244 }}
        transition={{ duration: 0.25, ease: [0.16, 1, 0.3, 1] }}
        className="hidden lg:flex flex-col shrink-0 h-full pt-3 pb-3 px-3 z-40 bg-white/95 backdrop-blur-md border-r border-[#EAE2DB]"
      >
        {/* Logo */}
        <div
          className={`flex items-center mb-6 pt-2 pb-1 ${collapsed ? "justify-center px-0" : "justify-start px-2.5"}`}
        >
          {collapsed ? (
            <img
              src="/logo/My card Share.svg"
              alt="Logo"
              className="w-9 h-9 object-contain"
            />
          ) : (
            <img
              src="/logo/image (4).png"
              alt="MyCardShare Logo"
              className="w-[190px] sm:w-[205px] h-auto object-contain scale-[1.1] origin-left"
            />
          )}
        </div>

        {/* Navigation Section */}
        <div className="flex flex-col">
          {!collapsed && (
            <span className="px-3 pb-2 text-[10px] font-black uppercase tracking-[0.16em] text-[#A89F97]">
              Menu
            </span>
          )}

          <nav className="flex flex-col gap-1">
            {navItems.map((item) => (
              <SidebarLink
                key={item.href}
                {...item}
                isActive={pathname === item.href}
                collapsed={collapsed}
              />
            ))}
          </nav>
        </div>

        {/* Bottom Section */}
        <div className="flex flex-col gap-1 pt-3 border-t border-[#EAE2DB]/70 mt-auto">
          {!collapsed && (
            <span className="px-3 pb-1 text-[10px] font-black uppercase tracking-[0.16em] text-[#A89F97]">
              Preferences
            </span>
          )}

          <SidebarLink
            label="Settings"
            href="/portal/settings"
            icon={Settings}
            isActive={pathname === "/portal/settings"}
            collapsed={collapsed}
          />

          {/* User Mini Profile Card */}
          {!collapsed ? (
            <div className="mt-2 p-2 rounded-xl bg-[#FAF6F2] border border-[#EAE2DB] flex items-center justify-between gap-2 shadow-2xs">
              <Link href="/portal/profile" className="flex items-center gap-2.5 min-w-0 flex-1 hover:opacity-80 transition-opacity">
                <div className="w-8 h-8 rounded-lg overflow-hidden bg-[#FCE9DF] border border-[#D4622C]/30 flex items-center justify-center shrink-0 text-[#D4622C] font-bold text-xs">
                  {userData?.avatarUrl ? (
                    <img src={userData.avatarUrl} alt="Avatar" className="w-full h-full object-cover" />
                  ) : (
                    userData?.fullName?.[0] || "U"
                  )}
                </div>
                <div className="min-w-0 flex-1">
                  <p className="text-xs font-bold text-[#191919] truncate leading-tight">
                    {userData?.fullName || "My Profile"}
                  </p>
                  <p className="text-[10px] text-[#77716C] truncate capitalize">
                    {userData?.role || "Individual"}
                  </p>
                </div>
              </Link>
              <button
                onClick={handleLogout}
                title="Sign Out"
                className="p-1.5 text-[#77716C] hover:text-[#D4622C] hover:bg-[#FCE9DF] rounded-lg transition-colors cursor-pointer"
              >
                <LogOut size={15} />
              </button>
            </div>
          ) : (
            <button
              onClick={handleLogout}
              title="Sign Out"
              className="w-10 h-10 mx-auto rounded-xl flex items-center justify-center text-[#77716C] hover:text-[#D4622C] hover:bg-[#FCE9DF] transition-colors cursor-pointer"
            >
              <LogOut size={18} />
            </button>
          )}

          {/* Collapse Toggle Button */}
          <button
            onClick={() => setCollapsed(!collapsed)}
            className={`mt-1.5 flex items-center rounded-xl cursor-pointer border border-[#EAE2DB]/70 transition-all text-[#77716C] hover:text-[#191919] hover:bg-[#F8F4EF] hover:border-[#D4622C]/30 ${
              collapsed ? "justify-center h-9 w-9 mx-auto" : "justify-between px-3 py-1.5 text-xs font-semibold"
            }`}
          >
            {collapsed ? (
              <ChevronRight size={15} />
            ) : (
              <>
                <span className="text-[11px] font-bold text-[#77716C]">Collapse</span>
                <ChevronLeft size={13} className="text-[#77716C]" />
              </>
            )}
          </button>
        </div>
      </motion.aside>

      {/* ── Mobile Sidebar Drawer ─── */}
      <AnimatePresence>
        {mobileOpen && (
          <>
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setMobileOpen(false)}
              className="fixed inset-0 bg-black/30 backdrop-blur-sm z-[50] lg:hidden"
            />
            <motion.aside
              initial={{ x: "-100%" }}
              animate={{ x: 0 }}
              exit={{ x: "-100%" }}
              transition={{ type: "spring", damping: 25, stiffness: 200 }}
              className="fixed inset-y-0 left-0 w-[270px] bg-white z-[51] pt-3 px-5 pb-5 lg:hidden flex flex-col shadow-xl border-r border-[#EAE2DB]"
            >
              <div className="flex items-center justify-between mb-6 pr-1">
                <img
                  src="/logo/image (4).png"
                  alt="Logo"
                  className="w-[170px] h-auto object-contain scale-[1.1] origin-left"
                />
                <button
                  onClick={() => setMobileOpen(false)}
                  className="p-1.5 text-[#77716C] hover:text-[#191919]"
                >
                  <X size={20} />
                </button>
              </div>
              <nav className="flex flex-col gap-1 flex-1">
                {navItems.map((item) => (
                  <SidebarLink
                    key={item.href}
                    {...item}
                    isActive={pathname === item.href}
                    collapsed={false}
                  />
                ))}
                <div className="pt-3 mt-2 border-t border-[#EAE2DB]">
                  <SidebarLink
                    label="Settings"
                    href="/portal/settings"
                    icon={Settings}
                    isActive={pathname === "/portal/settings"}
                    collapsed={false}
                  />
                </div>
              </nav>
            </motion.aside>
          </>
        )}
      </AnimatePresence>

      {/* ── Main Content ─── */}
      <main className="flex-1 h-full overflow-y-auto w-full min-w-0">
        {/* Top bar */}
        <div
          className="sticky top-0 z-30 flex items-center justify-between px-4 md:px-8 py-4 bg-[#F8F4EF]/85 backdrop-blur-md"
        >
          <div className="flex items-center gap-4">
            <button
              onClick={() => setMobileOpen(true)}
              className="lg:hidden p-2 -ml-2 text-[#77716C] hover:text-[#191919] transition-colors"
            >
              <Menu size={24} />
            </button>
            <div className="text-sm font-black tracking-[0.14em] text-[#191919] uppercase">
              {pathname === "/portal/settings" 
                ? "Settings" 
                : (navItems.find((i) => i.href === pathname)?.label || "Portal")}
            </div>
          </div>
          <div className="flex items-center gap-3">
            <button
              onClick={handleLogout}
              className="p-2 text-[#77716C] hover:text-[#D4622C] transition-colors rounded-lg hover:bg-[#F8F4EF]"
              title="Logout"
            >
              <LogOut size={20} />
            </button>
            <div className="h-6 w-[1px] bg-[#EAE2DB]" />
            <Link
              href="/portal/profile"
              className="w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold hover:ring-2 hover:ring-[#D4622C]/40 transition-all overflow-hidden shrink-0 border border-[#EAE2DB] bg-[#FCE9DF] text-[#D4622C]"
              title="My profile"
            >
              {userData?.avatarUrl ? (
                // eslint-disable-next-line @next/next/no-img-element
                <img
                  src={userData.avatarUrl}
                  alt="Profile"
                  className="w-full h-full object-cover"
                />
              ) : (
                userData?.fullName?.[0] || "U"
              )}
            </Link>
          </div>
        </div>

        {/* Page content */}
        <div className="p-6 md:p-8">{children}</div>
      </main>
    </div>
  );
}
