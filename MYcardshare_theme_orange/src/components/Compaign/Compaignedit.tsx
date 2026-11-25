"use client";

import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  X,
  Save,
  Loader2,
  Megaphone,
  MapPin,
  Calendar,
  DollarSign,
  FileText,
  Sparkles,
  Power,
} from "lucide-react";
import { authFetch, parseFetchJson } from "@/lib/api";

interface Campaign {
  id: string;
  name?: string;
  description?: string;
  area?: string;
  budget?: string | number;
  startDate?: string;
  endDate?: string;
  isActive?: boolean;
  [key: string]: any;
}

interface CampaignEditProps {
  isOpen: boolean;
  onClose: () => void;
  campaign: Campaign | null;
  onSuccess: () => void;
}

export default function CampaignEdit({
  isOpen,
  onClose,
  campaign,
  onSuccess,
}: CampaignEditProps) {
  const [saving, setSaving] = useState(false);
  const [dateError, setDateError] = useState("");
  const [form, setForm] = useState({
    name: "",
    description: "",
    area: "",
    budget: "",
    startDate: "",
    endDate: "",
    isActive: true,
  });

  useEffect(() => {
    if (campaign) {
      setForm({
        name: campaign.name || "",
        description: campaign.description || "",
        area: campaign.area || "",
        budget: campaign.budget ? String(campaign.budget) : "",
        startDate: campaign.startDate || "",
        endDate: campaign.endDate || "",
        isActive: campaign.isActive !== false,
      });
    }
  }, [campaign]);

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    const { name, value } = e.target;
    const next = { ...form, [name]: value };
    setForm(next);
    if (name === "startDate" || name === "endDate") {
      if (next.startDate && next.endDate && new Date(next.endDate) < new Date(next.startDate)) {
        setDateError("End date cannot be earlier than start date.");
      } else {
        setDateError("");
      }
    }
  };

  const handleSave = async () => {
    if (!campaign?.id) return;
    if (!form.name.trim()) {
      alert("Campaign name is required.");
      return;
    }
    if (form.startDate && form.endDate && new Date(form.endDate) < new Date(form.startDate)) {
      alert("End date cannot be earlier than start date.");
      return;
    }

    setSaving(true);
    try {
      const res = await authFetch(`/api/campaigns?id=${campaign.id}`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(form),
      });
      const data = await parseFetchJson(res);
      if (data.success) {
        onSuccess();
        onClose();
      } else {
        alert(data.error || "Failed to update campaign");
      }
    } catch (err) {
      console.error("Campaign update failed:", err);
      alert("Network error — please try again.");
    } finally {
      setSaving(false);
    }
  };

  if (!isOpen || !campaign) return null;

  const inputClass =
    "w-full px-4 py-3 rounded-2xl text-sm bg-white/[0.03] border border-white/[0.06] text-white placeholder:text-white/15 focus:outline-none focus:ring-2 focus:ring-sky-500/30 focus:border-sky-500/40 focus:bg-white/[0.05] transition-all duration-300 hover:bg-white/[0.04] hover:border-white/[0.1]";

  const labelClass =
    "text-[9px] font-black uppercase tracking-[0.2em] text-white/25 mb-2 block";

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
          className="bg-[#080b12] border border-white/[0.06] rounded-[2rem] w-full max-w-xl max-h-[88vh] overflow-hidden shadow-[0_40px_120px_-15px_rgba(14,165,233,0.12)] flex flex-col relative"
        >
          {/* Background Glows */}
          <div className="absolute top-0 right-0 w-80 h-80 bg-sky-500/[0.04] blur-[100px] rounded-full pointer-events-none" />
          <div className="absolute bottom-0 left-0 w-60 h-60 bg-indigo-500/[0.03] blur-[80px] rounded-full pointer-events-none" />

          {/* Header */}
          <div className="px-8 pt-8 pb-6 relative z-10">
            <div className="flex items-start justify-between">
              <div className="space-y-3">
                <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-sky-500/10 border border-sky-500/15">
                  <Sparkles size={10} className="text-sky-400" />
                  <span className="text-[9px] font-black uppercase tracking-[0.2em] text-sky-300">
                    Editing Campaign
                  </span>
                </div>
                <h2 className="text-2xl font-black text-white tracking-tight">
                  {campaign.name || "Untitled Campaign"}
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
            .campaign-scroll::-webkit-scrollbar {
              width: 4px;
            }
            .campaign-scroll::-webkit-scrollbar-track {
              background: transparent;
            }
            .campaign-scroll::-webkit-scrollbar-thumb {
              background: rgba(255, 255, 255, 0.06);
              border-radius: 10px;
            }
            .campaign-scroll::-webkit-scrollbar-thumb:hover {
              background: rgba(255, 255, 255, 0.12);
            }
          `}</style>
          <div className="flex-1 overflow-y-auto px-8 pb-6 space-y-7 campaign-scroll relative z-10">
            {/* ─── Campaign Details ─── */}
            <div>
              <div className="flex items-center gap-2.5 mb-5 pb-3 border-b border-white/[0.04]">
                <div className="w-7 h-7 rounded-xl bg-sky-500/10 flex items-center justify-center">
                  <Megaphone size={13} className="text-sky-400" />
                </div>
                <span className="text-[10px] font-black uppercase tracking-[0.2em] text-white/50">
                  Campaign Details
                </span>
              </div>

              <div className="space-y-4">
                <div>
                  <label className={labelClass}>
                    Campaign Name <span className="text-red-400/60">*</span>
                  </label>
                  <div className="relative group">
                    <Megaphone
                      size={13}
                      className="absolute left-3.5 top-1/2 -translate-y-1/2 text-white/15 group-focus-within:text-sky-400 transition-colors duration-300"
                    />
                    <input
                      name="name"
                      value={form.name}
                      onChange={handleChange}
                      className={`${inputClass} pl-10`}
                      placeholder="e.g. Summer Launch"
                    />
                  </div>
                </div>

                <div>
                  <label className={labelClass}>Description</label>
                  <div className="relative group">
                    <FileText
                      size={13}
                      className="absolute left-3.5 top-3.5 text-white/15 group-focus-within:text-sky-400 transition-colors duration-300"
                    />
                    <textarea
                      name="description"
                      value={form.description}
                      onChange={handleChange}
                      rows={3}
                      className={`${inputClass} pl-10 resize-none`}
                      placeholder="What is this campaign about?"
                    />
                  </div>
                </div>
              </div>
            </div>

            {/* ─── Location & Budget ─── */}
            <div>
              <div className="flex items-center gap-2.5 mb-5 pb-3 border-b border-white/[0.04]">
                <div className="w-7 h-7 rounded-xl bg-emerald-500/10 flex items-center justify-center">
                  <MapPin size={13} className="text-emerald-400" />
                </div>
                <span className="text-[10px] font-black uppercase tracking-[0.2em] text-white/50">
                  Location & Budget
                </span>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className={labelClass}>Area / Emirate</label>
                  <div className="relative group">
                    <MapPin
                      size={13}
                      className="absolute left-3.5 top-1/2 -translate-y-1/2 text-white/15 group-focus-within:text-emerald-400 transition-colors duration-300"
                    />
                    <input
                      name="area"
                      value={form.area}
                      onChange={handleChange}
                      className={`${inputClass} pl-10`}
                      placeholder="Dubai"
                    />
                  </div>
                </div>
                <div>
                  <label className={labelClass}>Budget (AED)</label>
                  <div className="relative group">
                    <DollarSign
                      size={13}
                      className="absolute left-3.5 top-1/2 -translate-y-1/2 text-white/15 group-focus-within:text-emerald-400 transition-colors duration-300"
                    />
                    <input
                      name="budget"
                      value={form.budget}
                      onChange={handleChange}
                      className={`${inputClass} pl-10`}
                      placeholder="50000"
                    />
                  </div>
                </div>
              </div>
            </div>

            {/* ─── Schedule ─── */}
            <div>
              <div className="flex items-center gap-2.5 mb-5 pb-3 border-b border-white/[0.04]">
                <div className="w-7 h-7 rounded-xl bg-amber-500/10 flex items-center justify-center">
                  <Calendar size={13} className="text-amber-400" />
                </div>
                <span className="text-[10px] font-black uppercase tracking-[0.2em] text-white/50">
                  Schedule
                </span>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className={labelClass}>Start Date</label>
                  <div className="relative group">
                    <Calendar
                      size={13}
                      className="absolute left-3.5 top-1/2 -translate-y-1/2 text-white/15 group-focus-within:text-amber-400 transition-colors duration-300"
                    />
                    <input
                      name="startDate"
                      type="date"
                      value={form.startDate}
                      onChange={handleChange}
                      className={`${inputClass} pl-10`}
                      style={{ colorScheme: "dark" }}
                    />
                  </div>
                </div>
                <div>
                  <label className={labelClass}>End Date</label>
                  <div className="relative group">
                    <Calendar
                      size={13}
                      className="absolute left-3.5 top-1/2 -translate-y-1/2 text-white/15 group-focus-within:text-amber-400 transition-colors duration-300"
                    />
                    <input
                      name="endDate"
                      type="date"
                      value={form.endDate}
                      onChange={handleChange}
                      className={`${inputClass} pl-10`}
                      style={{ colorScheme: "dark" }}
                    />
                  </div>
                </div>
              </div>

              {dateError && (
                <div className="flex items-center gap-2 p-3 rounded-2xl bg-red-500/10 border border-red-500/20 text-red-400 text-xs font-bold">
                  <span className="text-red-400">⚠</span> {dateError}
                </div>
              )}
            </div>

            {/* ─── Status Toggle ─── */}
            <div>
              <div className="flex items-center gap-2.5 mb-5 pb-3 border-b border-white/[0.04]">
                <div className="w-7 h-7 rounded-xl bg-violet-500/10 flex items-center justify-center">
                  <Power size={13} className="text-violet-400" />
                </div>
                <span className="text-[10px] font-black uppercase tracking-[0.2em] text-white/50">
                  Campaign Status
                </span>
              </div>

              <button
                type="button"
                onClick={() => setForm((prev) => ({ ...prev, isActive: !prev.isActive }))}
                className={`w-full flex items-center justify-between px-5 py-4 rounded-2xl border transition-all duration-300 ${
                  form.isActive
                    ? "bg-emerald-500/[0.06] border-emerald-500/20 hover:bg-emerald-500/[0.1]"
                    : "bg-white/[0.02] border-white/[0.06] hover:bg-white/[0.04]"
                }`}
              >
                <div className="flex items-center gap-3">
                  <div
                    className={`w-2 h-2 rounded-full ${
                      form.isActive ? "bg-emerald-400 shadow-[0_0_8px_rgba(52,211,153,0.5)]" : "bg-white/20"
                    } transition-all duration-300`}
                  />
                  <span
                    className={`text-xs font-black uppercase tracking-widest ${
                      form.isActive ? "text-emerald-400" : "text-white/30"
                    } transition-colors duration-300`}
                  >
                    {form.isActive ? "Active" : "Inactive"}
                  </span>
                </div>

                {/* Toggle Switch */}
                <div
                  className={`relative w-11 h-6 rounded-full transition-colors duration-300 ${
                    form.isActive ? "bg-emerald-500" : "bg-white/10"
                  }`}
                >
                  <div
                    className={`absolute top-1 w-4 h-4 rounded-full bg-white shadow-md transition-transform duration-300 ${
                      form.isActive ? "translate-x-[22px]" : "translate-x-1"
                    }`}
                  />
                </div>
              </button>
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
              whileHover={{
                scale: 1.02,
                boxShadow: "0 0 40px rgba(14,165,233,0.3)",
              }}
              whileTap={{ scale: 0.98 }}
              onClick={handleSave}
              disabled={saving || !!dateError}
              className="px-8 py-3 rounded-2xl bg-gradient-to-r from-sky-500 to-sky-600 text-white text-[10px] font-black uppercase tracking-[0.2em] hover:from-sky-400 hover:to-sky-500 transition-all duration-300 flex items-center gap-2.5 disabled:opacity-40 shadow-lg shadow-sky-500/20"
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
