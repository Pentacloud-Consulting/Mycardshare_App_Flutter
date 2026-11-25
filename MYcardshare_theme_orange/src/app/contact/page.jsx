import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import ContactContent from "@/components/content/ContactContent";
import { JsonLd, breadcrumbSchema } from "@/lib/schema";

export const metadata = {
  title: "Contact Pentacloud — Get in Touch",
  description:
    "Have questions about My Card Share? Contact our team for support, enterprise demos, partnerships, or general inquiries. We respond within 24 hours.",
  alternates: { canonical: "https://digitalbusinesscloudcard.com/contact" },
  openGraph: {
    title: "Contact Pentacloud — We'd Love to Hear From You",
    description:
      "Reach out for support, enterprise demos, or partnership inquiries. Response within 24 hours.",
    url: "https://digitalbusinesscloudcard.com/contact",
  },
};

export default function ContactPage() {
  const breadcrumbs = breadcrumbSchema([
    { name: "Home", url: "/" },
    { name: "Contact" },
  ]);

  return (
    <>
      <JsonLd data={breadcrumbs} />
      <Navbar />
      <ContactContent />
      <Footer />
    </>
  );
}
