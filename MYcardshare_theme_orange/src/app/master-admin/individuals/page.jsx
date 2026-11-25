"use client";
import { useEffect, useMemo, useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  UserCircle, Search, Loader2, AlertCircle, Trash2, X, CheckCircle,
  RefreshCw, Crown, Eye, Mail, Phone, ArrowUp, ArrowDown, ArrowUpDown, Users,
} from "lucide-react";
import { authFetch, parseFetchJson, toUserMessage } from "@/lib/api";

const STATUS_COLOR = {
  ACTIVE: { bg: "rgba(16,185,129,0.1)", border: "rgba(16,185,129,0.2)", text: "#059669" }, // emerald-600
  DRAFT: { bg: "rgba(245,158,11,0.1)", border: "rgba(245,158,11,0.2)", text: "#d97706" }, // amber-600
};

function Toast({ message, type, onClose }) {
  useEffect(() => { const t = setTimeout(onClose, 4000); return () => clearTimeout(t); }, [onClose]);
  const bg = type === "success" ? "#ecfdf5" : "#fef2f2";
  const border = type === "success" ? "#a7f3d0" : "#fecaca";
  const color = type === "success" ? "#059669" : "#dc2626";
  const Icon = type === "success" ? CheckCircle : AlertCircle;
  return (
    <motion.div initial={{ opacity: 0, y: 20, x: 20 }} animate={{ opacity: 1, y: 0, x: 0 }} exit={{ opacity: 0, y: 20 }}
      className="fixed bottom-6 right-6 z-[100] flex items-center gap-3 px-5 py-3.5 rounded-xl shadow-xl shadow-slate-200/50" style={{ background: bg, border: `1px solid ${border}` }}>
      <Icon size={16} style={{ color }} /><span className="text-sm font-bold tracking-tight" style={{ color }}>{message}</span>
      <button onClick={onClose} className="ml-2 opacity-50 hover:opacity-100 transition-opacity"><X size={14} style={{ color }} /></button>
    </motion.div>
  );
}

function DeleteModal({ user, onConfirm, onCancel, busy }) {
  return (
    <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
      className="fixed inset-0 bg-stone-900/40 backdrop-blur-sm z-[60] flex items-center justify-center p-4" onClick={onCancel}>
      <motion.div initial={{ scale: 0.9, opacity: 0 }} animate={{ scale: 1, opacity: 1 }} exit={{ scale: 0.9, opacity: 0 }}
        className="w-full max-w-md rounded-[2rem] p-8 bg-white shadow-2xl border border-[#EAE2DB]"
        onClick={(e) => e.stopPropagation()}>
        <div className="w-14 h-14 rounded-2xl mx-auto mb-6 flex items-center justify-center bg-red-50 border border-red-100 shadow-sm">
          <Trash2 size={24} className="text-red-500" /></div>
        <h3 className="text-xl font-black text-[#191919] tracking-tight text-center mb-3">Delete Individual</h3>
        <p className="text-sm text-[#77716C] text-center leading-relaxed mb-8">
          Are you sure you want to permanently delete <strong className="text-[#191919]">{user?.fullName || "this user"}</strong>?
          This will remove their account, card, and all related data. This action cannot be undone.
        </p>
        <div className="flex gap-3">
          <button onClick={onCancel} disabled={busy}
            className="flex-1 py-3.5 rounded-xl bg-white border border-[#EAE2DB] text-[#77716C] hover:text-[#191919] font-bold text-sm hover:bg-[#FAF6F2] shadow-sm transition-all disabled:opacity-50 cursor-pointer">Cancel</button>
          <button onClick={onConfirm} disabled={busy}
            className="flex-1 py-3.5 rounded-xl bg-red-500 text-white shadow-lg shadow-red-500/20 font-bold text-sm hover:bg-red-600 transition-all flex items-center justify-center gap-2 disabled:opacity-50 cursor-pointer">
            {busy ? <Loader2 size={14} className="animate-spin" /> : <Trash2 size={14} />} Delete
          </button>
        </div>
      </motion.div>
    </motion.div>
  );
}

