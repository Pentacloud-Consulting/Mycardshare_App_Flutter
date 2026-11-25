/* ═══════════════════════════════════════════════════════════
   llms.txt — Machine-readable site summary for LLM crawlers
   Convention: https://llmstxt.org
   ═══════════════════════════════════════════════════════════ */

export async function GET() {
  const content = `# My Card Share

> My Card Share is a digital business card platform that lets professionals create, share, and manage stunning digital identities using NFC, QR codes, and AI-powered card scanning.

## About

My Card Share replaces paper business cards with intelligent, connected digital identities. Founded in Dubai, the platform empowers professionals and teams worldwide.

## Key Features

- **Digital Identity Card**: Mobile-first digital business cards with custom themes, brand colors, and professional layouts
- **One-Tap NFC Sharing**: Share via NFC tap, QR scan, link, AirDrop, WhatsApp, or email
- **AI Card Scanner**: Camera-based OCR extracts contact details from paper cards in seconds
- **Live Analytics**: Real-time tracking of views, taps, saves, and shares with geographic breakdown
- **Enterprise Management**: Bulk team deployment, role-based permissions, SSO integration, brand compliance
- **Custom Themes**: 50+ premium themes with custom colors, fonts, and layouts

## Pages

- [Home](https://digitalbusinesscloudcard.com/): Landing page with product overview
- [Features](https://digitalbusinesscloudcard.com/features): Full platform feature list
- [Pricing](https://digitalbusinesscloudcard.com/pricing): Free and enterprise pricing plans
- [Enterprise](https://digitalbusinesscloudcard.com/enterprise): Enterprise team management and SSO
- [Blog](https://digitalbusinesscloudcard.com/blog): Insights on digital networking and identity
- [About](https://digitalbusinesscloudcard.com/about): Company mission and values
- [Contact](https://digitalbusinesscloudcard.com/contact): Get in touch

## Technical

- Platform: Next.js 15 (React 19)
- Authentication: Firebase Auth
- Database: MongoDB
- Hosting: High-performance cloud infrastructure
- Security: 256-bit AES encryption and robust data protection
`;

  return new Response(content, {
    headers: {
      "Content-Type": "text/plain; charset=utf-8",
      "Cache-Control": "public, max-age=86400",
    },
  });
}
