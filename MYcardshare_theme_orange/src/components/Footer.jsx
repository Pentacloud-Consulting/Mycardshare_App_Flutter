import Link from "next/link";
import {
  Twitter,
  Linkedin,
  Github,
  Instagram,
  Mail,
  Phone,
} from "lucide-react";

/* ═══════════════════════════════════════════════════════════
   PREMIUM FOOTER — WARM LUXURY PALETTE
   White base, Warm cream glow, Matte orange accents
   ═══════════════════════════════════════════════════════════ */

const LINK_GROUPS = [
  {
    title: "Product",
    links: [
      { label: "Features", href: "/features" },
      { label: "Pricing", href: "/pricing" },
      { label: "Enterprise", href: "/enterprise" },
      { label: "Blog", href: "/blog" },
    ],
  },
  {
    title: "Company",
    links: [
      { label: "About Us", href: "/about" },
      { label: "Contact", href: "/contact" },
      { label: "Privacy Policy", href: "/privacy" },
      { label: "Terms of Service", href: "/terms" },
    ],
  },
  {
    title: "Resources",
    links: [
      { label: "Documentation", href: "#" },
      { label: "Developer API", href: "#" },
      { label: "Security Architecture", href: "#" },
      { label: "System Status", href: "#" },
    ],
  },
];

const SOCIALS = [
  { icon: Linkedin, href: "#", label: "LinkedIn" },
  { icon: Instagram, href: "#", label: "Instagram" },
  { icon: Github, href: "#", label: "GitHub" },
  { icon: Twitter, href: "#", label: "Twitter" },
];

export default function Footer() {
  return (
    <footer className="relative w-full bg-white pt-20 pb-10 overflow-hidden border-t border-[#EFE8E1]">
      {/* Subtle ambient warm glow */}
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-3/4 h-40 bg-[radial-gradient(ellipse_at_top,_var(--tw-gradient-stops))] from-[#FAF6F2] via-transparent to-transparent pointer-events-none" />

      <div className="relative z-10 max-w-7xl mx-auto px-6 sm:px-8 lg:px-12">
        {/* Top Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 lg:gap-8 mb-12">
          {/* Logo & Contact */}
          <div className="lg:col-span-5 pr-0 lg:pr-12 flex flex-col items-center lg:items-start text-center lg:text-left">
            <Link href="/" className="inline-block mb-6">
              <img
                src="/logo/image (4).png"
                alt="MyCardShare Logo"
                className="h-24 sm:h-28 w-auto object-contain mx-auto lg:mx-0"
              />
            </Link>
            <p className="text-[13px] leading-relaxed text-stone-500 mb-8 max-w-xs px-4 lg:px-0 font-normal">
              The modern standard for digital business cards. Elevate your
              professional presence, capture high-intent leads, and network with
              confidence anywhere.
            </p>
            <div className="space-y-3.5 flex flex-col items-center lg:items-start">
              <div className="flex items-center gap-3 text-stone-700">
                <div className="w-8 h-8 rounded-lg bg-[#FAF6F2] flex items-center justify-center border border-[#EFE8E1] shrink-0 text-[#D4642C]">
                  <Phone size={14} />
                </div>
                <span className="text-[13px] font-medium">+1 (555) 123-4567</span>
              </div>
              <div className="flex items-center gap-3 text-stone-700">
                <div className="w-8 h-8 rounded-lg bg-[#FAF6F2] flex items-center justify-center border border-[#EFE8E1] shrink-0 text-[#D4642C]">
                  <Mail size={14} />
                </div>
                <span className="text-[13px] font-medium">hello@mycardshare.com</span>
              </div>
            </div>
          </div>

          {/* Links */}
          <div className="lg:col-span-7 grid grid-cols-1 sm:grid-cols-3 gap-8 sm:gap-6 pt-4 text-center sm:text-left">
            {LINK_GROUPS.map((group) => (
              <div
                key={group.title}
                className="flex flex-col items-center sm:items-start"
              >
                <h4
                  className="text-sm font-bold text-[#18181B] mb-4 uppercase tracking-wider"
                  style={{ fontFamily: "var(--font-display)" }}
                >
                  {group.title}
                </h4>
                <ul className="space-y-3">
                  {group.links.map((link) => (
                    <li key={link.label}>
                      <Link
                        href={link.href}
                        className="text-[13px] text-stone-500 hover:text-[#D4642C] transition-colors duration-200 block font-normal"
                      >
                        {link.label}
                      </Link>
                    </li>
                  ))}
                </ul>
              </div>
            ))}
          </div>
        </div>

        {/* Giant Watermark & Divider */}
        <div className="relative mt-16 mb-8 select-none pointer-events-none">
          <div className="text-[clamp(2.5rem,11vw,9.5rem)] font-black leading-none tracking-tighter text-center uppercase overflow-hidden whitespace-nowrap bg-clip-text text-transparent bg-gradient-to-br from-stone-200 via-stone-100 to-[#FAF6F2] opacity-80">
            MYCARDSHARE
          </div>

          <div className="absolute left-0 right-0 bottom-2 flex items-center">
            <div className="h-[1px] w-full bg-[#EFE8E1]" />
            <div className="absolute left-1/2 -translate-x-1/2 w-7 h-7 rounded-full border border-[#EFE8E1] bg-white flex items-center justify-center shadow-xs">
              <div className="w-[5px] h-[5px] rounded-full bg-[#D4642C] shadow-[0_0_8px_rgba(212,100,44,0.6)]" />
            </div>
          </div>
        </div>

        {/* Bottom Bar */}
        <div className="flex flex-col md:flex-row justify-between items-center gap-6 pt-2">
          <div className="text-xs text-stone-400">
            © {new Date().getFullYear()} My Card Share. All rights reserved.
          </div>

          <div className="flex items-center gap-2.5">
            {SOCIALS.map(({ icon: Icon, href, label }) => (
              <a
                key={label}
                href={href}
                aria-label={label}
                className="w-9 h-9 rounded-full bg-[#FAF6F2] hover:bg-white border border-[#EFE8E1] hover:border-[#D4642C]/40 flex items-center justify-center text-stone-500 hover:text-[#D4642C] transition-all duration-300 shadow-xs"
              >
                <Icon size={15} />
              </a>
            ))}
          </div>

          <div className="flex items-center gap-6 text-xs text-stone-400">
            <Link
              href="/terms"
              className="hover:text-[#D4642C] transition-colors"
            >
              Terms of Service
            </Link>
            <span className="w-[1px] h-3 bg-stone-300" />
            <Link
              href="/privacy"
              className="hover:text-[#D4642C] transition-colors"
            >
              Privacy Policy
            </Link>
          </div>
        </div>
      </div>
    </footer>
  );
}
