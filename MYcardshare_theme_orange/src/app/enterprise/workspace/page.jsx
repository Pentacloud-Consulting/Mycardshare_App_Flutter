"use client";
import { useState, useEffect, useMemo, useCallback } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Users, Search, RefreshCw, Eye, UserPlus, Filter, Loader2, CheckCircle, AlertCircle, X, Shield, Mail, Briefcase, Trash2 } from "lucide-react";
import { authFetch, parseFetchJson } from "@/lib/api";

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

function InviteMemberModal({ onClose, onSuccess }) {
  const [busy, setBusy] = useState(false);
  const [email, setEmail] = useState("");

  const submit = async (e) => {
    e.preventDefault();
    if (!email) return;
    setBusy(true);
    try {
      const res = await authFetch("/api/enterprise/workspace/invite", { 
        method: "POST", headers: { "Content-Type": "application/json" }, 
        body: JSON.stringify({ email }) 
      });
      const data = await parseFetchJson(res);
      if (data.success) { onSuccess(); onClose(); }
      else alert(data.error);
    } catch (_) {} finally { setBusy(false); }
  };

  return (
    <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="fixed inset-0 bg-black/40 backdrop-blur-sm z-[60] flex items-center justify-center p-4">
      <motion.div initial={{ scale: 0.9, opacity: 0 }} animate={{ scale: 1, opacity: 1 }} className="w-full max-w-md rounded-3xl p-8 bg-white border border-slate-200 shadow-2xl">
        <div className="flex justify-between items-center mb-8">
          <h2 className="text-xl font-black text-slate-800">Invite Member</h2>
          <button onClick={onClose} className="p-2 hover:bg-slate-100 rounded-xl transition-all text-slate-400"><X size={20} /></button>
        </div>
        <form onSubmit={submit} className="space-y-4">
          <div><label className="text-[10px] font-bold uppercase tracking-widest text-slate-500 mb-1.5 block">Email Address *</label>
            <input required type="email" value={email} onChange={(e) => setEmail(e.target.value)} className="w-full px-4 py-3 rounded-xl text-sm bg-slate-50 border border-slate-200 text-slate-800 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-[#D4642C]/30 focus:border-[#D4642C]" placeholder="employee@company.com" /></div>
          <button disabled={busy} className="w-full py-4 rounded-2xl bg-[#D4642C] hover:bg-[#BD5523] text-white font-bold text-sm shadow-lg shadow-[#D4642C]/20 hover:shadow-[#D4642C]/40 transition-all flex items-center justify-center gap-2">
            {busy ? <Loader2 size={18} className="animate-spin" /> : <Mail size={18} />} Send Invitation
          </button>
        </form>
      </motion.div>
    </motion.div>
  );
}

function WorkspaceAvatar({ member }) {
  const [error, setError] = useState(false);

  return (
    <div className="w-10 h-10 rounded-xl bg-slate-100 border border-slate-200 flex items-center justify-center shrink-0 overflow-hidden font-black text-slate-400">
      {member.avatarUrl && !error ? (
        <img 
          src={member.avatarUrl} 
          alt={member.fullName} 
          onError={() => setError(true)}
          className="w-full h-full object-cover" 
        />
      ) : (
        member.fullName?.[0] || '?'
      )}
    </div>
  );
}

