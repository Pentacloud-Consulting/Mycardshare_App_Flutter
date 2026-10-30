// @ts-nocheck
/**
 * Backend Sync Handler for Save Contact / vCard RFC 6350 Generation
 * Compatible with Next.js App Router API route (/api/sync/save-contact)
 */

export interface SaveContactPayload {
  fullName: string;
  phone: string;
  email?: string;
  company?: string;
  jobTitle?: string;
  website?: string;
  bio?: string;
  avatarUrl?: string;
}

export function generateVCard(payload: SaveContactPayload): string {
  const cleanPhone = payload.phone.replace(/[^\d+]/g, '').trim();
  const nameParts = payload.fullName.trim().split(' ');
  const firstName = nameParts[0] || payload.fullName;
  const lastName = nameParts.length > 1 ? nameParts.slice(1).join(' ') : '';

  const lines = [
    'BEGIN:VCARD',
    'VERSION:3.0',
    `FN:${payload.fullName}`,
    `N:${lastName};${firstName};;;`,
  ];

  if (payload.company) lines.push(`ORG:${payload.company}`);
  if (payload.jobTitle) lines.push(`TITLE:${payload.jobTitle}`);
  if (cleanPhone) lines.push(`TEL;TYPE=CELL,VOICE,PREF:${cleanPhone}`);
  if (payload.email) lines.push(`EMAIL;TYPE=WORK,INTERNET:${payload.email}`);
  if (payload.website) lines.push(`URL:${payload.website}`);
  if (payload.bio) lines.push(`NOTE:${payload.bio.replace(/\n/g, '\\n')}`);
  if (payload.avatarUrl) lines.push(`PHOTO;VALUE=URI:${payload.avatarUrl}`);

  lines.push('END:VCARD');
  return lines.join('\r\n') + '\r\n';
}

