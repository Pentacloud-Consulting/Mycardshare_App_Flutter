"use client";

import { useState, useEffect, useCallback } from "react";
import {
  motion,
  AnimatePresence,
  useScroll,
  useMotionValueEvent,
} from "framer-motion";
import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  Menu,
  X,
  ChevronRight,
  Zap,
  Shield,
  ScanLine,
  Archive,
  Users,
  LayoutDashboard,
  User,
  LogOut,
} from "lucide-react";
import { UiloraBrandButton } from "./UIComponents/Button/tsx/UiloraModernButtons";

/* ═══════════════════════════════════════════════════════════
   UILORA-INSPIRED FLOATING NAVBAR — NEXUS v3
   Glassmorphic · Framer Motion · Mobile-First · Next.js App Router
   ═══════════════════════════════════════════════════════════ */

const PUBLIC_LINKS = [
  { label: "Home", href: "/", icon: null },
  { label: "Pricing", href: "/pricing", icon: null },
  { label: "Blog", href: "/blog", icon: null },
  { label: "Contact", href: "/contact", icon: null },
];

const PORTAL_LINKS = [
  { label: "Overview", href: "/portal", icon: LayoutDashboard },
  { label: "Profile", href: "/portal/profile", icon: User },
  { label: "Scanner", href: "/portal/scanner", icon: ScanLine },
  { label: "Contact Vault", href: "/portal/vault", icon: Archive },
];

/* ── Nav Link ─── */
function NavLink({ label, href, isActive, icon: Icon }) {
  return (
    <Link href={href}>
      <motion.div
        whileHover={{ scale: 1.02 }}
        whileTap={{ scale: 0.97 }}
        className={`relative px-4 py-1.5 text-sm font-semibold transition-colors duration-300 rounded-full flex items-center gap-2 border border-transparent ${
          isActive
            ? "text-[#D4642C] bg-[#FAF6F2] border-[#EFE8E1] shadow-sm font-bold"
            : "text-stone-600 hover:text-stone-900"
        }`}
      >
        {isActive && (
          <motion.div
            layoutId="glass-active"
            className="absolute inset-0 bg-white rounded-full shadow-sm"
            transition={{ type: "spring", bounce: 0.3, duration: 0.6 }}
          />
        )}
        <span className="relative z-10 flex items-center gap-2">
          {Icon && <Icon size={14} strokeWidth={2.5} />}
          {label}
        </span>
      </motion.div>
    </Link>
  );
}

/* ── Mobile Menu Item ─── */
function MobileMenuItem({ label, href, isActive, icon: Icon, index, onClick }) {
  return (
    <motion.div
      initial={{ opacity: 0, x: -40, filter: "blur(10px)" }}
      animate={{ opacity: 1, x: 0, filter: "blur(0px)" }}
      exit={{ opacity: 0, x: 40, filter: "blur(10px)" }}
      transition={{
        delay: index * 0.06,
        type: "spring",
        stiffness: 200,
        damping: 25,
      }}
    >
      <Link href={href} onClick={onClick}>
        <div
          className="w-full flex items-center justify-between px-6 py-4 rounded-2xl cursor-pointer transition-all duration-300 group"
          style={{
            background: isActive
              ? "rgba(212, 100, 44, 0.1)"
              : "rgba(255,255,255,0.03)",
            border: isActive
              ? "1px solid rgba(212, 100, 44, 0.3)"
              : "1px solid rgba(255,255,255,0.06)",
          }}
        >
          <div className="flex items-center gap-4">
            {Icon && (
              <div
                className="flex items-center justify-center w-10 h-10 rounded-xl"
                style={{
                  background: isActive
                    ? "rgba(212, 100, 44, 0.2)"
                    : "rgba(255,255,255,0.06)",
                }}
              >
                <Icon
                  size={18}
                  style={{
                    color: isActive ? "#D4642C" : "rgba(255,255,255,0.5)",
                  }}
                />
              </div>
            )}
            <span
              className="text-lg font-bold tracking-tight"
              style={{
                color: isActive ? "#F28C59" : "#fff",
                fontFamily: "var(--font-display)",
              }}
            >
              {label}
            </span>
          </div>
          <ChevronRight
            size={20}
            className="transition-transform duration-300 group-hover:translate-x-1"
            style={{ color: isActive ? "#D4642C" : "rgba(255,255,255,0.15)" }}
          />
        </div>
      </Link>
    </motion.div>
  );
}

