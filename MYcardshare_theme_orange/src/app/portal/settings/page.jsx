"use client";

import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { motion } from "framer-motion";
import { useAuth } from "@/lib/auth-context";
import {
  Settings,
  Palette,
  Globe,
  Bell,
  Shield,
  Lock,
  Save,
  Loader2,
  ChevronRight,
  ToggleLeft,
  ToggleRight,
} from "lucide-react";
import { UiloraBrandButton } from "@/components/UIComponents/Button/tsx/UiloraModernButtons";
import { authFetch, parseFetchJson, toUserMessage } from "@/lib/api";
import ProfileSuccess from "@/components/Popup/ProfileSuccess";
import ChangePasswordModal from "@/components/Popup/ChangePasswordModal";

/* ═══════════════════════════════════════════════════════════
   SETTINGS — UILORA Settings Cards
   ═══════════════════════════════════════════════════════════ */



function Toggle({ enabled, onToggle, label, desc }) {
  return (
    <div className="flex items-center justify-between py-3 border-b border-[#EAE2DB]/60 last:border-0">
      <div className="pr-3">
        <div className="text-sm font-bold text-[#191919]">{label}</div>
        <div className="text-xs text-[#77716C] mt-0.5">{desc}</div>
      </div>
      <button
        type="button"
        onClick={onToggle}
        className={`w-11 h-6 flex items-center rounded-full p-1 cursor-pointer transition-colors duration-200 shrink-0 ${
          enabled ? "bg-[#D4622C]" : "bg-[#EAE2DB]"
        }`}
      >
        <div
          className={`bg-white w-4 h-4 rounded-full shadow-sm transform transition-transform duration-200 ${
            enabled ? "translate-x-5" : "translate-x-0"
          }`}
        />
      </button>
    </div>
  );
}

