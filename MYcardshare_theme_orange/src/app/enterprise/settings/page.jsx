"use client";
import { useState, useEffect, useCallback } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Settings, Save, Building2, Globe, Mail, Phone, MapPin, Loader2, CheckCircle, AlertCircle, Upload, Zap, CalendarClock, AlertTriangle, ImagePlus } from "lucide-react";
import { authFetch, parseFetchJson } from "@/lib/api";
import { useAuth } from "@/lib/auth-context";

function Toast({ message, type, onClose }) {
  useEffect(() => { const t = setTimeout(onClose, 4000); return () => clearTimeout(t); }, [onClose]);
  const color = type === "success" ? "#10d9a8" : "#ef4444";
  const Icon = type === "success" ? CheckCircle : AlertCircle;
  return (
    <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: 20 }}
      className="fixed bottom-6 right-6 z-[100] flex items-center gap-3 px-5 py-3.5 rounded-xl shadow-2xl bg-white border border-slate-200">
      <Icon size={16} style={{ color }} /><span className="text-sm font-semibold text-slate-800">{message}</span>
    </motion.div>
  );
}

function Section({ title, icon: Icon, children }) {
  return (
    <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.5, ease: "easeOut" }}
      className="rounded-[2rem] p-6 sm:p-8 bg-white/80 backdrop-blur-xl border border-white shadow-[0_8px_30px_rgb(0,0,0,0.04)] ring-1 ring-slate-200/50 hover:shadow-[0_8px_40px_rgba(212,100,44,0.06)] transition-all duration-500 relative overflow-hidden group">
      <div className="absolute inset-0 bg-gradient-to-br from-white/50 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500" />
      <div className="flex items-center gap-3 pb-6 border-b border-slate-100/60 mb-6 relative z-10">
        <div className="w-10 h-10 rounded-xl bg-[#FFF7ED] text-[#D4642C] flex items-center justify-center border border-[#FED7AA] shadow-sm group-hover:scale-110 transition-transform duration-500">
          <Icon size={18} />
        </div>
        <h2 className="text-[11px] font-black uppercase tracking-[0.2em] text-slate-800">{title}</h2>
      </div>
      <div className="relative z-10 space-y-6">{children}</div>
    </motion.div>
  );
}

