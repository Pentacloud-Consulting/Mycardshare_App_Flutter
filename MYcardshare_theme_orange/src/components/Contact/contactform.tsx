import React, { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  X,
  User,
  Mail,
  Phone,
  Briefcase,
  Award,
  Globe,
  MapPin,
  FileText,
  Calendar,
  CheckCircle2,
  RefreshCw,
} from "lucide-react";
import { UiloraBrandButton } from "@/components/UIComponents/Button/tsx/UiloraModernButtons";
import { authFetch } from "@/lib/api";

interface ContactFormProps {
  isOpen: boolean;
  onClose: () => void;
  onSuccess?: () => void;
}

export default function ContactForm({ isOpen, onClose, onSuccess }: ContactFormProps) {
  const [isProcessing, setIsProcessing] = useState(false);
  const [formData, setFormData] = useState({
    fullName: "",
    email: "",
    phone: "",
    phone2: "",
    company: "",
    jobTitle: "",
    website: "",
    address: "",
    meeting: "",
    notes: "",
  });

  const handleSave = async () => {
    if (!formData.fullName && !formData.email && !formData.phone) {
      alert("Please fill in at least a name, email, or phone number.");
      return;
    }

    setIsProcessing(true);
    try {
      const response = await authFetch("/api/scanned-contacts", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          ...formData,
        }),
      });

      if (response.ok) {
        setFormData({
          fullName: "",
          email: "",
          phone: "",
          phone2: "",
          company: "",
          jobTitle: "",
          website: "",
          address: "",
          meeting: "",
          notes: "",
        });
        if (onSuccess) onSuccess();
        onClose();
      } else {
        throw new Error("Failed to save contact");
      }
    } catch (err) {
      alert("Failed to save contact. Please try again.");
    } finally {
      setIsProcessing(false);
    }
  };

  const glassCard = {
    background: "#FFFFFF",
    backdropFilter: "blur(24px)",
    border: "1px solid #EAE2DB",
    boxShadow: "0 24px 60px rgba(28, 25, 23, 0.12)",
  };

  if (!isOpen) return null;

  return (
    <AnimatePresence>
      <div className="fixed inset-0 z-50 flex items-center justify-center p-4 overflow-y-auto">
        {/* Backdrop */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          onClick={onClose}
          className="fixed inset-0 bg-black/60 backdrop-blur-sm"
        />

        {/* Modal */}
        <motion.div
          initial={{ opacity: 0, y: 20, scale: 0.95 }}
          animate={{ opacity: 1, y: 0, scale: 1 }}
          exit={{ opacity: 0, y: 20, scale: 0.95 }}
          className="relative w-full max-w-2xl rounded-2xl overflow-hidden my-auto"
          style={glassCard}
        >
          {/* Header */}
          <div className="flex items-center justify-between px-6 py-5 border-b border-[#EAE2DB] bg-[#FAF6F2]/60">
            <h3 className="text-lg font-bold text-[#191919] flex items-center gap-2">
              <CheckCircle2 size={20} className="text-[#D4622C]" /> Add Contact
            </h3>
            <button
              onClick={onClose}
              className="w-9 h-9 rounded-xl hover:bg-[#FAF6F2] flex items-center justify-center text-[#77716C] hover:text-[#191919] transition-colors"
            >
              <X size={18} />
            </button>
          </div>

          <div className="p-6 max-h-[75vh] overflow-y-auto custom-scrollbar">
            {/* Form Grid */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-6">
              {[
                { key: "fullName", label: "Full Name", icon: User },
                { key: "email", label: "Email", icon: Mail },
                { key: "phone", label: "Primary Number", icon: Phone },
                { key: "phone2", label: "Secondary Number", icon: Phone },
                { key: "company", label: "Company", icon: Briefcase },
                { key: "jobTitle", label: "Job Title", icon: Award },
                { key: "website", label: "Website", icon: Globe },
                { key: "address", label: "Address", icon: MapPin },
              ].map((field) => (
                <div key={field.key}>
                  <label className="block text-[10px] font-bold uppercase tracking-wider text-[#77716C] mb-1.5 flex items-center gap-1">
                    <field.icon size={12} className="text-[#D4622C]" /> {field.label}
                  </label>
                  <input
                    type="text"
                    value={(formData as any)[field.key]}
                    onChange={(e) =>
                      setFormData((f) => ({
                        ...f,
                        [field.key]: e.target.value,
                      }))
                    }
                    placeholder={`Enter ${field.label.toLowerCase()}`}
                    className="w-full px-3.5 py-2.5 rounded-xl text-sm font-bold text-[#191919] placeholder:text-[#77716C]/50 border border-[#EAE2DB] bg-[#FAF6F2] focus:bg-white focus:border-[#D4622C] focus:ring-2 focus:ring-[#D4622C]/15 focus:outline-none transition-all shadow-2xs"
                  />
                </div>
              ))}
              <div className="sm:col-span-2">
                <label className="block text-[10px] font-bold uppercase tracking-wider text-[#77716C] mb-1.5 flex items-center gap-1">
                  <Calendar size={12} className="text-[#D4622C]" /> Meeting
                </label>
                <input
                  type="text"
                  value={formData.meeting}
                  onChange={(e) =>
                    setFormData((f) => ({ ...f, meeting: e.target.value }))
                  }
                  placeholder="Enter meeting details..."
                  className="w-full px-3.5 py-2.5 rounded-xl text-sm font-bold text-[#191919] placeholder:text-[#77716C]/50 border border-[#EAE2DB] bg-[#FAF6F2] focus:bg-white focus:border-[#D4622C] focus:ring-2 focus:ring-[#D4622C]/15 focus:outline-none transition-all shadow-2xs"
                />
              </div>
              <div className="sm:col-span-2">
                <label className="block text-[10px] font-bold uppercase tracking-wider text-[#77716C] mb-1.5 flex items-center gap-1">
                  <FileText size={12} className="text-[#D4622C]" /> Description
                </label>
                <textarea
                  value={formData.notes}
                  onChange={(e) =>
                    setFormData((f) => ({ ...f, notes: e.target.value }))
                  }
                  placeholder="Enter any additional description..."
                  className="w-full px-3.5 py-2.5 rounded-xl text-sm font-bold text-[#191919] placeholder:text-[#77716C]/50 border border-[#EAE2DB] bg-[#FAF6F2] focus:bg-white focus:border-[#D4622C] focus:ring-2 focus:ring-[#D4622C]/15 focus:outline-none transition-all min-h-[80px] resize-y shadow-2xs"
                />
              </div>
            </div>
          </div>

          {/* Footer Actions */}
          <div className="flex gap-3 px-6 py-5 border-t border-[#EAE2DB] bg-[#FAF6F2]/60">
            <UiloraBrandButton
              onClick={handleSave}
              disabled={isProcessing}
              className="flex-1 py-3 normal-case tracking-normal shadow-sm"
            >
              {isProcessing ? "Saving..." : "Save Contact"}
            </UiloraBrandButton>
            <button
              onClick={() => {
                setFormData({
                  fullName: "",
                  email: "",
                  phone: "",
                  phone2: "",
                  company: "",
                  jobTitle: "",
                  website: "",
                  address: "",
                  meeting: "",
                  notes: "",
                });
                onClose();
              }}
              className="flex-1 py-3 rounded-xl font-bold text-sm text-[#77716C] bg-white shadow-2xs border border-[#EAE2DB] cursor-pointer hover:bg-[#FAF6F2] hover:text-[#191919] transition-all flex items-center justify-center gap-2"
            >
              <RefreshCw size={16} /> Cancel
            </button>
          </div>
        </motion.div>
      </div>
    </AnimatePresence>
  );
}
