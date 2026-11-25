"use client";
import { useEffect, useState, useMemo, useCallback } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { MailPlus, Search, Loader2, RefreshCw, Eye, X, Building2, Calendar, Image, Plus, CheckCircle, AlertCircle, Upload, Trash2 } from "lucide-react";
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

function CreateCampaignModal({ companies, onSave, onClose, busy }) {
  const [form, setForm] = useState({ name: "", description: "", companyId: "", area: "", budget: "", startDate: "", endDate: "" });
  const [imagePreview, setImagePreview] = useState(null);
  const [imageFile, setImageFile] = useState(null);
  const set = (k, v) => setForm({ ...form, [k]: v });
  const inputClass = "w-full px-4 py-2.5 rounded-xl text-sm bg-white/5 border border-white/10 text-white placeholder:text-white/20 focus:outline-none focus:ring-2 focus:ring-indigo-500/40";

  const handleImage = (e) => {
    const file = e.target.files?.[0];
    if (file) { setImageFile(file); setImagePreview(URL.createObjectURL(file)); }
  };

  return (
    <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
      className="fixed inset-0 bg-black/70 backdrop-blur-sm z-[60] flex items-center justify-center p-4" onClick={onClose}>
      <motion.div initial={{ scale: 0.9 }} animate={{ scale: 1 }}
        className="w-full max-w-lg max-h-[85vh] overflow-y-auto rounded-2xl p-8" style={{ background: "#0d1424", border: "1px solid rgba(255,255,255,0.08)" }}
        onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center justify-between mb-6">
          <h3 className="text-lg font-black text-white">Create Campaign</h3>
          <button onClick={onClose} className="p-2 text-white/40 hover:text-white"><X size={18} /></button>
        </div>
        <div className="space-y-4">
          <div><label className="text-[10px] font-bold uppercase tracking-[0.15em] text-white/30 block mb-1.5">Campaign Name *</label>
            <input type="text" value={form.name} onChange={(e) => set("name", e.target.value)} placeholder="e.g. Dubai Marina Launch" className={inputClass} /></div>
          <div><label className="text-[10px] font-bold uppercase tracking-[0.15em] text-white/30 block mb-1.5">Company *</label>
            <select value={form.companyId} onChange={(e) => set("companyId", e.target.value)} className={`${inputClass} appearance-none`}>
              <option value="">Select company</option>
              {companies.map((c) => <option key={c.companyId} value={c.companyId}>{c.companyName || c.companyId}</option>)}
            </select></div>
          <div><label className="text-[10px] font-bold uppercase tracking-[0.15em] text-white/30 block mb-1.5">Description</label>
            <textarea value={form.description} onChange={(e) => set("description", e.target.value)} rows={2} placeholder="Campaign description…" className={inputClass} /></div>
          <div className="grid grid-cols-2 gap-4">
            <div><label className="text-[10px] font-bold uppercase tracking-[0.15em] text-white/30 block mb-1.5">Area / Emirate</label>
              <input type="text" value={form.area} onChange={(e) => set("area", e.target.value)} placeholder="Dubai" className={inputClass} /></div>
            <div><label className="text-[10px] font-bold uppercase tracking-[0.15em] text-white/30 block mb-1.5">Budget</label>
              <input type="text" value={form.budget} onChange={(e) => set("budget", e.target.value)} placeholder="50000" className={inputClass} /></div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div><label className="text-[10px] font-bold uppercase tracking-[0.15em] text-white/30 block mb-1.5">Start Date</label>
              <input type="date" value={form.startDate} onChange={(e) => set("startDate", e.target.value)} className={inputClass} /></div>
            <div><label className="text-[10px] font-bold uppercase tracking-[0.15em] text-white/30 block mb-1.5">End Date</label>
              <input type="date" value={form.endDate} onChange={(e) => set("endDate", e.target.value)} className={inputClass} /></div>
          </div>
          <div>
            <label className="text-[10px] font-bold uppercase tracking-[0.15em] text-white/30 block mb-1.5">Campaign Image (optional)</label>
            <div className="flex items-center gap-4">
              {imagePreview ? (
                <div className="w-20 h-20 rounded-xl overflow-hidden border border-white/10">
                  <img src={imagePreview} alt="Preview" className="w-full h-full object-cover" /></div>
              ) : (
                <div className="w-20 h-20 rounded-xl flex items-center justify-center" style={{ background: "rgba(255,255,255,0.03)", border: "1px solid rgba(255,255,255,0.08)" }}>
                  <Upload size={20} className="text-white/20" /></div>
              )}
              <label className="px-4 py-2 rounded-xl text-xs font-bold bg-white/5 border border-white/10 text-white/60 hover:text-white transition-all cursor-pointer">
                Choose Image <input type="file" accept=".jpg,.jpeg,.png,.webp" onChange={handleImage} className="hidden" /></label>
            </div>
          </div>
        </div>
        <div className="flex gap-3 mt-8">
          <button onClick={onClose} className="flex-1 py-3 rounded-xl bg-white/5 border border-white/10 text-white/70 font-bold text-sm">Cancel</button>
          <button onClick={() => onSave(form, imageFile)} disabled={busy || !form.name || !form.companyId}
            className="flex-1 py-3 rounded-xl bg-indigo-500/20 border border-indigo-500/30 text-indigo-400 font-bold text-sm flex items-center justify-center gap-2 disabled:opacity-50">
            {busy ? <Loader2 size={14} className="animate-spin" /> : <Plus size={14} />} Create</button>
        </div>
      </motion.div>
    </motion.div>
  );
}

