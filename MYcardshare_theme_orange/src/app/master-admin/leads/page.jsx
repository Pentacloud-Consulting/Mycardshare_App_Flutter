"use client";
import { useEffect, useState, useMemo, useCallback } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Megaphone, Search, Loader2, AlertCircle, RefreshCw, Download, X, Eye, Filter, Phone, Mail, Clock, Building2, Plus, Trash2, CheckCircle } from "lucide-react";
import { authFetch, parseFetchJson } from "@/lib/api";

function Toast({ message, type, onClose }) {
  useEffect(() => { const t = setTimeout(onClose, 4000); return () => clearTimeout(t); }, [onClose]);
  const color = type === "success" ? "#10d9a8" : "#ef4444";
  const Icon = type === "success" ? CheckCircle : AlertCircle;
  return (
    <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: 20 }}
      className="fixed bottom-6 right-6 z-[100] flex items-center gap-3 px-5 py-3.5 rounded-xl shadow-2xl"
      style={{ background: `${color}15`, border: `1px solid ${color}30` }}>
      <Icon size={16} style={{ color }} /><span className="text-sm font-semibold" style={{ color }}>{message}</span>
    </motion.div>
  );
}

function CreateLeadModal({ companies, onSave, onClose, busy }) {
  const [form, setForm] = useState({ fullName: "", mobile: "", email: "", companyId: "", campaignId: "", nationality: "", budgetRange: "", propertyType: "" });
  const set = (k, v) => setForm({ ...form, [k]: v });
  const inputClass = "w-full px-4 py-2.5 rounded-xl text-sm bg-white/5 border border-white/10 text-white placeholder:text-white/20 focus:outline-none focus:ring-2 focus:ring-indigo-500/40";
  return (
    <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
      className="fixed inset-0 bg-black/70 backdrop-blur-sm z-[60] flex items-center justify-center p-4" onClick={onClose}>
      <motion.div initial={{ scale: 0.9 }} animate={{ scale: 1 }}
        className="w-full max-w-lg max-h-[85vh] overflow-y-auto rounded-2xl p-8" style={{ background: "#0d1424", border: "1px solid rgba(255,255,255,0.08)" }}
        onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center justify-between mb-6">
          <h3 className="text-lg font-black text-white">Add Lead</h3>
          <button onClick={onClose} className="p-2 text-white/40 hover:text-white"><X size={18} /></button>
        </div>
        <div className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div><label className="text-[10px] font-bold uppercase tracking-[0.15em] text-white/30 block mb-1.5">Full Name *</label>
              <input type="text" value={form.fullName} onChange={(e) => set("fullName", e.target.value)} placeholder="John Doe" className={inputClass} /></div>
            <div><label className="text-[10px] font-bold uppercase tracking-[0.15em] text-white/30 block mb-1.5">Phone *</label>
              <input type="text" value={form.mobile} onChange={(e) => set("mobile", e.target.value)} placeholder="+971..." className={inputClass} /></div>
          </div>
          <div><label className="text-[10px] font-bold uppercase tracking-[0.15em] text-white/30 block mb-1.5">Email</label>
            <input type="email" value={form.email} onChange={(e) => set("email", e.target.value)} placeholder="john@example.com" className={inputClass} /></div>
          <div><label className="text-[10px] font-bold uppercase tracking-[0.15em] text-white/30 block mb-1.5">Company</label>
            <select value={form.companyId} onChange={(e) => set("companyId", e.target.value)}
              className={`${inputClass} appearance-none`}>
              <option value="">Select company</option>
              {companies.map((c) => <option key={c.companyId} value={c.companyId}>{c.companyName || c.companyId}</option>)}
            </select></div>
          <div><label className="text-[10px] font-bold uppercase tracking-[0.15em] text-white/30 block mb-1.5">Campaign ID</label>
            <input type="text" value={form.campaignId} onChange={(e) => set("campaignId", e.target.value)} placeholder="Optional" className={inputClass} /></div>
          <div className="grid grid-cols-2 gap-4">
            <div><label className="text-[10px] font-bold uppercase tracking-[0.15em] text-white/30 block mb-1.5">Nationality</label>
              <input type="text" value={form.nationality} onChange={(e) => set("nationality", e.target.value)} className={inputClass} /></div>
            <div><label className="text-[10px] font-bold uppercase tracking-[0.15em] text-white/30 block mb-1.5">Budget</label>
              <input type="text" value={form.budgetRange} onChange={(e) => set("budgetRange", e.target.value)} className={inputClass} /></div>
          </div>
        </div>
        <div className="flex gap-3 mt-8">
          <button onClick={onClose} className="flex-1 py-3 rounded-xl bg-white/5 border border-white/10 text-white/70 font-bold text-sm">Cancel</button>
          <button onClick={() => onSave(form)} disabled={busy || !form.fullName || !form.mobile}
            className="flex-1 py-3 rounded-xl bg-indigo-500/20 border border-indigo-500/30 text-indigo-400 font-bold text-sm flex items-center justify-center gap-2 disabled:opacity-50">
            {busy ? <Loader2 size={14} className="animate-spin" /> : <Plus size={14} />} Add Lead</button>
        </div>
      </motion.div>
    </motion.div>
  );
}

