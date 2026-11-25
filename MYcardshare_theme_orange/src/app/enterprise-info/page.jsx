import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import Link from "next/link";
import {
  Building2,
  Users,
  Shield,
  BarChart3,
  Zap,
  Globe,
  ArrowRight,
  Check,
} from "lucide-react";
import { JsonLd, breadcrumbSchema } from "@/lib/schema";

export const metadata = {
  title: "Enterprise Digital Business Cards — Team Management & SSO",
  description:
    "Deploy branded digital business cards across your entire organization. Bulk onboarding, admin approval workflows, organization analytics, SSO integration, and brand compliance built in.",
  alternates: { canonical: "https://digitalbusinesscloudcard.com/enterprise" },
  openGraph: {
    title: "My Card Share Enterprise — Scale Your Team's Digital Identity",
    description:
      "Deploy branded digital cards for your entire team. Admin controls, SSO, analytics, and brand compliance.",
    url: "https://digitalbusinesscloudcard.com/enterprise",
  },
};

const FEATURES = [
  {
    icon: Users,
    title: "Team Management",
    desc: "Onboard hundreds of employees in a single batch. Control card designs centrally.",
    color: "#6366f1",
  },
  {
    icon: Shield,
    title: "Admin Approval Workflows",
    desc: "Review and approve individual card changes before they go live.",
    color: "#06b6d4",
  },
  {
    icon: BarChart3,
    title: "Organization Analytics",
    desc: "Track team-wide card performance. See who's networking most effectively.",
    color: "#a78bfa",
  },
  {
    icon: Globe,
    title: "SSO Integration",
    desc: "Azure AD, Okta, Google Workspace — one login for the entire team.",
    color: "#10d9a8",
  },
  {
    icon: Zap,
    title: "API Access",
    desc: "Automate card creation and management with our REST API.",
    color: "#e8c975",
  },
  {
    icon: Building2,
    title: "Brand Compliance",
    desc: "Lock colors, logos, and templates to ensure brand consistency.",
    color: "#ec4899",
  },
];

export default function EnterprisePage() {
  const breadcrumbs = breadcrumbSchema([
    { name: "Home", url: "/" },
    { name: "Enterprise" },
  ]);

  return (
    <>
      <JsonLd data={breadcrumbs} />
      <Navbar />
      <section
        className="pt-40 pb-24"
        style={{ background: "var(--color-aurora-bg)" }}
      >
        <div className="max-w-6xl mx-auto px-6">
          {/* Hero */}
          <div className="text-center mb-20">
            <div
              className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full text-xs font-bold uppercase tracking-[0.15em] mb-4"
              style={{
                background: "rgba(232,201,117,0.1)",
                border: "1px solid rgba(232,201,117,0.2)",
                color: "#e8c975",
              }}
            >
              <Building2 size={12} /> Enterprise
            </div>
            <h1
              className="text-gradient mb-4"
              style={{ fontFamily: "var(--font-display)" }}
            >
              Scale Your Team's
              <br />
              Digital Identity
            </h1>
            <p
              className="text-base max-w-lg mx-auto mb-8"
              style={{ color: "var(--color-muted)" }}
            >
              Deploy branded digital business cards across your entire
              organization. Admin controls, analytics, and compliance — built
              in.
            </p>
            <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
              <Link
                href="/contact"
                className="btn-primary text-base px-8 py-4 flex items-center gap-2"
              >
                <Zap size={18} /> Request Demo
              </Link>
              <Link
                href="/pricing"
                className="flex items-center gap-2 text-sm font-bold transition-colors hover:text-white"
                style={{ color: "#818cf8" }}
              >
                View Pricing <ArrowRight size={14} />
              </Link>
            </div>
          </div>

          {/* Feature Grid */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {FEATURES.map(({ icon: Icon, title, desc, color }) => (
              <div
                key={title}
                className="bg-white border border-slate-200 shadow-sm rounded-2xl p-8 group transition-all duration-300 hover:border-sky-400 hover:shadow-md"
              >
                <div
                  className="w-12 h-12 rounded-2xl flex items-center justify-center mb-5"
                  style={{ background: `${color}15` }}
                >
                  <Icon size={22} style={{ color }} />
                </div>
                <h3
                  className="text-lg font-bold text-slate-800 mb-2"
                  style={{ fontFamily: "var(--font-display)" }}
                >
                  {title}
                </h3>
                <p
                  className="text-sm leading-relaxed"
                  style={{ color: "var(--color-muted)" }}
                >
                  {desc}
                </p>
              </div>
            ))}
          </div>
        </div>
      </section>
      <Footer />
    </>
  );
}
