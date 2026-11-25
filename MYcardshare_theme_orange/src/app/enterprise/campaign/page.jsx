"use client";
import { useEffect, useState, useMemo, useCallback } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { MailPlus, Search, Loader2, RefreshCw, Eye, X, Calendar, Plus, CheckCircle, AlertCircle, Trash2, MapPin, DollarSign, Pencil } from "lucide-react";
import { authFetch, parseFetchJson } from "@/lib/api";
import CampaignEdit from "@/components/Compaign/Compaignedit";

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

function CreateCampaignModal({ onSave, onClose, busy }) {
  const [form, setForm] = useState({ name: "", description: "", area: "", budget: "", startDate: "", endDate: "" });
  const [dateError, setDateError] = useState("");
  const set = (k, v) => {
    const next = { ...form, [k]: v };
    setForm(next);
    if (k === "startDate" || k === "endDate") {
      if (next.startDate && next.endDate && new Date(next.endDate) < new Date(next.startDate)) {
        setDateError("End date cannot be earlier than start date.");
      } else {
        setDateError("");
      }
    }
  };
  const inputClass = "w-full px-4 py-3 rounded-xl text-sm bg-slate-50 border border-slate-200 text-slate-800 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-[#D4642C]/30 focus:border-[#D4642C] transition-all";

  return (
    <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
      className="fixed inset-0 bg-black/40 backdrop-blur-sm z-[60] flex items-center justify-center p-4" onClick={onClose}>
      <motion.div initial={{ scale: 0.95, opacity: 0 }} animate={{ scale: 1, opacity: 1 }}
        className="w-full max-w-lg max-h-[90vh] overflow-y-auto rounded-3xl p-6 sm:p-8 bg-white border border-slate-200 shadow-2xl"
        onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center justify-between mb-8">
          <h3 className="text-xl font-black text-slate-800">Create Campaign</h3>
          <button onClick={onClose} className="p-2 text-slate-400 hover:bg-slate-100 hover:text-slate-800 rounded-xl transition-colors"><X size={20} /></button>
        </div>
        <div className="space-y-5">
          <div><label className="text-[10px] font-black uppercase tracking-widest text-slate-500 block mb-2">Campaign Name *</label>
            <input type="text" value={form.name} onChange={(e) => set("name", e.target.value)} placeholder="e.g. Summer Launch" className={inputClass} /></div>
          <div><label className="text-[10px] font-black uppercase tracking-widest text-slate-500 block mb-2">Description</label>
            <textarea value={form.description} onChange={(e) => set("description", e.target.value)} rows={2} placeholder="What is this campaign about?" className={inputClass} /></div>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-5">
            <div><label className="text-[10px] font-black uppercase tracking-widest text-slate-500 block mb-2">Area / Emirate</label>
              <input type="text" value={form.area} onChange={(e) => set("area", e.target.value)} placeholder="Dubai" className={inputClass} /></div>
            <div><label className="text-[10px] font-black uppercase tracking-widest text-slate-500 block mb-2">Budget (AED)</label>
              <input type="text" value={form.budget} onChange={(e) => set("budget", e.target.value)} placeholder="50000" className={inputClass} /></div>
          </div>
          <div className="grid grid-cols-2 gap-5">
            <div><label className="text-[10px] font-black uppercase tracking-widest text-slate-500 block mb-2">Start Date</label>
              <input type="date" value={form.startDate} onChange={(e) => set("startDate", e.target.value)} className={inputClass} /></div>
            <div><label className="text-[10px] font-black uppercase tracking-widest text-slate-500 block mb-2">End Date</label>
              <input type="date" value={form.endDate} onChange={(e) => set("endDate", e.target.value)} className={inputClass} /></div>
          </div>
          {dateError && (
            <div className="flex items-center gap-2 p-3 rounded-xl bg-red-50 border border-red-200 text-red-600 text-xs font-bold">
              <AlertCircle size={14} /> {dateError}
            </div>
          )}
        </div>
        <div className="flex gap-3 mt-10">
          <button onClick={onClose} className="flex-1 py-4 rounded-2xl bg-white border border-slate-200 text-slate-500 font-black text-xs uppercase tracking-widest hover:bg-slate-50 hover:text-slate-800 transition-all shadow-sm">Cancel</button>
          <button onClick={() => { if (dateError) { alert(dateError); return; } onSave(form); }} disabled={busy || !form.name || !!dateError}
            className="flex-[2] py-4 rounded-2xl bg-[#D4642C] hover:bg-[#BD5523] text-white font-black text-xs uppercase tracking-widest shadow-lg shadow-[#D4642C]/20 hover:shadow-[#D4642C]/40 transition-all flex items-center justify-center gap-2 disabled:opacity-50">
            {busy ? <Loader2 size={16} className="animate-spin" /> : <Plus size={16} />} Create Campaign</button>
        </div>
      </motion.div>
    </motion.div>
  );
}

