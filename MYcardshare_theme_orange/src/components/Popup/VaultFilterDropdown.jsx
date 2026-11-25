"use client";

import React from "react";
import { motion, AnimatePresence } from "framer-motion";
import { X, Check, Filter, SortAsc, Calendar, User, Building2, Tag } from "lucide-react";

/**
 * VaultFilterDropdown
 * A premium, glassmorphic dropdown for filtering contacts.
 * Positions itself relative to its parent container.
 */
export default function VaultFilterDropdown({ 
  isOpen, 
  onClose, 
  filters, 
  setFilters, 
  role = "individual" 
}) {
  const updateFilter = (key, value) => {
    setFilters(prev => ({ ...prev, [key]: value }));
  };

  const clearFilters = () => {
    setFilters({
      sort: "newest",
      source: "all",
      category: "all",
      ownership: "all",
      status: "all",
    });
  };

  const sections = [
    {
      title: "Sort Order",
      icon: SortAsc,
      key: "sort",
      options: [
        { label: "Recently Added", value: "newest" },
        { label: "Oldest First", value: "oldest" },
        { label: "Name (A-Z)", value: "a-z" },
        { label: "Name (Z-A)", value: "z-a" },
      ],
    },
    {
      title: "Source",
      icon: Filter,
      key: "source",
      options: [
        { label: "All Sources", value: "all" },
        { label: "OCR Scanner", value: "scanner" },
        { label: "Manual Entry", value: "manual" },
        { label: "QR Share", value: "qr" },
      ],
    },
  ];

  // Role-specific sections
  if (role === "individual") {
    sections.push({
      title: "Category",
      icon: Tag,
      key: "category",
      options: [
        { label: "All Categories", value: "all" },
        { label: "Business", value: "business" },
        { label: "Personal", value: "personal" },
        { label: "Lead", value: "lead" },
      ],
    });
  } else if (role === "employee") {
    sections.push({
      title: "Visibility",
      icon: User,
      key: "ownership",
      options: [
        { label: "All Contacts", value: "all" },
        { label: "My Contacts", value: "mine" },
        { label: "Shared with Me", value: "shared" },
      ],
    });
  } else if (role === "admin" || role === "enterprise") {
    sections.push({
      title: "Team View",
      icon: Building2,
      key: "ownership",
      options: [
        { label: "All Company", value: "all" },
        { label: "My Contacts", value: "mine" },
        { label: "By Department", value: "department" },
      ],
    });
  }

  return (
    <AnimatePresence>
      {isOpen && (
        <>
          {/* Backdrop for closing */}
          <div 
            className="fixed inset-0 z-40" 
            onClick={onClose} 
          />
          
          <motion.div
            initial={{ opacity: 0, y: 10, scale: 0.95 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: 10, scale: 0.95 }}
            transition={{ duration: 0.2, ease: "easeOut" }}
            className="absolute right-0 top-full mt-2 w-72 z-50 overflow-hidden"
          >
            <div className="bg-white/95 backdrop-blur-xl border border-[#EAE2DB] rounded-2xl shadow-[0_20px_50px_rgba(28,25,23,0.15)] p-2">
              <div className="flex items-center justify-between px-3 py-2.5 border-b border-[#EAE2DB]">
                <span className="text-xs font-black uppercase tracking-widest text-[#77716C] flex items-center gap-2">
                  <Filter size={13} className="text-[#D4622C]" /> Filters
                </span>
                <button 
                  onClick={clearFilters}
                  className="text-[10px] font-bold text-[#D4622C] hover:text-[#BD5523] transition-colors uppercase tracking-wider"
                >
                  Clear All
                </button>
              </div>

              <div className="max-h-[360px] overflow-y-auto px-1 py-2 space-y-4 no-scrollbar">
                {sections.map((section) => (
                  <div key={section.key} className="space-y-2">
                    <div className="px-2 flex items-center gap-2 text-[10px] font-black text-[#A8A29E] uppercase tracking-widest">
                      <section.icon size={11} className="text-[#D4622C]" /> {section.title}
                    </div>
                    <div className="grid grid-cols-1 gap-1">
                      {section.options.map((opt) => {
                        const isActive = filters[section.key] === opt.value;
                        return (
                          <button
                            key={opt.value}
                            onClick={() => updateFilter(section.key, opt.value)}
                            className={`flex items-center justify-between px-3 py-2 rounded-xl text-xs transition-all ${
                              isActive 
                                ? "bg-[#FCE9DF] text-[#D4622C] border border-[#D4622C]/30 shadow-2xs font-bold" 
                                : "text-[#57534E] hover:bg-[#FAF6F2] hover:text-[#191919] border border-transparent font-medium"
                            }`}
                          >
                            {opt.label}
                            {isActive && <Check size={12} className="shrink-0 text-[#D4622C]" />}
                          </button>
                        );
                      })}
                    </div>
                  </div>
                ))}
              </div>

              <div className="p-1.5 mt-1 border-t border-[#EAE2DB]">
                <button
                  onClick={onClose}
                  className="w-full py-3 rounded-xl bg-[#D4622C] hover:bg-[#BD5523] text-white text-xs font-black uppercase tracking-widest shadow-[0_4px_16px_rgba(212,98,44,0.3)] transition-all active:scale-[0.98]"
                >
                  Apply Filters
                </button>
              </div>
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
}
