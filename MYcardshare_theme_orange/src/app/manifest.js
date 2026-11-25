export default function manifest() {
  return {
    name: "My Card Share — Digital Business Card Platform",
    short_name: "My Card Share",
    description:
      "Create, share, and manage stunning digital business cards with NFC, QR, and AI-powered scanning.",
    start_url: "/",
    display: "standalone",
    background_color: "#020617",
    theme_color: "#6366f1",
    icons: [
      {
        src: "/assets/icon-192.png",
        sizes: "192x192",
        type: "image/png",
      },
      {
        src: "/assets/icon-512.png",
        sizes: "512x512",
        type: "image/png",
      },
    ],
  };
}
