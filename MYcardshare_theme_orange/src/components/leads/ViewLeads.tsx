"use client";

import { motion, AnimatePresence } from "framer-motion";
import {
  X,
  User,
  Phone,
  Mail,
  Target,
  Globe,
  Wallet,
  Building2,
  MapPin,
  Star,
  Clock,
  FileText,
  Calendar,
  Tag,
  Briefcase,
  ChevronRight,
  TrendingUp,
} from "lucide-react";

export default function ViewLeads({ isOpen, onClose, lead }) {
  if (!isOpen || !lead) return null;

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
      <div className="text-sm font-bold text-[#191919] pl-4 border-l-2 border-[#EAE2DB] group-hover:border-[#D4622C] transition-colors">
        {value || <span className="text-[#77716C]/40 font-medium italic text-[11px]">No data provided</span>}
      </div>
    </div>
  );

  return (
    <AnimatePresence>
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm"
      >
        <motion.div
          initial={{ scale: 0.95, opacity: 0, y: 20 }}
          animate={{ scale: 1, opacity: 1, y: 0 }}
          exit={{ scale: 0.95, opacity: 0, y: 20 }}
          transition={{ type: "spring", damping: 25, stiffness: 300 }}
          className="bg-white border border-[#EAE2DB] rounded-[2.5rem] w-full max-w-3xl max-h-[85vh] overflow-hidden shadow-2xl flex flex-col relative"
        >
          {/* Accent Glow */}
          <div className="absolute top-0 right-0 w-1/2 h-1/2 bg-[#D4622C]/5 blur-[120px] pointer-events-none" />
          
          {/* Header */}
          <div className="px-8 md:px-10 py-8 flex items-start justify-between relative z-10 border-b border-[#EAE2DB] bg-[#FAF6F2]/80 backdrop-blur-sm">
            <div className="space-y-3">
              <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#FCE9DF] border border-[#F3C5AF] text-[#D4622C] text-[10px] font-black uppercase tracking-widest">
                <span className="w-1.5 h-1.5 rounded-full bg-[#D4622C] animate-pulse" />
                {lead.status || "Active"} Lead
              </div>
              <div>
                <h2 className="text-2xl md:text-3xl font-black text-[#191919] tracking-tight leading-tight">
                  {lead.fullName || lead.name || "Untitled Lead"}
                </h2>
                <div className="flex items-center gap-4 mt-1.5 text-[#77716C] text-[11px] font-bold uppercase tracking-widest">
                   <div className="flex items-center gap-1.5">
                    <Calendar size={12} />
                    {lead.createdAt ? new Date(lead.createdAt).toLocaleDateString('en-GB', { day: '2-digit', month: 'long', year: 'numeric' }) : "Recently Added"}
                  </div>
                  <span className="w-1 h-1 rounded-full bg-[#EAE2DB]" />
                  <div className="flex items-center gap-1.5">
                    <TrendingUp size={12} className="text-[#D4622C]" />
                    {lead.campaignName || "Organic Search"}
                  </div>
                </div>
              </div>
            </div>
            <button
              onClick={onClose}
              className="w-10 h-10 rounded-xl bg-white border border-[#EAE2DB] flex items-center justify-center text-[#77716C] hover:text-[#D4622C] hover:bg-[#FCE9DF] hover:border-[#D4622C]/30 shadow-2xs transition-all cursor-pointer group"
            >
              <X size={18} className="group-hover:rotate-90 transition-transform duration-300" />
            </button>
          </div>

          {/* Report Body */}
          <div className="flex-1 overflow-y-auto px-8 md:px-10 py-8 space-y-10 custom-scrollbar relative z-10">
            
            {/* Customer Profile Section */}
            <section>
              {renderSectionHeader("Customer Profile", <User size={14} />)}
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-y-6 gap-x-8">
                {renderInfoItem(<Phone size={13} />, "Mobile Contact", lead.mobile || lead.phone)}
                {renderInfoItem(<Mail size={13} />, "Email Address", lead.email || lead.workEmail)}
                {renderInfoItem(<Globe size={13} />, "Nationality", lead.nationality)}
                {renderInfoItem(<Briefcase size={13} />, "Investor Type", lead.investorType)}
              </div>
            </section>

            {/* Property Interest Section */}
            <section className="bg-[#FAF6F2] border border-[#EAE2DB] rounded-3xl p-6 md:p-8">
              {renderSectionHeader("Property Requirements", <Building2 size={14} />)}
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-y-6 gap-x-8">
                {renderInfoItem(<Tag size={13} />, "Category", lead.propertyCategory)}
                {renderInfoItem(<Building2 size={13} />, "Type", lead.propertyType)}
                {renderInfoItem(<Wallet size={13} />, "Budget Range", lead.budgetRange)}
                {renderInfoItem(<MapPin size={13} />, "Location / Emirate", lead.emirate)}
                
                {/* Area of Interest */}
                <div className="col-span-full md:col-span-2 group">
                  <div className="flex items-center gap-2 mb-3">
                    <MapPin size={13} className="text-[#77716C] group-hover:text-[#D4622C] transition-colors" />
                    <span className="text-[10px] font-black uppercase tracking-widest text-[#77716C]">
                      Area of Interest
                    </span>
                  </div>
                  <div className="flex flex-wrap gap-2 pl-4 border-l-2 border-[#EAE2DB] group-hover:border-[#D4622C] transition-colors">
                    {Array.isArray(lead.areaOfInterest) && lead.areaOfInterest.length > 0 ? (
                      lead.areaOfInterest.map((area, idx) => (
                        <span key={idx} className="px-3 py-1 text-[11px] font-bold rounded-lg bg-white text-[#D4622C] border border-[#EAE2DB] shadow-2xs">
                          {area}
                        </span>
                      ))
                    ) : lead.areaOfInterest && typeof lead.areaOfInterest === 'string' ? (
                       <span className="px-3 py-1 text-[11px] font-bold rounded-lg bg-white text-[#D4622C] border border-[#EAE2DB] shadow-2xs">
                        {lead.areaOfInterest}
                      </span>
                    ) : (
                      <span className="text-[#77716C]/40 font-medium italic text-[11px]">Not specified</span>
                    )}
                  </div>
                </div>
              </div>
            </section>

            {/* Engagement & Analysis */}
            <section>
              {renderSectionHeader("Analysis & Timeline", <Clock size={14} />)}
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-y-6 gap-x-8">
                 {renderInfoItem(<Clock size={13} />, "Closing Timeline", lead.timeline)}
                 {renderInfoItem(<Target size={13} />, "Lead Source", lead.campaignName || lead.campaignId)}
              </div>
            </section>

            {/* Notes Section */}
            <section className="space-y-3">
              <div className="flex items-center gap-2 text-[#77716C]">
                <FileText size={14} />
                <span className="text-[10px] font-black uppercase tracking-widest">Additional Intelligence / Notes</span>
              </div>
              <div className="p-6 rounded-2xl bg-[#FAF6F2] border border-[#EAE2DB] text-sm text-[#191919] leading-relaxed font-medium">
                {lead.notes || "No supplemental intelligence has been recorded for this lead yet."}
              </div>
            </section>
          </div>

          {/* Bottom Control */}
          <div className="px-8 md:px-10 py-5 border-t border-[#EAE2DB] flex items-center justify-between bg-[#FAF6F2]/80 backdrop-blur-md relative z-20">
             <div className="flex items-center gap-2 text-[10px] font-black text-[#77716C] uppercase tracking-[0.15em]">
                <Globe size={12} className="text-[#D4622C]" />
                My Card Share Intelligence Report
             </div>
             <button
              onClick={onClose}
              className="px-6 py-2.5 rounded-xl bg-gradient-to-r from-[#D4622C] to-[#E3743E] hover:from-[#BF5321] hover:to-[#D4622C] text-white text-[11px] font-bold uppercase tracking-wider shadow-md shadow-[#D4622C]/25 transition-all flex items-center gap-2 cursor-pointer group"
            >
              Close Report
              <ChevronRight size={14} className="group-hover:translate-x-1 transition-transform" />
            </button>
          </div>
        </motion.div>
      </motion.div>
    </AnimatePresence>
  );
}
