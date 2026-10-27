// @ts-nocheck
import { NextResponse } from 'next/server';

/**
 * ⚡ Live Web Backend Sync Route: Save Contact / vCard Generator
 * Endpoint: /api/sync/save-contact
 * Generates RFC 6350 standard vCard 3.0 (.vcf) for instant contact import without dialpad.
 */

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const fullName = searchParams.get('fullName') || searchParams.get('name') || 'Card Contact';
    const phone = searchParams.get('phone') || searchParams.get('phoneNumber') || '';
    const email = searchParams.get('email') || '';
    const company = searchParams.get('company') || searchParams.get('companyName') || '';
    const jobTitle = searchParams.get('jobTitle') || searchParams.get('title') || '';
    const website = searchParams.get('website') || searchParams.get('websiteUrl') || '';
    const bio = searchParams.get('bio') || '';
    const avatarUrl = searchParams.get('avatarUrl') || searchParams.get('photo') || '';

    const cleanPhone = phone.replace(/[^\d+]/g, '').trim();
    const nameParts = fullName.trim().split(' ');
    const firstName = nameParts[0] || fullName;
    const lastName = nameParts.length > 1 ? nameParts.slice(1).join(' ') : '';

    const vCardLines = [
      'BEGIN:VCARD',
      'VERSION:3.0',
      `FN:${fullName}`,
      `N:${lastName};${firstName};;;`,
    ];

    if (company) vCardLines.push(`ORG:${company}`);
    if (jobTitle) vCardLines.push(`TITLE:${jobTitle}`);
    if (cleanPhone) vCardLines.push(`TEL;TYPE=CELL,VOICE,PREF:${cleanPhone}`);
    if (email) vCardLines.push(`EMAIL;TYPE=WORK,INTERNET:${email}`);
    if (website) vCardLines.push(`URL:${website}`);
    if (bio) vCardLines.push(`NOTE:${bio.replace(/\n/g, '\\n')}`);
    if (avatarUrl) vCardLines.push(`PHOTO;VALUE=URI:${avatarUrl}`);

    vCardLines.push('END:VCARD');
    const vCardContent = vCardLines.join('\r\n') + '\r\n';

    const sanitizedFileName = fullName.replace(/[^a-zA-Z0-9_-]/g, '_');

    return new NextResponse(vCardContent, {
      status: 200,
      headers: {
        'Content-Type': 'text/vcard; charset=utf-8',
        'Content-Disposition': `attachment; filename="${sanitizedFileName}.vcf"`,
        'Cache-Control': 'no-cache, no-store, must-revalidate',
      },
    });
  } catch (error) {
    return NextResponse.json({ success: false, error: String(error) }, { status: 500 });
  }
}

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const fullName = body.fullName || body.name || 'Card Contact';
    const phone = body.phone || body.phoneNumber || '';
    const email = body.email || '';
    const company = body.company || body.companyName || '';
    const jobTitle = body.jobTitle || body.title || '';
    const website = body.website || body.websiteUrl || '';
    const bio = body.bio || '';
    const avatarUrl = body.avatarUrl || body.photo || '';

    const cleanPhone = phone.replace(/[^\d+]/g, '').trim();
    const nameParts = fullName.trim().split(' ');
    const firstName = nameParts[0] || fullName;
    const lastName = nameParts.length > 1 ? nameParts.slice(1).join(' ') : '';

    const vCardLines = [
      'BEGIN:VCARD',
      'VERSION:3.0',
      `FN:${fullName}`,
      `N:${lastName};${firstName};;;`,
    ];

    if (company) vCardLines.push(`ORG:${company}`);
    if (jobTitle) vCardLines.push(`TITLE:${jobTitle}`);
    if (cleanPhone) vCardLines.push(`TEL;TYPE=CELL,VOICE,PREF:${cleanPhone}`);
    if (email) vCardLines.push(`EMAIL;TYPE=WORK,INTERNET:${email}`);
    if (website) vCardLines.push(`URL:${website}`);
    if (bio) vCardLines.push(`NOTE:${bio.replace(/\n/g, '\\n')}`);
    if (avatarUrl) vCardLines.push(`PHOTO;VALUE=URI:${avatarUrl}`);

    vCardLines.push('END:VCARD');
    const vCardContent = vCardLines.join('\r\n') + '\r\n';

    return NextResponse.json({
      success: true,
      contact: {
        fullName,
        firstName,
        lastName,
        phone: cleanPhone,
        email,
        company,
        jobTitle,
        website,
        bio,
      },
      vCard: vCardContent,
    });
  } catch (error) {
    return NextResponse.json({ success: false, error: String(error) }, { status: 500 });
  }
}