function MemberTable({ members, onView }) {
  return (
    <div className="w-full overflow-hidden rounded-xl bg-white border border-slate-200 shadow-sm">
      {/* Desktop View */}
      <div className="hidden lg:block overflow-x-auto">
        <table className="w-full text-left border-collapse min-w-[900px]">
          <thead>
            <tr className="border-b border-slate-200 bg-slate-50">
              <th className="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400">Employee</th>
              <th className="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400">Information</th>
              <th className="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400">Role</th>
              <th className="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Status</th>
              <th className="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Profile</th>
              <th className="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400 text-right">Actions</th>
            </tr>
          </thead>
          <tbody>
            {members.map((member) => (
              <tr key={member.userId || member._id} className="border-b border-slate-200 hover:bg-slate-50 transition-colors group">
                <td className="px-6 py-4">
                  <div className="flex items-center gap-3">
                    <WorkspaceAvatar member={member} />
                    <div>
                      <div className="font-bold text-sm text-slate-800 leading-none mb-1">{member.fullName}</div>
                      <div className="text-[10px] text-slate-500 uppercase tracking-widest">{member.jobTitle || 'N/A'}</div>
                    </div>
                  </div>
                </td>
                <td className="px-6 py-4">
                  <div className="flex items-center gap-2 text-xs text-slate-500"><Mail size={12} className="opacity-60" /> {member.email || member.workEmail || 'N/A'}</div>
                </td>
                <td className="px-6 py-4">
                  <div className="inline-flex items-center text-[10px] font-black text-slate-600 uppercase tracking-widest bg-slate-100 border border-slate-200 rounded-lg px-3 py-1.5">
                    {member.role || 'EMPLOYEE'}
                  </div>
                </td>
                <td className="px-6 py-4 text-center">
                  <div className="flex items-center justify-center gap-3">
                    <button onClick={() => onView({ ...member, action: 'updateStatus', newStatus: member.status !== 'inactive' ? 'inactive' : 'active' })}
                      className={`relative inline-flex h-4 w-8 items-center rounded-full transition-colors ${member.status !== 'inactive' ? 'bg-emerald-500' : 'bg-slate-200'}`}>
                      <span className={`inline-block h-2.5 w-2.5 transform rounded-full bg-white transition-transform ${member.status !== 'inactive' ? 'translate-x-5' : 'translate-x-0.5'}`} />
                    </button>
                    <span className="text-[9px] font-black uppercase tracking-widest text-slate-500">{member.status !== 'inactive' ? 'Active' : 'Inactive'}</span>
                  </div>
                </td>
                <td className="px-6 py-4 text-center">
                  <span className={`px-2 py-0.5 rounded-lg text-[9px] font-black uppercase tracking-widest ${member.cardStatus === "Published" ? "bg-amber-50 text-[#D4642C] border border-[#FED7AA]" : "bg-slate-100 text-slate-500 border border-slate-200"}`}>
                    {member.cardStatus === "Published" ? "Live" : "Draft"}
                  </span>
                </td>
                <td className="px-6 py-4 text-right">
                  <div className="flex items-center justify-end gap-2">
                    {member.cardStatus === "Published" && member.cardSlug && (
                      <button onClick={() => window.open(`/card/${member.cardSlug}`, '_blank')} className="p-2 rounded-lg bg-slate-50 hover:bg-[#FFF7ED] border border-slate-200 hover:border-[#FED7AA] text-slate-500 hover:text-[#D4642C] transition-all"><Eye size={14} /></button>
                    )}
                    <button onClick={() => onView({ ...member, action: 'delete' })} className="p-2 rounded-lg bg-red-500/10 hover:bg-red-500/20 text-red-400 transition-all border border-red-500/10"><Trash2 size={14} /></button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Mobile View */}
      <div className="lg:hidden divide-y divide-slate-200">
        {members.map((member) => (
          <div key={member.userId || member._id} className="p-5 space-y-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <WorkspaceAvatar member={member} />
                <div className="min-w-0">
                  <div className="font-bold text-sm text-slate-800 truncate leading-none mb-1">{member.fullName}</div>
                  <div className="text-[10px] text-slate-500 uppercase tracking-widest truncate">{member.jobTitle || 'N/A'}</div>
                </div>
              </div>
              <div className="flex items-center gap-2">
                <button onClick={() => onView({ ...member, action: 'delete' })} className="p-2 rounded-lg bg-red-500/10 text-red-400 border border-red-500/10"><Trash2 size={14} /></button>
              </div>
            </div>
            
            <div className="grid grid-cols-2 gap-4 pt-1">
              <div>
                <div className="text-[8px] font-black uppercase tracking-widest text-slate-400 mb-1.5">Role</div>
                <div className="w-full text-[10px] font-black text-slate-600 uppercase tracking-widest bg-slate-100 border border-slate-200 rounded-lg px-3 py-2">
                  {member.role || 'EMPLOYEE'}
                </div>
              </div>
              <div>
                <div className="text-[8px] font-black uppercase tracking-widest text-slate-400 mb-1.5">Status</div>
                <div className="flex items-center gap-3 h-9">
                  <button onClick={() => onView({ ...member, action: 'updateStatus', newStatus: member.status !== 'inactive' ? 'inactive' : 'active' })}
                    className={`relative inline-flex h-4 w-8 items-center rounded-full transition-colors ${member.status !== 'inactive' ? 'bg-emerald-500' : 'bg-slate-200'}`}>
                    <span className={`inline-block h-2.5 w-2.5 transform rounded-full bg-white transition-transform ${member.status !== 'inactive' ? 'translate-x-5' : 'translate-x-0.5'}`} />
                  </button>
                  <span className="text-[9px] font-black uppercase tracking-widest text-slate-500">{member.status !== 'inactive' ? 'Active' : 'Inactive'}</span>
                </div>
              </div>
            </div>

            <div className="flex items-center justify-between pt-2 border-t border-slate-200">
              <div className="flex items-center gap-2 text-[10px] text-slate-500 truncate pr-4">
                <Mail size={10} className="shrink-0" /> {member.email || member.workEmail || 'N/A'}
              </div>
              <div className="flex items-center gap-2 shrink-0">
                <span className={`px-2 py-0.5 rounded-lg text-[8px] font-black uppercase tracking-widest ${member.cardStatus === "Published" ? "bg-amber-50 text-[#D4642C] border border-[#FED7AA]" : "bg-slate-100 text-slate-500 border border-slate-200"}`}>
                  {member.cardStatus === "Published" ? "Live" : "Draft"}
                </span>
                {member.cardStatus === "Published" && member.cardSlug && (
                  <button onClick={() => window.open(`/card/${member.cardSlug}`, '_blank')} className="p-2 rounded-lg bg-slate-50 hover:bg-[#FFF7ED] border border-slate-200 hover:border-[#FED7AA] text-slate-500 hover:text-[#D4642C]"><Eye size={12} /></button>
                )}
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

export default function EnterpriseWorkspacePage() {
  const [members, setMembers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [query, setQuery] = useState("");
  const [filter, setFilter] = useState("all");
  const [showInviteModal, setShowInviteModal] = useState(false);
  const [toast, setToast] = useState(null);
  const fetchData = useCallback(async () => {
    setLoading(true);
    try {
      const res = await authFetch("/api/enterprise/workspace");
      const data = await parseFetchJson(res);
      if (data.success) setMembers(data.data || []);
    } catch (_) {}
    finally { setLoading(false); }
  }, []);

  useEffect(() => { fetchData(); }, [fetchData]);

  const filtered = useMemo(() => {
    let list = members;
    if (filter === "live") {
      list = list.filter(m => m.cardStatus === "Published");
    } else if (filter === "draft") {
      list = list.filter(m => m.cardStatus !== "Published");
    }
    if (query.trim()) {
      const q = query.toLowerCase();
      list = list.filter(m => [m.fullName, m.email, m.workEmail, m.jobTitle].some(v => String(v).toLowerCase().includes(q)));
    }
    return list;
  }, [members, query, filter]);

  const handleMemberAction = async (payload) => {
    if (payload.action === 'updateRole') {
      try {
        const res = await authFetch(`/api/enterprise/workspace/${payload.userId}`, {
          method: "PATCH",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ role: payload.newRole })
        });
        const data = await parseFetchJson(res);
        if (data.success) {
          setToast({ message: "Role updated successfully", type: "success" });
          fetchData();
        } else {
          setToast({ message: data.error, type: "error" });
        }
      } catch (e) {
        setToast({ message: "Network error", type: "error" });
      }
    } else if (payload.action === 'updateStatus') {
      try {
        const res = await authFetch(`/api/users/status`, {
          method: "PATCH",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ userId: payload.userId, status: payload.newStatus })
        });
        const data = await parseFetchJson(res);
        if (data.success) {
          setToast({ message: "Status updated successfully", type: "success" });
          fetchData();
        } else {
          setToast({ message: data.error, type: "error" });
        }
      } catch (e) {
        setToast({ message: "Network error", type: "error" });
      }
    } else if (payload.action === 'delete') {
      if (!confirm(`Are you sure you want to remove ${payload.fullName} from this workspace?`)) return;
      try {
        const res = await authFetch(`/api/enterprise/workspace/${payload.userId}`, {
          method: "DELETE"
        });
        const data = await parseFetchJson(res);
        if (data.success) {
          setToast({ message: "Employee removed successfully", type: "success" });
          fetchData();
        } else {
          setToast({ message: data.error, type: "error" });
        }
      } catch (e) {
        setToast({ message: "Network error", type: "error" });
      }
    }
  };

  return (
    <div className="space-y-8 pb-20">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-black tracking-tight text-slate-800">Workspace</h1>
          <p className="text-sm mt-1 text-slate-500 leading-tight">{loading ? "Loading directory..." : `${members.length} team member${members.length !== 1 ? "s" : ""} on cloud`}</p>
        </div>
        <div className="flex items-center gap-2">
          <button onClick={() => setShowInviteModal(true)} className="flex-1 sm:flex-none inline-flex items-center justify-center gap-2 px-5 py-2.5 rounded-xl bg-[#D4642C] hover:bg-[#BD5523] text-white font-bold text-xs shadow-lg shadow-[#D4642C]/20 hover:shadow-[#D4642C]/40 transition-all uppercase tracking-widest">
            <UserPlus size={14} /> <span className="sm:inline">Invite Member</span></button>
          <button onClick={fetchData} className="p-2.5 rounded-xl bg-white border border-slate-200 text-slate-500 hover:text-slate-800 hover:bg-slate-50 shadow-sm transition-colors"><RefreshCw size={16} /></button>
        </div>
      </div>

      <div className="flex flex-col md:flex-row gap-3 sm:gap-4">
        <div className="relative flex-1">
          <Search size={14} className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" />
          <input type="text" value={query} onChange={(e) => setQuery(e.target.value)} placeholder="Search team members..." 
            className="w-full pl-11 pr-4 py-2.5 sm:py-3 rounded-xl text-xs sm:text-sm bg-white border border-slate-200 text-slate-800 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-[#D4642C]/30 focus:border-[#D4642C] shadow-sm transition-all" />
        </div>
        <div className="flex gap-1 p-1 rounded-xl bg-slate-100 border border-slate-200 shrink-0">
          {["all", "live", "draft"].map((s) => (
            <button key={s} onClick={() => setFilter(s)}
              className={`flex-1 sm:flex-none px-4 py-1.5 rounded-lg text-[9px] sm:text-[10px] font-black uppercase tracking-widest transition-all ${filter === s ? "bg-white text-slate-800 shadow-sm" : "text-slate-500 hover:text-slate-800"}`}>
              {s}</button>
          ))}
        </div>
      </div>

      {loading ? (
        <div className="w-full h-64 rounded-xl bg-white border border-slate-200 shadow-sm animate-pulse" />
      ) : filtered.length === 0 ? (
        <div className="py-32 flex flex-col items-center justify-center gap-4 text-slate-400">
          <Users size={48} className="opacity-20" />
          <p className="text-sm font-bold uppercase tracking-[0.2em]">{query ? "No matches found" : "Your workspace is empty"}</p>
          <button onClick={() => setShowInviteModal(true)} className="text-[10px] font-bold uppercase tracking-widest text-[#D4642C] hover:text-[#BD5523]">Start by inviting employees</button>
        </div>
      ) : (
        <MemberTable members={filtered} onView={handleMemberAction} />
      )}

      <AnimatePresence>
        {showInviteModal && <InviteMemberModal onClose={() => setShowInviteModal(false)} onSuccess={() => { setToast({ message: "Invitation recorded", type: "success" }); fetchData(); }} />}
        {toast && <Toast key="toast" {...toast} onClose={() => setToast(null)} />}
      </AnimatePresence>
    </div>
  );
}