/* ═══════════════════════════════════════════════════════════ */
export default function Navbar({ user = null }) {
  const pathname = usePathname();
  const [mobileOpen, setMobileOpen] = useState(false);
  const [scrolled, setScrolled] = useState(false);
  const [hidden, setHidden] = useState(false);
  const { scrollY } = useScroll();

  useMotionValueEvent(scrollY, "change", (latest) => {
    const prev = scrollY.getPrevious();
    setScrolled(latest > 50);
    setHidden(latest > prev && latest > 150);
  });

  useEffect(() => {
    document.body.style.overflow = mobileOpen ? "hidden" : "";
    return () => {
      document.body.style.overflow = "";
    };
  }, [mobileOpen]);

  const links = user ? PORTAL_LINKS : PUBLIC_LINKS;

  return (
    <>
      {/* ── Floating Nav Bar ─── */}
      <motion.nav
        initial={{ y: -100, opacity: 0 }}
        animate={{ y: hidden ? -120 : 0, opacity: hidden ? 0 : 1 }}
        transition={{ type: "spring", damping: 30, stiffness: 200 }}
        className="fixed top-5 left-1/2 -translate-x-1/2 z-[100] flex items-center justify-between"
        style={{
          width: "min(92vw, 1200px)",
          height: 68,
          padding: "0 20px",
          borderRadius: 20,
          background: scrolled
            ? "rgba(255, 255, 255, 0.92)"
            : "rgba(250, 246, 242, 0.75)",
          backdropFilter: "blur(24px) saturate(1.6)",
          WebkitBackdropFilter: "blur(24px) saturate(1.6)",
          border: scrolled
            ? "1px solid rgba(239, 232, 225, 0.9)"
            : "1px solid rgba(255, 255, 255, 0.8)",
          boxShadow: scrolled
            ? "0 10px 30px rgba(0, 0, 0, 0.04), 0 1px 3px rgba(212, 100, 44, 0.04)"
            : "0 4px 20px rgba(0, 0, 0, 0.02)",
          transition: "background .4s, border .4s, box-shadow .4s",
        }}
      >
        {/* Logo */}
        <Link href="/" className="flex items-center select-none pl-4">
          <img
            src="/logo/image (4).png"
            alt="Logo"
            className="w-40 h-auto object-contain scale-[1.1] origin-left"
          />
        </Link>

        {/* Desktop Links */}
        <div className="hidden lg:flex items-center gap-1">
          <div
            className="flex items-center gap-1 px-2 py-1 rounded-2xl"
            style={{
              background: "rgba(255,255,255,0.4)",
              border: "1px solid rgba(239,232,225,0.6)",
            }}
          >
            {links.map((l) => (
              <NavLink
                key={l.href}
                {...l}
                isActive={
                  pathname === l.href ||
                  (l.href !== "/" && pathname.startsWith(l.href))
                }
              />
            ))}
          </div>
        </div>

        {/* Desktop CTA */}
        <div className="hidden lg:flex items-center gap-3">
          {!user ? (
            <>
              <Link
                href="/login"
                className="px-4 py-2 text-sm font-semibold text-stone-600 hover:text-[#D4642C] transition-colors"
              >
                Sign In
              </Link>
              <Link href="/signup">
                <UiloraBrandButton className="px-6 py-2.5 text-sm normal-case tracking-normal font-bold">
                  <Zap size={14} /> Join My Card Share
                </UiloraBrandButton>
              </Link>
            </>
          ) : (
            <motion.button
              whileHover={{ scale: 1.04 }}
              whileTap={{ scale: 0.96 }}
              className="px-4 py-2 text-sm font-bold rounded-xl border-0 cursor-pointer flex items-center gap-2"
              style={{
                background: "rgba(239,68,68,0.1)",
                color: "#ef4444",
                border: "1px solid rgba(239,68,68,0.2)",
              }}
            >
              <LogOut size={14} /> Disconnect
            </motion.button>
          )}
        </div>

        {/* Mobile Hamburger */}
        <motion.button
          whileTap={{ scale: 0.85, rotate: 90 }}
          className="lg:hidden border-0 bg-transparent text-white cursor-pointer p-2 rounded-xl"
          onClick={() => setMobileOpen(!mobileOpen)}
          aria-label="Toggle menu"
        >
          <AnimatePresence mode="wait">
            {mobileOpen ? (
              <motion.div
                key="x"
                initial={{ rotate: -90, opacity: 0 }}
                animate={{ rotate: 0, opacity: 1 }}
                exit={{ rotate: 90, opacity: 0 }}
              >
                <X size={24} />
              </motion.div>
            ) : (
              <motion.div
                key="m"
                initial={{ rotate: 90, opacity: 0 }}
                animate={{ rotate: 0, opacity: 1 }}
                exit={{ rotate: -90, opacity: 0 }}
              >
                <Menu size={24} />
              </motion.div>
            )}
          </AnimatePresence>
        </motion.button>
      </motion.nav>

      {/* ═══ Mobile Fullscreen Menu ═══ */}
      <AnimatePresence>
        {mobileOpen && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-[99] flex flex-col"
            style={{
              background: "rgba(3,6,15,0.97)",
              backdropFilter: "blur(40px)",
            }}
          >
            <div className="absolute inset-0 overflow-hidden pointer-events-none">
              <div
                className="absolute w-96 h-96 rounded-full -top-20 -right-20"
                style={{
                  background:
                    "radial-gradient(circle, rgba(212,100,44,0.2), transparent 70%)",
                  filter: "blur(60px)",
                }}
              />
              <div
                className="absolute w-72 h-72 rounded-full bottom-20 -left-20"
                style={{
                  background:
                    "radial-gradient(circle, rgba(242,140,89,0.15), transparent 70%)",
                  filter: "blur(60px)",
                }}
              />
            </div>
            <div className="flex flex-col h-full pt-28 pb-8 px-6 relative z-10 overflow-y-auto">
              <div className="flex flex-col gap-2.5 flex-1">
                {links.map((l, i) => (
                  <MobileMenuItem
                    key={l.href}
                    {...l}
                    isActive={pathname === l.href}
                    index={i}
                    onClick={() => setMobileOpen(false)}
                  />
                ))}
              </div>
              <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.3 }}
                className="flex flex-col gap-3 mt-8"
              >
                {!user ? (
                  <>
                    <Link
                      href="/login"
                      onClick={() => setMobileOpen(false)}
                      className="w-full py-3.5 rounded-2xl font-bold text-white/70 text-center text-base"
                      style={{
                        background: "rgba(255,255,255,0.05)",
                        border: "1px solid rgba(255,255,255,0.1)",
                      }}
                    >
                      Sign In
                    </Link>
                    <Link
                      href="/signup"
                      onClick={() => setMobileOpen(false)}
                      className="w-full"
                    >
                      <UiloraBrandButton className="w-full py-4 text-base normal-case tracking-normal">
                        <Zap size={16} /> Join the Network
                      </UiloraBrandButton>
                    </Link>
                  </>
                ) : (
                  <button
                    className="w-full py-3.5 rounded-2xl font-bold text-base border-0 flex items-center justify-center gap-2"
                    style={{
                      background: "rgba(239,68,68,0.1)",
                      color: "#ef4444",
                      border: "1px solid rgba(239,68,68,0.2)",
                    }}
                  >
                    <LogOut size={16} /> Disconnect
                  </button>
                )}
              </motion.div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
}