function SortableHeader({ label, field, sortField, sortOrder, onSort, className }) {
  const isActive = sortField === field;
  return (
    <button onClick={() => onSort(field)}
      className={`flex items-center gap-1.5 group cursor-pointer select-none hover:text-[#191919] transition-colors ${className || ""}`}>
      <span>{label}</span>
      {isActive ? (
        sortOrder === "asc" ? <ArrowUp size={12} className="text-[#D4622C]" /> : <ArrowDown size={12} className="text-[#D4622C]" />
      ) : (
        <ArrowUpDown size={12} className="opacity-0 group-hover:opacity-100 transition-opacity text-[#77716C]" />
      )}
    </button>
  );
}

function UserAvatar({ user }) {
  const [error, setError] = useState(false);
  return (
    <div className="w-10 h-10 rounded-xl bg-[#FAF6F2] border border-[#EAE2DB] shadow-sm flex items-center justify-center shrink-0 overflow-hidden font-black text-[#D4622C] text-sm">
      {user.avatarUrl && !error ? (
        <img src={user.avatarUrl} alt={user.fullName} onError={() => setError(true)} className="w-full h-full object-cover" />
      ) : (
        user.fullName?.[0] || "?"
      )}
    </div>
  );
}

const formatDate = (val) => {
  if (!val) return "\u2014";
  const d = new Date(val);
  if (isNaN(d)) return "\u2014";
  return d.toLocaleDateString("en-GB", { day: "2-digit", month: "short", year: "numeric" });
};