export default function EnterpriseCampaignPage() {
  const [campaigns, setCampaigns] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState("");
  const [showCreate, setShowCreate] = useState(false);
  const [createBusy, setCreateBusy] = useState(false);
  const [deletingId, setDeletingId] = useState(null);
  const [statusFilter, setStatusFilter] = useState("all");
  const [editCampaign, setEditCampaign] = useState(null);
  const [toast, setToast] = useState(null);

  const fetchData = useCallback(async () => {
    setLoading(true);
    try {
      const res = await authFetch("/api/campaigns");
      const data = await parseFetchJson(res);
      if (data.success) setCampaigns(data.data || []);
    } catch (_) {}
    finally { setLoading(false); }
  }, []);

  useEffect(() => { fetchData(); }, [fetchData]);

  const filtered = useMemo(() => {
    let list = campaigns;
    if (statusFilter === "active") list = list.filter((c) => c.isActive === true);
    else if (statusFilter === "inactive") list = list.filter((c) => c.isActive === false);
    if (searchQuery.trim()) {
      const q = searchQuery.trim().toLowerCase();
      list = list.filter((c) => [c.name, c.area, c.description].filter(Boolean).some((v) => String(v).toLowerCase().includes(q)));
    }
    return list;
  }, [campaigns, searchQuery, statusFilter]);

  const handleCreate = async (form) => {
    setCreateBusy(true);
    try {
      const res = await authFetch("/api/campaigns", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(form) });
      const data = await parseFetchJson(res);
      if (data.success) { setShowCreate(false); setToast({ message: "Campaign created!", type: "success" }); await fetchData(); }
      else setToast({ message: data.error || "Failed", type: "error" });
    } catch (err) { setToast({ message: err?.message || "Network error", type: "error" }); }
    finally { setCreateBusy(false); }
  };

  const handleDelete = async (campaignId) => {
    if (!confirm("Are you sure you want to delete this campaign?")) return;
    setDeletingId(campaignId);
    try {
      const res = await authFetch(`/api/campaigns/${campaignId}`, { method: "DELETE" });
      const data = await parseFetchJson(res);
      if (data.success) { setToast({ message: "Campaign deleted", type: "success" }); await fetchData(); }
      else setToast({ message: data.error || "Failed", type: "error" });
    } catch (err) { setToast({ message: err?.message || "Network error", type: "error" }); }
    finally { setDeletingId(null); }
  };

  const toggleStatus = async (campaignId, currentStatus) => {
    try {
      const res = await authFetch(`/api/campaigns?id=${campaignId}`, {
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
    <div className="space-y-8 pb-20">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div><h1 className="text-2xl font-black tracking-tight text-slate-800 leading-tight">Campaigns</h1>
          <p className="text-sm mt-1 text-slate-500 leading-tight">{loading ? "Loading…" : `${filtered.length} campaign${filtered.length !== 1 ? "s" : ""} active`}</p></div>
        <div className="flex items-center gap-2">
          <button onClick={() => setShowCreate(true)}
            className="flex-1 sm:flex-none inline-flex items-center justify-center gap-2 px-5 py-2.5 rounded-xl bg-[#D4642C] hover:bg-[#BD5523] text-white font-black text-xs shadow-lg shadow-[#D4642C]/20 hover:shadow-[#D4642C]/40 transition-all uppercase tracking-widest">
            <Plus size={14} /> <span className="sm:inline">Create Campaign</span></button>
          <button onClick={fetchData} className="p-2.5 rounded-xl bg-white border border-slate-200 text-slate-500 hover:bg-slate-50 hover:text-slate-800 transition-colors shadow-sm"><RefreshCw size={16} /></button>
        </div>
      </div>

      <div className="flex flex-col md:flex-row gap-3">
        <div className="relative flex-1"><Search size={14} className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" />
          <input type="text" value={searchQuery} onChange={(e) => setSearchQuery(e.target.value)} placeholder="Search campaigns…"
            className="w-full pl-11 pr-4 py-3 sm:py-3.5 rounded-xl text-xs sm:text-sm bg-white border border-slate-200 text-slate-800 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-[#D4642C]/30 focus:border-[#D4642C] transition-all shadow-sm" /></div>
        <div className="flex gap-1 p-1 rounded-xl bg-slate-100 border border-slate-200 shrink-0">
          {["all", "active", "inactive"].map((s) => (
            <button key={s} onClick={() => setStatusFilter(s || "all")}
              className={`flex-1 sm:flex-none px-4 py-1.5 rounded-lg text-[9px] sm:text-[10px] font-black uppercase tracking-widest transition-all ${statusFilter === s ? "bg-white text-slate-800 shadow-sm" : "text-slate-500 hover:text-slate-800"}`}>
              {s}</button>
          ))}
        </div>
      </div>

      <div className="grid grid-cols-1 gap-4">
        {loading ? (
          <div className="py-20 flex items-center justify-center bg-white border border-slate-200 rounded-xl shadow-sm"><Loader2 className="animate-spin text-[#D4642C]" size={28} /></div>
        ) : filtered.length === 0 ? (
          <div className="py-32 flex flex-col items-center justify-center gap-4 bg-white border border-slate-200 rounded-xl shadow-sm text-slate-400">
            <MailPlus size={48} className="opacity-20 text-slate-400" /><p className="text-sm font-black uppercase tracking-widest">{searchQuery ? "No matches found" : "No campaigns created"}</p>
          </div>
        ) : (
          filtered.map((c, i) => (
            <motion.div key={c.id} initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: Math.min(i * 0.05, 0.5) }}
              className="group p-5 sm:p-6 rounded-3xl bg-white border border-slate-200 hover:border-[#FED7AA] transition-all relative overflow-hidden shadow-sm">
              {/* Card Decoration */}
              <div className="absolute top-0 right-0 w-32 h-32 bg-[#D4642C]/5 blur-3xl -mr-16 -mt-16 group-hover:bg-[#D4642C]/10 transition-colors" />
              
              <div className="flex flex-col sm:flex-row sm:items-start justify-between gap-6 relative">
                <div className="flex-1 min-w-0">
                  <h3 className="text-lg font-black text-slate-800 leading-tight mb-1 truncate group-hover:text-[#D4642C] transition-colors">{c.name || "Untitled Campaign"}</h3>
                  <p className="text-[10px] text-slate-500 font-black uppercase tracking-widest mb-4 truncate">{c.description || "No description provided"}</p>
                  
                  <div className="flex flex-wrap items-center gap-4 sm:gap-6">
                    <div className="flex items-center gap-2">
                      <MapPin size={12} className="text-[#D4642C]/60" />
                      <span className="text-[10px] font-black uppercase tracking-widest text-slate-600">{c.area || c.emirate || "Not Specified"}</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <Calendar size={12} className="text-[#D4642C]/60" />
                      <span className="text-[10px] font-black uppercase tracking-widest text-slate-500">
                        {c.startDate || "—"} <span className="opacity-20 mx-1">→</span> {c.endDate || "—"}
                      </span>
                    </div>
                  </div>
                </div>

                <div className="flex sm:flex-col items-center sm:items-end justify-between gap-4 shrink-0">
                  <div className="text-right">
                    <div className="text-xl font-black text-slate-800 leading-none font-mono tracking-tighter">{c.budget ? Number(c.budget).toLocaleString() : "0"}</div>
                    <div className="text-[8px] font-black uppercase tracking-[0.2em] text-slate-400 mt-1.5">Total Budget (AED)</div>
                  </div>
                  
                  <div className="flex items-center gap-2">
                    <span className={`px-2.5 py-1 rounded-lg text-[9px] font-black uppercase tracking-widest ${c.isActive ? "bg-emerald-50 border border-emerald-200 text-emerald-600" : "bg-slate-100 border border-slate-200 text-slate-500"}`}>
                      {c.isActive ? "Active" : "Inactive"}
                    </span>
                    <div className="flex items-center gap-2">
                      <button onClick={() => setEditCampaign(c)} title="Edit" className="p-2.5 rounded-xl bg-[#FFF7ED] border border-[#FED7AA] text-[#D4642C] hover:bg-[#FFEDD5] transition-all">
                        <Pencil size={16} />
                      </button>
                      <button onClick={() => toggleStatus(c.id, c.isActive)} title={c.isActive ? "Deactivate" : "Activate"} className={`p-2.5 rounded-xl border transition-all ${c.isActive ? "bg-amber-50 border-amber-200 text-amber-600 hover:bg-amber-100" : "bg-emerald-50 border-emerald-200 text-emerald-600 hover:bg-emerald-100"}`}>
                        {c.isActive ? <X size={16} /> : <CheckCircle size={16} />}
                      </button>
                      <button onClick={() => handleDelete(c.id)} disabled={deletingId === c.id} title="Delete" className="p-2.5 rounded-xl bg-red-50 border border-red-200 text-red-600 hover:bg-red-100 transition-all disabled:opacity-30">
                        {deletingId === c.id ? <Loader2 size={16} className="animate-spin" /> : <Trash2 size={16} />}
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </motion.div>
          ))
        )}
      </div>

      <AnimatePresence>
        {showCreate && <CreateCampaignModal key="create-modal" onSave={handleCreate} onClose={() => setShowCreate(false)} busy={createBusy} />}
        {editCampaign && <CampaignEdit isOpen={!!editCampaign} onClose={() => setEditCampaign(null)} campaign={editCampaign} onSuccess={() => { setToast({ message: "Campaign updated successfully", type: "success" }); fetchData(); }} />}
        {toast && <Toast key="toast" {...toast} onClose={() => setToast(null)} />}
      </AnimatePresence>
    </div>
  );
}
