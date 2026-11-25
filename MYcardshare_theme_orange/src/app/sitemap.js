export default function sitemap() {
  const baseUrl = "https://digitalbusinesscloudcard.com";

  const staticRoutes = [
    { path: "", priority: 1.0, changeFrequency: "weekly" },
    { path: "/features", priority: 0.9, changeFrequency: "monthly" },
    { path: "/pricing", priority: 0.9, changeFrequency: "monthly" },
    { path: "/enterprise", priority: 0.85, changeFrequency: "monthly" },
    { path: "/about", priority: 0.7, changeFrequency: "monthly" },
    { path: "/contact", priority: 0.7, changeFrequency: "monthly" },
    { path: "/blog", priority: 0.8, changeFrequency: "weekly" },
  ];

  const blogSlugs = [
    "future-of-networking",
    "nfc-vs-qr",
    "enterprise-digital-cards",
    "design-your-identity",
  ];

  return [
    ...staticRoutes.map((route) => ({
      url: `${baseUrl}${route.path}`,
      lastModified: new Date(),
      changeFrequency: route.changeFrequency,
      priority: route.priority,
    })),
    ...blogSlugs.map((slug) => ({
      url: `${baseUrl}/blog/${slug}`,
      lastModified: new Date(),
      changeFrequency: "monthly",
      priority: 0.6,
    })),
  ];
}