function LeadDetailModal({ lead, onClose }) {
  if (!lead) return null;
  const fields = [
    { label: "Full Name", value: lead.fullName }, { label: "Phone", value: lead.mobile },
    { label: "Email", value: lead.email }, { label: "Company", value: lead.companyName },
    { label: "Campaign ID", value: lead.campaignId }, { label: "Agent ID", value: lead.agentId },
    { label: "Nationality", value: lead.nationality }, { label: "Budget", value: lead.budgetRange },
    { label: "Property Type", value: lead.propertyType }, { label: "Source", value: lead.source },
    { label: "Status", value: lead.status || "New" },
    { label: "Created At", value: lead.createdAt ? new Date(lead.createdAt).toLocaleString() : "—" },
  ];
  return (
    <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
      className="fixed inset-0 bg-black/70 backdrop-blur-sm z-[60] flex items-center justify-center p-4" onClick={onClose}>
      <motion.div initial={{ scale: 0.9 }} animate={{ scale: 1 }}
        className="w-full max-w-lg max-h-[80vh] overflow-y-auto rounded-2xl p-8" style={{ background: "#0d1424", border: "1px solid rgba(255,255,255,0.08)" }}
        onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center justify-between mb-6">
          <h3 className="text-lg font-black text-white">Lead Details</h3>
          <button onClick={onClose} className="p-2 text-white/40 hover:text-white"><X size={18} /></button>
        </div>
        <div className="space-y-3">
          {fields.map((f) => f.value ? (
            <div key={f.label} className="flex items-start gap-3 p-3 rounded-xl" style={{ background: "rgba(255,255,255,0.02)", border: "1px solid rgba(255,255,255,0.04)" }}>
              <div className="text-[10px] font-bold uppercase tracking-[0.15em] text-white/30 w-24 shrink-0 pt-0.5">{f.label}</div>
              <div className="text-sm text-white/80">{f.value}</div>
            </div>
          ) : null)}
        </div>
      </motion.div>
    </motion.div>
  );
}

