import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import Link from "next/link";
import {
  Smartphone,
  ArrowRight,
  Zap,
  Share2,
  Scan,
  BarChart3,
  Lock,
  Palette,
  Users,
  Globe,
} from "lucide-react";
import {
  JsonLd,
  softwareAppSchema,
  breadcrumbSchema,
  faqSchema,
} from "@/lib/schema";

export const metadata = {
  title: "Digital Business Card Features — QR, AI Scanner",
  description:
    "Explore My Card Share features: QR code scanning, AI-powered card scanner, live analytics, custom themes, and enterprise team management. Free to start.",
  alternates: { canonical: "https://digitalbusinesscloudcard.com/features" },
  openGraph: {
    title:
      "My Card Share Platform Features — Everything You Need for Digital Networking",
    description:
      "QR sharing, AI card scanner, live analytics, 50+ themes, and enterprise SSO. Discover every feature of the My Card Share digital business card platform.",
    url: "https://digitalbusinesscloudcard.com/features",
  },
};

const FEATURES = [
  {
    icon: Smartphone,
    title: "Digital Identity Card",
    desc: "Create stunning, mobile-first digital business cards with custom themes, brand colors, and professional layouts that adapt to any device.",
    color: "#6366f1",
  },
  {
    icon: Share2,
    title: "One-Tap Sharing",
    desc: "Share instantly via QR scan, link, AirDrop, WhatsApp, or email. One card, infinite touchpoints.",
    color: "#06b6d4",
  },
  {
    icon: Scan,
    title: "AI Card Scanner",
    desc: "Point your camera at any paper business card. Our AI extracts all contact details in seconds and saves to your vault.",
    color: "#a78bfa",
  },
  {
    icon: BarChart3,
    title: "Live Analytics",
    desc: "Track every view, tap, save, and share in real-time. Geographic breakdown, time series, and conversion metrics.",
    color: "#10d9a8",
  },
  {
    icon: Lock,
    title: "Enterprise Security",
    desc: "256-bit AES encryption, robust data protection, SSO integration, and admin approval workflows.",
    color: "#ef4444",
  },
  {
    icon: Palette,
    title: "Custom Themes",
    desc: "50+ premium themes or create your own. Custom colors, fonts, layouts, and brand guidelines enforcement.",
    color: "#ec4899",
  },
  {
    icon: Users,
    title: "Team Portal",
    desc: "Deploy and manage cards for your entire team. Bulk onboarding, role-based permissions, and centralized control.",
    color: "#e8c975",
  },
  {
    icon: Globe,
    title: "Global Network",
    desc: "Your card loads instantly, anywhere. Built on high-performance cloud infrastructure for fast response times.",
    color: "#f97316",
  },
];

export default function FeaturesPage() {
  const breadcrumbs = breadcrumbSchema([
    { name: "Home", url: "/" },
    { name: "Features" },
  ]);

  const featureFaq = faqSchema([
    {
      question: "What is a digital business card?",
      answer:
        "A digital business card is an electronic alternative to paper cards that you can share via QR code, or link. It updates in real-time, tracks analytics, and never runs out.",
    },
    {
      question: "Can I use My Card Share for my entire team?",
      answer:
        "Yes. My Card Share Enterprise supports bulk onboarding, centralized design control, SSO integration, and admin approval workflows for teams of any size.",
    },
    {
      question: "Is My Card Share free to use?",
      answer:
        "Yes. Create one digital business card for free. Upgrade to Pro for unlimited cards, analytics, and custom themes. Enterprise plans include SSO and team management.",
    },
    {
      question: "What information can I put on my digital business card?",
      answer:
        "Your name, title, company, phone, email, website, social media profiles, profile photo, banner image, and a custom bio. All editable in real-time.",
    },
  ]);

  const appSchema = softwareAppSchema();

  return (
    <>
      <JsonLd data={breadcrumbs} />
      <JsonLd data={featureFaq} />
      <JsonLd data={appSchema} />
      <Navbar />
      <section
        className="pt-40 pb-24"
        style={{ background: "var(--color-aurora-bg)" }}
      >
        <div className="max-w-6xl mx-auto px-6">
          <div className="text-center mb-16">
            <h1
              className="text-gradient mb-4"
              style={{ fontFamily: "var(--font-display)" }}
            >
              Platform Features
            </h1>
            <p
              className="text-base max-w-lg mx-auto"
              style={{ color: "var(--color-muted)" }}
            >
              Every tool you need to create, share, scan, and manage
              professional digital identities.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
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
                  className="text-xl font-bold mb-3"
                  style={{ fontFamily: "var(--font-display)", color: "#111827" }}
                >
                  {title}
                </h3>
                <p
                  className="text-sm leading-relaxed"
                  style={{ color: "#6B7280" }}
                >
                  {desc}
                </p>
              </div>
            ))}
          </div>

          <div className="text-center mt-16">
            <Link
              href="/signup"
              className="btn-primary text-base px-8 py-4 inline-flex items-center gap-2"
            >
              <Zap size={18} /> Get Started Free
            </Link>
          </div>
        </div>
      </section>
      <Footer />
    </>
  );
}
