import HomeContent from "@/components/Home/HomeContent";
import { JsonLd, websiteSchema, softwareAppSchema } from "@/lib/schema";

export const metadata = {
  title: "My Card Share — Create & Share Digital Business Cards | QR & Link",
  description:
    "My Card Share is the global standard for digital business cards. Create stunning digital cards, share via QR scan, and manage contacts with AI-powered scanning. Free to start.",
  alternates: {
    canonical: "https://digitalbusinesscloudcard.com",
  },
  openGraph: {
    title: "My Card Share — Digital Business Card Platform",
    description:
      "Create, share, and capture contacts with digital business cards via QR scan and AI-powered card scanning.",
    url: "https://digitalbusinesscloudcard.com",
  },
};

export default function HomePage() {
  return (
    <>
      <JsonLd data={websiteSchema()} />
      <JsonLd data={softwareAppSchema()} />
      <HomeContent />
    </>
  );
}
