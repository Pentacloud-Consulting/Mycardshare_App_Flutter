export default function robots() {
  return {
    rules: [
      {
        userAgent: "*",
        allow: "/",
        disallow: [
          "/portal/",
          "/api/",
          "/login",
          "/signup",
          "/onboarding",
          "/reset-password",
          "/ui-preview",
        ],
      },
    ],
    sitemap: "https://digitalbusinesscloudcard.com/sitemap.xml",
  };
}
