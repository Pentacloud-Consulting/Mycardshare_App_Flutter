"use client";

import { motion } from "framer-motion";
import Link from "next/link";
import { ArrowRight, Clock } from "lucide-react";

const recentBlogs = [
  {
    category: "Product Architecture",
    title: "Introducing My Card Share: The Sovereign Identity Protocol",
    excerpt:
      "How our decentralized card engine transforms ephemeral paper handshakes into permanent digital relationship bridges.",
    date: "April 12, 2026",
    readTime: "3 min read",
    slug: "/blog/introducing-mycardshare",
    image:
      "https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&q=80&w=800",
  },
  {
    category: "Executive Playbook",
    title: "How Global Founders Maximize Global Conference ROI",
    excerpt:
      "Field-tested workflows on utilizing instant NFC taps and automated CRM pushes to capture 500+ warm leads at major summits.",
    date: "March 28, 2026",
    readTime: "4 min read",
    slug: "/blog/maximize-conference-roi",
    image:
      "https://images.unsplash.com/photo-1556761175-5973dc0f32e7?auto=format&fit=crop&q=80&w=800",
  },
  {
    category: "Security & Engineering",
    title: "Building Ultra Low-Latency NFC Tag Infrastructure",
    excerpt:
      "An in-depth technical exploration into optimizing edge CDN routes to deliver responsive profile renders under 40 milliseconds.",
    date: "March 15, 2026",
    readTime: "5 min read",
    slug: "/blog/zero-latency-nfc",
    image:
      "https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&q=80&w=800",
  },
];

export default function BlogSection() {
  return (
    <section className="py-20 md:py-28 bg-white">
      <div className="max-w-7xl mx-auto px-6">
        {/* Header */}
        <div className="flex flex-col md:flex-row md:items-end justify-between mb-12 sm:mb-16 gap-6">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
          >
            <div className="inline-flex items-center gap-2 px-3.5 py-1 rounded-full text-xs font-bold uppercase tracking-widest mb-3 bg-[#FAF6F2] border border-[#EFE8E1] text-[#D4642C]">
              Thoughts & Analysis
            </div>
            <h2
              className="text-3xl sm:text-4xl md:text-5xl font-black text-[#18181B] uppercase tracking-tight"
              style={{ fontFamily: "var(--font-display)" }}
            >
              Latest Insights
            </h2>
            <p className="text-stone-500 max-w-md mt-2 text-base font-normal">
              Strategies, product innovations, and engineering notes from the
              MyCardShare team.
            </p>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, x: 20 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
          >
            <Link
              href="/blog"
              className="inline-flex items-center gap-2 text-[#D4642C] font-bold text-sm tracking-wider uppercase group hover:text-[#BD5523] transition-colors"
            >
              View All Articles{" "}
              <ArrowRight
                size={16}
                className="transition-transform group-hover:translate-x-1"
              />
            </Link>
          </motion.div>
        </div>

        {/* Blog Cards */}
        <div className="grid md:grid-cols-3 gap-6 sm:gap-8">
          {recentBlogs.map((post, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 25 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ delay: i * 0.08 }}
              viewport={{ once: true }}
            >
              <Link href={post.slug} className="block h-full group">
                <div className="bg-[#FAF6F2] border border-[#EFE8E1] group-hover:border-[#D4642C]/40 rounded-[28px] overflow-hidden flex flex-col h-full transition-all duration-300 shadow-xs group-hover:shadow-[0_12px_30px_rgba(212,100,44,0.08)] group-hover:-translate-y-1">
                  {/* Image */}
                  <div className="w-full h-48 sm:h-52 relative overflow-hidden bg-stone-100">
                    <img
                      src={post.image}
                      alt={post.title}
                      className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105"
                    />
                    <div className="absolute top-4 left-4">
                      <span className="px-3 py-1 rounded-full text-[11px] font-bold uppercase tracking-wider bg-white/90 backdrop-blur-md border border-[#EFE8E1] text-[#D4642C] shadow-xs">
                        {post.category}
                      </span>
                    </div>
                  </div>

                  {/* Body */}
                  <div className="p-6 sm:p-7 flex flex-col flex-1">
                    <div className="flex items-center gap-3 text-xs text-stone-400 font-medium mb-3">
                      <span>{post.date}</span>
                      <span>•</span>
                      <span className="flex items-center gap-1">
                        <Clock size={12} /> {post.readTime}
                      </span>
                    </div>

                    <h3
                      className="text-lg sm:text-xl font-bold text-[#18181B] group-hover:text-[#D4642C] transition-colors mb-3 leading-snug"
                      style={{ fontFamily: "var(--font-display)" }}
                    >
                      {post.title}
                    </h3>

                    <p className="text-stone-500 text-sm leading-relaxed mb-6 font-normal">
                      {post.excerpt}
                    </p>

                    <div className="mt-auto flex items-center gap-1.5 text-xs font-bold text-[#D4642C] uppercase tracking-wider">
                      Read Article <ArrowRight size={14} />
                    </div>
                  </div>
                </div>
              </Link>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