function CampaignDetailModal({ campaign, onClose }) {
  if (!campaign) return null;
  return (
    <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
      className="fixed inset-0 bg-black/70 backdrop-blur-sm z-[60] flex items-center justify-center p-4" onClick={onClose}>
      <motion.div initial={{ scale: 0.9 }} animate={{ scale: 1 }}
        className="w-full max-w-lg max-h-[80vh] overflow-y-auto rounded-2xl p-8" style={{ background: "#0d1424", border: "1px solid rgba(255,255,255,0.08)" }}
        onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center justify-between mb-6">
          <h3 className="text-lg font-black text-white">Campaign Details</h3>
          <button onClick={onClose} className="p-2 text-white/40 hover:text-white"><X size={18} /></button>
        </div>
        {campaign.imageUrl && (
          <div className="rounded-xl overflow-hidden mb-6 border border-white/10"><img src={campaign.imageUrl} alt={campaign.name} className="w-full h-48 object-cover" /></div>
        )}
        <div className="space-y-3">
          {[{ label: "Name", value: campaign.name }, { label: "Company", value: campaign.companyName }, { label: "Description", value: campaign.description },
            { label: "Area", value: campaign.area }, { label: "Budget", value: campaign.budget }, { label: "Start Date", value: campaign.startDate },
            { label: "End Date", value: campaign.endDate }, { label: "Status", value: campaign.isActive ? "Active" : "Inactive" },
            { label: "Created", value: campaign.createdAt ? new Date(campaign.createdAt).toLocaleString() : "—" },
          ].map((f) => f.value ? (
            <div key={f.label} className="flex items-start gap-3 p-3 rounded-xl" style={{ background: "rgba(255,255,255,0.02)", border: "1px solid rgba(255,255,255,0.04)" }}>
              <div className="text-[10px] font-bold uppercase tracking-[0.15em] text-white/30 w-24 shrink-0 pt-0.5">{f.label}</div>
              <div className="text-sm text-white/80">{String(f.value)}</div>
            </div>
          ) : null)}
        </div>
      </motion.div>
    </motion.div>
  );
}

