"use client";

import { useEffect, useState } from "react";
import { motion } from "framer-motion";
import {
  Users,
  Plus,
  Search,
  Building2,
  Mail,
  Phone,
  Calendar,
  Loader2,
} from "lucide-react";
import { useAuth } from "@/lib/auth-context";
import { authFetch } from "@/lib/api";
import { UiloraBrandButton } from "@/components/UIComponents/Button/tsx/UiloraModernButtons";
import LeadForm from "@/components/leads/LeadForm";

import ViewLeads from "@/components/leads/ViewLeads";

/* ═══════════════════════════════════════════════════════════
   LEADS — UILORA Table
   ═══════════════════════════════════════════════════════════ */

const STATUS_COLORS = {
  New: {
    bg: "#FCE9DF",
    border: "#F3C5AF",
    text: "#D4622C",
  },
  Contacted: {
    bg: "#FEF3C7",
    border: "#FDE68A",
    text: "#D97706",
  },
  Qualified: {
    bg: "#DCFCE7",
    border: "#BBF7D0",
    text: "#16A34A",
  },
};

export default function LeadsPage() {
  const [leads, setLeads] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [isFormOpen, setIsFormOpen] = useState(false);
  const [selectedLead, setSelectedLead] = useState(null);
  const [editingLead, setEditingLead] = useState(null);

  const handleDeleteLead = async (id) => {
    if (!confirm("Are you sure you want to delete this lead?")) return;
    try {
      const res = await authFetch(`/api/leads/${id}`, { method: "DELETE" });
      if (res.ok) {
        fetchLeads();
      } else {
        alert("Failed to delete lead");
      }
    } catch (e) {
      alert("Error deleting lead");
    }
  };

  const fetchLeads = async () => {
    setLoading(true);
    try {
      const res = await authFetch("/api/leads");
      const data = await res.json();
      if (data.success) {
        setLeads(data.data);
      }
    } catch (err) {
      console.error("Failed to fetch leads:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchLeads();
  }, []);

  const filtered = leads.filter(
    (l) =>
      (l.name || l.fullName || "")
        .toLowerCase()
        .includes(search.toLowerCase()) ||
      (l.company || l.companyName || "")
        .toLowerCase()
        .includes(search.toLowerCase()),
  );

  return (
    <div className="max-w-7xl mx-auto space-y-6">
      <div className="flex items-center justify-between gap-4">
        <div>
          <h1
            className="text-2xl font-black tracking-tight text-[var(--color-ink-2)]"
            style={{ fontFamily: "var(--font-display)" }}
          >
            Leads
          </h1>
          <p className="text-sm mt-1 text-[var(--color-muted)]">
            {loading ? "..." : leads.length} leads captured
          </p>
        </div>
      </div>

      <LeadForm 
        isOpen={isFormOpen} 
        onClose={() => {
          setIsFormOpen(false);
          setEditingLead(null);
        }} 
        onLeadCreated={fetchLeads} 
        editLead={editingLead}
      />

      <ViewLeads 
        isOpen={!!selectedLead} 
        onClose={() => setSelectedLead(null)} 
        lead={selectedLead} 
      />

      {/* Search & Add Lead */}
      <div className="flex items-center gap-3">
        <div className="relative flex-1 flex items-center bg-white border border-[#EAE2DB] rounded-2xl shadow-2xs overflow-hidden">
          <Search
            size={16}
            className="absolute left-4 text-[#77716C]"
          />
          <input
            type="text"
            placeholder="Search leads..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-11 pr-4 py-3 bg-transparent border-none text-sm font-medium text-[#191919] placeholder:text-[#77716C]/60 focus:ring-0 outline-none transition-all"
          />
        </div>
        <UiloraBrandButton 
          onClick={() => setIsFormOpen(true)}
          className="px-4 sm:px-6 py-3 normal-case tracking-normal shrink-0 shadow-sm"
        >
          <Plus size={16} /> <span className="hidden sm:inline">Add Lead</span><span className="sm:hidden">Add</span>
        </UiloraBrandButton>
      </div>

      {/* Leads Table/Cards */}
      <div className="bg-white rounded-3xl overflow-hidden min-h-[300px] shadow-xs border border-[#EAE2DB]">
        {/* Header */}
        <div className="hidden md:grid grid-cols-12 gap-4 px-6 py-4 text-xs font-bold uppercase tracking-[0.12em] text-[#77716C] border-b border-[#EAE2DB] bg-[#FAF6F2]">
          <div className="col-span-4">Lead</div>
          <div className="col-span-3">Contact</div>
          <div className="col-span-2">Status</div>
          <div className="col-span-2">Date</div>
          <div className="col-span-1"></div>
        </div>

        {/* Rows */}
        {loading ? (
          <div className="flex items-center justify-center py-20">
            <Loader2 className="animate-spin text-[#D4622C]" size={32} />
          </div>
        ) : filtered.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-20 text-[#77716C]">
            <Users size={48} className="mb-4 opacity-20 text-[#D4622C]" />
            <p className="text-sm font-bold tracking-widest uppercase text-[#77716C]">
              No leads found
            </p>
          </div>
        ) : (
          filtered.map((lead, i) => {
            const sc = STATUS_COLORS[lead.status] || STATUS_COLORS.New;
            const initials = (lead.name || lead.fullName || "L")
              .split(" ")
              .map((n) => n[0])
              .join("")
              .toUpperCase();

            return (
              <motion.div
                key={lead._id || lead.id}
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: i * 0.05 }}
                className="relative grid grid-cols-1 md:grid-cols-12 gap-3 md:gap-4 px-4 sm:px-6 py-4 sm:py-5 items-center hover:bg-[#FAF6F2] transition-colors border-b border-[#EAE2DB]/60 last:border-0"
              >
                <div className="col-span-4 flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl flex items-center justify-center text-xs font-black text-[#D4622C] shrink-0 bg-[#FCE9DF] border border-[#EAE2DB] shadow-2xs">
                    {initials}
                  </div>
                  <div>
                    <div className="text-sm font-bold text-[#191919]">
                      {lead.name || lead.fullName}
                    </div>
                    <div className="text-xs flex items-center gap-1 text-[#77716C] font-medium mt-0.5">
                      <Building2 size={12} className="text-[#77716C]" />{" "}
                      {lead.company || lead.companyName || "N/A"}
                    </div>
                  </div>
                </div>
                <div className="col-span-3 space-y-1">
                  <div className="text-xs flex items-center gap-1.5 text-[#77716C] font-medium">
                    <Mail size={12} className="text-[#D4622C]" /> {lead.email || lead.workEmail || "N/A"}
                  </div>
                  <div className="text-xs flex items-center gap-1.5 text-[#77716C] font-medium">
                    <Phone size={12} className="text-[#77716C]" /> {lead.phone || lead.workPhone || "N/A"}
                  </div>
                </div>
                <div className="col-span-2">
                  <span
                    className="px-2.5 py-1 rounded-full text-[11px] font-bold"
                    style={{
                      background: sc.bg,
                      border: `1px solid ${sc.border}`,
                      color: sc.text,
                    }}
                  >
                    {lead.status || "New"}
                  </span>
                </div>
                <div className="col-span-2 text-xs flex items-center gap-1.5 text-[#77716C] font-medium">
                  <Calendar size={12} />{" "}
                  {lead.createdAt
                    ? new Date(lead.createdAt).toLocaleDateString()
                    : "Recently"}
                </div>
                <div className="absolute top-4 right-4 md:static col-span-1 text-right flex md:flex-row md:items-center justify-end gap-2 md:gap-3">
                  <button 
                    onClick={() => setSelectedLead(lead)}
                    className="text-[10px] sm:text-xs font-bold cursor-pointer border-0 bg-transparent text-[#77716C] hover:bg-[#FCE9DF] hover:text-[#D4622C] px-3 py-1.5 rounded-full transition-all duration-200"
                  >
                    View
                  </button>
                  <button 
                    onClick={() => { setEditingLead(lead); setIsFormOpen(true); }}
                    className="text-[10px] sm:text-xs font-bold cursor-pointer border-0 bg-transparent text-[#77716C] hover:bg-[#FCE9DF] hover:text-[#D4622C] px-3 py-1.5 rounded-full transition-all duration-200"
                  >
                    Edit
                  </button>
                  <button 
                    onClick={() => handleDeleteLead(lead._id || lead.id)}
                    className="text-[10px] sm:text-xs font-bold cursor-pointer border-0 bg-transparent text-[#77716C] hover:bg-rose-500/10 hover:text-rose-600 px-3 py-1.5 rounded-full transition-all duration-200"
                  >
                    Delete
                  </button>
                </div>
              </motion.div>
            );
          })
        )}
      </div>
    </div>
  );
}
