import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import PricingContent from "@/components/content/PricingContent";
import { JsonLd, breadcrumbSchema } from "@/lib/schema";

export const metadata = {
  title: "Pricing Plans — Free & Enterprise Digital Business Cards",
  description:
    "Simple, transparent pricing for My Card Share. Start free with one digital business card. Upgrade to Pro for unlimited cards and analytics. Enterprise plans with SSO and team management.",
  alternates: { canonical: "https://digitalbusinesscloudcard.com/pricing" },
  openGraph: {
    title: "My Card Share Pricing — Free, Pro & Enterprise Plans",
    description:
      "Start free. Upgrade when you're ready. Transparent pricing for individuals and enterprise teams.",
    url: "https://digitalbusinesscloudcard.com/pricing",
  },
};

export default function PricingPage() {
  const breadcrumbs = breadcrumbSchema([
    { name: "Home", url: "/" },
    { name: "Pricing" },
  ]);

  return (
    <>
      <JsonLd data={breadcrumbs} />
      <Navbar />
      <PricingContent />
      <Footer />
    </>
  );
}
