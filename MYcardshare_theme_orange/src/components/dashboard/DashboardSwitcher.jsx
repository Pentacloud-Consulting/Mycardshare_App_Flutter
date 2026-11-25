"use client";

import { useAuth } from "@/lib/auth-context";
import { isMasterAdmin, isEnterprise } from "@/lib/roles";
import IndividualDashboard from "./IndividualDashboard";
import CorporateDashboard from "./CorporateDashboard";

import { useEffect } from "react";
import { useRouter } from "next/navigation";

export default function DashboardSwitcher() {
  const { userData, loading, refreshUserData } = useAuth();
  const router = useRouter();

  useEffect(() => {
    // Only redirect if onboardingCompleted is explicitly false (new users).
    // Existing users without this field are treated as already onboarded.
    if (!loading && userData) {
      if (userData.onboardingCompleted === false) {
        console.log("[DashboardSwitcher] Onboarding incomplete, redirecting...");
        router.push("/onboarding");
        return;
      }
      const currentRole = userData.role || userData.type || "standard";
      if (isEnterprise(currentRole)) {
        console.log("[DashboardSwitcher] Enterprise admin detected, routing to /enterprise/dashboard...");
        router.push("/enterprise/dashboard");
        return;
      }
      if (isMasterAdmin(currentRole)) {
        console.log("[DashboardSwitcher] Master admin detected, routing to /master-admin/dashboard...");
        router.push("/master-admin/dashboard");
        return;
      }
    }
  }, [userData, loading, router]);

  if (loading) {
    return (
      <div className="min-h-[400px] flex items-center justify-center">
        <div className="flex flex-col items-center gap-4">
          <div className="w-12 h-12 border-4 border-[#FCE9DF] border-t-[#D4622C] rounded-full animate-spin" />
          <p className="text-[#77716C] font-bold text-xs uppercase tracking-widest animate-pulse">
            Syncing Cloud Profile...
          </p>
        </div>
      </div>
    );
  }

  if (!userData) {
    return (
      <div className="min-h-[400px] flex flex-col items-center justify-center gap-4">
        <h2 className="text-[#191919] font-bold">Profile not found.</h2>
        <p className="text-[#77716C] text-sm">
          Please ensure you are logged in correctly.
        </p>
      </div>
    );
  }

  const role = userData.role || userData.type || "standard";

  console.log("[DashboardSwitcher] Detected Role:", role);

  // Corporate Console — Master Admins and Enterprise Admins
  if (isMasterAdmin(role) || isEnterprise(role)) {
    return (
      <CorporateDashboard
        userData={userData}
        onSignOut={() => {
          /* Handle signout */
        }}
      />
    );
  }

  // Default to Individual/Employee dashboard
  return (
    <IndividualDashboard
      userData={userData}
      refreshUserData={refreshUserData}
      onSignOut={() => {
        /* Handle signout */
      }}
    />
  );
}
