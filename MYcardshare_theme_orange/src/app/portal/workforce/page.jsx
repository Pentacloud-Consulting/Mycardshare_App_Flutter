"use client";

import { useEffect, useMemo, useState } from "react";
import { motion } from "framer-motion";
import {
  Users,
  Plus,
  Search,
  Loader2,
  Mail,
  Crown,
  Eye,
  AlertCircle,
  Ticket,
  RefreshCw,
  Info,
  Building2,
} from "lucide-react";
import { useAuth } from "@/lib/auth-context";
import { authFetch, parseFetchJson, toUserMessage } from "@/lib/api";
import InviteEmployeeModal from "@/components/workforce/InviteEmployeeModal";

/* ═══════════════════════════════════════════════════════════
   WORKFORCE — Team Workforce directory for employees & admins
   ═══════════════════════════════════════════════════════════ */

export default function WorkforcePage() {
  const { userData, loading: authLoading } = useAuth();
  const [employees, setEmployees] = useState([]);
  const [companyInfo, setCompanyInfo] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [query, setQuery] = useState("");
  const [filterRole, setFilterRole] = useState("All");
  const [inviteOpen, setInviteOpen] = useState(false);

  const companyId = userData?.companyId || userData?.enterpriseUid;
  const isMaster = userData?.role === "super_admin" || userData?.role === "master-admin";
  const isEmployeeRole = userData?.role === "employee" || (!isMaster && userData?.role !== "enterprise");

  const fetchData = async () => {
    if (!companyId) {
      setLoading(false);
      setError("No organization linked to this account.");
      return;
    }
    setLoading(true);
    setError(null);
    try {
      const [empRes, coRes] = await Promise.all([
        authFetch(`/api/company/${companyId}/employees`),
        authFetch(`/api/company/${companyId}`).catch(() => null),
      ]);

      const empData = await parseFetchJson(empRes);
      if (empData.success) {
        setEmployees(empData.data?.employees || []);
      } else {
        setError(toUserMessage(empData.error, "Failed to load team directory."));
      }

      if (coRes) {
        try {
          const coData = await parseFetchJson(coRes);
          if (coData.success) {
            setCompanyInfo(coData.data?.company || coData.data || null);
          }
        } catch (_) {}
      }
    } catch (err) {
      setError(err?.message || "Network error loading workforce.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (!authLoading) fetchData();
  }, [authLoading, companyId]);

  const filtered = useMemo(() => {
    let list = employees;
    if (filterRole === "Admins") {
      list = list.filter((e) => (e.role || "").toLowerCase().includes("admin") || (e.jobTitle || "").toLowerCase().includes("admin"));
    }
    const q = query.trim().toLowerCase();
    if (!q) return list;
    return list.filter((e) =>
      [e.fullName, e.email, e.jobTitle, e.role]
        .filter(Boolean)
        .some((x) => String(x).toLowerCase().includes(q)),
    );
  }, [employees, query, filterRole]);

  if (authLoading) {
    return (
      <div className="min-h-[400px] flex items-center justify-center">
        <Loader2 className="animate-spin text-[#D4642C]" size={32} />
      </div>
    );
  }

  const organizationName = companyInfo?.companyName || userData?.companyName || "Organization";

  return (
    <div className="max-w-7xl mx-auto space-y-6 pb-12 font-sans">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="px-2.5 py-0.5 rounded-md text-[10px] font-black uppercase tracking-widest bg-[#FFF7ED] text-[#D4642C] border border-[#FED7AA]">
              {isMaster ? "Master Admin" : isEmployeeRole ? "EMPLOYEE" : "ENTERPRISE"}
            </span>
          </div>
          <h1 className="text-2xl sm:text-3xl font-black tracking-tight text-slate-800 leading-none">
            Team Workforce
          </h1>
          <p className="text-xs sm:text-sm mt-1.5 text-slate-500 font-medium">
            {organizationName} · {loading ? "Syncing..." : `${employees.length} team member${employees.length !== 1 ? "s" : ""}`}
          </p>
        </div>

        <div className="flex gap-2 sm:gap-3 items-center">
          <button
            onClick={fetchData}
            className="p-2.5 rounded-xl bg-white border border-slate-200 text-slate-500 hover:text-slate-800 hover:bg-slate-50 transition-colors shadow-sm"
            title="Refresh"
          >
            <RefreshCw size={16} />
          </button>

          {!isEmployeeRole && (
            <>
              {companyInfo?.voucherCode && (
                <button
                  onClick={() => setInviteOpen(true)}
                  className="hidden sm:flex items-center gap-2 px-4 py-2.5 rounded-xl bg-[#FFF7ED] border border-[#FED7AA] hover:bg-[#FFEDD5] transition-colors"
                  title="Share voucher"
                >
                  <Ticket size={14} className="text-[#D4642C]" />
                  <span className="text-[10px] font-black uppercase tracking-[0.2em] text-[#D4642C]">
                    Voucher
                  </span>
                  <span className="font-mono text-sm font-black text-slate-800 tracking-widest">
                    {companyInfo.voucherCode}
                  </span>
                </button>
              )}
              <button
                onClick={() => setInviteOpen(true)}
                className="inline-flex items-center gap-2 px-5 py-2.5 rounded-xl bg-[#D4642C] hover:bg-[#BD5523] text-white font-bold text-xs uppercase tracking-widest shadow-md shadow-[#D4642C]/20 hover:shadow-[#D4642C]/40 transition-all"
              >
                <Plus size={14} /> Invite Member
              </button>
            </>
          )}
        </div>
      </div>

      {error && (
        <div className="flex items-start gap-3 rounded-2xl bg-amber-50 border border-amber-200 p-4 text-amber-800 text-xs font-bold">
          <AlertCircle size={18} className="mt-0.5 shrink-0 text-amber-600" />
          <p>{error}</p>
        </div>
      )}

      {/* Search & Filters */}
      <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-3">
        <div className="relative flex-1">
          <Search size={14} className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" />
          <input
            type="text"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Search teammates..."
            className="w-full pl-11 pr-4 py-3 rounded-xl text-xs sm:text-sm bg-white border border-slate-200 text-slate-800 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-[#D4642C]/30 focus:border-[#D4642C] shadow-sm transition-all"
          />
        </div>
        <div className="flex gap-1 p-1 rounded-xl bg-slate-100 border border-slate-200 shrink-0">
          {["All", "Admins"].map((tab) => (
            <button
              key={tab}
              onClick={() => setFilterRole(tab)}
              className={`px-4 py-2 rounded-lg text-xs font-bold transition-all ${
                filterRole === tab
                  ? "bg-[#D4642C] text-white shadow-sm"
                  : "text-slate-600 hover:text-slate-900"
              }`}
            >
              {tab}
            </button>
          ))}
        </div>
      </div>

      {/* Member Cards / Directory */}
      <div className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
        {loading ? (
          <div className="flex items-center justify-center py-24">
            <Loader2 className="animate-spin text-[#D4642C]" size={32} />
          </div>
        ) : filtered.length === 0 ? (
          <div className="py-24 text-center flex flex-col items-center justify-center gap-3 text-slate-400">
            <Users size={44} className="opacity-30 text-slate-400" />
            <p className="text-sm font-bold uppercase tracking-widest text-slate-500">
              {employees.length === 0 ? "No teammates found in directory." : "No matches found."}
            </p>
          </div>
        ) : (
          <div className="divide-y divide-slate-100">
            {filtered.map((m, i) => {
              const name = m.fullName || m.name || "Team Member";
              const initials = name
                .split(/\s+/)
                .filter(Boolean)
                .map((n) => n[0]?.toUpperCase())
                .slice(0, 2)
                .join("") || "TM";
              const slug = m.cardSlug || m.slug;

              return (
                <div
                  key={m.userId || m.id || i}
                  className="p-4 sm:p-5 flex flex-col sm:flex-row sm:items-center justify-between gap-4 hover:bg-slate-50/60 transition-colors"
                >
                  <div className="flex items-center gap-3.5 min-w-0">
                    <div className="w-11 h-11 rounded-full flex items-center justify-center text-sm font-bold bg-[#FFF7ED] text-[#D4642C] border border-[#FED7AA] shrink-0 shadow-xs">
                      {initials}
                    </div>
                    <div className="min-w-0">
                      <div className="text-sm font-bold text-slate-900 flex items-center gap-2">
                        <span className="truncate">{name}</span>
                        <span className="px-2 py-0.5 rounded text-[9px] font-black uppercase tracking-wider bg-slate-100 text-slate-600 border border-slate-200">
                          {m.jobTitle || m.role || "Employee"}
                        </span>
                      </div>
                      <div className="text-xs text-slate-500 flex items-center gap-3 mt-1 truncate">
                        {m.email && (
                          <span className="flex items-center gap-1.5 truncate">
                            <Mail size={12} className="opacity-60" /> {m.email}
                          </span>
                        )}
                        {m.cardStatus && (
                          <span className={`text-[10px] font-bold uppercase tracking-wider ${
                            m.cardStatus === "Published" || m.cardStatus === "Active" ? "text-emerald-600" : "text-slate-400"
                          }`}>
                            • {m.cardStatus}
                          </span>
                        )}
                      </div>
                    </div>
                  </div>

                  <div className="flex items-center gap-2 self-end sm:self-center">
                    {slug && (
                      <button
                        onClick={() => window.open(`/card/${slug}`, "_blank")}
                        className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-bold bg-[#FFF7ED] hover:bg-[#FFEDD5] text-[#D4642C] border border-[#FED7AA] transition-all shadow-2xs"
                        title="View Live Card"
                      >
                        <Eye size={12} /> View Card
                      </button>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>

      {/* Mobile-aligned View-Only Footer Caption for Employees */}
      {isEmployeeRole && (
        <div className="flex items-center justify-center gap-2 pt-2 text-xs font-medium text-slate-400">
          <Info size={14} className="text-slate-400" />
          <span>Contact your admin to update team member details</span>
        </div>
      )}

      {!isEmployeeRole && (
        <InviteEmployeeModal
          open={inviteOpen}
          onClose={() => setInviteOpen(false)}
          companyId={companyId}
          voucherCode={companyInfo?.voucherCode}
          companyName={companyInfo?.companyName}
          inviteCode={companyInfo?.inviteCode}
        />
      )}
    </div>
  );
}