export default function MasterCampaignPage() {
  const [campaigns, setCampaigns] = useState([]);
  const [companies, setCompanies] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [searchQuery, setSearchQuery] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");
  const [detailCampaign, setDetailCampaign] = useState(null);
  const [showCreate, setShowCreate] = useState(false);
  const [createBusy, setCreateBusy] = useState(false);
  const [deletingId, setDeletingId] = useState(null);
  const [toast, setToast] = useState(null);

  const fetchData = useCallback(async () => {
    setLoading(true); setError(null);
    try {
      const [campRes, compRes] = await Promise.all([
        authFetch("/api/platform/campaigns"),
        authFetch("/api/platform/companies"),
      ]);
      const campData = await parseFetchJson(campRes);
      const compData = await parseFetchJson(compRes);
      if (campData.success) setCampaigns(campData.data || []);
      else setError("Failed to load campaigns.");
      if (compData.success) setCompanies(compData.data?.companies || []);
    } catch (err) { setError(err?.message || "Network error."); }
    finally { setLoading(false); }
  }, []);

  useEffect(() => { fetchData(); }, [fetchData]);

  const filtered = useMemo(() => {
    let list = campaigns;
    if (statusFilter === "active") list = list.filter((c) => c.isActive === true);
    else if (statusFilter === "inactive") list = list.filter((c) => c.isActive === false);
    if (searchQuery.trim()) {
      const q = searchQuery.trim().toLowerCase();
      list = list.filter((c) => [c.name, c.companyName, c.area, c.description].filter(Boolean).some((v) => String(v).toLowerCase().includes(q)));
    }
    return list;
  }, [campaigns, searchQuery, statusFilter]);

  const handleCreateCampaign = async (form) => {
    setCreateBusy(true);
    try {
      const res = await authFetch("/api/campaigns", {
        method: "POST", headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ ...form, companyId: form.companyId }),
      });
      const data = await parseFetchJson(res);
      if (data.success) { setShowCreate(false); setToast({ message: "Campaign created successfully", type: "success" }); await fetchData(); }
      else setToast({ message: data.error || "Failed to create campaign", type: "error" });
    } catch (err) { setToast({ message: err?.message || "Network error", type: "error" }); }
    finally { setCreateBusy(false); }
  };

  const handleDeleteCampaign = async (campaignId, companyId) => {
    if (!confirm("Are you sure you want to delete this campaign?")) return;
    setDeletingId(campaignId);
    try {
      const res = await authFetch(`/api/campaigns?id=${campaignId}&companyId=${companyId}`, { method: "DELETE" });
      const data = await parseFetchJson(res);
      if (data.success) { setToast({ message: "Campaign deleted", type: "success" }); await fetchData(); }
      else setToast({ message: data.error || "Failed", type: "error" });
    } catch (err) { setToast({ message: err?.message || "Network error", type: "error" }); }
    finally { setDeletingId(null); }
  };

  const toggleStatus = async (campaignId, companyId, currentStatus) => {
    try {
      const res = await authFetch(`/api/campaigns?id=${campaignId}&companyId=${companyId}`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ isActive: !currentStatus }),
      });
      const data = await parseFetchJson(res);
      if (data.success) { setToast({ message: `Campaign ${!currentStatus ? "activated" : "deactivated"}`, type: "success" }); await fetchData(); }
      else setToast({ message: data.error || "Failed", type: "error" });
    } catch (err) { setToast({ message: err?.message || "Network error", type: "error" }); }
  };

  return (
    <div className="space-y-6 sm:space-y-8">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-xl sm:text-2xl font-black tracking-tight text-white">Campaigns</h1>
          <p className="text-xs sm:text-sm mt-1 text-white/40">{loading ? "Loading…" : `${filtered.length} campaign${filtered.length !== 1 ? "s" : ""} across all enterprises`}</p>
        </div>
        <div className="flex items-center gap-2">
          <button onClick={() => setShowCreate(true)}
            className="inline-flex items-center gap-2 px-4 py-2 rounded-xl text-[11px] font-bold uppercase tracking-widest bg-indigo-500/10 border border-indigo-500/20 text-indigo-400 hover:bg-indigo-500/20 transition-all">
            <Plus size={14} /> Create Campaign</button>
          <button onClick={fetchData} className="p-2.5 rounded-xl bg-white/5 border border-white/10 text-white/60 hover:text-white transition-colors"><RefreshCw size={16} /></button>
        </div>
      </div>

      {error && <div className="rounded-2xl bg-red-500/10 border border-red-500/20 p-4 text-red-400 text-xs font-bold">{error}</div>}

      <div className="flex flex-col sm:flex-row gap-3">
        <div className="relative flex-1"><Search size={14} className="absolute left-4 top-1/2 -translate-y-1/2 text-white/30" />
          <input type="text" value={searchQuery} onChange={(e) => setSearchQuery(e.target.value)} placeholder="Search campaigns…"
            className="w-full pl-10 pr-4 py-2.5 rounded-xl text-sm bg-white/5 border border-white/10 text-white placeholder:text-white/20 focus:outline-none focus:ring-2 focus:ring-indigo-500/40" /></div>
        <div className="flex gap-1 p-1 rounded-xl bg-white/5 border border-white/10">
          {["all", "active", "inactive"].map((s) => (
            <button key={s} onClick={() => setStatusFilter(s)}
              className={`px-4 py-1.5 rounded-lg text-[11px] font-bold uppercase tracking-widest transition-all ${statusFilter === s ? "bg-white/10 text-white" : "text-white/40 hover:text-white/60"}`}>
              {s}</button>
          ))}
        </div>
      </div>

      <div className="rounded-2xl overflow-hidden bg-white/[0.02] border border-white/5">
        <div className="hidden lg:grid grid-cols-12 gap-2 px-6 py-3 text-[10px] font-bold uppercase tracking-[0.12em] text-white/20 bg-white/[0.01]">
          <div className="col-span-1"></div><div className="col-span-3">Campaign</div><div className="col-span-2">Company</div>
          <div className="col-span-2">Area</div><div className="col-span-1">Status</div><div className="col-span-2">Dates</div><div className="col-span-1 text-right">View</div></div>

        {loading ? (<div className="py-20 flex items-center justify-center"><Loader2 className="animate-spin text-indigo-500" size={28} /></div>
        ) : filtered.length === 0 ? (
          <div className="py-20 flex flex-col items-center justify-center gap-3 text-white/30">
            <MailPlus size={36} className="opacity-20" /><p className="text-xs font-bold uppercase tracking-widest">No campaigns found</p>
            <p className="text-xs text-white/20">Click "Create Campaign" to add one</p></div>
        ) : (filtered.map((c, i) => (
          <motion.div key={`${c.companyId}-${c.id}`} initial={{ opacity: 0, y: 4 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: Math.min(i * 0.02, 0.5) }}
            className="flex flex-col lg:grid lg:grid-cols-12 gap-4 lg:gap-2 px-4 sm:px-6 py-5 lg:py-3.5 items-start lg:items-center hover:bg-white/[0.02] transition-colors border-b border-white/[0.03]">
            
            {/* Mobile Header: Image + Name + Status */}
            <div className="flex items-start gap-3 w-full lg:contents">
              <div className="lg:col-span-1">
                {c.imageUrl ? (
                  <div className="w-10 h-10 rounded-lg overflow-hidden border border-white/10 shrink-0">
                    <img src={c.imageUrl} alt="" className="w-full h-full object-cover" />
                  </div>
                ) : (
                  <div className="w-10 h-10 rounded-lg flex items-center justify-center bg-white/5 border border-white/10 shrink-0">
                    <Image size={14} className="text-white/20" />
                  </div>
                )}
              </div>
              
              <div className="flex-1 lg:col-span-3 min-w-0">
                <div className="flex items-start justify-between lg:block gap-2">
                  <div className="min-w-0">
                    <div className="text-sm font-bold text-white truncate">{c.name || "Untitled"}</div>
                    <div className="lg:hidden text-xs text-white/50 truncate flex items-center gap-1.5 mt-0.5">
                      <Building2 size={10} className="text-white/20" />{c.companyName}
                    </div>
                  </div>
                  <div className="lg:hidden">
                    <span className={`px-2 py-0.5 rounded text-[8px] font-black uppercase tracking-widest ${c.isActive ? "bg-emerald-500/10 border border-emerald-500/20 text-emerald-400" : "bg-white/5 border border-white/10 text-white/40"}`}>
                      {c.isActive ? "Active" : "Inactive"}
                    </span>
                  </div>
                </div>
                {c.description && <div className="hidden lg:block text-[10px] text-white/30 truncate">{c.description}</div>}
              </div>
            </div>

            {/* Desktop Company & Area */}
            <div className="hidden lg:block lg:col-span-2 text-xs text-white/50 truncate flex items-center gap-1.5">
              <Building2 size={10} className="shrink-0 text-white/25" />{c.companyName}
            </div>
            
            {/* Mobile Stats / Desktop Area */}
            <div className="grid grid-cols-2 lg:contents gap-4 w-full">
              <div className="lg:col-span-2 min-w-0">
                <div className="text-[8px] font-bold uppercase tracking-widest text-white/20 lg:hidden mb-1">Location</div>
                <div className="text-xs text-white/60 truncate">{c.area || "—"}</div>
              </div>
              <div className="lg:col-span-2 min-w-0">
                <div className="text-[8px] font-bold uppercase tracking-widest text-white/20 lg:hidden mb-1">Timeline</div>
                <div className="text-[10px] lg:text-[10px] text-white/30 flex items-center gap-1.5">
                  <Calendar size={10} className="hidden lg:block" />
                  {c.startDate || "—"} <span className="text-white/10">→</span> {c.endDate || "—"}
                </div>
              </div>
            </div>

            {/* Desktop Status */}
            <div className="hidden lg:block lg:col-span-1">
              <span className={`px-2 py-0.5 rounded text-[9px] font-bold uppercase tracking-widest ${c.isActive ? "bg-emerald-500/10 border border-emerald-500/20 text-emerald-400" : "bg-white/5 border border-white/10 text-white/40"}`}>
                {c.isActive ? "Active" : "Inactive"}
              </span>
            </div>

            {/* Actions */}
            <div className="flex items-center justify-start lg:justify-end gap-2 w-full lg:w-auto lg:col-span-1 pt-3 lg:pt-0 border-t border-white/5 lg:border-t-0">
              <button onClick={() => setDetailCampaign(c)} className="p-1.5 rounded-lg bg-white/5 border border-white/10 text-white/50 hover:text-white transition-all" title="View Details"><Eye size={12} /></button>
              <button onClick={() => toggleStatus(c.id, c.companyId, c.isActive)} className={`p-1.5 rounded-lg border transition-all ${c.isActive ? "bg-amber-500/10 border-amber-500/20 text-amber-400 hover:bg-amber-500/20" : "bg-emerald-500/10 border-emerald-500/20 text-emerald-400 hover:bg-emerald-500/20"}`} title={c.isActive ? "Deactivate" : "Activate"}>
                {c.isActive ? <X size={12} /> : <CheckCircle size={12} />}
              </button>
              <button onClick={() => handleDeleteCampaign(c.id, c.companyId)} disabled={deletingId === c.id}
                className="p-1.5 rounded-lg bg-red-500/10 border border-red-500/20 text-red-400 hover:bg-red-500/20 transition-all disabled:opacity-30" title="Delete">
                {deletingId === c.id ? <Loader2 size={12} className="animate-spin" /> : <Trash2 size={12} />}
              </button>
            </div>
          </motion.div>
        )))}
      </div>

      <AnimatePresence>
        {showCreate && <CreateCampaignModal key="create-modal" companies={companies} onSave={handleCreateCampaign} onClose={() => setShowCreate(false)} busy={createBusy} />}
        {detailCampaign && <CampaignDetailModal key="detail-modal" campaign={detailCampaign} onClose={() => setDetailCampaign(null)} />}
        {toast && <Toast key="toast" {...toast} onClose={() => setToast(null)} />}
      </AnimatePresence>
    </div>
  );
}
