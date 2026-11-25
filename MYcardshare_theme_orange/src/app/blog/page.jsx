import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import Link from "next/link";
import { Clock, ArrowRight } from "lucide-react";
import { JsonLd, breadcrumbSchema } from "@/lib/schema";

export const metadata = {
  title: "Blog — Digital Networking & Business Card Insights",
  description:
    "Expert insights on professional networking, digital business cards, NFC technology, and enterprise identity management. Guides, case studies, and industry trends from Pentacloud.",
  alternates: { canonical: "https://digitalbusinesscloudcard.com/blog" },
  openGraph: {
    title: "My Card Share Blog — Digital Identity & Networking Insights",
    description:
      "Guides, case studies, and industry trends on digital business cards, NFC, and professional networking.",
    url: "https://digitalbusinesscloudcard.com/blog",
  },
};

const POSTS = [
  {
    slug: "future-of-networking",
    title: "The Future of Professional Networking in 2026",
    excerpt:
      "How digital business cards and NFC technology are reshaping the way professionals connect.",
    category: "Industry",
    readTime: "40 seconds",
    date: "Mar 15, 2026",
    dateISO: "2026-03-15",
    color: "#6366f1",
    image:
      "https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&q=80&w=800",
  },
  {
    slug: "nfc-vs-qr",
    title: "NFC vs QR: Which Sharing Method Wins?",
    excerpt:
      "A deep-dive comparison of NFC tap, QR scan, and link sharing for business card distribution.",
    category: "Technology",
    readTime: "55 seconds",
    date: "Mar 8, 2026",
    dateISO: "2026-03-08",
    color: "#06b6d4",
    image:
      "https://images.unsplash.com/photo-1550751827-4bd374c3f58b?auto=format&fit=crop&q=80&w=800",
  },
  {
    slug: "enterprise-digital-cards",
    title: "Why Enterprises Are Going Digital-First with Business Cards",
    excerpt:
      "Case study: How a global team streamlined networking with digital cards.",
    category: "Enterprise",
    readTime: "45 seconds",
    date: "Feb 28, 2026",
    dateISO: "2026-02-28",
    color: "#a78bfa",
    image:
      "https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&q=80&w=800",
  },
  {
    slug: "design-your-identity",
    title: "Designing a Digital Identity That Converts",
    excerpt:
      "Best practices for creating a business card that turns views into connections.",
    category: "Design",
    readTime: "50 seconds",
    date: "Feb 20, 2026",
    dateISO: "2026-02-20",
    color: "#10d9a8",
    image:
      "https://images.unsplash.com/photo-1561070791-2526d30994b5?auto=format&fit=crop&q=80&w=800",
  },
];

export default function BlogPage() {
  const breadcrumbs = breadcrumbSchema([
    { name: "Home", url: "/" },
    { name: "Blog" },
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
          <div className="text-center mb-16">
            <h1
              className="text-gradient mb-4"
              style={{ fontFamily: "var(--font-display)" }}
            >
              My Card Share Blog
            </h1>
            <p
              className="text-base max-w-lg mx-auto"
              style={{ color: "var(--color-muted)" }}
            >
              Expert insights on digital identity, NFC networking, and the
              future of professional connections.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {POSTS.map((post) => (
              <Link key={post.slug} href={`/blog/${post.slug}`}>
                <article
                  className="group bg-white border border-slate-200 shadow-sm rounded-2xl flex flex-col h-full transition-all duration-300 cursor-pointer hover:border-sky-400 hover:shadow-md overflow-hidden relative"
                >
                  <div className="w-full h-56 relative overflow-hidden">
                    <img
                      src={post.image}
                      alt={post.title}
                      className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-700"
                    />
                    <div className="absolute inset-0 bg-gradient-to-t from-[#05091a] to-transparent opacity-60"></div>
                  </div>
                  <div className="p-8 flex flex-col flex-grow">
                    <div className="flex items-center gap-3 mb-4">
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
                      <span
                        className="text-xs flex items-center gap-1"
                        style={{ color: "rgba(15, 23, 42, 0.5)" }}
                      >
                        <Clock size={10} /> {post.readTime}
                      </span>
                    </div>
                    <h2
                      className="text-xl font-bold text-slate-800 mb-3 group-hover:text-indigo-500 transition-colors"
                      style={{ fontFamily: "var(--font-display)" }}
                    >
                      {post.title}
                    </h2>
                    <p
                      className="text-sm leading-relaxed mb-6 flex-grow"
                      style={{ color: "var(--color-muted)" }}
                    >
                      {post.excerpt}
                    </p>
                    <div className="flex items-center justify-between mt-auto">
                      <time
                        dateTime={post.dateISO}
                        className="text-xs"
                        style={{ color: "rgba(15, 23, 42, 0.5)" }}
                      >
                        {post.date}
                      </time>
                      <span
                        className="text-xs font-bold flex items-center gap-1 group-hover:text-slate-800 transition-colors"
                        style={{ color: "#818cf8" }}
                      >
                        Read{" "}
                        <ArrowRight
                          size={12}
                          className="group-hover:translate-x-1 transition-transform"
                        />
                      </span>
                    </div>
                  </div>
                </article>
              </Link>
            ))}
          </div>
        </div>
      </section>
      <Footer />
    </>
  );
}
