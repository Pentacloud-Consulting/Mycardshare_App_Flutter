"use client";
import { useEffect, useState, use } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Building2, Loader2, AlertCircle, ShieldCheck, XCircle, Trash2, ArrowLeft, Globe, Phone, Mail, MapPin, FileText, CalendarClock, AlertTriangle, Pencil, Save, CheckCircle } from "lucide-react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { authFetch, parseFetchJson, toUserMessage } from "@/lib/api";

function SubscriptionEditor({ company, companyId, onUpdated }) {
  const [editing, setEditing] = useState(false);
  const [saving, setSaving] = useState(false);
  const [toast, setToast] = useState(null);

  const toInputDate = (val) => {
    if (!val) return "";
    const d = new Date(val);
    if (isNaN(d)) return "";
    return d.toISOString().split("T")[0];
  };

  const [startDate, setStartDate] = useState(toInputDate(company.subscriptionStartDate));
  const [renewalDate, setRenewalDate] = useState(toInputDate(company.renewalDate));
  const [status, setStatus] = useState(company.subscriptionStatus || "active");

  useEffect(() => {
    setStartDate(toInputDate(company.subscriptionStartDate));
    setRenewalDate(toInputDate(company.renewalDate));
    setStatus(company.subscriptionStatus || "active");
  }, [company.subscriptionStartDate, company.renewalDate, company.subscriptionStatus]);

  const formatDisplayDate = (val) => {
    if (!val) return "\u2014";
    const d = new Date(val);
    if (isNaN(d)) return "\u2014";
    return d.toLocaleDateString("en-GB", { day: "2-digit", month: "short", year: "numeric" });
  };

  const now = new Date();
  const rd = renewalDate ? new Date(renewalDate) : null;
  const daysUntilRenewal = rd ? Math.ceil((rd - now) / (1000 * 60 * 60 * 24)) : null;
  const isExpired = rd && now > rd;
  const isWarning = daysUntilRenewal !== null && daysUntilRenewal <= 7 && daysUntilRenewal > 0;
  const displayStatus = isExpired ? "expired" : status;

  const statusColors = {
    active: { bg: "#ecfdf5", border: "#a7f3d0", text: "#059669" },
    expired: { bg: "#fef2f2", border: "#fecaca", text: "#dc2626" },
    suspended: { bg: "#fffbeb", border: "#fde68a", text: "#d97706" },
    unknown: { bg: "#faf6f2", border: "#eae2db", text: "#77716c" },
  };
  const sc = statusColors[displayStatus] || statusColors.unknown;

  const handleSave = async () => {
    setSaving(true);
    setToast(null);
    try {
      const body = {};
      if (startDate) body.subscriptionStartDate = startDate;
      if (renewalDate) body.renewalDate = renewalDate;
      if (status) body.subscriptionStatus = status;

      const res = await authFetch(`/api/platform/companies/${companyId}`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body),
      });
      const data = await parseFetchJson(res);
      if (data.success) {
        setToast({ type: "success", message: "Subscription updated!" });
        setEditing(false);
        onUpdated?.();
      } else {
        setToast({ type: "error", message: toUserMessage(data.error, "Failed to save.") });
      }
    } catch (err) {
      setToast({ type: "error", message: err?.message || "Network error." });
    } finally {
      setSaving(false);
    }
  };

  const inputClass = "w-full px-4 py-2.5 rounded-xl text-sm bg-[#FAF6F2] shadow-inner border border-[#EAE2DB] text-[#191919] focus:outline-none focus:ring-2 focus:ring-[#D4622C]/30 focus:border-[#D4622C] transition-all";
  const selectClass = "w-full px-4 py-2.5 rounded-xl text-sm bg-[#FAF6F2] shadow-inner border border-[#EAE2DB] text-[#191919] focus:outline-none focus:ring-2 focus:ring-[#D4622C]/30 focus:border-[#D4622C] transition-all appearance-none cursor-pointer";

  return (
    <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.2 }}
      className="rounded-3xl p-6 sm:p-8 bg-white shadow-sm border border-[#EAE2DB]">
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-lg font-black text-[#191919] flex items-center gap-2">
          <CalendarClock size={20} className="text-[#D4622C]" /> Subscription Details
        </h2>
        {!editing ? (
          <button onClick={() => setEditing(true)}
            className="inline-flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-bold uppercase tracking-widest bg-[#FCE9DF] border border-[#F3C5AF] text-[#D4622C] hover:bg-[#D4622C] hover:text-white transition-all cursor-pointer">
            <Pencil size={14} /> Edit
          </button>
        ) : (
          <div className="flex items-center gap-2">
            <button onClick={() => setEditing(false)} disabled={saving}
              className="inline-flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-bold uppercase tracking-widest bg-white shadow-sm border border-[#EAE2DB] text-[#77716C] hover:text-[#191919] hover:bg-[#FAF6F2] transition-all disabled:opacity-50 cursor-pointer">
              Cancel
            </button>
            <button onClick={handleSave} disabled={saving}
              className="inline-flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-bold uppercase tracking-widest bg-gradient-to-r from-[#D4622C] to-[#E3743E] hover:from-[#BF5321] hover:to-[#D4622C] text-white shadow-md shadow-[#D4622C]/20 transition-all disabled:opacity-50 cursor-pointer">
              {saving ? <Loader2 size={14} className="animate-spin" /> : <Save size={14} />} Save
            </button>
          </div>
        )}
      </div>

      <div className="space-y-6">
        {(isWarning || isExpired) && !editing && (
          <div className={`flex items-center gap-3 p-4 rounded-xl ${
            isExpired
              ? "bg-red-50 border border-red-200 text-red-600"
              : "bg-amber-50 border border-amber-200 text-amber-600"
          }`}>
            <AlertTriangle size={18} />
            <span className="text-sm font-bold">
              {isExpired
                ? "Subscription expired"
                : `Renewal due in ${daysUntilRenewal} day${daysUntilRenewal === 1 ? "" : "s"}`}
            </span>
          </div>
        )}

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div>
            <div className="text-[10px] font-bold uppercase tracking-widest text-[#77716C] mb-1.5">Start Date</div>
            {editing ? (
              <input type="date" value={startDate} onChange={(e) => setStartDate(e.target.value)} className={inputClass} />
            ) : (
              <div className="text-[#191919] font-medium">{formatDisplayDate(startDate)}</div>
            )}
          </div>
          <div>
            <div className="text-[10px] font-bold uppercase tracking-widest text-[#77716C] mb-1.5">Renewal Date</div>
            {editing ? (
              <input type="date" value={renewalDate} onChange={(e) => setRenewalDate(e.target.value)} className={inputClass} />
            ) : (
              <div className="text-[#191919] font-medium">{formatDisplayDate(renewalDate)}</div>
            )}
          </div>
          <div>
            <div className="text-[10px] font-bold uppercase tracking-widest text-[#77716C] mb-1.5">Status</div>
            {editing ? (
              <select value={status} onChange={(e) => setStatus(e.target.value)} className={selectClass}>
                <option value="active">Active</option>
                <option value="expired">Expired</option>
                <option value="suspended">Suspended</option>
              </select>
            ) : (
              <span className="inline-block px-3 py-1 rounded-lg text-[10px] font-bold uppercase tracking-widest"
                style={{ background: sc.bg, border: `1px solid ${sc.border}`, color: sc.text }}>
                {displayStatus}
              </span>
            )}
          </div>
        </div>
      </div>

      <AnimatePresence>
        {toast && (
          <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: 10 }}
            className={`mt-6 flex items-center gap-3 p-4 rounded-xl text-sm font-bold ${
              toast.type === "success"
                ? "bg-emerald-50 border border-emerald-200 text-emerald-700"
                : "bg-red-50 border border-red-200 text-red-600"
            }`}>
            {toast.type === "success" ? <CheckCircle size={16} /> : <AlertCircle size={16} />}
            {toast.message}
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  );
}

