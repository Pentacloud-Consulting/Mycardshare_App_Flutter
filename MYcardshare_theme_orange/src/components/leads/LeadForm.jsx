"use client";

import { useState, useEffect, useRef } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  X,
  User,
  Phone,
  Mail,
  Target,
  Globe,
  Wallet,
  Building2,
  MapPin,
  Star,
  Clock,
  FileText,
  Loader2,
  ChevronLeft,
  ChevronDown,
} from "lucide-react";
import { authFetch } from "@/lib/api";
import { useAuth } from "@/lib/auth-context";
import { UiloraBrandButton } from "../UIComponents/Button/tsx/UiloraModernButtons";
import IndividualLeads from "../Popup/individualLeads";

const CustomSelect = ({ value, onChange, options, icon: Icon, placeholder }) => {
  const [isOpen, setIsOpen] = useState(false);
  const selectRef = useRef(null);

  useEffect(() => {
    const handleClickOutside = (event) => {
      if (selectRef.current && !selectRef.current.contains(event.target)) {
        setIsOpen(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  return (
    <div className="relative" ref={selectRef}>
      {Icon && (
        <Icon
          size={16}
          className="absolute left-4 top-1/2 -translate-y-1/2 text-[#77716C] z-10 pointer-events-none"
        />
      )}
      <div
        onClick={() => setIsOpen(!isOpen)}
        className={`w-full bg-[#FAF6F2] shadow-2xs border border-[#EAE2DB] rounded-xl py-3 pr-4 ${
          Icon ? "pl-11" : "pl-4"
        } text-sm font-medium cursor-pointer flex items-center justify-between hover:bg-white hover:border-[#D4622C]/40 focus:ring-2 focus:ring-[#D4622C]/20 transition-all`}
      >
        <span className={value ? "text-[#191919]" : "text-[#77716C]/60"}>
          {value ? options.find((o) => o.value === value)?.label || value : placeholder}
        </span>
        <ChevronDown
          size={14}
          className={`text-[#77716C] transition-transform ${isOpen ? "rotate-180" : ""}`}
        />
      </div>

      <AnimatePresence>
        {isOpen && (
          <motion.div
            initial={{ opacity: 0, y: -6 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -6 }}
            transition={{ duration: 0.15 }}
            className="absolute z-[100] w-full mt-1.5 bg-white border border-[#EAE2DB] rounded-2xl shadow-xl overflow-hidden"
          >
            <div className="max-h-60 overflow-y-auto custom-scrollbar py-1.5">
              {options.map((opt) => (
                <div
                  key={opt.value}
                  onClick={() => {
                    onChange(opt.value);
                    setIsOpen(false);
                  }}
                  className={`px-4 py-2.5 text-sm cursor-pointer transition-colors ${
                    value === opt.value
                      ? "bg-[#FCE9DF] text-[#D4622C] font-bold"
                      : "text-[#191919] hover:bg-[#FAF6F2] hover:text-[#D4622C]"
                  }`}
                >
                  {opt.label}
                </div>
              ))}
              {options.length === 0 && (
                <div className="px-4 py-3 text-sm text-[#77716C] text-center">
                  No options available
                </div>
              )}
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
};

const DUBAI_AREAS = [
  "All Dubai", "Downtown Dubai", "Business Bay", "Dubai Marina", "Jumeirah", "Jumeirah Beach Residence (JBR)", "Palm Jumeirah", "Deira", "Bur Dubai", "Al Barsha", "Al Quoz", "Al Nahda", "Al Qusais", "Dubai Silicon Oasis", "Dubai International City", "Mirdif", "Dubai Sports City", "Dubai Production City (IMPZ)", "Dubai Investment Park", "Discovery Gardens", "Jumeirah Village Circle (JVC)", "Jumeirah Village Triangle (JVT)", "Arabian Ranches", "Dubai Hills Estate", "Al Furjan", "The Greens", "The Views", "Barsha Heights (Tecom)", "City Walk", "Bluewaters Island", "Dubai Creek Harbour", "Al Karama", "Satwa"
];

const ABU_DHABI_AREAS = [
  "Abu Dhabi Island", "Al Reem Island", "Saadiyat Island", "Yas Island", "Khalifa City", "Mohammed Bin Zayed City (MBZ City)", "Al Raha Beach", "Al Raha Gardens", "Al Mushrif", "Al Khalidiyah", "Al Bateen", "Al Muroor", "Al Zahiyah (Tourist Club Area)", "Al Markaziyah", "Al Danah", "Al Mina", "Corniche Area", "Al Shamkha", "Al Shawamekh", "Al Bahia", "Al Falah", "Masdar City", "Zayed City", "Baniyas", "Shakhbout City"
];

const NATIONALITIES = [
  "UAE", "Saudi Arabia", "Qatar", "Kuwait", "Bahrain", "Oman",
  "India", "Pakistan", "Bangladesh", "Sri Lanka", "Nepal", "Afghanistan",
  "UK", "USA", "Canada", "Australia", "New Zealand",
  "Germany", "France", "Italy", "Spain", "Netherlands", "Belgium", "Switzerland", "Austria", "Sweden", "Norway", "Denmark", "Finland", "Portugal", "Greece", "Ireland", "Poland", "Czech Republic", "Hungary", "Romania", "Bulgaria",
  "Russia", "Ukraine", "Turkey", "Egypt", "Jordan", "Lebanon", "Syria", "Iraq", "Iran", "Yemen", "Libya", "Tunisia", "Morocco", "Algeria", "Sudan",
  "China", "Japan", "South Korea", "Singapore", "Malaysia", "Indonesia", "Thailand", "Vietnam", "Philippines", "Hong Kong",
  "Nigeria", "Kenya", "Ghana", "Ethiopia", "South Africa", "Tanzania", "Uganda",
  "Brazil", "Argentina", "Colombia", "Mexico", "Chile", "Peru",
  "Israel", "Kazakhstan", "Uzbekistan", "Azerbaijan", "Georgia", "Armenia", "Other"
];

export default function LeadForm({ isOpen, onClose, onLeadCreated, editLead, apiUrl, apiMethod }) {
  const { userData } = useAuth();
  const isEnterpriseOrEmployee = userData?.role === "enterprise" || userData?.role === "employee";
  const [loading, setLoading] = useState(false);
  const [pushToCRM, setPushToCRM] = useState(false);
  const [formData, setFormData] = useState({
    fullName: "",
    mobile: "",
    email: "",
    campaignId: "",
    nationality: "",
    budgetRange: "",
    propertyCategory: "Ready", // Ready or Off-plan
    propertyType: "",
    emirate: "",
    areaOfInterest: [],
    investorType: "",
    timeline: "",
    notes: "",
  });

  const [alert, setAlert] = useState({ isVisible: false, message: "", type: "error" });
  const [campaigns, setCampaigns] = useState([]);

  useEffect(() => {
    if (isOpen) {
      fetchCampaigns();
      if (editLead) {
        setFormData({
          fullName: editLead.name || editLead.fullName || "",
          mobile: editLead.phone || editLead.mobile || "",
          email: editLead.email || editLead.workEmail || "",
          campaignId: editLead.campaignId || "",
          nationality: editLead.nationality || "",
          budgetRange: editLead.budgetRange || "",
          propertyCategory: editLead.propertyCategory || "Ready",
          propertyType: editLead.propertyType || "",
          emirate: editLead.emirate || "",
          areaOfInterest: Array.isArray(editLead.areaOfInterest) ? editLead.areaOfInterest : [],
          investorType: editLead.investorType || "",
          timeline: editLead.timeline || "",
          notes: editLead.notes || "",
        });
      } else {
        setFormData({
          fullName: "",
          mobile: "",
          email: "",
          campaignId: "",
          nationality: "",
          budgetRange: "",
          propertyCategory: "Ready",
          propertyType: "",
          emirate: "",
          areaOfInterest: [],
          investorType: "",
          timeline: "",
          notes: "",
        });
      }
    }
  }, [isOpen, editLead]);

  const fetchCampaigns = async () => {
    try {
      const res = await authFetch("/api/campaigns?activeOnly=true");
      const data = await res.json();
      if (data.success) {
        setCampaigns(data.data);
        if (data.data.length > 0 && !formData.campaignId && !editLead?.campaignId) {
          setFormData((prev) => ({ ...prev, campaignId: data.data[0]._id || data.data[0].id }));
        }
      }
    } catch (err) {
      console.error("Failed to fetch campaigns:", err);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!formData.campaignId && campaigns.length > 0) {
      setAlert({ 
        isVisible: true, 
        message: "Please select a campaign before saving this lead.", 
        type: "warning" 
      });
      return;
    }

    // Manual validation for required fields if they are missing
    if (!formData.fullName || !formData.mobile) {
      setAlert({ 
        isVisible: true, 
        message: "Full Name and Mobile are required fields. Please fill them to continue.", 
        type: "error" 
      });
      return;
    }

    setLoading(true);

    try {
      const url = apiUrl || (editLead ? `/api/leads/${editLead._id || editLead.id}` : "/api/leads/create");
      const method = apiMethod || (editLead ? "PATCH" : "POST");

      const res = await authFetch(url, {
        method,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(formData),
      });
      const data = await res.json();

      if (data.success) {
        if (pushToCRM) {
          try {
            const urlEncodedData = new URLSearchParams();
            Object.entries(formData).forEach(([key, value]) => {
              urlEncodedData.append(key, Array.isArray(value) ? value.join(", ") : value);
            });

            // Append unique identifiers so Zapier can update existing Salesforce records
            if (editLead) {
              urlEncodedData.append("leadId", editLead._id || editLead.id);
              urlEncodedData.append("action", "update");
            } else if (data.data) {
              urlEncodedData.append("leadId", data.data._id || data.data.id);
              urlEncodedData.append("action", "create");
            }

            if (userData?.zapierWebhookUrl) {
              await fetch(userData.zapierWebhookUrl, {
                method: "POST",
                mode: "no-cors",
                headers: {
                  "Content-Type": "application/x-www-form-urlencoded",
                },
                body: urlEncodedData.toString(),
              });
            } else {
              console.warn("Zapier integration enabled but no webhook URL provided.");
            }
          } catch (e) {
            console.error("Failed to push to CRM:", e);
          }
        }

        onLeadCreated();
        onClose();
        setFormData({
          fullName: "",
          mobile: "",
          email: "",
          campaignId: "",
          nationality: "",
          budgetRange: "",
          propertyCategory: "Ready",
          propertyType: "",
          emirate: "",
          areaOfInterest: [],
          investorType: "",
          timeline: "",
          notes: "",
        });
        setPushToCRM(false);
      } else {
        const errorMsg = typeof data.error === 'object' ? JSON.stringify(data.error) : (data.error || "Failed to create lead");
        setAlert({ 
          isVisible: true, 
          message: errorMsg, 
          type: "error" 
        });
      }
    } catch (err) {
      console.error("Error creating lead:", err);
      setAlert({ 
        isVisible: true, 
        message: "An unexpected error occurred while saving the lead. Please try again.", 
        type: "error" 
      });
    } finally {
      setLoading(false);
    }
  };

  const inputClasses =
    "w-full bg-[#FAF6F2] shadow-2xs border border-[#EAE2DB] rounded-xl px-4 py-3 text-sm font-medium text-[#191919] placeholder:text-[#77716C]/60 focus:bg-white focus:outline-none focus:border-[#D4622C] focus:ring-2 focus:ring-[#D4622C]/20 transition-all";
  const labelClasses =
    "text-[10px] font-black uppercase tracking-widest text-[#77716C] mb-2 block ml-1";

  if (!isOpen) return null;

  return (
    <AnimatePresence>
      <motion.div
        key="lead-form-overlay"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm"
      >
        <motion.div
          initial={{ scale: 0.95, opacity: 0, y: 20 }}
          animate={{ scale: 1, opacity: 1, y: 0 }}
          exit={{ scale: 0.95, opacity: 0, y: 20 }}
          className="bg-white border border-[#EAE2DB] rounded-[2rem] w-full max-w-2xl max-h-[90vh] overflow-hidden shadow-2xl flex flex-col"
        >
          {/* Header */}
          <div className="p-6 md:p-7 border-b border-[#EAE2DB] flex items-center justify-between bg-[#FAF6F2]/80 backdrop-blur-sm">
            <div className="flex items-center gap-3.5">
              <button
                type="button"
                onClick={onClose}
                className="w-10 h-10 rounded-xl flex items-center justify-center bg-white border border-[#EAE2DB] shadow-2xs text-[#191919] hover:bg-[#FCE9DF] hover:text-[#D4622C] hover:border-[#D4622C]/30 transition-all cursor-pointer"
              >
                <ChevronLeft size={18} />
              </button>
              <div>
                <h2 className="text-xl md:text-2xl font-black text-[#191919] tracking-tight">
                  {editLead ? "Edit Lead" : "Add New Lead"}
                </h2>
                <p className="text-xs text-[#77716C] font-bold uppercase tracking-widest mt-0.5">
                  {editLead ? "Update lead details" : "Create a manual entry"}
                </p>
              </div>
            </div>
            <button
              type="button"
              onClick={onClose}
              className="w-10 h-10 rounded-xl flex items-center justify-center bg-white border border-[#EAE2DB] shadow-2xs text-[#77716C] hover:text-[#D4622C] hover:bg-[#FCE9DF] hover:border-[#D4622C]/30 transition-all cursor-pointer"
            >
              <X size={18} />
            </button>
          </div>

          {/* Form Content */}
          <form
            onSubmit={handleSubmit}
            className="flex-1 overflow-y-auto p-6 md:p-8 space-y-6 md:space-y-8 no-scrollbar"
          >
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {/* Full Name */}
              <div className="space-y-2">
                <label className={labelClasses}>Full Name *</label>
                  <div className="relative">
                    <User
                      size={16}
                      className="absolute left-4 top-1/2 -translate-y-1/2 text-[#77716C] z-10 pointer-events-none"
                    />
                    <input
                      required
                      type="text"
                      placeholder="Lead Name"
                      value={formData.fullName}
                      onChange={(e) =>
                        setFormData({ ...formData, fullName: e.target.value })
                      }
                      className={`${inputClasses} pl-12`}
                    />
                  </div>
              </div>

              {/* Mobile */}
              <div className="space-y-2">
                <label className={labelClasses}>Mobile *</label>
                  <div className="relative">
                    <Phone
                      size={16}
                      className="absolute left-4 top-1/2 -translate-y-1/2 text-[#77716C] z-10 pointer-events-none"
                    />
                    <input
                      required
                      type="tel"
                      placeholder="971501234567"
                      value={formData.mobile}
                      onChange={(e) =>
                        setFormData({ ...formData, mobile: e.target.value })
                      }
                      className={`${inputClasses} pl-12`}
                    />
                  </div>
              </div>

              {/* Email */}
              <div className="space-y-2">
                <label className={labelClasses}>Email</label>
                  <div className="relative">
                    <Mail
                      size={16}
                      className="absolute left-4 top-1/2 -translate-y-1/2 text-[#77716C] z-10 pointer-events-none"
                    />
                    <input
                      type="email"
                      placeholder="lead@example.com"
                      value={formData.email}
                      onChange={(e) =>
                        setFormData({ ...formData, email: e.target.value })
                      }
                      className={`${inputClasses} pl-12`}
                    />
                  </div>
              </div>

              {/* Campaign */}
              <div className="space-y-2">
                <label className={labelClasses}>Campaign *</label>
                <CustomSelect
                  icon={Target}
                  placeholder="Select Campaign"
                  value={formData.campaignId}
                  onChange={(val) => setFormData({ ...formData, campaignId: val })}
                  options={
                    campaigns.length > 0
                      ? campaigns.map((c) => ({ label: c.name, value: c._id || c.id }))
                      : [
                          { label: "test", value: "test" },
                          { label: "Test Campaign", value: "Test Campaign" },
                          { label: "Campaign No 1", value: "Campaign No 1" },
                          { label: "new Campaign", value: "new Campaign" },
                          { label: "General", value: "General" },
                          { label: "Damac Islands Launch", value: "Damac Islands Launch" },
                        ]
                  }
                />
              </div>

              {/* Nationality */}
              <div className="space-y-2">
                <label className={labelClasses}>Nationality</label>
                <CustomSelect
                  icon={Globe}
                  placeholder="Select Nationality"
                  value={formData.nationality}
                  onChange={(val) => setFormData({ ...formData, nationality: val })}
                  options={NATIONALITIES.map((n) => ({ label: n, value: n }))}
                />
              </div>

              {/* Budget Range */}
              <div className="space-y-2">
                <label className={labelClasses}>Budget Range</label>
                <CustomSelect
                  icon={Wallet}
                  placeholder="Select Budget"
                  value={formData.budgetRange}
                  onChange={(val) => setFormData({ ...formData, budgetRange: val })}
                  options={[
                    { label: "< 500K", value: "< 500K" },
                    { label: "500K - 1M", value: "500K - 1M" },
                    { label: "1M - 2M", value: "1M - 2M" },
                    { label: "2M+", value: "2M+" },
                  ]}
                />
              </div>

              {/* Property Category */}
              <div className="space-y-2">
                <label className={labelClasses}>Property Category</label>
                <div className="flex p-1 bg-[#FAF6F2] shadow-2xs border border-[#EAE2DB] rounded-xl">
                  {["Ready", "Off-plan"].map((cat) => (
                    <button
                      key={cat}
                      type="button"
                      onClick={() =>
                        setFormData({ ...formData, propertyCategory: cat })
                      }
                      className={`flex-1 py-2 text-xs font-bold rounded-lg transition-all cursor-pointer ${
                        formData.propertyCategory === cat
                          ? "bg-[#D4622C] text-white shadow-md shadow-[#D4622C]/25"
                          : "text-[#77716C] hover:text-[#191919] hover:bg-white/60"
                      }`}
                    >
                      {cat}
                    </button>
                  ))}
                </div>
              </div>

              {/* Property Type */}
              <div className="space-y-2">
                <label className={labelClasses}>Property Type</label>
                <CustomSelect
                  icon={Building2}
                  placeholder="Select Type"
                  value={formData.propertyType}
                  onChange={(val) => setFormData({ ...formData, propertyType: val })}
                  options={[
                    { label: "Apartment", value: "Apartment" },
                    { label: "Villa", value: "Villa" },
                    { label: "Townhouse", value: "Townhouse" },
                    { label: "Commercial", value: "Commercial" },
                  ]}
                />
              </div>

              {/* Emirate */}
              <div className="space-y-2">
                <label className={labelClasses}>Emirate</label>
                <CustomSelect
                  icon={MapPin}
                  placeholder="Select Emirate"
                  value={formData.emirate}
                  onChange={(val) => setFormData({ ...formData, emirate: val, areaOfInterest: [] })}
                  options={[
                    { label: "Dubai", value: "Dubai" },
                    { label: "Abu Dhabi", value: "Abu Dhabi" },
                  ]}
                />
              </div>

              {/* Area of Interest */}
              <div className="space-y-2 col-span-full">
                <label className={labelClasses}>Area of Interest (Up to 5)</label>
                {formData.emirate === "Dubai" || formData.emirate === "Abu Dhabi" ? (
                  <div className="p-4 bg-[#FAF6F2] shadow-2xs border border-[#EAE2DB] rounded-xl max-h-[160px] overflow-y-auto custom-scrollbar flex flex-wrap gap-2">
                    {(formData.emirate === "Dubai" ? DUBAI_AREAS : ABU_DHABI_AREAS).map((area) => {
                      const isSelected = Array.isArray(formData.areaOfInterest) && formData.areaOfInterest.includes(area);
                      return (
                        <button
                          key={area}
                          type="button"
                          onClick={() => {
                            const current = Array.isArray(formData.areaOfInterest) ? formData.areaOfInterest : [];
                            if (isSelected) {
                              setFormData({
                                ...formData,
                                areaOfInterest: current.filter((a) => a !== area),
                              });
                            } else if (current.length < 5) {
                              setFormData({
                                ...formData,
                                areaOfInterest: [...current, area],
                              });
                            }
                          }}
                          className={`px-3 py-1.5 text-xs font-bold rounded-full transition-all border cursor-pointer ${
                            isSelected
                              ? "bg-[#D4622C] text-white border-[#D4622C] shadow-sm shadow-[#D4622C]/20"
                              : "bg-white text-[#77716C] border-[#EAE2DB] hover:border-[#D4622C]/40 hover:text-[#D4622C]"
                          }`}
                        >
                          {area}
                        </button>
                      );
                    })}
                  </div>
                ) : (
                  <div className="relative">
                    <MapPin
                      size={16}
                      className="absolute left-4 top-1/2 -translate-y-1/2 text-[#77716C]"
                    />
                    <input
                      type="text"
                      placeholder={formData.emirate ? "Enter Area (comma separated)" : "Select emirate first"}
                      value={Array.isArray(formData.areaOfInterest) ? formData.areaOfInterest.join(", ") : formData.areaOfInterest}
                      onChange={(e) =>
                        setFormData({
                          ...formData,
                          areaOfInterest: e.target.value.split(",").map(s => s.trim()).filter(Boolean)
                        })
                      }
                      className={`${inputClasses} pl-11`}
                      disabled={!formData.emirate}
                    />
                  </div>
                )}
              </div>

              {/* Investor Type */}
              <div className="space-y-2">
                <label className={labelClasses}>Investor Type</label>
                <CustomSelect
                  icon={Star}
                  placeholder="Select Type"
                  value={formData.investorType}
                  onChange={(val) => setFormData({ ...formData, investorType: val })}
                  options={[
                    { label: "Investor", value: "Investor" },
                    { label: "End User", value: "End User" },
                  ]}
                />
              </div>

              {/* Timeline */}
              <div className="space-y-2">
                <label className={labelClasses}>Timeline</label>
                <CustomSelect
                  icon={Clock}
                  placeholder="Select Timeline"
                  value={formData.timeline}
                  onChange={(val) => setFormData({ ...formData, timeline: val })}
                  options={[
                    { label: "0-1 Month", value: "0-1 Month" },
                    { label: "1-2 Months", value: "1-2 Months" },
                    { label: "3+ Months", value: "3+ Months" },
                  ]}
                />
              </div>

              {/* CRM Integration */}
              {(isEnterpriseOrEmployee && userData?.isIntegrationEnabled && userData?.zapierWebhookUrl) && (
                <div className="col-span-full">
                  <label className="flex items-center gap-3 p-4 rounded-xl border border-[#EAE2DB] bg-[#FAF6F2] hover:bg-[#FCE9DF]/40 cursor-pointer transition-all group">
                    <div className="relative flex items-center justify-center">
                      <input
                        type="checkbox"
                        className="peer sr-only"
                        checked={pushToCRM}
                        onChange={(e) => setPushToCRM(e.target.checked)}
                      />
                      <div className="w-5 h-5 rounded-lg border border-[#EAE2DB] bg-white peer-checked:border-[#D4622C] peer-checked:bg-[#D4622C] transition-all flex items-center justify-center">
                        <svg
                          className={`w-3 h-3 text-white transition-transform ${
                            pushToCRM ? "scale-100" : "scale-0"
                          }`}
                          fill="none"
                          viewBox="0 0 24 24"
                          stroke="currentColor"
                          strokeWidth="3"
                        >
                          <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
                        </svg>
                      </div>
                    </div>
                    <div>
                      <h4 className="text-sm font-bold text-[#191919]">Save Lead to Salesforce CRM</h4>
                      <p className="text-[10px] text-[#77716C] mt-0.5 uppercase tracking-wider font-bold">Automatically push data via Zapier</p>
                    </div>
                  </label>
                </div>
              )}

              {/* Notes */}
              <div className="col-span-full space-y-2">
                <label className={labelClasses}>Notes</label>
                  <div className="relative">
                    <FileText
                      size={16}
                      className="absolute left-4 top-6 text-[#77716C] z-10 pointer-events-none"
                    />
                    <textarea
                      placeholder="Lead requirements..."
                      value={formData.notes}
                      onChange={(e) =>
                        setFormData({ ...formData, notes: e.target.value })
                      }
                      className={`${inputClasses} pl-12 min-h-[100px] py-4 resize-none`}
                    />
                  </div>
              </div>
            </div>
          </form>

          {/* Footer */}
          <div className="p-6 md:p-7 border-t border-[#EAE2DB] bg-[#FAF6F2]/80 backdrop-blur-sm flex items-center gap-4">
            <button
              type="button"
              onClick={onClose}
              className="flex-1 py-3.5 rounded-2xl text-xs font-bold uppercase tracking-widest text-[#77716C] bg-white border border-[#EAE2DB] hover:bg-[#FAF6F2] hover:text-[#191919] shadow-2xs transition-all cursor-pointer"
            >
              Cancel
            </button>
            <button
              type="button"
              onClick={handleSubmit}
              disabled={loading}
              className="flex-[2] py-3.5 rounded-2xl normal-case tracking-normal text-sm font-bold h-[48px] bg-gradient-to-r from-[#D4622C] to-[#E3743E] hover:from-[#BF5321] hover:to-[#D4622C] text-white shadow-lg shadow-[#D4622C]/25 transition-all flex items-center justify-center cursor-pointer disabled:opacity-50"
            >
              {loading ? (
                <Loader2 size={18} className="animate-spin text-white" />
              ) : (
                editLead ? "Update Lead" : "Save Lead"
              )}
            </button>
          </div>
        </motion.div>
      </motion.div>
      <IndividualLeads 
        isVisible={alert.isVisible}
        onClose={() => setAlert({ ...alert, isVisible: false })}
        message={alert.message}
        type={alert.type}
      />
    </AnimatePresence>
  );
}
