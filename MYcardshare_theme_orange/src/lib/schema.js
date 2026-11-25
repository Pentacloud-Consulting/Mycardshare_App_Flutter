/* ═══════════════════════════════════════════════════════════
   JSON-LD Schema Generators — My Card Share
   Centralized structured data for SEO / AEO / GEO / LLM
   ═══════════════════════════════════════════════════════════ */

const SITE_URL = "https://digitalbusinesscloudcard.com";
const SITE_NAME = "My Card Share";
const LOGO_URL = `${SITE_URL}/assets/logo.png`;

// ── Organization (root layout) ───────────────────────────
export function organizationSchema() {
  return {
    "@context": "https://schema.org",
    "@type": "Organization",
    name: "Pentacloud",
    alternateName: "My Card Share",
    url: SITE_URL,
    logo: LOGO_URL,
    description:
      "My Card Share is the modern way to share your professional identity. Create, share, and manage stunning digital business cards with NFC, QR, and AI-powered scanning.",
    foundingDate: "2024",
    foundingLocation: {
      "@type": "Place",
      name: "Dubai, UAE",
    },
    sameAs: [
      "https://twitter.com/pentacloud",
      "https://linkedin.com/company/pentacloud",
      "https://github.com/pentacloud",
      "https://instagram.com/pentacloud",
    ],
    contactPoint: {
      "@type": "ContactPoint",
      contactType: "customer service",
      url: `${SITE_URL}/contact`,
    },
  };
}

// ── WebSite + SearchAction (home page) ───────────────────
export function websiteSchema() {
  return {
    "@context": "https://schema.org",
    "@type": "WebSite",
    name: SITE_NAME,
    url: SITE_URL,
    description:
      "Create, share, and manage digital business cards with NFC tap, QR scan, and AI-powered card scanning.",
    publisher: {
      "@type": "Organization",
      name: "Pentacloud",
      logo: { "@type": "ImageObject", url: LOGO_URL },
    },
    potentialAction: {
      "@type": "SearchAction",
      target: `${SITE_URL}/blog?q={search_term_string}`,
      "query-input": "required name=search_term_string",
    },
  };
}

// ── SoftwareApplication (features / home) ────────────────
export function softwareAppSchema() {
  return {
    "@context": "https://schema.org",
    "@type": "SoftwareApplication",
    name: "My Card Share",
    applicationCategory: "BusinessApplication",
    operatingSystem: "Web",
    url: SITE_URL,
    description:
      "Digital business card platform with NFC sharing, QR codes, AI card scanner, live analytics, and enterprise team management.",
    offers: {
      "@type": "Offer",
      price: "0",
      priceCurrency: "USD",
      description: "Free tier available — create one digital business card",
    },
  };
}

// ── FAQPage ──────────────────────────────────────────────
export function faqSchema(items) {
  return {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    mainEntity: items.map(({ question, answer }) => ({
      "@type": "Question",
      name: question,
      acceptedAnswer: {
        "@type": "Answer",
        text: answer,
      },
    })),
  };
}

// ── Article (blog detail) ────────────────────────────────
export function articleSchema({
  headline,
  description,
  slug,
  datePublished,
  dateModified,
  authorName = "Pentacloud Team",
  readTime,
}) {
  return {
    "@context": "https://schema.org",
    "@type": "Article",
    headline,
    description,
    url: `${SITE_URL}/blog/${slug}`,
    datePublished,
    dateModified: dateModified || datePublished,
    author: {
      "@type": "Organization",
      name: authorName,
      url: SITE_URL,
    },
    publisher: {
      "@type": "Organization",
      name: "Pentacloud",
      logo: { "@type": "ImageObject", url: LOGO_URL },
    },
    mainEntityOfPage: {
      "@type": "WebPage",
      "@id": `${SITE_URL}/blog/${slug}`,
    },
    timeRequired: readTime ? `PT${parseInt(readTime)}M` : undefined,
  };
}

// ── BreadcrumbList ───────────────────────────────────────
export function breadcrumbSchema(items) {
  return {
    "@context": "https://schema.org",
    "@type": "BreadcrumbList",
    itemListElement: items.map((item, i) => ({
      "@type": "ListItem",
      position: i + 1,
      name: item.name,
      item: item.url ? `${SITE_URL}${item.url}` : undefined,
    })),
  };
}

// ── Person / ProfilePage (public card) ───────────────────
export function personCardSchema({
  name,
  title,
  company,
  email,
  phone,
  website,
  avatar,
  slug,
}) {
  return {
    "@context": "https://schema.org",
    "@type": "Person",
    name,
    jobTitle: title,
    worksFor: company ? { "@type": "Organization", name: company } : undefined,
    email: email || undefined,
    telephone: phone || undefined,
    url: website || `${SITE_URL}/card/${slug}`,
    image: avatar || undefined,
    mainEntityOfPage: {
      "@type": "ProfilePage",
      "@id": `${SITE_URL}/card/${slug}`,
    },
  };
}

// ── Helper: render JSON-LD as a <script> tag string ──────
export function JsonLd({ data }) {
  return (
    <script
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(data) }}
    />
  );
}