export default function CompanyDetailsPage({ params }) {
  const router = useRouter();
  const { companyId } = use(params);

  const [company, setCompany] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [busy, setBusy] = useState(false);
  const [deleteBusy, setDeleteBusy] = useState(false);

  const fetchCompany = async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await authFetch(`/api/platform/companies/${companyId}`);
      const data = await parseFetchJson(res);
      if (data.success) {
        setCompany(data.data?.company);
      } else {
        setError(toUserMessage(data.error, "Failed to load company details."));
      }
    } catch (err) {
      setError(err?.message || "Network error.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (companyId) fetchCompany();
  }, [companyId]);

  const toggleSuspend = async () => {
    if (!company) return;
    setBusy(true);
    const newSuspended = !company.isSuspended;
    try {
      const res = await authFetch(`/api/platform/companies/${companyId}/suspend`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ isSuspended: newSuspended }),
      });
      const data = await parseFetchJson(res);
      if (data.success) {
        await fetchCompany();
      } else {
        alert(toUserMessage(data.error, "Failed to update status."));
      }
    } catch (err) {
      alert(err?.message || "Network error.");
    } finally {
      setBusy(false);
    }
  };

  const confirmDelete = async () => {
    if (!company) return;
    const confirmed = window.confirm(`Are you sure you want to completely delete ${company.companyName || "this company"}? This cannot be undone.`);
    if (!confirmed) return;
    
    setDeleteBusy(true);
    try {
      const res = await authFetch(`/api/platform/companies/${companyId}`, { method: "DELETE" });
      const data = await parseFetchJson(res);
      if (data.success) {
        router.push("/master-admin/company");
      } else {
        alert(toUserMessage(data.error, "Failed to delete company."));
        setDeleteBusy(false);
      }
    } catch (err) {
      alert(err?.message || "Network error.");
      setDeleteBusy(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[60vh]">
        <Loader2 className="animate-spin text-[#D4622C]" size={32} />
      </div>
    );
  }

  if (error || !company) {
    return (
      <div className="space-y-6">
        <Link href="/master-admin/company" className="inline-flex items-center gap-2 text-sm text-[#77716C] hover:text-[#D4622C] transition-colors">
          <ArrowLeft size={16} /> Back to Companies
        </Link>
        <div className="flex items-center gap-3 rounded-2xl bg-red-50 border border-red-200 p-6 text-red-600">
          <AlertCircle size={24} />
          <p className="font-bold">{error || "Company not found."}</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-8 max-w-7xl pb-12">
      <Link href="/master-admin/company" className="inline-flex items-center gap-2 text-xs font-bold uppercase tracking-widest text-[#77716C] hover:text-[#D4622C] transition-colors">
        <ArrowLeft size={16} /> Back
      </Link>

      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-6">
        <div>
          <div className="flex items-center gap-3 mb-2">
            <div className="w-12 h-12 rounded-xl bg-[#FAF6F2] shadow-sm border border-[#EAE2DB] flex items-center justify-center">
              <Building2 size={24} className="text-[#D4622C]" />
            </div>
            <div>
              <h1 className="text-2xl sm:text-3xl font-black tracking-tight text-[#191919]">{company.companyName || "Unnamed Company"}</h1>
              <div className="text-xs sm:text-sm font-mono text-[#77716C] mt-0.5">{company.companyId}</div>
            </div>
          </div>
        </div>

        <div className="flex items-center gap-3">
          <button onClick={toggleSuspend} disabled={busy}
            className="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl text-xs font-bold uppercase tracking-widest bg-white shadow-sm border border-[#EAE2DB] text-[#77716C] hover:text-[#191919] hover:bg-[#FAF6F2] transition-all disabled:opacity-50 cursor-pointer">
            {busy ? <Loader2 size={16} className="animate-spin" /> : company.isSuspended ? <ShieldCheck size={16} /> : <XCircle size={16} />}
            {company.isSuspended ? "Reinstate Company" : "Suspend Company"}
          </button>
          
          <button onClick={confirmDelete} disabled={deleteBusy}
            className="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl text-xs font-bold uppercase tracking-widest bg-red-50 border border-red-100 text-red-500 hover:bg-red-100 transition-all disabled:opacity-50 cursor-pointer">
            {deleteBusy ? <Loader2 size={16} className="animate-spin" /> : <Trash2 size={16} />}
            Delete Company
          </button>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Company Information */}
        <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }}
          className="rounded-3xl p-6 sm:p-8 bg-white shadow-sm border border-[#EAE2DB]">
          <h2 className="text-lg font-black text-[#191919] mb-6 flex items-center gap-2">
            <FileText size={20} className="text-[#D4622C]" /> Organization Details
          </h2>
          
          <div className="space-y-6">
            <div>
              <div className="text-[10px] font-bold uppercase tracking-widest text-[#77716C] mb-1.5">Organization Name</div>
              <div className="text-[#191919] font-medium">{company.companyName || "\u2014"}</div>
            </div>
            <div>
              <div className="text-[10px] font-bold uppercase tracking-widest text-[#77716C] mb-1.5">Public Slug</div>
              <div className="text-[#191919] font-medium">{company.slug || "\u2014"}</div>
            </div>
            <div>
              <div className="text-[10px] font-bold uppercase tracking-widest text-[#77716C] mb-1.5">Description</div>
              <div className="text-[#77716C] text-sm leading-relaxed">{company.description || "No description provided."}</div>
            </div>
            <div className="pt-4 border-t border-[#EAE2DB] flex gap-8">
              <div>
                <div className="text-[10px] font-bold uppercase tracking-widest text-[#77716C] mb-1.5">Status</div>
                <div className="text-[#191919] font-bold capitalize">{company.approvalStatus || "Pending"}</div>
              </div>
              <div>
                <div className="text-[10px] font-bold uppercase tracking-widest text-[#77716C] mb-1.5">Suspended</div>
                <div className={(company.isSuspended || company.subscriptionStatus === "suspended") ? "text-rose-600 font-bold" : "text-emerald-600 font-bold"}>
                  {(company.isSuspended || company.subscriptionStatus === "suspended") ? "Yes" : "No"}
                </div>
              </div>
            </div>
          </div>
        </motion.div>

        {/* Contact Information */}
        <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 }}
          className="rounded-3xl p-6 sm:p-8 bg-white shadow-sm border border-[#EAE2DB]">
          <h2 className="text-lg font-black text-[#191919] mb-6 flex items-center gap-2">
            <MapPin size={20} className="text-[#D4622C]" /> Contact Information
          </h2>
          
          <div className="space-y-6">
            <div>
              <div className="text-[10px] font-bold uppercase tracking-widest text-[#77716C] mb-1.5">Email</div>
              <div className="flex items-center gap-3 text-[#191919] font-medium">
                <Mail size={16} className="text-[#77716C]" />
                {company.email ? (
                  <a href={`mailto:${company.email}`} className="text-[#D4622C] hover:underline">{company.email}</a>
                ) : "—"}
              </div>
            </div>
            <div>
              <div className="text-[10px] font-bold uppercase tracking-widest text-[#77716C] mb-1.5">Phone Number</div>
              <div className="flex items-center gap-3 text-[#191919] font-medium">
                <Phone size={16} className="text-[#77716C]" />
                {company.phoneNumber || "—"}
              </div>
            </div>
            <div>
              <div className="text-[10px] font-bold uppercase tracking-widest text-[#77716C] mb-1.5">Website</div>
              <div className="flex items-center gap-3 text-[#191919] font-medium">
                <Globe size={16} className="text-[#77716C]" />
                {company.website ? (
                  <a href={company.website.startsWith('http') ? company.website : `https://${company.website}`} target="_blank" rel="noreferrer" className="text-[#D4622C] hover:underline">
                    {company.website}
                  </a>
                ) : "\u2014"}
              </div>
            </div>
            <div>
              <div className="text-[10px] font-bold uppercase tracking-widest text-[#77716C] mb-1.5">Office Address</div>
              <div className="flex items-start gap-3 text-[#191919] font-medium">
                <MapPin size={16} className="text-[#77716C] mt-0.5" />
                <span className="leading-relaxed">{company.officeAddress || "\u2014"}</span>
              </div>
            </div>
          </div>
        </motion.div>
      </div>

      {/* Editable Subscription Details */}
      <SubscriptionEditor company={company} companyId={companyId} onUpdated={fetchCompany} />
    </div>
  );
}