import "./globals.css";
import Providers from "./providers";
import { organizationSchema } from "@/lib/schema";
import SplashScreen from "@/components/SplashScreen";

export const metadata = {
  metadataBase: new URL("https://digitalbusinesscloudcard.com"),
  title: {
    default: "The Future of Business Networking Starts Here.",
    template: "%s | My Card Share",
  },
  description:
    "More Than a Digital Business Card. It's Your Networking & Lead Generation Platform.",
  keywords: [
    "digital business card",
    "NFC business card",
    "QR code business card",
    "professional networking",
    "contact management",
    "digital identity",
    "electronic business card",
    "virtual business card",
    "business card app",
    "NFC tap to share",
    "AI card scanner",
    "enterprise business cards",
    "team card management",
    "paperless business card",
  ],
  authors: [{ name: "Pentacloud", url: "https://pentacloud.com" }],
  creator: "Pentacloud",
  publisher: "Pentacloud",
  formatDetection: { email: false, address: false, telephone: false },
  openGraph: {
    title: "The Future of Business Networking Starts Here.",
    description:
      "More Than a Digital Business Card. It's Your Networking & Lead Generation Platform.",
    url: "https://digitalbusinesscloudcard.com",
    siteName: "My Card Share",
    locale: "en_US",
    type: "website",
    images: [
      {
        url: "/assets/og-image.png",
        width: 1200,
        height: 630,
        alt: "My Card Share — Digital Business Card Platform",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "The Future of Business Networking Starts Here.",
    description:
      "More Than a Digital Business Card. It's Your Networking & Lead Generation Platform.",
    images: ["/assets/og-image.png"],
    creator: "@pentacloud",
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      "max-video-preview": -1,
      "max-image-preview": "large",
      "max-snippet": -1,
    },
  },
  alternates: {
    canonical: "https://digitalbusinesscloudcard.com",
  },
  icons: {
    icon: "/logo/MYSHAREFAVO.png",
    apple: "/assets/apple-touch-icon.png",
  },
};

export const viewport = {
  themeColor: "#D4642C",
  width: "device-width",
  initialScale: 1,
};

export default function RootLayout({ children }) {
  const orgJsonLd = organizationSchema();

  return (
    <html lang="en" data-scroll-behavior="smooth" suppressHydrationWarning>
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link
          rel="preconnect"
          href="https://fonts.gstatic.com"
          crossOrigin="anonymous"
        />
        <link
          href="https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:opsz,wght@12..96,200..800&family=Plus+Jakarta+Sans:ital,wght@0,200..800;1,200..800&family=Space+Grotesk:wght@300..700&family=Inter:wght@300..900&family=Space+Mono:wght@400;700&display=swap"
          rel="stylesheet"
        />
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(orgJsonLd) }}
        />
      </head>
      <body className="antialiased" suppressHydrationWarning>
        <SplashScreen />
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
