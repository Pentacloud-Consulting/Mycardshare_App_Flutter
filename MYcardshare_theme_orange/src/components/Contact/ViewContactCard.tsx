"use client";

import { motion, AnimatePresence } from "framer-motion";
import {
  X,
  User,
  Phone,
  Mail,
  Building2,
  Globe,
  Briefcase,
  MapPin,
  FileText,
  Calendar,
  Tag,
  ChevronRight,
  TrendingUp,
} from "lucide-react";

export default function ViewContactCard({ isOpen, onClose, contact }) {
  if (!isOpen || !contact) return null;

  const renderSectionHeader = (title, icon) => (
    <div className="flex items-center gap-3 mb-6 pb-2 border-b border-[#EAE2DB]">
      <div className="p-2 rounded-xl bg-[#FCE9DF] text-[#D4622C]">
        {icon}
      </div>
      <h3 className="text-xs font-black uppercase tracking-[0.2em] text-[#191919]">
        {title}
      </h3>
    </div>
  );

  const renderInfoItem = (icon, label, value, colSpan = "col-span-1") => (
    <div className={`${colSpan} group`}>
      <div className="flex items-center gap-2 mb-2">
        <div className="text-[#77716C] group-hover:text-[#D4622C] transition-colors">
          {icon}
        </div>
        <span className="text-[10px] font-black uppercase tracking-widest text-[#77716C]">
          {label}
        </span>
      </div>
      <div className="text-sm font-bold text-[#191919] pl-6 border-l border-[#EAE2DB] group-hover:border-[#D4622C]/40 transition-colors">
        {value || <span className="text-[#77716C]/40 font-medium italic text-[11px]">No data provided</span>}
      </div>
    </div>
  );

  const displayName = contact.fullName || contact.name || "Untitled Contact";
  const displayCompany = contact.companyName || contact.company || "N/A";

  return (
    <AnimatePresence>
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm"
      >
        <motion.div
          initial={{ scale: 0.95, opacity: 0, y: 30 }}
          animate={{ scale: 1, opacity: 1, y: 0 }}
          exit={{ scale: 0.95, opacity: 0, y: 30 }}
          transition={{ type: "spring", damping: 25, stiffness: 300 }}
          className="bg-white border border-[#EAE2DB] rounded-[3rem] w-full max-w-3xl max-h-[85vh] overflow-hidden shadow-[0_30px_100px_-12px_rgba(28,25,23,0.15)] flex flex-col relative"
        >
          {/* Accent Glow */}
          <div className="absolute top-0 right-0 w-1/2 h-1/2 bg-[#D4622C]/5 blur-[120px] pointer-events-none" />
          
          {/* Header */}
          <div className="px-10 py-10 flex items-start justify-between relative z-10 border-b border-[#EAE2DB] bg-[#FAF6F2]/40">
            <div className="space-y-4">
              <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-[#FCE9DF] border border-[#D4622C]/30 text-[#D4622C] text-[9px] font-black uppercase tracking-widest">
                <span className="w-1.5 h-1.5 rounded-full bg-[#D4622C] animate-pulse" />
                {contact.source ? `${contact.source} Contact` : "Saved Contact"}
              </div>
              <div>
                <h2 className="text-4xl font-black text-[#191919] tracking-tighter leading-tight">
                  {displayName}
                </h2>
                <div className="flex items-center gap-4 mt-2 text-[#77716C] text-[11px] font-bold uppercase tracking-widest">
                   <div className="flex items-center gap-1.5">
                    <Calendar size={12} className="text-[#D4622C]" />
                    {contact.createdAt ? new Date(contact.createdAt).toLocaleDateString('en-GB', { day: '2-digit', month: 'long', year: 'numeric' }) : "Recently Added"}
                  </div>
                  <span className="w-1 h-1 rounded-full bg-[#EAE2DB]" />
                  <div className="flex items-center gap-1.5">
                    <TrendingUp size={12} className="text-[#D4622C]" />
                    {contact.category || "General"}
                  </div>
                </div>
              </div>
            </div>
            <button
              onClick={onClose}
              className="w-12 h-12 rounded-2xl bg-white border border-[#EAE2DB] flex items-center justify-center text-[#77716C] hover:text-[#191919] hover:bg-[#FAF6F2] transition-all group shadow-2xs"
            >
              <X size={20} className="group-hover:rotate-90 transition-transform duration-300" />
            </button>
          </div>

          {/* Report Body */}
          <div className="flex-1 overflow-y-auto px-10 py-8 space-y-10 no-scrollbar relative z-10">
            
            {/* Contact Profile Section */}
            <section>
              {renderSectionHeader("Contact Profile", <User size={14} />)}
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-y-8 gap-x-12">
                {renderInfoItem(<Phone size={13} />, "Phone Number", contact.phone || contact.workPhone)}
                {renderInfoItem(<Mail size={13} />, "Email Address", contact.email || contact.workEmail)}
                {renderInfoItem(<Briefcase size={13} />, "Job Title", contact.jobTitle || contact.designation)}
                {renderInfoItem(<Building2 size={13} />, "Company", displayCompany)}
                {renderInfoItem(<Globe size={13} />, "Website", contact.website)}
                {renderInfoItem(<MapPin size={13} />, "Location", contact.location || contact.address)}
              </div>
            </section>

            {/* Notes Section */}
            <section className="space-y-4">
              <div className="flex items-center gap-2 text-[#77716C]">
                <FileText size={14} className="text-[#D4622C]" />
                <span className="text-[10px] font-black uppercase tracking-widest">Extracted Intelligence / Notes</span>
              </div>
              <div className="p-6 rounded-3xl bg-[#FAF6F2] border border-[#EAE2DB] text-sm text-[#57534E] leading-relaxed font-medium">
                {contact.notes || "No supplemental intelligence has been recorded for this contact."}
              </div>
            </section>
          </div>

          {/* Bottom Control */}
          <div className="px-10 py-6 border-t border-[#EAE2DB] flex items-center justify-between bg-[#FAF6F2]/80 backdrop-blur-xl relative z-20">
             <div className="flex items-center gap-3 text-[10px] font-black text-[#77716C] uppercase tracking-[0.2em]">
                <Globe size={12} className="text-[#D4622C]" />
                My Card Share Vault Data
             </div>
             <button
              onClick={onClose}
              className="px-10 py-3.5 rounded-2xl bg-[#D4622C] text-white text-[11px] font-black uppercase tracking-[0.2em] hover:bg-[#BD5523] hover:shadow-[0_4px_20px_rgba(212,98,44,0.3)] transition-all flex items-center gap-2 group cursor-pointer"
            >
              Close
              <ChevronRight size={14} className="group-hover:translate-x-1 transition-transform" />
            </button>
          </div>
        </motion.div>
      </motion.div>
    </AnimatePresence>
  );
}
