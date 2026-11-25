"use client";

import { useEffect, useState } from "react";
import { motion } from "framer-motion";
import {
  Search,
  Filter,
  Download,
  MoreHorizontal,
  User,
  Mail,
  Phone,
  Building2,
  Loader2,
  Plus,
  Mic,
} from "lucide-react";
import { authFetch } from "@/lib/api";
import { useAuth } from "@/lib/auth-context";
import { UiloraBrandButton } from "@/components/UIComponents/Button/tsx/UiloraModernButtons";
import VaultFilterDropdown from "@/components/Popup/VaultFilterDropdown";

import ContactForm from "@/components/Contact/contactform";
import VoiceRecordModal from "@/components/Contact/VoiceRecordModal";
import ViewContactCard from "@/components/Contact/ViewContactCard";

/* ═══════════════════════════════════════════════════════════
   CONTACT VAULT — UILORA Table + Cards
   ═══════════════════════════════════════════════════════════ */

export default function VaultPage() {
  const { userData } = useAuth();
  const [contacts, setContacts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [isFilterOpen, setIsFilterOpen] = useState(false);
  const [isAddContactOpen, setIsAddContactOpen] = useState(false);
  const [isVoiceRecordOpen, setIsVoiceRecordOpen] = useState(false);
  const [selectedContact, setSelectedContact] = useState(null);
  const [isViewContactOpen, setIsViewContactOpen] = useState(false);
  const [filters, setFilters] = useState({
    sort: "newest",
    source: "all",
    category: "all",
    ownership: "all",
    status: "all",
  });

  const fetchContacts = async () => {
    try {
      const res = await authFetch("/api/vault");
      const data = await res.json();
      if (data.success) {
        setContacts(data.data);
      }
    } catch (err) {
      console.error("Failed to fetch contacts:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchContacts();
  }, []);

  const filtered = contacts
    .filter((c) => {
      // Search filter
      const matchesSearch =
        (c.name || c.fullName || "").toLowerCase().includes(search.toLowerCase()) ||
        (c.company || c.companyName || "").toLowerCase().includes(search.toLowerCase());

      if (!matchesSearch) return false;

      // Source filter
      if (filters.source !== "all") {
        if (c.source !== filters.source) return false;
      }

      // Category filter (Individual)
      if (filters.category !== "all") {
        if (c.category !== filters.category) return false;
      }

      // Ownership filter (Employee/Enterprise)
      if (filters.ownership !== "all") {
        if (filters.ownership === "mine" && c.ownerId !== userData?.uid) return false;
        // Add other ownership logic as needed
      }

      return true;
    })
    .sort((a, b) => {
      if (filters.sort === "newest") {
        return new Date(b.createdAt || b.id) - new Date(a.createdAt || a.id);
      }
      if (filters.sort === "oldest") {
        return new Date(a.createdAt || a.id) - new Date(b.createdAt || b.id);
      }
      if (filters.sort === "a-z") {
        return (a.name || a.fullName || "").localeCompare(b.name || b.fullName || "");
      }
      if (filters.sort === "z-a") {
        return (b.name || b.fullName || "").localeCompare(a.name || a.fullName || "");
      }
      return 0;
    });

  return (
    <div className="max-w-7xl mx-auto space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1
            className="text-2xl font-black tracking-tight text-[var(--color-ink-2)]"
            style={{ fontFamily: "var(--font-display)" }}
          >
            Contact Vault
          </h1>
          <p className="text-sm mt-1 text-[var(--color-muted)]">
            {loading ? "..." : contacts.length} contacts saved
          </p>
        </div>
        <div className="flex gap-3">
          <UiloraBrandButton 
            onClick={() => setIsAddContactOpen(true)}
            className="px-4 py-2 text-xs normal-case tracking-normal shadow-sm"
          >
            <Plus size={14} /> Add Contact
          </UiloraBrandButton>
          <UiloraBrandButton 
            onClick={() => setIsVoiceRecordOpen(true)}
            className="px-4 py-2 text-xs normal-case tracking-normal shadow-sm"
          >
            <Mic size={14} /> Add Record
          </UiloraBrandButton>
          <UiloraBrandButton className="px-4 py-2 text-xs normal-case tracking-normal shadow-sm">
            <Download size={14} /> Export
          </UiloraBrandButton>
        </div>
      </div>

      {/* Search + Filter */}
      <div className="flex gap-3">
        <div className="premium-input relative flex-1 flex items-center overflow-hidden">
          <Search
            size={16}
            className="absolute left-4 text-[var(--color-muted)]"
          />
          <input
            type="text"
            placeholder="Search contacts..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-11 pr-4 py-3 bg-transparent border-none text-sm text-[var(--color-ink-2)] placeholder-[var(--color-muted)]/50 focus:ring-0 outline-none transition-all"
          />
        </div>
        <div className="relative">
          <UiloraBrandButton 
            onClick={() => setIsFilterOpen(!isFilterOpen)}
            className="px-4 py-3 text-xs normal-case tracking-normal shadow-sm h-full"
          >
            <Filter size={14} /> Filter
          </UiloraBrandButton>
          
          <VaultFilterDropdown 
            isOpen={isFilterOpen}
            onClose={() => setIsFilterOpen(false)}
            filters={filters}
            setFilters={setFilters}
            role={userData?.role || userData?.type || "individual"}
          />
        </div>
      </div>

      {/* Contact Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
        {loading ? (
          <div className="col-span-full flex items-center justify-center py-20">
            <Loader2 className="animate-spin text-[#D4622C]" size={32} />
          </div>
        ) : filtered.length === 0 ? (
          <div className="col-span-full flex flex-col items-center justify-center py-20 text-[var(--color-muted)]">
            <User size={48} className="mb-4 opacity-20" />
            <p className="text-sm font-bold tracking-widest uppercase">
              No contacts found
            </p>
          </div>
        ) : (
          filtered.map((c, i) => {
            const initials = (c.name || c.fullName || "C")
              .split(" ")
              .map((n) => n[0])
              .join("")
              .toUpperCase();

            return (
              <motion.div
                key={c._id || c.id}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: i * 0.05 }}
                className="glass-premium p-5 group cursor-pointer"
              >
                <div className="flex items-start justify-between mb-4">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-xl flex items-center justify-center text-sm font-bold text-[#D4622C] bg-[#FCE9DF] border border-[#D4622C]/20 shadow-2xs">
                      {initials}
                    </div>
                    <div>
                      <div className="text-sm font-bold text-[var(--color-ink-2)]">
                        {c.name || c.fullName}
                      </div>
                      <div className="text-[11px] flex items-center gap-1 text-[var(--color-muted)] mt-0.5 font-medium">
                        <Building2 size={10} />{" "}
                        {c.company || c.companyName || "N/A"}
                      </div>
                    </div>
                  </div>
                  <button 
                    onClick={() => {
                      setSelectedContact(c);
                      setIsViewContactOpen(true);
                    }}
                    className="p-1.5 rounded-lg border border-transparent bg-transparent text-[var(--color-muted)] hover:text-[#D4622C] hover:bg-[#FAF6F2] hover:border-[#EAE2DB] transition-colors"
                  >
                    <MoreHorizontal size={16} />
                  </button>
                </div>
                <div className="space-y-2 mt-2 pt-3 border-t border-[var(--color-glass-border)]/50">
                  <div className="flex items-center gap-2 text-xs text-[var(--color-muted)] font-medium">
                    <Mail size={12} className="text-[#D4622C]/70" /> {c.email || c.workEmail || "N/A"}
                  </div>
                  <div className="flex items-center gap-2 text-xs text-[var(--color-muted)] font-medium">
                    <Phone size={12} className="text-[#D4622C]/70" /> {c.phone || c.workPhone || "N/A"}
                  </div>
                </div>
              </motion.div>
            );
          })
        )}
      </div>

      <ContactForm 
        isOpen={isAddContactOpen}
        onClose={() => setIsAddContactOpen(false)}
        onSuccess={() => fetchContacts()}
      />

      <VoiceRecordModal
        isOpen={isVoiceRecordOpen}
        onClose={() => setIsVoiceRecordOpen(false)}
        onSuccess={() => fetchContacts()}
      />

      <ViewContactCard 
        isOpen={isViewContactOpen}
        onClose={() => {
          setIsViewContactOpen(false);
          setSelectedContact(null);
        }}
        contact={selectedContact}
      />
    </div>
  );
}