export default function EnterpriseSettingsPage() {
  const { refreshUserData } = useAuth();
  const [profile, setProfile] = useState(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [toast, setToast] = useState(null);

  const fetchData = useCallback(async () => {
    setLoading(true);
    try {
      const res = await authFetch("/api/enterprise/profile");
      const data = await parseFetchJson(res);
      if (data.success) setProfile(data.data);
    } catch (_) {}
    finally { setLoading(false); }
  }, []);

  useEffect(() => { fetchData(); }, [fetchData]);

  const handleSave = async () => {
    setSaving(true);
    try {
      const res = await authFetch("/api/enterprise/profile", {
        method: "PATCH", headers: { "Content-Type": "application/json" },
        body: JSON.stringify(profile),
      });
      const data = await parseFetchJson(res);
      if (data.success) {
        setToast({ message: "Settings saved successfully", type: "success" });
        await refreshUserData?.();
      } else {
        setToast({ message: data.error || "Failed to save", type: "error" });
      }
    } catch (err) { setToast({ message: err?.message || "Network error", type: "error" }); }
    finally { setSaving(false); }
  };

  const handleImageUpload = async (e, field) => {
    const file = e.target.files?.[0];
    if (!file) return;

    if (file.size > 2 * 1024 * 1024) {
      setToast({ message: "File size exceeds 2MB limit", type: "error" });
      return;
    }

    const reader = new FileReader();
    reader.onload = async (event) => {
      const base64 = event.target.result;
      setSaving(true);
      try {
        const res = await authFetch("/api/storage/profile-image", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            imageBase64: base64,
            type: field,
            userId: profile.id || profile.companyId || "company",
          }),
        });
        const data = await parseFetchJson(res);
        if (data.success && data.url) {
          const updatedProfile = { ...profile, [field]: data.url };
          setProfile(updatedProfile);
          
          const saveRes = await authFetch("/api/enterprise/profile", {
            method: "PATCH",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ [field]: data.url })
          });
          
          if (saveRes.ok) {
            setToast({ message: "Image uploaded and saved!", type: "success" });
            await refreshUserData?.();
          } else {
            setToast({ message: "Image uploaded but failed to save.", type: "error" });
          }
        } else {
          const errMsg = typeof data.error === 'string' ? data.error : (data.error?.message || "Upload failed");
          setToast({ message: errMsg, type: "error" });
        }
      } catch (err) {
        setToast({ message: "Upload error", type: "error" });
      } finally {
        setSaving(false);
      }
    };
    reader.readAsDataURL(file);
  };

  const set = (k, v) => setProfile({ ...profile, [k]: v });
  const inputClass = "w-full px-4 py-3.5 rounded-xl text-sm font-semibold bg-slate-50/50 border border-slate-200 text-slate-800 placeholder:text-slate-400 focus:outline-none focus:ring-4 focus:ring-[#D4642C]/10 focus:border-[#D4642C] focus:bg-white transition-all shadow-inner";

  if (loading) {
    return (<div className="flex items-center justify-center py-32"><Loader2 className="animate-spin text-[#D4642C]" size={32} /></div>);
  }

  return (
    <div className="max-w-7xl w-full mx-auto pb-20 font-sans relative">
      {/* Subtle Background Mesh for the whole page */}
      <div className="fixed inset-0 pointer-events-none -z-10 bg-slate-50">
        <div className="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] rounded-full bg-[#D4642C]/10 blur-[120px]" />
        <div className="absolute bottom-[-10%] right-[-10%] w-[40%] h-[40%] rounded-full bg-amber-500/10 blur-[120px]" />
      </div>

      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-6 mb-8">
        <div>
          <h1 className="text-2xl sm:text-3xl font-black tracking-tight text-slate-900 leading-none">Settings</h1>
          <p className="text-xs sm:text-sm mt-1.5 text-slate-500 font-medium leading-tight">Manage organization identity and configuration</p>
        </div>
        <button onClick={handleSave} disabled={saving}
          className="w-full sm:w-auto inline-flex items-center justify-center gap-2 px-8 py-3.5 rounded-xl bg-[#D4642C] hover:bg-[#BD5523] text-white font-bold text-[10px] sm:text-xs uppercase tracking-widest shadow-lg shadow-[#D4642C]/20 hover:shadow-[#D4642C]/40 transition-all disabled:opacity-50 active:scale-95 group">
          {saving ? <Loader2 size={16} className="animate-spin" /> : <Save size={16} className="group-hover:scale-110 transition-transform" />} Save Changes
        </button>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 sm:gap-8 items-start">
        <div className="space-y-6 sm:space-y-8">
          <Section title="Company Identity" icon={Building2}>
            <div className="space-y-5">
              <div><label className="text-[9px] font-black uppercase tracking-widest text-slate-500 block mb-2">Organization Name</label>
                <input type="text" value={profile?.companyName || ""} onChange={(e) => set("companyName", e.target.value)} className={inputClass} placeholder="e.g. Acme Corp" /></div>
              <div><label className="text-[9px] font-black uppercase tracking-widest text-slate-500 block mb-2">Public Slug</label>
                <input type="text" value={profile?.slug || ""} onChange={(e) => set("slug", e.target.value)} className={inputClass} placeholder="company-name" />
                <p className="text-[8px] text-slate-400 mt-2 uppercase font-black tracking-widest">Alphanumeric and hyphens only.</p>
              </div>
              <div><label className="text-[9px] font-black uppercase tracking-widest text-slate-500 block mb-2">Description</label>
                <textarea value={profile?.description || ""} onChange={(e) => set("description", e.target.value)} rows={3} className={inputClass} placeholder="Short bio about your company..." /></div>
            </div>
          </Section>

          <Section title="Contact Information" icon={Mail}>
            <div className="space-y-5">
              <div><label className="text-[9px] font-black uppercase tracking-widest text-slate-500 block mb-2">Phone Number</label>
                <div className="relative"><Phone size={14} className="absolute left-5 top-1/2 -translate-y-1/2 text-slate-400" />
                  <input type="tel" value={profile?.phoneNumber || ""} onChange={(e) => set("phoneNumber", e.target.value)} className={`${inputClass} pl-12`} placeholder="+971 00 000 0000" /></div></div>
              <div><label className="text-[9px] font-black uppercase tracking-widest text-slate-500 block mb-2">Website</label>
                <div className="relative"><Globe size={14} className="absolute left-5 top-1/2 -translate-y-1/2 text-slate-400" />
                  <input type="url" value={profile?.website || ""} onChange={(e) => set("website", e.target.value)} className={`${inputClass} pl-12`} placeholder="https://company.com" /></div></div>
              <div><label className="text-[9px] font-black uppercase tracking-widest text-slate-500 block mb-2">Office Address</label>
                <div className="relative"><MapPin size={14} className="absolute left-5 top-1/2 -translate-y-1/2 text-slate-400" />
                  <input type="text" value={profile?.address || ""} onChange={(e) => set("address", e.target.value)} className={`${inputClass} pl-12`} placeholder="Dubai, UAE" /></div></div>
            </div>
          </Section>
        </div>

        <div className="space-y-6 sm:space-y-8">
          <Section title="Branding & Media" icon={Upload}>
            <div className="space-y-6">
              <div>
                <label className="text-[9px] font-black uppercase tracking-[0.15em] text-slate-500 block mb-3 ml-1">Company Logo</label>
                <div className="flex flex-col sm:flex-row sm:items-center gap-5 p-5 rounded-2xl bg-slate-50/50 border border-slate-200 w-full sm:w-fit group hover:bg-white transition-colors">
                  <div className="relative">
                    <div className="relative w-16 h-16 sm:w-20 sm:h-20 rounded-[1.25rem] flex items-center justify-center overflow-hidden border border-slate-200 bg-white shadow-sm group-hover:shadow-md transition-shadow">
                      {/* Fallback Icon */}
                      <div className="absolute inset-0 flex items-center justify-center bg-slate-50 z-0">
                         <Building2 size={24} className="text-slate-300" />
                      </div>
                      {/* Actual Image */}
                      {profile?.companyLogo && profile.companyLogo !== "null" && profile.companyLogo !== "undefined" && (
                        <img src={profile.companyLogo} alt="Logo" className="absolute inset-0 w-full h-full object-contain p-2 z-10 bg-white" onError={(e) => { e.target.style.display = 'none'; }} />
                      )}
                    </div>
                    <label className="absolute -bottom-2 -right-2 p-2.5 rounded-xl bg-white border border-slate-200 text-slate-600 shadow-sm cursor-pointer hover:bg-[#FFF7ED] hover:text-[#D4642C] hover:border-[#FED7AA] active:scale-95 transition-all">
                      <Upload size={12} />
                      <input type="file" accept="image/*" className="hidden" onChange={(e) => handleImageUpload(e, 'companyLogo')} />
                    </label>
                  </div>
                  <div className="space-y-1">
                    <div className="text-[10px] text-slate-700 font-bold uppercase tracking-widest leading-tight">Square recommended</div>
                    <div className="text-[9px] text-slate-400 font-medium uppercase tracking-widest leading-relaxed">PNG / SVG / JPG</div>
                  </div>
                </div>
              </div>
              <div>
                <label className="text-[9px] font-black uppercase tracking-[0.15em] text-slate-500 block mb-3 ml-1">Cover Banner</label>
                <div className="relative h-36 sm:h-48 rounded-[2rem] overflow-hidden border-2 border-slate-100/50 bg-slate-50 shadow-inner group">
                  {/* Always render the fallback underneath */}
                  <div className="absolute inset-0 flex flex-col items-center justify-center bg-gradient-to-br from-slate-50 to-slate-100/80 z-0">
                     <div className="w-12 h-12 sm:w-16 sm:h-16 rounded-full bg-white shadow-sm border border-slate-100 flex items-center justify-center mb-3 sm:mb-4">
                       <ImagePlus size={20} className="text-slate-300" />
                     </div>
                     <div className="text-slate-400 font-black text-[10px] sm:text-[11px] uppercase tracking-widest mb-1.5">No Banner Uploaded</div>
                     <div className="text-slate-400/70 font-bold text-[8px] sm:text-[9px] uppercase tracking-[0.15em]">1200 x 400px Recommended</div>
                  </div>

                  {/* If we have a URL, render the image on top. If it breaks, hide it, revealing the fallback. */}
                  {profile?.companyBanner && profile.companyBanner !== "null" && profile.companyBanner !== "undefined" && (
                    <img 
                      src={profile.companyBanner} 
                      alt="Banner" 
                      className="absolute inset-0 w-full h-full object-cover z-10" 
                      onError={(e) => { e.target.style.display = 'none'; }}
                    />
                  )}

                  <label className="absolute bottom-3 right-3 sm:bottom-4 sm:right-4 flex items-center gap-2 sm:gap-2.5 px-3 py-2 sm:px-4 sm:py-3 rounded-xl bg-white/95 backdrop-blur-md border border-slate-200/50 text-slate-700 font-bold text-[9px] sm:text-[10px] uppercase tracking-widest shadow-lg cursor-pointer hover:bg-[#D4642C] hover:text-white hover:border-[#D4642C] hover:scale-105 active:scale-95 transition-all z-20">
                    <Upload size={14} /> {profile?.companyBanner ? 'Change Banner' : 'Upload Banner'}
                    <input type="file" accept="image/*" className="hidden" onChange={(e) => handleImageUpload(e, 'companyBanner')} />
                  </label>
                </div>
              </div>
            </div>
          </Section>

          <Section title="Integration Details" icon={Zap}>
            <div className="space-y-5">
              <div className="flex items-center justify-between">
                <div>
                  <div className="text-[10px] sm:text-xs font-black uppercase tracking-widest text-slate-800">Enable Integration</div>
                  <div className="text-[8px] sm:text-[9px] text-slate-500 mt-1 uppercase tracking-widest leading-relaxed">Unlock custom integrations like Salesforce via Zapier.</div>
                </div>
                <button 
                  onClick={async () => {
                    const newVal = !profile?.isIntegrationEnabled;
                    set("isIntegrationEnabled", newVal);
                    
                    // Auto-save the toggle
                    try {
                      const res = await authFetch("/api/enterprise/profile", {
                        method: "PATCH", 
                        headers: { "Content-Type": "application/json" },
                        body: JSON.stringify({ isIntegrationEnabled: newVal }),
                      });
                      const data = await parseFetchJson(res);
                      if (data.success) {
                        await refreshUserData?.();
                      } else {
                        set("isIntegrationEnabled", !newVal); // revert
                      }
                    } catch (err) {
                      set("isIntegrationEnabled", !newVal); // revert
                    }
                  }} 
                  className="bg-transparent border-0 cursor-pointer transition-colors hover:opacity-80 disabled:opacity-50"
                  disabled={saving}
                >
                  {profile?.isIntegrationEnabled ? (
                    <div className="w-12 h-6 rounded-full bg-[#D4642C] relative transition-all shadow-inner">
                      <div className="absolute right-1 top-1 w-4 h-4 bg-white rounded-full shadow-md" />
                    </div>
                  ) : (
                    <div className="w-12 h-6 rounded-full bg-slate-200 relative transition-all shadow-inner">
                      <div className="absolute left-1 top-1 w-4 h-4 bg-white rounded-full shadow-sm" />
                    </div>
                  )}
                </button>
              </div>
            </div>
          </Section>

          <Section title="Subscription Status" icon={CalendarClock}>
            {(() => {
              const startDate = profile?.subscriptionStartDate ? new Date(profile.subscriptionStartDate) : null;
              const renewalDate = profile?.renewalDate ? new Date(profile.renewalDate) : null;
              const subStatus = profile?.subscriptionStatus || "unknown";
              const now = new Date();
              const daysUntilRenewal = renewalDate ? Math.ceil((renewalDate - now) / (1000 * 60 * 60 * 24)) : null;
              const isExpired = renewalDate && now > renewalDate;
              const isWarning = daysUntilRenewal !== null && daysUntilRenewal <= 7 && daysUntilRenewal > 0;
              const displayStatus = isExpired ? "expired" : subStatus;

              const formatDate = (d) => {
                if (!d || isNaN(d)) return "\u2014";
                return d.toLocaleDateString("en-GB", { day: "2-digit", month: "short", year: "numeric" });
              };

              const statusColors = {
                active: { bg: "rgba(16,217,168,0.1)", border: "rgba(16,217,168,0.25)", text: "#059669" },
                expired: { bg: "rgba(239,68,68,0.1)", border: "rgba(239,68,68,0.25)", text: "#dc2626" },
                suspended: { bg: "rgba(245,158,11,0.1)", border: "rgba(245,158,11,0.25)", text: "#d97706" },
                unknown: { bg: "rgba(148,163,184,0.1)", border: "rgba(148,163,184,0.2)", text: "#64748b" },
              };
              const sc = statusColors[displayStatus] || statusColors.unknown;

              return (
                <div className="space-y-6">
                  {(isWarning || isExpired) && (
                    <div className={`flex items-center gap-3 p-4 rounded-2xl ${
                      isExpired ? "bg-red-50 border border-red-200 text-red-600" : "bg-amber-50 border border-amber-200 text-amber-600"
                    }`}>
                      <AlertTriangle size={16} />
                      <span className="text-[10px] font-black uppercase tracking-widest leading-none">
                        {isExpired ? "Expired" : `Renewal in ${daysUntilRenewal}d`}
                      </span>
                    </div>
                  )}

                  <div className="grid grid-cols-2 gap-y-6 gap-x-4">
                    <div><div className="text-[8px] font-black uppercase tracking-widest text-slate-400 mb-2">Started</div>
                      <div className="text-slate-800 font-black text-xs sm:text-sm leading-none">{formatDate(startDate)}</div></div>
                    <div><div className="text-[8px] font-black uppercase tracking-widest text-slate-400 mb-2">Renewal</div>
                      <div className="text-slate-800 font-black text-xs sm:text-sm leading-none">{formatDate(renewalDate)}</div></div>
                    <div><div className="text-[8px] font-black uppercase tracking-widest text-slate-400 mb-2">Status</div>
                      <span className="inline-block px-2.5 py-1 rounded-lg text-[7px] sm:text-[8px] font-black uppercase tracking-[0.15em]"
                        style={{ background: sc.bg, border: `1px solid ${sc.border}`, color: sc.text }}>{displayStatus}</span></div>
                    <div><div className="text-[8px] font-black uppercase tracking-widest text-slate-400 mb-2">Days Left</div>
                      <div className={`text-lg sm:text-xl font-black leading-none ${isExpired ? "text-red-500" : isWarning ? "text-amber-500" : "text-emerald-500"}`}>
                        {isExpired ? "0" : daysUntilRenewal !== null ? daysUntilRenewal : "\u2014"}</div></div>
                  </div>
                </div>
              );
            })()}
          </Section>


        </div>
      </div>

      <AnimatePresence>
        {toast && <Toast key="toast" {...toast} onClose={() => setToast(null)} />}
      </AnimatePresence>
    </div>
  );
}
