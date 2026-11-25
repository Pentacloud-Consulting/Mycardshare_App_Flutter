"use client";
import { useState, useEffect, useMemo, useCallback } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Megaphone, Search, Filter, Download, Plus, RefreshCw, Trash2, Mail, Phone, MapPin, Loader2, CheckCircle, AlertCircle, X, User, Pencil, Eye } from "lucide-react";
import { authFetch, parseFetchJson, toUserMessage } from "@/lib/api";
import LeadForm from "@/components/leads/LeadForm";
import ViewLeads from "@/components/leads/ViewLeads";

function Toast({ message, type, onClose }) {
  useEffect(() => { const t = setTimeout(onClose, 4000); return () => clearTimeout(t); }, [onClose]);
  const color = type === "success" ? "#10d9a8" : "#ef4444";
  return (
    <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: 20 }}
      className="fixed bottom-6 right-6 z-[100] flex items-center gap-3 px-5 py-3.5 rounded-xl shadow-2xl"
      style={{ background: `${color}15`, border: `1px solid ${color}30` }}>
      {type === "success" ? <CheckCircle size={16} style={{ color }} /> : <AlertCircle size={16} style={{ color }} />}
      <span className="text-sm font-semibold" style={{ color }}>{message}</span>
    </motion.div>
  );
}



