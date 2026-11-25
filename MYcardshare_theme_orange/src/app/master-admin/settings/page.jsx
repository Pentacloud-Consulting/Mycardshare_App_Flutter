"use client";
import { useState, useEffect, useCallback } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Settings, Save, Plus, Pencil, Trash2, X, Loader2, CheckCircle, AlertCircle, ToggleLeft, ToggleRight, Bell, Shield, CreditCard } from "lucide-react";
import { authFetch, parseFetchJson } from "@/lib/api";

function Toast({ message, type, onClose }) {
  useEffect(() => { const t = setTimeout(onClose, 4000); return () => clearTimeout(t); }, [onClose]);
  const bg = type === "success" ? "#ecfdf5" : "#fef2f2";
  const border = type === "success" ? "#a7f3d0" : "#fecaca";
  const color = type === "success" ? "#059669" : "#dc2626";
  const Icon = type === "success" ? CheckCircle : AlertCircle;
  return (
    <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: 20 }}
      className="fixed bottom-6 right-6 z-[100] flex items-center gap-3 px-5 py-3.5 rounded-xl shadow-xl shadow-stone-200/50" style={{ background: bg, border: `1px solid ${border}` }}>
      <Icon size={16} style={{ color }} /><span className="text-sm font-bold tracking-tight" style={{ color }}>{message}</span>
    </motion.div>
  );
}

function Toggle({ value, onChange, label }) {
  return (
    <div className="flex items-center justify-between py-3 sm:py-4">
      <span className="text-xs sm:text-sm font-medium text-[#77716C] pr-4">{label}</span>
      <button onClick={() => onChange(!value)} className="transition-all shrink-0 cursor-pointer">
        {value ? <ToggleRight size={32} className="text-[#D4622C]" /> : <ToggleLeft size={32} className="text-[#EAE2DB]" />}
      </button>
    </div>
  );
}

function PlanModal({ plan, onSave, onClose, busy }) {
  const [form, setForm] = useState({ name: plan?.name || "", maxEmployees: plan?.maxEmployees || "", maxCards: plan?.maxCards || "", price: plan?.price || "" });
  return (
    <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
      className="fixed inset-0 bg-stone-900/40 backdrop-blur-sm z-[60] flex items-center justify-center p-4" onClick={onClose}>
      <motion.div initial={{ scale: 0.9 }} animate={{ scale: 1 }} className="w-full max-w-md rounded-[2rem] p-8 bg-white shadow-2xl border border-[#EAE2DB]"
        onClick={(e) => e.stopPropagation()}>
        <h3 className="text-xl font-black text-[#191919] tracking-tight mb-6">{plan ? "Edit Plan" : "Add New Plan"}</h3>
        <div className="space-y-4">
          <div>
            <label className="text-[10px] font-black uppercase tracking-[0.15em] text-[#77716C] block mb-1.5">Plan Name</label>
            <input type="text" value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} placeholder="e.g. Starter"
              className="w-full px-4 py-3 rounded-2xl text-sm bg-[#FAF6F2] border border-[#EAE2DB] shadow-inner text-[#191919] placeholder:text-[#77716C] focus:outline-none focus:ring-2 focus:ring-[#D4622C]/30 focus:border-[#D4622C] transition-all" />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="text-[10px] font-black uppercase tracking-[0.15em] text-[#77716C] block mb-1.5">Max Employees</label>
              <input type="number" value={form.maxEmployees} onChange={(e) => setForm({ ...form, maxEmployees: e.target.value })} placeholder="50"
                className="w-full px-4 py-3 rounded-2xl text-sm bg-[#FAF6F2] border border-[#EAE2DB] shadow-inner text-[#191919] placeholder:text-[#77716C] focus:outline-none focus:ring-2 focus:ring-[#D4622C]/30 focus:border-[#D4622C] transition-all" />
            </div>
            <div>
              <label className="text-[10px] font-black uppercase tracking-[0.15em] text-[#77716C] block mb-1.5">Max Cards</label>
              <input type="number" value={form.maxCards} onChange={(e) => setForm({ ...form, maxCards: e.target.value })} placeholder="100"
                className="w-full px-4 py-3 rounded-2xl text-sm bg-[#FAF6F2] border border-[#EAE2DB] shadow-inner text-[#191919] placeholder:text-[#77716C] focus:outline-none focus:ring-2 focus:ring-[#D4622C]/30 focus:border-[#D4622C] transition-all" />
            </div>
          </div>
          <div>
            <label className="text-[10px] font-black uppercase tracking-[0.15em] text-[#77716C] block mb-1.5">Monthly Price (USD)</label>
            <input type="number" value={form.price} onChange={(e) => setForm({ ...form, price: e.target.value })} placeholder="49"
              className="w-full px-4 py-3 rounded-2xl text-sm bg-[#FAF6F2] border border-[#EAE2DB] shadow-inner text-[#191919] placeholder:text-[#77716C] focus:outline-none focus:ring-2 focus:ring-[#D4622C]/30 focus:border-[#D4622C] transition-all" />
          </div>
        </div>
        <div className="flex gap-3 mt-8">
          <button onClick={onClose} className="flex-1 py-3.5 rounded-xl bg-white border border-[#EAE2DB] text-[#77716C] hover:text-[#191919] font-bold text-sm hover:bg-[#FAF6F2] shadow-sm transition-all cursor-pointer">Cancel</button>
          <button onClick={() => onSave(form)} disabled={busy || !form.name}
            className="flex-1 py-3.5 rounded-xl bg-gradient-to-r from-[#D4622C] to-[#E3743E] hover:from-[#BF5321] hover:to-[#D4622C] text-white shadow-lg shadow-[#D4622C]/20 font-bold text-sm flex items-center justify-center gap-2 transition-all disabled:opacity-50 cursor-pointer">
            {busy ? <Loader2 size={14} className="animate-spin" /> : <Save size={14} />} Save</button>
        </div>
      </motion.div>
    </motion.div>
  );
}

