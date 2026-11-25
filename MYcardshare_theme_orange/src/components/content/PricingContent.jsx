"use client";

import { motion, useInView } from "framer-motion";
import { useRef, useState } from "react";
import Link from "next/link";
import { Check, Zap, Crown, Building2, Sparkles } from "lucide-react";

/* ═══════════════════════════════════════════════════════════
   PRICING — UILORA Dark Executive Style
   ═══════════════════════════════════════════════════════════ */

const PLANS = [
  {
    name: "Starter",
    price: "Free",
    period: "forever",
    desc: "Perfect for individuals getting started with digital identity.",
    color: "#818cf8",
    icon: Zap,
    features: [
      "1 Digital Business Card",
      "QR Code Sharing",
      "Basic Analytics",
      "100 Contact Vault",
      "Standard Templates",
    ],
    cta: "Get Started Free",
    popular: false,
  },
  {
    name: "Pro",
    price: "$9",
    period: "/month",
    desc: "For professionals who want to stand out and track their reach.",
    color: "#6366f1",
    icon: Crown,
    features: [
      "Unlimited Digital Cards",
      "QR + Link Sharing",
      "Advanced Analytics Dashboard",
      "Unlimited Contact Vault",
      "Premium Templates",
      "AI Card Scanner",
      "Custom Branding",
      "Priority Support",
    ],
    cta: "Start Pro Trial",
    popular: true,
  },
  {
    name: "Enterprise",
    price: "Custom",
    period: "",
    desc: "For teams and organizations that need centralized control.",
    color: "#e8c975",
    icon: Building2,
    features: [
      "Everything in Pro",
      "Team Management Portal",
      "Admin Approval Workflows",
      "Bulk Card Deployment",
      "SSO Integration",
      "Custom API Access",
      "Dedicated Account Manager",
      "SLA Guarantee",
    ],
    cta: "Contact Sales",
    popular: false,
  },
];

function PlanCard({
  name,
  price,
  period,
  desc,
  color,
  icon: Icon,
  features,
  cta,
  popular,
  index,
}) {
  const ref = useRef(null);
  const inView = useInView(ref, { once: true, margin: "-60px" });

  return (
    <motion.div
      ref={ref}
      initial={{ opacity: 0, y: 30 }}
      animate={inView ? { opacity: 1, y: 0 } : {}}
      transition={{
        delay: index * 0.1,
        duration: 0.6,
        ease: [0.16, 1, 0.3, 1],
      }}
      className={`group relative ${popular ? "lg:-mt-4 lg:mb-4 w-full max-w-[320px] mx-auto shadow-2xl" : "w-full max-w-[320px] mx-auto"}`}
    >
      {/* Animated Background Glow */}
      <div
        className="absolute -inset-0.5 rounded-3xl blur opacity-20 group-hover:opacity-100 transition duration-1000 group-hover:duration-200"
        style={{
          background: popular
            ? "linear-gradient(to right, #9333ea, #2563eb)"
            : "linear-gradient(to right, #4b5563, #374151)",
        }}
      ></div>

      <div
        className="relative w-full bg-white border border-slate-200 shadow-sm rounded-3xl p-6 flex flex-col h-full hover:border-slate-300 transition-colors"
        style={{ minHeight: "480px" }}
      >
        <div className="flex justify-between items-start mb-8">
          <div className="p-3 bg-slate-50 rounded-2xl border border-slate-100">
            <Icon size={24} style={{ color }} />
          </div>
          {popular && (
            <span className="bg-purple-500/10 text-purple-400 text-[10px] font-bold px-3 py-1 rounded-full border border-purple-500/20 uppercase tracking-widest">
              Popular
            </span>
          )}
        </div>

        <h3 className="text-slate-800 text-xl font-bold mb-1 tracking-tight">
          {name}
        </h3>
        <div className="flex items-baseline gap-1 mb-6">
          <span className="text-slate-800 text-3xl font-extrabold">{price}</span>
          <span className="text-slate-500 text-sm font-medium">{period}</span>
        </div>

        <p className="text-sm text-slate-500 mb-6 h-auto">{desc}</p>

        <div className="flex-grow space-y-4 mb-10">
          {features.map((f, i) => (
            <div key={i} className="flex items-center gap-3">
              <div
                className="w-1.5 h-1.5 rounded-full"
                style={{
                  backgroundColor: color,
                  boxShadow: `0 0 10px ${color}`,
                }}
              />
              <span className="text-slate-600 text-sm font-medium group-hover:text-slate-900 transition-colors flex-1 leading-snug">
                {f}
              </span>
            </div>
          ))}
        </div>

        <div className="mt-auto">
          <Link href={name === "Enterprise" ? "/contact" : "/signup"}>
            <button
              className={`w-full font-bold py-3 rounded-2xl transition-all shadow-xl ${
                popular
                  ? "bg-slate-900 text-white hover:bg-slate-800 active:scale-95 hover:shadow-slate-900/10"
                  : "bg-white text-slate-800 border border-slate-200 hover:bg-slate-50 active:scale-95"
              }`}
            >
              {cta}
            </button>
          </Link>
        </div>
      </div>
    </motion.div>
  );
}

export default function PricingContent() {
  return (
    <section
      className="relative pt-24 pb-16"
      style={{ background: "var(--color-aurora-bg)" }}
    >
      <div className="absolute inset-0 pointer-events-none overflow-hidden">
        <div
          className="absolute w-[600px] h-[600px] rounded-full top-0 left-1/2 -translate-x-1/2"
          style={{
            background:
              "radial-gradient(circle, rgba(99,102,241,0.1), transparent 60%)",
            filter: "blur(100px)",
          }}
        />
      </div>

      <div className="relative z-10 max-w-6xl mx-auto px-6">
        <div className="text-center mb-12">
          <div
            className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full text-xs font-bold uppercase tracking-[0.15em] mb-4"
            style={{
              background: "rgba(99,102,241,0.1)",
              border: "1px solid rgba(99,102,241,0.2)",
              color: "#818cf8",
            }}
          >
            <Zap size={12} /> Pricing
          </div>
          <h1
            className="text-gradient mb-4"
            style={{ fontFamily: "var(--font-display)" }}
          >
            Simple, Transparent Pricing
          </h1>
          <p
            className="text-base max-w-lg mx-auto"
            style={{ color: "var(--color-muted)" }}
          >
            Start free. Upgrade when you need more power. No hidden fees.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {PLANS.map((p, i) => (
            <PlanCard key={p.name} {...p} index={i} />
          ))}
        </div>
      </div>
    </section>
  );
}