export default function MasterLeadsPage() {
  const [leads, setLeads] = useState([]);
  const [companies, setCompanies] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [detailLead, setDetailLead] = useState(null);
  const [showCreate, setShowCreate] = useState(false);
  const [createBusy, setCreateBusy] = useState(false);
  const [deletingId, setDeletingId] = useState(null);
  const [toast, setToast] = useState(null);

  const [filterCompany, setFilterCompany] = useState("");
  const [filterCampaign, setFilterCampaign] = useState("");
  const [filterDateFrom, setFilterDateFrom] = useState("");
  const [filterDateTo, setFilterDateTo] = useState("");
  const [searchQuery, setSearchQuery] = useState("");

  const fetchData = useCallback(async () => {
    setLoading(true); setError(null);
    try {
      const params = new URLSearchParams();
      if (filterCompany) params.set("companyId", filterCompany);
      if (filterCampaign) params.set("campaignId", filterCampaign);
      if (filterDateFrom) params.set("dateFrom", filterDateFrom);
      if (filterDateTo) params.set("dateTo", filterDateTo);

      const [leadsRes, companiesRes] = await Promise.all([
        authFetch(`/api/platform/leads?${params.toString()}`),
        authFetch("/api/platform/companies"),
      ]);
      const leadsData = await parseFetchJson(leadsRes);
      const companiesData = await parseFetchJson(companiesRes);
      if (leadsData.success) setLeads(leadsData.data || []);
      else setError("Failed to load leads.");
      if (companiesData.success) setCompanies(companiesData.data?.companies || []);
    } catch (err) { setError(err?.message || "Network error."); }
    finally { setLoading(false); }
  }, [filterCompany, filterCampaign, filterDateFrom, filterDateTo]);

  useEffect(() => { fetchData(); }, [fetchData]);

  const filtered = useMemo(() => {
    if (!searchQuery.trim()) return leads;
    const q = searchQuery.trim().toLowerCase();
    return leads.filter((l) => [l.fullName, l.mobile, l.email, l.companyName].filter(Boolean).some((v) => String(v).toLowerCase().includes(q)));
  }, [leads, searchQuery]);

  const clearFilters = () => { setFilterCompany(""); setFilterCampaign(""); setFilterDateFrom(""); setFilterDateTo(""); setSearchQuery(""); };

  const handleCreateLead = async (form) => {
    setCreateBusy(true);
    try {
      const res = await authFetch("/api/platform/leads", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(form) });
      const data = await parseFetchJson(res);
      if (data.success) { setShowCreate(false); setToast({ message: "Lead created successfully", type: "success" }); await fetchData(); }
      else setToast({ message: data.error || "Failed to create lead", type: "error" });
    } catch (err) { setToast({ message: err?.message || "Network error", type: "error" }); }
    finally { setCreateBusy(false); }
  };

  const handleDeleteLead = async (leadId) => {
    setDeletingId(leadId);
    try {
      const res = await authFetch(`/api/platform/leads?id=${leadId}`, { method: "DELETE" });
      const data = await parseFetchJson(res);
      if (data.success) { setToast({ message: "Lead deleted", type: "success" }); await fetchData(); }
      else setToast({ message: data.error || "Failed to delete", type: "error" });
    } catch (err) { setToast({ message: err?.message || "Network error", type: "error" }); }
    finally { setDeletingId(null); }
  };

  const exportCsv = () => {
    const esc = (v) => v ? `"${String(v).replace(/"/g, '""')}"` : '""';
    const headers = ["Full Name","Phone","Email","Company","Campaign","Status","Created At"];
    const rows = filtered.map((l) => [l.fullName, l.mobile, l.email, l.companyName, l.campaignId, l.status || "New", l.createdAt ? new Date(l.createdAt).toLocaleString() : ""].map(esc).join(","));
    const csv = [headers.join(","), ...rows].join("\r\n");
    const blob = new Blob([csv], { type: "text/csv" });
    const url = URL.createObjectURL(blob); const a = document.createElement("a"); a.href = url; a.download = "leads_export.csv"; a.click(); URL.revokeObjectURL(url);
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-black tracking-tight text-white">Leads</h1>
          <p className="text-sm mt-1 text-white/40">{loading ? "Loading…" : `${filtered.length} lead${filtered.length !== 1 ? "s" : ""} total`}</p>
        </div>
        <div className="flex items-center gap-2">
          <button onClick={() => setShowCreate(true)}
            className="inline-flex items-center gap-2 px-4 py-2 rounded-xl text-[11px] font-bold uppercase tracking-widest bg-indigo-500/10 border border-indigo-500/20 text-indigo-400 hover:bg-indigo-500/20 transition-all">
            <Plus size={14} /> Add Lead</button>
          <button onClick={exportCsv} disabled={!filtered.length}
            className="inline-flex items-center gap-2 px-4 py-2 rounded-xl text-[11px] font-bold uppercase tracking-widest bg-white/5 border border-white/10 text-white/70 hover:text-white disabled:opacity-30 transition-all">
            <Download size={14} /> Export</button>
          <button onClick={fetchData} className="p-2.5 rounded-xl bg-white/5 border border-white/10 text-white/60 hover:text-white transition-colors"><RefreshCw size={16} /></button>
        </div>
      </div>

      {error && <div className="rounded-2xl bg-red-500/10 border border-red-500/20 p-4 text-red-400 text-xs font-bold">{error}</div>}

      {/* Filters */}
      <div className="rounded-2xl p-4" style={{ background: "rgba(255,255,255,0.02)", border: "1px solid rgba(255,255,255,0.06)" }}>
        <div className="flex items-center gap-2 mb-3"><Filter size={14} className="text-white/30" /><span className="text-[10px] font-bold uppercase tracking-[0.15em] text-white/30">Filters</span></div>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-3">
          <select value={filterCompany} onChange={(e) => setFilterCompany(e.target.value)}
            className="pl-3 pr-8 py-2 rounded-xl text-xs bg-white/5 border border-white/10 text-white/80 focus:outline-none focus:ring-2 focus:ring-indigo-500/40 appearance-none">
            <option value="">All Companies</option>
            {companies.map((c) => <option key={c.companyId} value={c.companyId}>{c.companyName || c.companyId}</option>)}
          </select>
          <input type="text" placeholder="Campaign ID" value={filterCampaign} onChange={(e) => setFilterCampaign(e.target.value)}
            className="pl-3 pr-4 py-2 rounded-xl text-xs bg-white/5 border border-white/10 text-white placeholder:text-white/20 focus:outline-none focus:ring-2 focus:ring-indigo-500/40" />
          <input type="date" value={filterDateFrom} onChange={(e) => setFilterDateFrom(e.target.value)}
            className="pl-3 pr-4 py-2 rounded-xl text-xs bg-white/5 border border-white/10 text-white focus:outline-none focus:ring-2 focus:ring-indigo-500/40" />
          <input type="date" value={filterDateTo} onChange={(e) => setFilterDateTo(e.target.value)}
            className="pl-3 pr-4 py-2 rounded-xl text-xs bg-white/5 border border-white/10 text-white focus:outline-none focus:ring-2 focus:ring-indigo-500/40" />
          <button onClick={clearFilters} className="px-4 py-2 rounded-xl text-xs font-bold bg-white/5 border border-white/10 text-white/50 hover:text-white transition-all">Clear</button>
        </div>
      </div>

      <div className="relative"><Search size={14} className="absolute left-4 top-1/2 -translate-y-1/2 text-white/30" />
        <input type="text" value={searchQuery} onChange={(e) => setSearchQuery(e.target.value)} placeholder="Search leads…"
          className="w-full pl-10 pr-4 py-2.5 rounded-xl text-sm bg-white/5 border border-white/10 text-white placeholder:text-white/20 focus:outline-none focus:ring-2 focus:ring-indigo-500/40" /></div>

      {/* Table */}
      <div className="rounded-2xl overflow-hidden bg-white/[0.02] border border-white/5">
        <div className="hidden lg:grid grid-cols-12 gap-2 px-6 py-3 text-[10px] font-bold uppercase tracking-[0.12em] text-white/20 bg-white/[0.01]">
          <div className="col-span-2">Name</div><div className="col-span-2">Phone</div><div className="col-span-2">Email</div>
          <div className="col-span-2">Company</div><div className="col-span-1">Status</div><div className="col-span-1">Created</div><div className="col-span-2 text-right">Actions</div></div>

        {loading ? (<div className="py-20 flex items-center justify-center"><Loader2 className="animate-spin text-indigo-500" size={28} /></div>
        ) : filtered.length === 0 ? (
          <div className="py-20 flex flex-col items-center justify-center gap-3 text-white/30">
            <Megaphone size={36} className="opacity-20" />
            <p className="text-xs font-bold uppercase tracking-widest">No leads found</p>
            <p className="text-xs text-white/20">Click "Add Lead" to create one</p>
          </div>
        ) : (filtered.slice(0, 100).map((l, i) => (
          <motion.div key={l._id} initial={{ opacity: 0, y: 4 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: Math.min(i * 0.02, 0.5) }}
            className="grid grid-cols-1 lg:grid-cols-12 gap-2 px-6 py-3.5 items-center hover:bg-white/[0.02] transition-colors border-b border-white/[0.03]">
            <div className="col-span-2 text-sm font-semibold text-white truncate">{l.fullName || "—"}</div>
            <div className="col-span-2 text-xs text-white/50 truncate flex items-center gap-1.5"><Phone size={10} className="shrink-0 text-white/25" />{l.mobile || "—"}</div>
            <div className="col-span-2 text-xs text-white/50 truncate flex items-center gap-1.5"><Mail size={10} className="shrink-0 text-white/25" />{l.email || "—"}</div>
            <div className="col-span-2 text-xs text-white/50 truncate flex items-center gap-1.5"><Building2 size={10} className="shrink-0 text-white/25" />{l.companyName || "—"}</div>
            <div className="col-span-1"><span className="px-2 py-0.5 rounded text-[9px] font-bold uppercase tracking-widest bg-white/5 border border-white/10 text-white/50">{l.status || "New"}</span></div>
            <div className="col-span-1 text-[10px] text-white/30">{l.createdAt ? new Date(l.createdAt).toLocaleDateString() : "—"}</div>
            <div className="col-span-2 flex items-center justify-end gap-1.5">
              <button onClick={() => setDetailLead(l)} className="p-1.5 rounded-lg bg-white/5 border border-white/10 text-white/50 hover:text-white transition-all"><Eye size={12} /></button>
              <button onClick={() => handleDeleteLead(l._id)} disabled={deletingId === l._id}
                className="p-1.5 rounded-lg bg-red-500/10 border border-red-500/20 text-red-400 hover:bg-red-500/20 transition-all disabled:opacity-50">
                {deletingId === l._id ? <Loader2 size={12} className="animate-spin" /> : <Trash2 size={12} />}</button>
            </div>
          </motion.div>
        )))}
      </div>

      <AnimatePresence>
        {showCreate && <CreateLeadModal key="create-modal" companies={companies} onSave={handleCreateLead} onClose={() => setShowCreate(false)} busy={createBusy} />}
        {detailLead && <LeadDetailModal key="detail-modal" lead={detailLead} onClose={() => setDetailLead(null)} />}
        {toast && <Toast key="toast" {...toast} onClose={() => setToast(null)} />}
      </AnimatePresence>
    </div>
  );
}