export default function MasterSettingsPage() {
  const [toast, setToast] = useState(null);
  const [saving, setSaving] = useState(false);

  // Platform config
  const [platformName, setPlatformName] = useState("MyCardShare");
  const [supportEmail, setSupportEmail] = useState("support@mycardshare.com");

  // Governance
  const [allowSelfRegistration, setAllowSelfRegistration] = useState(true);
  const [requireEmailVerification, setRequireEmailVerification] = useState(true);

  // Notifications
  const [notifyNewEnterprise, setNotifyNewEnterprise] = useState(true);
  const [notifyNewLead, setNotifyNewLead] = useState(false);

  // Plans
  const [plans, setPlans] = useState([
    { id: "1", name: "Starter", maxEmployees: 10, maxCards: 20, price: 29 },
    { id: "2", name: "Professional", maxEmployees: 50, maxCards: 100, price: 79 },
    { id: "3", name: "Enterprise", maxEmployees: 500, maxCards: 1000, price: 199 },
  ]);
  const [planModal, setPlanModal] = useState(null);
  const [deleteConfirm, setDeleteConfirm] = useState(null);

  const handleSave = () => {
    setSaving(true);
    setTimeout(() => { setSaving(false); setToast({ message: "Settings saved successfully", type: "success" }); }, 800);
  };

  const handleSavePlan = (form) => {
    if (planModal?.plan) {
      setPlans(plans.map((p) => p.id === planModal.plan.id ? { ...p, ...form } : p));
    } else {
      setPlans([...plans, { id: Date.now().toString(), ...form }]);
    }
    setPlanModal(null);
    setToast({ message: "Plan saved successfully", type: "success" });
  };

  const handleDeletePlan = (id) => {
    setPlans(plans.filter((p) => p.id !== id));
    setDeleteConfirm(null);
    setToast({ message: "Plan deleted", type: "success" });
  };

  const sectionClass = "rounded-[2rem] p-5 sm:p-8 bg-white border border-[#EAE2DB] shadow-sm";
  const inputClass = "w-full px-4 py-3 rounded-2xl text-sm bg-[#FAF6F2] border border-[#EAE2DB] shadow-inner text-[#191919] placeholder:text-[#77716C] focus:outline-none focus:ring-2 focus:ring-[#D4622C]/30 focus:border-[#D4622C] transition-all";

  return (
    <div className="space-y-8 max-w-4xl pb-12">
      <div>
        <h1 className="text-2xl sm:text-3xl font-black tracking-tight text-[#191919]">Settings</h1>
        <p className="text-sm mt-1 text-[#77716C] font-medium">Platform configuration and governance</p>
      </div>

      {/* Platform Configuration */}
      <motion.div initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} className={sectionClass}>
        <div className="flex items-center gap-3 mb-6 sm:mb-8">
          <Settings size={20} className="text-[#D4622C]" />
          <h2 className="text-xs sm:text-sm font-black uppercase tracking-[0.2em] text-[#77716C]">Platform Configuration</h2>
        </div>
        <div className="space-y-6">
          <div>
            <label className="text-[10px] font-black uppercase tracking-[0.15em] text-[#77716C] block mb-1.5">Platform Name</label>
            <input type="text" value={platformName} onChange={(e) => setPlatformName(e.target.value)} className={inputClass} />
          </div>
          <div>
            <label className="text-[10px] font-black uppercase tracking-[0.15em] text-[#77716C] block mb-1.5">Support Email</label>
            <input type="email" value={supportEmail} onChange={(e) => setSupportEmail(e.target.value)} className={inputClass} />
          </div>
        </div>
      </motion.div>

      {/* Plan Management */}
      <motion.div initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 }} className={sectionClass}>
        <div className="flex items-center justify-between mb-6 sm:mb-8">
          <div className="flex items-center gap-3">
            <CreditCard size={20} className="text-[#D4622C]" />
            <h2 className="text-xs sm:text-sm font-black uppercase tracking-[0.2em] text-[#77716C]">Plan Management</h2>
          </div>
          <button onClick={() => setPlanModal({})} className="inline-flex items-center gap-2 px-4 py-2 rounded-xl text-[10px] font-black uppercase tracking-[0.15em] bg-[#FCE9DF] border border-[#F3C5AF] text-[#D4622C] hover:bg-[#D4622C] hover:text-white shadow-sm transition-all cursor-pointer">
            <Plus size={14} /> Add Plan
          </button>
        </div>
        <div className="rounded-[1.5rem] overflow-hidden border border-[#EAE2DB] shadow-sm bg-white">
          <div className="hidden md:grid grid-cols-5 gap-4 px-6 py-4 text-[10px] font-black uppercase tracking-[0.2em] text-[#77716C] bg-[#FAF6F2] border-b border-[#EAE2DB]">
            <div>Plan Name</div><div>Max Employees</div><div>Max Cards</div><div>Price/mo</div><div className="text-right">Actions</div>
          </div>
          {plans.map((plan, index) => (
            <div key={plan.id} className={`flex flex-col md:grid md:grid-cols-5 gap-4 px-6 py-5 md:py-4 items-start md:items-center hover:bg-[#FAF6F2]/60 transition-colors relative ${index !== plans.length - 1 ? 'border-b border-[#EAE2DB]/60' : ''}`}>
              <div className="text-sm font-bold text-[#191919]">{plan.name}</div>
              <div className="grid grid-cols-3 md:contents gap-4 w-full md:w-auto">
                <div className="md:contents">
                  <div className="text-[8px] font-black uppercase tracking-[0.15em] text-[#77716C] md:hidden mb-1">Members</div>
                  <div className="text-xs font-medium text-[#77716C]">{plan.maxEmployees}</div>
                </div>
                <div className="md:contents">
                  <div className="text-[8px] font-black uppercase tracking-[0.15em] text-[#77716C] md:hidden mb-1">Cards</div>
                  <div className="text-xs font-medium text-[#77716C]">{plan.maxCards}</div>
                </div>
                <div className="md:contents">
                  <div className="text-[8px] font-black uppercase tracking-[0.15em] text-[#77716C] md:hidden mb-1">Price</div>
                  <div className="text-xs font-bold text-[#D4622C]">${plan.price}</div>
                </div>
              </div>
              <div className="flex items-center justify-end gap-2 absolute top-5 right-6 md:static">
                <button onClick={() => setPlanModal({ plan })} className="p-2 rounded-xl bg-white border border-[#EAE2DB] text-[#77716C] hover:text-[#D4622C] hover:bg-[#FCE9DF] hover:border-[#F3C5AF] shadow-sm transition-all cursor-pointer"><Pencil size={12} /></button>
                <button onClick={() => handleDeletePlan(plan.id)} className="p-2 rounded-xl bg-red-50 border border-red-100 text-red-500 hover:bg-red-100 shadow-sm transition-all cursor-pointer"><Trash2 size={12} /></button>
              </div>
            </div>
          ))}
        </div>
      </motion.div>

      {/* Governance */}
      <motion.div initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.2 }} className={sectionClass}>
        <div className="flex items-center gap-3 mb-4 sm:mb-6">
          <Shield size={20} className="text-[#D4622C]" />
          <h2 className="text-xs sm:text-sm font-black uppercase tracking-[0.2em] text-[#77716C]">Governance Defaults</h2>
        </div>
        <div className="divide-y divide-[#EAE2DB]/60">
          <Toggle label="Allow Self-Registration globally" value={allowSelfRegistration} onChange={setAllowSelfRegistration} />
          <Toggle label="Require email verification on signup" value={requireEmailVerification} onChange={setRequireEmailVerification} />
        </div>
      </motion.div>

      {/* Notifications */}
      <motion.div initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.3 }} className={sectionClass}>
        <div className="flex items-center gap-3 mb-4 sm:mb-6">
          <Bell size={20} className="text-[#D4622C]" />
          <h2 className="text-xs sm:text-sm font-black uppercase tracking-[0.2em] text-[#77716C]">Notification Settings</h2>
        </div>
        <div className="divide-y divide-[#EAE2DB]/60">
          <Toggle label="Email master admin when new enterprise registers" value={notifyNewEnterprise} onChange={setNotifyNewEnterprise} />
          <Toggle label="Email master admin when a lead is created" value={notifyNewLead} onChange={setNotifyNewLead} />
        </div>
      </motion.div>

      {/* Save */}
      <div className="flex justify-end pt-4">
        <button onClick={handleSave} disabled={saving}
          className="inline-flex items-center gap-2 px-8 py-3.5 rounded-xl bg-gradient-to-r from-[#D4622C] to-[#E3743E] hover:from-[#BF5321] hover:to-[#D4622C] text-white font-bold text-sm shadow-lg shadow-[#D4622C]/25 transition-all disabled:opacity-50 cursor-pointer">
          {saving ? <Loader2 size={16} className="animate-spin" /> : <Save size={16} />} Save Settings</button>
      </div>

      <AnimatePresence>
        {planModal && <PlanModal plan={planModal.plan} onSave={handleSavePlan} onClose={() => setPlanModal(null)} busy={false} />}
        {toast && <Toast {...toast} onClose={() => setToast(null)} />}
      </AnimatePresence>
    </div>
  );
}