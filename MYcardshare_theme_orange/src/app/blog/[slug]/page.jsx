import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import Link from "next/link";
import { ArrowLeft, Clock, Calendar } from "lucide-react";
import { JsonLd, articleSchema, breadcrumbSchema } from "@/lib/schema";

/* ── Blog Posts Data ──────────────────────────────────────── */
const POSTS = {
  "future-of-networking": {
    title: "The Future of Professional Networking in 2026",
    description:
      "How digital business cards and NFC technology are reshaping the way professionals connect in 2026.",
    category: "Industry",
    readTime: "40 seconds",
    date: "Mar 15, 2026",
    dateISO: "2026-03-15",
    color: "#6366f1",
  },
  "nfc-vs-qr": {
    title: "NFC vs QR: Which Sharing Method Wins?",
    description:
      "A deep-dive comparison of NFC tap, QR scan, and link sharing for business card distribution.",
    category: "Technology",
    readTime: "55 seconds",
    date: "Mar 8, 2026",
    dateISO: "2026-03-08",
    color: "#06b6d4",
  },
  "enterprise-digital-cards": {
    title: "Why Enterprises Are Going Digital-First with Business Cards",
    description:
      "Case study: How a global team deployed digital business cards in a single week.",
    category: "Enterprise",
    readTime: "45 seconds",
    date: "Feb 28, 2026",
    dateISO: "2026-02-28",
    color: "#a78bfa",
  },
  "design-your-identity": {
    title: "Designing a Digital Identity That Converts",
    description:
      "Best practices for creating a digital business card that turns profile views into real connections.",
    category: "Design",
    readTime: "50 seconds",
    date: "Feb 20, 2026",
    dateISO: "2026-02-20",
    color: "#10d9a8",
  },
};

/* ── Dynamic Metadata ─────────────────────────────────────── */
export async function generateMetadata({ params }) {
  const { slug } = await params;
  const post = POSTS[slug];

  if (!post) {
    return { title: "Article Not Found" };
  }

  return {
    title: post.title,
    description: post.description,
    alternates: { canonical: `https://digitalbusinesscloudcard.com/blog/${slug}` },
    openGraph: {
      title: post.title,
      description: post.description,
      url: `https://digitalbusinesscloudcard.com/blog/${slug}`,
      type: "article",
      publishedTime: post.dateISO,
      authors: ["Pentacloud Team"],
      tags: [post.category, "digital business card", "professional networking"],
    },
    twitter: {
      card: "summary_large_image",
      title: post.title,
      description: post.description,
    },
  };
}

/* ── Page Component ───────────────────────────────────────── */
export default async function BlogDetailPage({ params }) {
  const { slug } = await params;
  const post = POSTS[slug] || POSTS["future-of-networking"];

  const articleJsonLd = articleSchema({
    headline: post.title,
    description: post.description,
    slug,
    datePublished: post.dateISO,
    readTime: post.readTime,
  });

  const breadcrumbs = breadcrumbSchema([
    { name: "Home", url: "/" },
    { name: "Blog", url: "/blog" },
    { name: post.title },
  ]);

  return (
    <>
      <JsonLd data={articleJsonLd} />
      <JsonLd data={breadcrumbs} />
      <Navbar />
      <article
        className="pt-40 pb-24"
        style={{ background: "var(--color-aurora-bg)" }}
      >
        <div className="max-w-3xl mx-auto px-6">
          <Link
            href="/blog"
            className="inline-flex items-center gap-2 text-sm font-semibold mb-8 transition-colors hover:text-slate-900"
            style={{ color: "#818cf8" }}
          >
            <ArrowLeft size={14} /> Back to Blog
          </Link>

          <div className="flex items-center gap-4 mb-6">
            <span
              className="px-2.5 py-1 rounded-lg text-[11px] font-bold"
              style={{
                background: `${post.color}15`,
                color: post.color,
                border: `1px solid ${post.color}25`,
              }}
            >
              {post.category}
            </span>
            <span className="text-xs flex items-center gap-1 text-slate-500">
              <Clock size={10} /> {post.readTime} read
            </span>
            <time
              dateTime={post.dateISO}
              className="text-xs flex items-center gap-1 text-slate-500"
            >
              <Calendar size={10} /> {post.date}
            </time>
          </div>

          <h1
            className="text-3xl md:text-4xl font-black tracking-tight text-slate-900 mb-6 leading-tight"
            style={{ fontFamily: "var(--font-display)" }}
          >
            {post.title}
          </h1>

          <div
            className="flex items-center gap-3 mb-10 pb-8 border-b border-slate-200"
          >
            <div
              className="w-10 h-10 rounded-full flex items-center justify-center text-sm font-bold"
              style={{ background: "rgba(99,102,241,0.15)", color: "#818cf8" }}
            >
              P
            </div>
            <div>
              <div className="text-sm font-bold text-slate-900">
                Pentacloud Team
              </div>
              <div className="text-xs" style={{ color: "var(--color-muted)" }}>
                My Card Share Research
              </div>
            </div>
          </div>

          <div className="prose max-w-none space-y-6">
            <p className="text-base leading-relaxed text-slate-600">
              The way professionals connect is undergoing a fundamental shift.
              Paper business cards, once the standard bearer of professional
              introductions, are giving way to a new paradigm of digital-first
              identity.
            </p>
            <p className="text-base leading-relaxed text-slate-600">
              With NFC-enabled devices now in the hands of billions, the
              tap-to-share gesture is becoming as natural as a handshake.
              Digital business cards aren&apos;t just replacements for paper —
              they&apos;re entirely new tools for building professional
              relationships.
            </p>
            <h2
              className="text-2xl font-black tracking-tight text-slate-900 mt-10 mb-4"
              style={{ fontFamily: "var(--font-display)" }}
            >
              The Data Speaks
            </h2>
            <p className="text-base leading-relaxed text-slate-600">
              Our research shows that digital business cards have a 6.8x higher
              conversion rate than traditional paper cards. Recipients of
              digital cards are 3.2x more likely to follow up within 48 hours.
            </p>
          </div>
        </div>
      </article>
      <Footer />
    </>
  );
}
