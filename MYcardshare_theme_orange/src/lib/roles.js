/**
 * Centralized Role Helpers for RBAC v2
 *
 * Role strings:
 *   "master-admin"   — Platform master admin (admin@pentcloud.me)
 *   "enterprise"     — Enterprise company admin
 *   "employee"       — Company team member
 *   "individual"     — Personal card holder
 *   "standard"       — New/unfinished user
 *
 * Legacy support: super_admin, master_admin, platform_admin, admin
 */

const MASTER_ADMIN_EMAIL = "admin@pentcloud.me";

export function isMasterAdmin(role) {
  const r = (role || "").toLowerCase();
  return (
    r === "master-admin" ||
    r === "super_admin" ||
    r === "master_admin" ||
    r === "platform_admin"
  );
}

export function isMasterAdminEmail(email) {
  return (email || "").toLowerCase().trim() === MASTER_ADMIN_EMAIL;
}

export function isEnterprise(role) {
  const r = (role || "").toLowerCase();
  return r === "enterprise" || r === "admin";
}

export function isEmployee(role) {
  return (role || "").toLowerCase() === "employee";
}

export function isIndividual(role) {
  const r = (role || "").toLowerCase();
  return r === "individual" || r === "standard" || r === "" || !r;
}

export function isApproved(status) {
  const s = (status || "").toLowerCase();
  return s === "approved" || s === "active";
}

export function isPendingApproval(role, status) {
  if (!isEnterprise(role)) return false;
  return !isApproved(status);
}

export { MASTER_ADMIN_EMAIL };