export default function EnterpriseLeadsPage() {
  const [leads, setLeads] = useState([]);
  const [loading, setLoading] = useState(true);
  const [query, setQuery] = useState("");
  const [busyId, setBusyId] = useState(null);
  const [showModal, setShowModal] = useState(false);
  const [editLead, setEditLead] = useState(null);
  const [selectedLead, setSelectedLead] = useState(null);
  const [toast, setToast] = useState(null);

  const fetchData = useCallback(async () => {
    setLoading(true);
    try {
      const res = await authFetch("/api/enterprise/leads");
      const data = await parseFetchJson(res);
      if (data.success) setLeads(data.data || []);
    } catch (_) {} finally { setLoading(false); }
  }, []);

  useEffect(() => { fetchData(); }, [fetchData]);

  const deleteLead = async (id) => {
    if (!confirm("Are you sure you want to delete this lead?")) return;
    setBusyId(id);
    try {
      const res = await authFetch(`/api/enterprise/leads?id=${id}`, { method: "DELETE" });
      const data = await parseFetchJson(res);
      if (data.success) { setLeads(leads.filter(l => l._id !== id)); setToast({ message: "Lead removed", type: "success" }); }
      else setToast({ message: data.error, type: "error" });
    } catch (_) {} finally { setBusyId(null); }
  };

  const filtered = useMemo(() => {
    if (!query.trim()) return leads;
    const q = query.toLowerCase();
    return leads.filter(l => [l.fullName, l.mobile, l.email, l.status].some(v => String(v).toLowerCase().includes(q)));
  }, [leads, query]);

  const exportCsv = () => {
    const headers = ["Name", "Mobile", "Email", "Nationality", "Budget", "Property", "Source", "Date"];
    const rows = filtered.map(l => [l.fullName, l.mobile, l.email, l.nationality, l.budgetRange, l.propertyType, l.source, new Date(l.createdAt).toLocaleDateString()]);
    const csvContent = [headers, ...rows].map(e => e.join(",")).join("\n");
    const blob = new Blob([csvContent], { type: "text/csv" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a"); a.href = url; a.download = "enterprise_leads.csv"; a.click();
  };

  return (
    <div className="space-y-8 pb-20">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-black tracking-tight text-slate-800">Lead Center</h1>
          <p className="text-sm mt-1 text-slate-500 leading-tight">{loading ? "Synchronizing database..." : `${leads.length} leads in your pipeline`}</p>
        </div>
        <div className="flex items-center gap-2">
          <button onClick={() => setShowModal(true)} className="flex-1 sm:flex-none inline-flex items-center justify-center gap-2 px-5 py-2.5 rounded-xl bg-[#D4642C] hover:bg-[#BD5523] text-white font-bold text-sm shadow-lg shadow-[#D4642C]/20 hover:shadow-[#D4642C]/40 transition-all"><Plus size={16} /> <span className="sm:inline">Manual Entry</span></button>
          <button onClick={exportCsv} disabled={!filtered.length} className="p-2.5 rounded-xl bg-white border border-slate-200 text-slate-500 hover:text-slate-800 hover:bg-slate-50 transition-all disabled:opacity-20 shadow-sm"><Download size={18} /></button>
          <button onClick={fetchData} className="p-2.5 rounded-xl bg-white border border-slate-200 text-slate-500 hover:text-slate-800 hover:bg-slate-50 transition-all shadow-sm"><RefreshCw size={18} /></button>
        </div>
      </div>

      <div className="relative">
        <Search size={14} className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" />
        <input type="text" value={query} onChange={(e) => setQuery(e.target.value)} placeholder="Search by name, phone or email..."
          className="w-full pl-11 pr-4 py-2.5 sm:py-3.5 rounded-xl text-xs sm:text-sm bg-white border border-slate-200 text-slate-800 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-[#D4642C]/30 focus:border-[#D4642C] shadow-sm" />
      </div>

      <div className="rounded-xl overflow-hidden bg-white border border-slate-200 shadow-sm">
        <div className="hidden lg:grid grid-cols-12 gap-4 px-8 py-4 text-[10px] font-black uppercase tracking-[0.2em] text-slate-400 bg-slate-50 border-b border-slate-200">
          <div className="col-span-3">Contact</div>
          <div className="col-span-3">Information</div>
          <div className="col-span-2 text-center">Status</div>
          <div className="col-span-2 text-center">Captured</div>
          <div className="col-span-2 text-right">Actions</div>
        </div>

        {loading ? (
          <div className="py-20 flex flex-col items-center justify-center gap-4 text-slate-400">
            <Loader2 className="animate-spin text-[#D4642C]" size={28} />
            <p className="text-[10px] font-bold uppercase tracking-widest">Accessing Vault</p>
          </div>
        ) : filtered.length === 0 ? (
          <div className="py-20 flex flex-col items-center justify-center gap-4 text-slate-400">
            <Megaphone size={40} className="opacity-20" />
            <p className="text-xs font-bold uppercase tracking-[0.2em]">No leads found</p>
          </div>
        ) : (
          <div className="divide-y divide-slate-200">
            {filtered.map((l) => (
              <div key={l._id} className="grid grid-cols-1 lg:grid-cols-12 gap-3 sm:gap-4 px-5 sm:px-8 py-4 sm:py-5 items-center hover:bg-slate-50 transition-colors group relative">
                <div className="col-span-3 flex items-center gap-3 sm:gap-4">
                  <div className="w-9 h-9 sm:w-10 sm:h-10 rounded-lg sm:rounded-xl bg-slate-100 flex items-center justify-center text-slate-400 shrink-0 border border-slate-200"><User size={16} /></div>
                  <div className="min-w-0 pr-12 lg:pr-0">
                    <h3 className="text-sm font-bold text-slate-800 truncate">{l.fullName}</h3>
                    <p className="text-[10px] text-slate-500 truncate uppercase tracking-wider">{l.source || "organic"}</p>
                  </div>
                </div>
                <div className="col-span-3 flex lg:flex-col gap-4 lg:gap-1">
                  <div className="flex items-center gap-2 text-[11px] sm:text-xs text-slate-600"><Phone size={12} className="opacity-60" />{l.mobile}</div>
                  {l.email && <div className="flex items-center gap-2 text-[11px] sm:text-xs text-slate-500"><Mail size={12} className="opacity-60" />{l.email}</div>}
                </div>
                <div className="col-span-2 flex justify-start lg:justify-center">
                  <span className="px-2 py-0.5 rounded-md sm:rounded-lg bg-emerald-50 border border-emerald-200 text-emerald-600 text-[8px] sm:text-[10px] font-black uppercase tracking-widest">{l.status || "New"}</span>
                </div>
                <div className="col-span-2 text-left lg:text-center text-[10px] sm:text-[11px] text-slate-500 font-bold uppercase">
                  {new Date(l.createdAt).toLocaleDateString()}
                </div>
                <div className="absolute right-5 top-1/2 -translate-y-1/2 lg:static lg:translate-y-0 lg:col-span-2 lg:text-right flex items-center justify-end gap-2">
                  <button onClick={() => setSelectedLead(l)} className="p-2 sm:p-2.5 rounded-lg sm:rounded-xl bg-[#FFF7ED] border border-[#FED7AA] text-[#D4642C] hover:bg-[#FFEDD5] transition-all">
                    <Eye size={12} />
                  </button>
                  <button onClick={() => setEditLead(l)} className="p-2 sm:p-2.5 rounded-lg sm:rounded-xl bg-[#FFF7ED] border border-[#FED7AA] text-[#D4642C] hover:bg-[#FFEDD5] transition-all">
                    <Pencil size={12} />
                  </button>
                  <button onClick={() => deleteLead(l._id)} disabled={busyId === l._id} className="p-2 sm:p-2.5 rounded-lg sm:rounded-xl bg-red-500/10 border border-red-500/20 text-red-400 hover:bg-red-500/20 transition-all disabled:opacity-30">
                    {busyId === l._id ? <Loader2 size={12} className="animate-spin" /> : <Trash2 size={12} />}
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      <ViewLeads 
        isOpen={!!selectedLead} 
        onClose={() => setSelectedLead(null)} 
        lead={selectedLead} 
      />

      <AnimatePresence>
        {(showModal || editLead) && (
          <LeadForm
            isOpen={showModal || !!editLead}
            onClose={() => {
              setShowModal(false);
              setEditLead(null);
            }}
            onLeadCreated={() => {
              setToast({ message: editLead ? "Lead updated successfully" : "Lead created successfully", type: "success" });
              fetchData();
            }}
            editLead={editLead}
            apiUrl={editLead ? `/api/enterprise/leads?id=${editLead._id}` : "/api/enterprise/leads"}
            apiMethod={editLead ? "PATCH" : "POST"}
          />
        )}
        {toast && <Toast key="toast" {...toast} onClose={() => setToast(null)} />}
      </AnimatePresence>
    </div>
  );
}
