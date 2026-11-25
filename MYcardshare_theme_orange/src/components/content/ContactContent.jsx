"use client";

import { useState } from "react";
import { motion } from "framer-motion";
import {
  Mail,
  MessageSquare,
  Send,
  User,
  Building2,
  Loader2,
  MapPin,
  Phone as PhoneIcon,
} from "lucide-react";

/* ═══════════════════════════════════════════════════════════
   CONTACT — UILORA Form + Info Cards
   ═══════════════════════════════════════════════════════════ */

const inputStyles = {
  background: "rgba(255, 255, 255, 0.7)",
  border: "1px solid rgba(15, 23, 42, 0.1)",
  color: "#1e293b",
};
const inputFocusClass =
  "focus:outline-none focus:ring-2 focus:ring-indigo-500/40";

export default function ContactContent() {
  const [loading, setLoading] = useState(false);

  return (
    <section
      className="relative pt-24 pb-16"
      style={{ background: "var(--color-aurora-bg)" }}
    >
      <div className="max-w-6xl mx-auto px-6">
        <div className="text-center mb-12">
          <h1
            className="text-gradient mb-4"
            style={{ fontFamily: "var(--font-display)" }}
          >
            Get in Touch
          </h1>
          <p
            className="text-base max-w-lg mx-auto"
            style={{ color: "var(--color-muted)" }}
          >
            Have a question or want to learn about enterprise solutions? We'd
            love to hear from you.
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-5 gap-8">
          {/* Form */}
          <div
            className="lg:col-span-3 rounded-2xl p-6 md:p-8 bg-white border border-slate-200 shadow-sm"
          >
            <form className="space-y-4">
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label
                    className="block text-xs font-bold uppercase tracking-[0.12em] mb-2 text-slate-500"
                  >
                    Name
                  </label>
                  <div className="relative">
                    <User
                      size={16}
                      className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400"
                    />
                    <input
                      type="text"
                      placeholder="Your name"
                      className={`w-full pl-11 pr-4 py-3 rounded-xl text-sm placeholder:text-slate-400 ${inputFocusClass}`}
                      style={inputStyles}
                    />
                  </div>
                </div>
                <div>
                  <label
                    className="block text-xs font-bold uppercase tracking-[0.12em] mb-2 text-slate-500"
                  >
                    Company
                  </label>
                  <div className="relative">
                    <Building2
                      size={16}
                      className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400"
                    />
                    <input
                      type="text"
                      placeholder="Company name"
                      className={`w-full pl-11 pr-4 py-3 rounded-xl text-sm placeholder:text-slate-400 ${inputFocusClass}`}
                      style={inputStyles}
                    />
                  </div>
                </div>
              </div>
              <div>
                <label
                  className="block text-xs font-bold uppercase tracking-[0.12em] mb-2 text-slate-500"
                >
                  Email
                </label>
                <div className="relative">
                  <Mail
                    size={16}
                    className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400"
                  />
                  <input
                    type="email"
                    placeholder="you@company.com"
                    className={`w-full pl-11 pr-4 py-3 rounded-xl text-sm placeholder:text-slate-400 ${inputFocusClass}`}
                    style={inputStyles}
                  />
                </div>
              </div>
              <div>
                <label
                  className="block text-xs font-bold uppercase tracking-[0.12em] mb-2 text-slate-500"
                >
                  Message
                </label>
                <div className="relative">
                  <MessageSquare
                    size={16}
                    className="absolute left-4 top-4 text-slate-400"
                  />
                  <textarea
                    placeholder="Tell us about your needs..."
                    rows={4}
                    className={`w-full pl-11 pr-4 py-3 rounded-xl text-sm placeholder:text-slate-400 resize-none ${inputFocusClass}`}
                    style={inputStyles}
                  />
                </div>
              </div>
              <motion.button
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
                className="flex items-center justify-center gap-2 w-full py-3 rounded-xl text-sm font-bold text-white border-0 cursor-pointer"
                style={{
                  background:
                    "linear-gradient(135deg, #6366f1, #2563eb, #06b6d4)",
                  boxShadow: "0 8px 24px rgba(99,102,241,0.4)",
                }}
              >
                <Send size={14} /> Send Message
              </motion.button>
            </form>
          </div>

          {/* Info */}
          <div className="lg:col-span-2 space-y-4">
            {[
              {
                icon: Mail,
                title: "Email",
                detail: "hello@pentacloud.ae",
                color: "#6366f1",
              },
              {
                icon: PhoneIcon,
                title: "Phone",
                detail: "+971 4 555 0000",
                color: "#06b6d4",
              },
              {
                icon: MapPin,
                title: "Office",
                detail: "Dubai, United Arab Emirates",
                color: "#a78bfa",
              },
            ].map(({ icon: Icon, title, detail, color }) => (
              <div
                key={title}
                className="rounded-2xl p-4 md:p-6 flex items-center gap-3 bg-white border border-slate-200 shadow-sm"
              >
                <div
                  className="w-11 h-11 rounded-xl flex items-center justify-center shrink-0"
                  style={{ background: `${color}15` }}
                >
                  <Icon size={18} style={{ color }} />
                </div>
                <div>
                  <div
                    className="text-xs font-bold uppercase tracking-[0.12em] text-slate-500"
                  >
                    {title}
                  </div>
                  <div className="text-sm font-semibold text-slate-800 mt-0.5">
                    {detail}
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