export default function MasterIndividualsPage() {
  const [individuals, setIndividuals] = useState([]);
  const [query, setQuery] = useState("");
  const [filter, setFilter] = useState("all");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [deleteTarget, setDeleteTarget] = useState(null);
  const [deleteBusy, setDeleteBusy] = useState(false);
  const [toast, setToast] = useState(null);
  const [sortField, setSortField] = useState(null);
  const [sortOrder, setSortOrder] = useState("asc");

  const fetchData = async () => {
    setLoading(true); setError(null);
    try {
      const res = await authFetch("/api/platform/individuals");
      const data = await parseFetchJson(res);
      if (data.success) setIndividuals(data.data?.individuals || []);
      else setError(toUserMessage(data.error, "Failed to load individuals."));
    } catch (err) { setError(err?.message || "Network error."); } finally { setLoading(false); }
  };

  useEffect(() => { fetchData(); }, []);

  const handleSort = (field) => {
    if (sortField === field) {
      setSortOrder(sortOrder === "asc" ? "desc" : "asc");
    } else {
      setSortField(field);
      setSortOrder("asc");
    }
  };

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    let list = individuals;

    if (filter === "active") list = list.filter((u) => u.profileStatus === "ACTIVE");
    else if (filter === "draft") list = list.filter((u) => u.profileStatus === "DRAFT");

    if (q) {
      list = list.filter((u) =>
        [u.fullName, u.email, u.username, u.phone].filter(Boolean).some((x) => String(x).toLowerCase().includes(q))
      );
    }

    if (sortField) {
      list = [...list].sort((a, b) => {
        const aVal = a[sortField];
        const bVal = b[sortField];
        if (!aVal && !bVal) return 0;
        if (!aVal) return 1;
        if (!bVal) return -1;
        if (sortField === "createdAt") {
          const diff = new Date(aVal) - new Date(bVal);
          return sortOrder === "asc" ? diff : -diff;
        }
        const diff = String(aVal).localeCompare(String(bVal));
        return sortOrder === "asc" ? diff : -diff;
      });
    }

    return list;
  }, [individuals, query, filter, sortField, sortOrder]);

  const confirmDelete = async () => {
    if (!deleteTarget) return;
    setDeleteBusy(true);
    try {
      const res = await authFetch(`/api/platform/individuals/${deleteTarget.userId}`, { method: "DELETE" });
      const data = await parseFetchJson(res);
      if (data.success) {
        setToast({ message: "Individual deleted successfully", type: "success" });
        setDeleteTarget(null);
        await fetchData();
      } else {
        setToast({ message: toUserMessage(data.error, "Failed to delete."), type: "error" });
      }
    } catch (err) {
      setToast({ message: err?.message || "Network error.", type: "error" });
    } finally { setDeleteBusy(false); }
  };

  return (
    <div className="space-y-6 sm:space-y-8 pb-12 max-w-[1400px]">
      <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 mb-1.5"><Crown size={14} className="text-[#D4622C]" />
            <span className="text-[10px] font-black uppercase tracking-[0.2em] text-[#D4622C]">Platform Registry</span></div>
          <h1 className="text-2xl sm:text-3xl font-black tracking-tight text-[#191919]">All Individuals</h1>
          <p className="text-xs sm:text-sm mt-1 text-[#77716C] font-medium">{loading ? "Loading…" : `${individuals.length} standalone user${individuals.length !== 1 ? "s" : ""} registered`}</p>
        </div>
        <button onClick={fetchData} className="p-2.5 rounded-xl bg-white border border-[#EAE2DB] shadow-2xs text-[#77716C] hover:text-[#D4622C] hover:bg-[#FCE9DF]/50 hover:border-[#D4622C]/30 transition-all w-fit cursor-pointer"><RefreshCw size={16} /></button>
      </div>

      {error && (<div className="flex items-start gap-3 rounded-2xl bg-rose-50 border border-rose-200 shadow-2xs p-4 text-rose-600">
        <AlertCircle size={18} className="mt-0.5 shrink-0" /><p className="text-xs font-bold uppercase tracking-widest leading-relaxed">{error}</p></div>)}

      <div className="flex flex-col sm:flex-row gap-3 sm:gap-4">
        <div className="relative flex-1"><Search size={16} className="absolute left-4 top-1/2 -translate-y-1/2 text-[#77716C]" />
          <input type="text" value={query} onChange={(e) => setQuery(e.target.value)} placeholder="Search by name, email, username…"
            className="w-full pl-11 pr-4 py-3 rounded-2xl text-sm bg-white border border-[#EAE2DB] shadow-2xs text-[#191919] placeholder:text-[#77716C]/60 focus:outline-none focus:border-[#D4622C] focus:ring-2 focus:ring-[#D4622C]/20 transition-all" /></div>
        <div className="flex gap-1 p-1 rounded-2xl bg-white border border-[#EAE2DB] shadow-2xs shrink-0">
          {["all", "active", "draft"].map((s) => (
            <button key={s} onClick={() => setFilter(s)}
              className={`flex-1 sm:flex-none px-5 py-2 rounded-xl text-[10px] font-black uppercase tracking-[0.15em] transition-all cursor-pointer ${filter === s ? "bg-[#FCE9DF] text-[#D4622C] shadow-2xs border border-[#F3C5AF]" : "text-[#77716C] hover:text-[#191919]"}`}>
              {s}
            </button>
          ))}
        </div>
      </div>

      <div className="rounded-[2rem] overflow-hidden bg-white border border-[#EAE2DB] shadow-sm">
        {/* Desktop Header */}
        <div className="hidden md:grid gap-3 px-6 py-4 text-[10px] font-black uppercase tracking-[0.2em] text-[#77716C] bg-[#FAF6F2] border-b border-[#EAE2DB]"
          style={{ gridTemplateColumns: "3fr 3fr 2fr 2fr 2fr 1.5fr 2fr" }}>
          <div>Name</div>
          <div>Email</div>
          <div>Username</div>
          <div>Phone</div>
          <SortableHeader label="Created" field="createdAt" sortField={sortField} sortOrder={sortOrder} onSort={handleSort} />
          <div>Status</div>
          <div className="text-right">Actions</div>
        </div>

        {loading ? (
          <div className="py-24 flex items-center justify-center"><Loader2 className="animate-spin text-[#D4622C]" size={32} /></div>
        ) : filtered.length === 0 ? (
          <div className="py-24 flex flex-col items-center justify-center gap-3 text-[#77716C]">
            <Users size={40} className="text-[#EAE2DB]" />
            <p className="text-[11px] font-bold uppercase tracking-[0.2em]">{individuals.length === 0 ? "No individuals found" : "No matches"}</p>
          </div>
        ) : (
          filtered.map((u, i) => {
            const sc = STATUS_COLOR[u.profileStatus] || STATUS_COLOR.DRAFT;
            return (
              <motion.div key={u.userId} initial={{ opacity: 0, y: 6 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.02 }}
                className="flex flex-col md:grid md:items-center hover:bg-[#FAF6F2]/60 transition-colors border-b border-[#EAE2DB]/60 px-4 sm:px-6 py-5 md:py-4 gap-4 md:gap-3 group"
                style={{ gridTemplateColumns: "3fr 3fr 2fr 2fr 2fr 1.5fr 2fr" }}>

                {/* Name + Avatar */}
                <div className="flex items-center gap-4 min-w-0">
                  <UserAvatar user={u} />
                  <div className="min-w-0">
                    <div className="text-sm font-black tracking-tight text-[#191919] truncate group-hover:text-[#D4622C] transition-colors">{u.fullName}</div>
                    <div className="text-[9px] md:text-[10px] font-medium text-[#77716C] font-mono truncate md:hidden">{u.email}</div>
                  </div>
                  {/* Mobile status */}
                  <div className="md:hidden ml-auto">
                    <span className="px-2 py-0.5 rounded text-[8px] font-black uppercase tracking-widest shadow-sm"
                      style={{ background: sc.bg, border: `1px solid ${sc.border}`, color: sc.text }}>{u.profileStatus}</span>
                  </div>
                </div>

                {/* Email - desktop */}
                <div className="hidden md:flex items-center gap-2 min-w-0">
                  <Mail size={12} className="text-[#77716C] shrink-0" />
                  <span className="text-[11px] font-semibold text-[#77716C] truncate">{u.email}</span>
                </div>

                {/* Username */}
                <div className="hidden md:block min-w-0">
                  <span className="text-[11px] font-semibold text-[#77716C] truncate block">{u.username || "\u2014"}</span>
                </div>

                {/* Phone */}
                <div className="hidden md:flex items-center gap-2 min-w-0">
                  {u.phone ? (
                    <><Phone size={12} className="text-[#77716C] shrink-0" /><span className="text-[11px] font-semibold text-[#77716C] truncate">{u.phone}</span></>
                  ) : (
                    <span className="text-[11px] text-[#77716C]">&mdash;</span>
                  )}
                </div>

                {/* Mobile info grid */}
                <div className="grid grid-cols-3 md:contents gap-2">
                  <div className="md:hidden min-w-0">
                    <div className="text-[8px] font-black uppercase tracking-[0.15em] text-[#77716C] mb-1">Username</div>
                    <div className="text-[10px] font-medium text-[#77716C] truncate">{u.username || "\u2014"}</div>
                  </div>
                  <div className="md:hidden min-w-0">
                    <div className="text-[8px] font-black uppercase tracking-[0.15em] text-[#77716C] mb-1">Phone</div>
                    <div className="text-[10px] font-medium text-[#77716C] truncate">{u.phone || "\u2014"}</div>
                  </div>
                  <div className="min-w-0">
                    <div className="text-[8px] font-black uppercase tracking-[0.15em] text-[#77716C] md:hidden mb-1">Created</div>
                    <div className="text-[10px] md:text-xs font-medium text-[#77716C]">{formatDate(u.createdAt)}</div>
                  </div>
                </div>

                {/* Desktop Status */}
                <div className="hidden md:block">
                  <span className="px-2.5 py-1 rounded-lg text-[9px] font-black uppercase tracking-[0.15em] shadow-sm"
                    style={{ background: sc.bg, border: `1px solid ${sc.border}`, color: sc.text }}>{u.profileStatus}</span>
                </div>

                {/* Actions */}
                <div className="flex items-center justify-start md:justify-end gap-2 mt-1 md:mt-0 pt-3 md:pt-0 border-t border-[#EAE2DB]/60 md:border-t-0">
                  {u.cardSlug && u.profileStatus === "ACTIVE" && (
                    <button onClick={() => window.open(`/card/${u.cardSlug}`, "_blank")}
                      className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-[10px] font-black uppercase tracking-[0.15em] bg-[#FCE9DF] border border-[#F3C5AF] text-[#D4622C] hover:bg-[#D4622C] hover:text-white shadow-sm transition-all cursor-pointer" title="View Card">
                      <Eye size={12} /> View
                    </button>
                  )}
                  <button onClick={() => setDeleteTarget(u)}
                    className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-[10px] font-black uppercase tracking-widest bg-red-50 border border-red-100 text-red-500 hover:bg-red-100 shadow-sm transition-all cursor-pointer" title="Delete">
                    <Trash2 size={12} />
                  </button>
                </div>
              </motion.div>
            );
          })
        )}
      </div>

      <AnimatePresence>
        {deleteTarget && <DeleteModal user={deleteTarget} onConfirm={confirmDelete} onCancel={() => !deleteBusy && setDeleteTarget(null)} busy={deleteBusy} />}
        {toast && <Toast {...toast} onClose={() => setToast(null)} />}
      </AnimatePresence>
    </div>
  );
}