export default function SettingsPage() {
  const { userData, refreshUserData } = useAuth();
  const [saving, setSaving] = useState(false);
  const [slug, setSlug] = useState("");
  const [isIntegrationEnabled, setIsIntegrationEnabled] = useState(false);
  const [zapierWebhookUrl, setZapierWebhookUrl] = useState("");
  const [notifications, setNotifications] = useState(true);
  const [analytics, setAnalytics] = useState(true);
  const [twoFactor, setTwoFactor] = useState(false);
  const [isDeleting, setIsDeleting] = useState(false);
  const [showSuccess, setShowSuccess] = useState(false);
  const [showPasswordModal, setShowPasswordModal] = useState(false);
  const router = useRouter();

  // Sync slug from userData
  useEffect(() => {
    if (userData?.cardSlug) {
      setSlug(userData.cardSlug);
    }
    if (userData?.isIntegrationEnabled !== undefined) {
      setIsIntegrationEnabled(userData.isIntegrationEnabled);
    }
    if (userData?.zapierWebhookUrl) {
      setZapierWebhookUrl(userData.zapierWebhookUrl);
    }
  }, [userData]);

  const handleSave = async () => {
    setSaving(true);
    try {
      const res = await authFetch("/api/user/me", {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          cardSlug: slug,
          ...(userData?.role === "enterprise" && {
            isIntegrationEnabled,
            zapierWebhookUrl,
          }),
        }),
      });
      const data = await parseFetchJson(res);

      if (res.ok && data.success !== false) {
        await refreshUserData();
        setShowSuccess(true);
      } else {
        alert(toUserMessage(data.error, "Failed to update settings"));
      }
    } catch (err) {
      console.error("Settings save failed:", err);
      alert("Failed to update settings.");
    } finally {
      setSaving(false);
    }
  };

  const handleDeleteAccount = async () => {
    const confirmed = window.confirm(
      "Are you absolutely sure you want to delete your account? This action is irreversible and all your data will be permanently removed.",
    );

    if (!confirmed) return;

    setIsDeleting(true);
    try {
      const response = await authFetch("/api/user/me", {
        method: "DELETE",
      });

      const result = await parseFetchJson(response);
      if (result.success) {
        // Clear local storage/session if necessary
        // Redirect to landing page
        window.location.href = "/";
      } else {
        alert(
          `Failed to delete account: ${toUserMessage(result.error, "Unknown error")}`,
        );
      }
    } catch (error) {
      console.error("Error deleting account:", error);
      alert("An error occurred while deleting your account.");
    } finally {
      setIsDeleting(false);
    }
  };

  return (
    <div className="max-w-6xl mx-auto space-y-4 sm:space-y-5">
      {/* Page Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl sm:text-2xl font-black tracking-tight text-[#191919]">
            Settings
          </h1>
          <p className="text-xs text-[#77716C] mt-0.5">
            Manage your account preferences and security.
          </p>
        </div>
        <UiloraBrandButton
          onClick={handleSave}
          disabled={saving}
          className="px-5 py-2 normal-case tracking-normal text-xs font-bold shadow-sm"
        >
          {saving ? (
            <Loader2 size={13} className="animate-spin" />
          ) : (
            <Save size={13} />
          )}
          {saving ? "Saving..." : "Save Changes"}
        </UiloraBrandButton>
      </div>

      {/* 2-Column Balanced Grid: Fits Entire Settings in One Viewport */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 sm:gap-5">
        {/* Left Column: URL & Notifications */}
        <div className="space-y-4 sm:space-y-5">
          {/* 1. Card URL */}
          <div className="bg-white border border-[#EAE2DB] rounded-3xl p-5 sm:p-6 shadow-xs transition-all">
            <div className="flex items-center gap-3 mb-4">
              <div className="w-9 h-9 rounded-xl flex items-center justify-center text-[#D4622C] bg-[#FCE9DF] border border-[#EAE2DB] shadow-2xs">
                <Globe size={16} />
              </div>
              <div>
                <h3 className="text-sm font-black text-[#191919]">
                  Card URL
                </h3>
                <p className="text-[11px] text-[#77716C]">
                  Your public digital business card link
                </p>
              </div>
            </div>
            <div>
              <label className="block text-[10px] font-black uppercase tracking-wider text-[#77716C] mb-1.5">
                Custom URL Slug
              </label>
              <div className="flex items-center rounded-2xl bg-[#FAF6F2] border border-[#EAE2DB] overflow-hidden focus-within:bg-white focus-within:border-[#D4622C] focus-within:ring-2 focus-within:ring-[#D4622C]/20 transition-all shadow-2xs">
                <span className="px-3.5 py-2.5 text-xs font-bold text-[#77716C] border-r border-[#EAE2DB] bg-black/[0.02] shrink-0">
                  mycardshare.io/
                </span>
                <input
                  type="text"
                  placeholder="your-name"
                  value={slug}
                  onChange={(e) => setSlug(e.target.value)}
                  className="w-full bg-transparent border-none px-3.5 py-2.5 text-xs sm:text-sm font-semibold text-[#191919] placeholder:text-[#77716C]/50 focus:ring-0 outline-none transition-all"
                />
              </div>
            </div>
          </div>

          {/* 2. Notifications */}
          <div className="bg-white border border-[#EAE2DB] rounded-3xl p-5 sm:p-6 shadow-xs transition-all">
            <div className="flex items-center gap-3 mb-3">
              <div className="w-9 h-9 rounded-xl flex items-center justify-center text-[#D4622C] bg-[#FCE9DF] border border-[#EAE2DB] shadow-2xs">
                <Bell size={16} />
              </div>
              <div>
                <h3 className="text-sm font-black text-[#191919]">
                  Notifications
                </h3>
                <p className="text-[11px] text-[#77716C]">
                  Alerts & weekly summary preferences
                </p>
              </div>
            </div>
            <Toggle
              label="Push Notifications"
              desc="Get notified when someone views your card"
              enabled={notifications}
              onToggle={() => setNotifications(!notifications)}
            />
            <Toggle
              label="Analytics Reports"
              desc="Weekly performance summary via email"
              enabled={analytics}
              onToggle={() => setAnalytics(!analytics)}
            />
          </div>

          {/* 3. Integration Settings (Enterprise Only) */}
          {userData?.role === "enterprise" && (
            <div className="bg-white border border-[#EAE2DB] rounded-3xl p-5 sm:p-6 shadow-xs transition-all">
              <div className="flex items-center gap-3 mb-3">
                <div className="w-9 h-9 rounded-xl flex items-center justify-center text-[#D4622C] bg-[#FCE9DF] border border-[#EAE2DB] shadow-2xs">
                  <Globe size={16} />
                </div>
                <div>
                  <h3 className="text-sm font-black text-[#191919]">
                    CRM Integration
                  </h3>
                  <p className="text-[11px] text-[#77716C]">
                    Salesforce & Zapier connection
                  </p>
                </div>
              </div>
              <Toggle
                label="Enable Integration"
                desc="Unlock custom integrations like Salesforce via Zapier."
                enabled={isIntegrationEnabled}
                onToggle={() => setIsIntegrationEnabled(!isIntegrationEnabled)}
              />

              {isIntegrationEnabled && (
                <div className="mt-3 pt-3 border-t border-[#EAE2DB]/60">
                  <label className="block text-[10px] font-black uppercase tracking-wider text-[#77716C] mb-1.5">
                    Zapier Webhook URL
                  </label>
                  <input
                    type="text"
                    placeholder="https://hooks.zapier.com/hooks/catch/..."
                    value={zapierWebhookUrl}
                    onChange={(e) => setZapierWebhookUrl(e.target.value)}
                    className="w-full bg-[#FAF6F2] border border-[#EAE2DB] rounded-2xl px-3.5 py-2.5 text-xs text-[#191919] placeholder:text-[#77716C]/50 focus:bg-white focus:border-[#D4622C] focus:ring-2 focus:ring-[#D4622C]/20 outline-none transition-all shadow-2xs"
                  />
                  <p className="text-[10px] text-[#77716C] font-semibold mt-1">
                    Connect your CRM by pasting a Zapier Catch Hook URL.
                  </p>
                </div>
              )}
            </div>
          )}
        </div>

        {/* Right Column: Security & Danger Zone */}
        <div className="space-y-4 sm:space-y-5">
          {/* 4. Security */}
          <div className="bg-white border border-[#EAE2DB] rounded-3xl p-5 sm:p-6 shadow-xs transition-all">
            <div className="flex items-center gap-3 mb-3">
              <div className="w-9 h-9 rounded-xl flex items-center justify-center text-[#D4622C] bg-[#FCE9DF] border border-[#EAE2DB] shadow-2xs">
                <Shield size={16} />
              </div>
              <div>
                <h3 className="text-sm font-black text-[#191919]">
                  Security & Access
                </h3>
                <p className="text-[11px] text-[#77716C]">
                  Two-factor authentication and passwords
                </p>
              </div>
            </div>
            <Toggle
              label="Two-Factor Authentication"
              desc="Add an extra layer of security to your account"
              enabled={twoFactor}
              onToggle={() => setTwoFactor(!twoFactor)}
            />
            <div className="pt-3 border-t border-[#EAE2DB]/60 mt-1 flex items-center justify-between">
              <div>
                <div className="text-sm font-bold text-[#191919]">Password</div>
                <div className="text-xs text-[#77716C]">Update your account password</div>
              </div>
              <button
                type="button"
                onClick={() => setShowPasswordModal(true)}
                className="px-3.5 py-1.5 rounded-xl text-xs font-bold text-[#D4622C] bg-[#FCE9DF] hover:bg-[#D4622C] hover:text-white border border-[#D4622C]/20 transition-all cursor-pointer flex items-center gap-1.5 shadow-2xs"
              >
                <Lock size={12} /> Change
              </button>
            </div>
          </div>

          {/* 5. Danger Zone */}
          <div className="bg-white border border-rose-200/80 rounded-3xl p-5 sm:p-6 shadow-xs transition-all relative overflow-hidden">
            <div className="flex items-center gap-3 mb-3">
              <div className="w-9 h-9 rounded-xl flex items-center justify-center text-rose-600 bg-rose-50 border border-rose-200/60 shadow-2xs">
                <Shield size={16} />
              </div>
              <div>
                <h3 className="text-sm font-black text-rose-600">
                  Danger Zone
                </h3>
                <p className="text-[11px] text-rose-500/80 font-medium">
                  Irreversible account actions
                </p>
              </div>
            </div>
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pt-3 border-t border-rose-100">
              <p className="text-xs text-[#77716C]">
                Permanently delete your profile, card link and all saved data.
              </p>
              <button
                type="button"
                onClick={handleDeleteAccount}
                disabled={isDeleting}
                className="px-4 py-2 rounded-xl text-xs font-bold cursor-pointer transition-all disabled:opacity-50 bg-rose-500 text-white hover:bg-rose-600 shadow-sm shadow-rose-500/20 shrink-0 text-center"
              >
                {isDeleting ? "Deleting..." : "Delete Account"}
              </button>
            </div>
          </div>
        </div>
      </div>

      <ProfileSuccess
        isVisible={showSuccess}
        onClose={() => setShowSuccess(false)}
      />

      <ChangePasswordModal
        isVisible={showPasswordModal}
        onClose={() => setShowPasswordModal(false)}
      />
    </div>
  );
}

