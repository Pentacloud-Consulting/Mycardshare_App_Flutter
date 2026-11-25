"use client";

import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  X,
  Save,
  Loader2,
  User,
  Phone,
  Mail,
  Globe,
  Wallet,
  Building2,
  FileText,
  Tag,
  MapPin,
  Clock,
  Briefcase,
  Sparkles,
} from "lucide-react";
import { authFetch, parseFetchJson } from "@/lib/api";

interface Lead {
  _id: string;
  fullName?: string;
  mobile?: string;
  email?: string;
  nationality?: string;
  budgetRange?: string;
  propertyType?: string;
  propertyCategory?: string;
  emirate?: string;
  areaOfInterest?: string | string[];
  investorType?: string;
  timeline?: string;
  notes?: string;
  status?: string;
  [key: string]: any;
}

interface EnterpriseLeadsEditProps {
  isOpen: boolean;
  onClose: () => void;
  lead: Lead | null;
  onSuccess: () => void;
}

export default function EnterpriseLeadsEdit({
  isOpen,
  onClose,
  lead,
  onSuccess,
}: EnterpriseLeadsEditProps) {
  const [saving, setSaving] = useState(false);
  const [form, setForm] = useState({
    fullName: "",
    mobile: "",
    email: "",
    nationality: "",
    budgetRange: "",
    propertyType: "",
    propertyCategory: "",
    emirate: "",
    areaOfInterest: "",
    investorType: "",
    timeline: "",
    notes: "",
    status: "New",
  });

  useEffect(() => {
    if (lead) {
      setForm({
        fullName: lead.fullName || "",
        mobile: lead.mobile || "",
        email: lead.email || "",
        nationality: lead.nationality || "",
        budgetRange: lead.budgetRange || "",
        propertyType: lead.propertyType || "",
        propertyCategory: lead.propertyCategory || "",
        emirate: lead.emirate || "",
        areaOfInterest: Array.isArray(lead.areaOfInterest)
          ? lead.areaOfInterest.join(", ")
          : lead.areaOfInterest || "",
        investorType: lead.investorType || "",
        timeline: lead.timeline || "",
        notes: lead.notes || "",
        status: lead.status || "New",
      });
    }
  }, [lead]);

  const handleChange = (
    e: React.ChangeEvent<
      HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement
    >
  ) => {
    const { name, value } = e.target;
    setForm((prev) => ({ ...prev, [name]: value }));
  };

  const handleSave = async () => {
    if (!lead?._id) return;
    if (!form.fullName.trim() || !form.mobile.trim()) {
      alert("Name and Mobile are required.");
      return;
    }

    setSaving(true);
    try {
      const payload = {
        ...form,
        areaOfInterest: form.areaOfInterest
          ? form.areaOfInterest
              .split(",")
              .map((s) => s.trim())
              .filter(Boolean)
          : [],
      };

      const res = await authFetch(`/api/enterprise/leads?id=${lead._id}`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      });
      const data = await parseFetchJson(res);
      if (data.success) {
        onSuccess();
        onClose();
      } else {
        alert(data.error || "Failed to update lead");
      }
    } catch (err) {
      console.error("Lead update failed:", err);
      alert("Network error — please try again.");
    } finally {
      setSaving(false);
    }
  };

  if (!isOpen || !lead) return null;

  const inputClass =
    "w-full px-4 py-3 rounded-2xl text-sm bg-white/[0.03] border border-white/[0.06] text-white placeholder:text-white/15 focus:outline-none focus:ring-2 focus:ring-indigo-500/30 focus:border-indigo-500/40 focus:bg-white/[0.05] transition-all duration-300 hover:bg-white/[0.04] hover:border-white/[0.1]";

  const labelClass =
    "text-[9px] font-black uppercase tracking-[0.2em] text-white/25 mb-2 block";

  const sectionHeaderClass =
    "flex items-center gap-2.5 mb-5 pb-3 border-b border-white/[0.04]";

  return (
    <AnimatePresence>
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        onClick={onClose}
        className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-black/85 backdrop-blur-xl"
      >
        <motion.div
          initial={{ scale: 0.92, opacity: 0, y: 40 }}
          animate={{ scale: 1, opacity: 1, y: 0 }}
          exit={{ scale: 0.92, opacity: 0, y: 40 }}
          transition={{ type: "spring", damping: 28, stiffness: 320 }}
          onClick={(e) => e.stopPropagation()}
          className="bg-[#080b12] border border-white/[0.06] rounded-[2rem] w-full max-w-2xl max-h-[88vh] overflow-hidden shadow-[0_40px_120px_-15px_rgba(99,102,241,0.15)] flex flex-col relative"
        >
          {/* Background Glows */}
          <div className="absolute top-0 right-0 w-80 h-80 bg-indigo-500/[0.04] blur-[100px] rounded-full pointer-events-none" />
          <div className="absolute bottom-0 left-0 w-60 h-60 bg-sky-500/[0.03] blur-[80px] rounded-full pointer-events-none" />

          {/* Header */}
          <div className="px-8 pt-8 pb-6 relative z-10">
            <div className="flex items-start justify-between">
              <div className="space-y-3">
                <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-indigo-500/10 border border-indigo-500/15">
                  <Sparkles size={10} className="text-indigo-400" />
                  <span className="text-[9px] font-black uppercase tracking-[0.2em] text-indigo-300">
                    Editing Lead
                  </span>
                </div>
                <h2 className="text-2xl font-black text-white tracking-tight">
                  {lead.fullName || "Untitled Lead"}
                </h2>
              </div>
              <motion.button
                whileHover={{ scale: 1.05, rotate: 90 }}
                whileTap={{ scale: 0.95 }}
                onClick={onClose}
                className="w-10 h-10 rounded-2xl bg-white/[0.03] border border-white/[0.06] flex items-center justify-center text-white/30 hover:text-white hover:bg-white/[0.08] transition-all duration-300"
              >
                <X size={16} />
              </motion.button>
            </div>
          </div>

          {/* Scrollable Form Body */}
          <style jsx>{`
            .edit-scroll::-webkit-scrollbar {
              width: 4px;
            }
            .edit-scroll::-webkit-scrollbar-track {
              background: transparent;
            }
            .edit-scroll::-webkit-scrollbar-thumb {
              background: rgba(255, 255, 255, 0.06);
              border-radius: 10px;
            }
            .edit-scroll::-webkit-scrollbar-thumb:hover {
              background: rgba(255, 255, 255, 0.12);
            }
          `}</style>
          <div className="flex-1 overflow-y-auto px-8 pb-6 space-y-7 edit-scroll relative z-10">
            {/* ─── Contact Info ─── */}
            <div>
              <div className={sectionHeaderClass}>
                <div className="w-7 h-7 rounded-xl bg-indigo-500/10 flex items-center justify-center">
                  <User size={13} className="text-indigo-400" />
                </div>
                <span className="text-[10px] font-black uppercase tracking-[0.2em] text-white/50">
                  Contact Information
                </span>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className={labelClass}>
                    Full Name <span className="text-red-400/60">*</span>
                  </label>
                  <div className="relative group">
                    <User
                      size={13}
                      className="absolute left-3.5 top-1/2 -translate-y-1/2 text-white/15 group-focus-within:text-indigo-400 transition-colors duration-300"
                    />
                    <input
                      name="fullName"
                      value={form.fullName}
                      onChange={handleChange}
                      className={`${inputClass} pl-10`}
                      placeholder="John Doe"
                    />
                  </div>
                </div>
                <div>
                  <label className={labelClass}>
                    Mobile <span className="text-red-400/60">*</span>
                  </label>
                  <div className="relative group">
                    <Phone
                      size={13}
                      className="absolute left-3.5 top-1/2 -translate-y-1/2 text-white/15 group-focus-within:text-indigo-400 transition-colors duration-300"
                    />
                    <input
                      name="mobile"
                      value={form.mobile}
                      onChange={handleChange}
                      className={`${inputClass} pl-10`}
                      placeholder="+971..."
                    />
                  </div>
                </div>
                <div>
                  <label className={labelClass}>Email</label>
                  <div className="relative group">
                    <Mail
                      size={13}
                      className="absolute left-3.5 top-1/2 -translate-y-1/2 text-white/15 group-focus-within:text-indigo-400 transition-colors duration-300"
                    />
                    <input
                      name="email"
                      type="email"
                      value={form.email}
                      onChange={handleChange}
                      className={`${inputClass} pl-10`}
                      placeholder="john@example.com"
                    />
                  </div>
                </div>
                <div>
                  <label className={labelClass}>Nationality</label>
                  <div className="relative group">
                    <Globe
                      size={13}
                      className="absolute left-3.5 top-1/2 -translate-y-1/2 text-white/15 group-focus-within:text-indigo-400 transition-colors duration-300"
                    />
                    <input
                      name="nationality"
                      value={form.nationality}
                      onChange={handleChange}
                      className={`${inputClass} pl-10`}
                      placeholder="United Kingdom"
                    />
                  </div>
                </div>
              </div>
            </div>

            {/* ─── Property Requirements ─── */}
            <div>
              <div className={sectionHeaderClass}>
                <div className="w-7 h-7 rounded-xl bg-sky-500/10 flex items-center justify-center">
                  <Building2 size={13} className="text-sky-400" />
                </div>
                <span className="text-[10px] font-black uppercase tracking-[0.2em] text-white/50">
                  Property Requirements
                </span>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className={labelClass}>Property Category</label>
                  <div className="relative group">
                    <Tag
                      size={13}
                      className="absolute left-3.5 top-1/2 -translate-y-1/2 text-white/15 group-focus-within:text-sky-400 transition-colors duration-300"
                    />
                    <input
                      name="propertyCategory"
                      value={form.propertyCategory}
                      onChange={handleChange}
                      className={`${inputClass} pl-10`}
                      placeholder="Residential, Commercial..."
                    />
                  </div>
                </div>
                <div>
                  <label className={labelClass}>Property Type</label>
                  <div className="relative group">
                    <Building2
                      size={13}
                      className="absolute left-3.5 top-1/2 -translate-y-1/2 text-white/15 group-focus-within:text-sky-400 transition-colors duration-300"
                    />
                    <input
                      name="propertyType"
                      value={form.propertyType}
                      onChange={handleChange}
                      className={`${inputClass} pl-10`}
                      placeholder="Villa, Apartment..."
                    />
                  </div>
                </div>
                <div>
                  <label className={labelClass}>Budget Range</label>
                  <div className="relative group">
                    <Wallet
                      size={13}
                      className="absolute left-3.5 top-1/2 -translate-y-1/2 text-white/15 group-focus-within:text-sky-400 transition-colors duration-300"
                    />
                    <input
                      name="budgetRange"
                      value={form.budgetRange}
                      onChange={handleChange}
                      className={`${inputClass} pl-10`}
                      placeholder="1M - 2M AED"
                    />
                  </div>
                </div>
                <div>
                  <label className={labelClass}>Emirate / Location</label>
                  <div className="relative group">
                    <MapPin
                      size={13}
                      className="absolute left-3.5 top-1/2 -translate-y-1/2 text-white/15 group-focus-within:text-sky-400 transition-colors duration-300"
                    />
                    <input
                      name="emirate"
                      value={form.emirate}
                      onChange={handleChange}
                      className={`${inputClass} pl-10`}
                      placeholder="Dubai, Abu Dhabi..."
                    />
                  </div>
                </div>
                <div className="md:col-span-2">
                  <label className={labelClass}>Area of Interest</label>
                  <div className="relative group">
                    <MapPin
                      size={13}
                      className="absolute left-3.5 top-1/2 -translate-y-1/2 text-white/15 group-focus-within:text-sky-400 transition-colors duration-300"
                    />
                    <input
                      name="areaOfInterest"
                      value={form.areaOfInterest}
                      onChange={handleChange}
                      className={`${inputClass} pl-10`}
                      placeholder="Downtown, Marina, JBR (comma-separated)"
                    />
                  </div>
                </div>
              </div>
            </div>

            {/* ─── Additional Details ─── */}
            <div>
              <div className={sectionHeaderClass}>
                <div className="w-7 h-7 rounded-xl bg-emerald-500/10 flex items-center justify-center">
                  <Briefcase size={13} className="text-emerald-400" />
                </div>
                <span className="text-[10px] font-black uppercase tracking-[0.2em] text-white/50">
                  Additional Details
                </span>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className={labelClass}>Investor Type</label>
                  <div className="relative group">
                    <Briefcase
                      size={13}
                      className="absolute left-3.5 top-1/2 -translate-y-1/2 text-white/15 group-focus-within:text-emerald-400 transition-colors duration-300"
                    />
                    <input
                      name="investorType"
                      value={form.investorType}
                      onChange={handleChange}
                      className={`${inputClass} pl-10`}
                      placeholder="End User, Investor..."
                    />
                  </div>
                </div>
                <div>
                  <label className={labelClass}>Closing Timeline</label>
                  <div className="relative group">
                    <Clock
                      size={13}
                      className="absolute left-3.5 top-1/2 -translate-y-1/2 text-white/15 group-focus-within:text-emerald-400 transition-colors duration-300"
                    />
                    <input
                      name="timeline"
                      value={form.timeline}
                      onChange={handleChange}
                      className={`${inputClass} pl-10`}
                      placeholder="Immediate, 3 months..."
                    />
                  </div>
                </div>
                <div>
                  <label className={labelClass}>Status</label>
                  <select
                    name="status"
                    value={form.status}
                    onChange={handleChange}
                    className={`${inputClass} appearance-none cursor-pointer`}
                    style={{ colorScheme: "dark" }}
                  >
                    <option value="New">🟢 New</option>
                    <option value="Contacted">📞 Contacted</option>
                    <option value="Qualified">✅ Qualified</option>
                    <option value="Negotiation">🤝 Negotiation</option>
                    <option value="Won">🏆 Won</option>
                    <option value="Lost">❌ Lost</option>
                  </select>
                </div>
              </div>

              <div className="mt-4">
                <label className={labelClass}>Notes</label>
                <div className="relative group">
                  <FileText
                    size={13}
                    className="absolute left-3.5 top-3.5 text-white/15 group-focus-within:text-emerald-400 transition-colors duration-300"
                  />
                  <textarea
                    name="notes"
                    value={form.notes}
                    onChange={handleChange}
                    rows={3}
                    className={`${inputClass} pl-10 resize-none`}
                    placeholder="Additional notes about this lead..."
                  />
                </div>
              </div>
            </div>
          </div>

          {/* Footer */}
          <div className="px-8 py-5 border-t border-white/[0.04] flex items-center justify-between relative z-20 bg-[#080b12]/80 backdrop-blur-xl">
            <motion.button
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              onClick={onClose}
              className="px-5 py-2.5 rounded-xl text-[10px] font-black uppercase tracking-[0.15em] text-white/30 hover:text-white/60 hover:bg-white/[0.03] transition-all duration-300"
            >
              Cancel
            </motion.button>
            <motion.button
              whileHover={{ scale: 1.02, boxShadow: "0 0 40px rgba(99,102,241,0.3)" }}
              whileTap={{ scale: 0.98 }}
              onClick={handleSave}
              disabled={saving}
              className="px-8 py-3 rounded-2xl bg-gradient-to-r from-indigo-500 to-indigo-600 text-white text-[10px] font-black uppercase tracking-[0.2em] hover:from-indigo-400 hover:to-indigo-500 transition-all duration-300 flex items-center gap-2.5 disabled:opacity-40 shadow-lg shadow-indigo-500/20"
            >
              {saving ? (
                <Loader2 size={13} className="animate-spin" />
              ) : (
                <Save size={13} />
              )}
              {saving ? "Saving..." : "Save Changes"}
            </motion.button>
          </div>
        </motion.div>
      </motion.div>
    </AnimatePresence>
  );
}
