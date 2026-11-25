import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";

export const metadata = {
  title: "Terms of Service — My Card Share",
  description:
    "Terms governing use of the My Card Share digital business card platform for individuals, employees, and enterprise administrators.",
  alternates: { canonical: "https://digitalbusinesscloudcard.com/terms" },
};

const SECTIONS = [
  {
    title: "1. Acceptance",
    body:
      "By creating an account you agree to these Terms. If you use the service on behalf of an organization, you represent that you have authority to bind that organization.",
  },
  {
    title: "2. Account types",
    body:
      "Individual accounts manage a single identity. Employee accounts are linked to a parent organization via a voucher or invitation. Enterprise accounts provision and manage an organization's workforce on the platform.",
  },
  {
    title: "3. Acceptable use",
    body:
      "You may not use the service to impersonate others, publish unlawful content, send unsolicited bulk messages, attempt to break authentication, or reverse-engineer paid features. Violations may result in suspension.",
  },
  {
    title: "4. Content ownership",
    body:
      "You retain ownership of the content you publish (photos, bios, links). You grant Pentacloud a limited license to host and display it for the purpose of operating your digital business card.",
  },
  {
    title: "5. Paid features",
    body:
      "Certain features (custom domains, advanced analytics, bulk provisioning) may require a paid plan. Pricing and availability are listed on the Pricing page.",
  },
  {
    title: "6. Termination",
    body:
      "You may delete your account at any time from Settings. Pentacloud may suspend or terminate accounts that violate these Terms or abuse the service.",
  },
  {
    title: "7. Warranty disclaimer",
    body:
      "The service is provided \"as is\". We work hard on uptime but do not warrant uninterrupted or error-free operation.",
  },
  {
    title: "8. Contact",
    body:
      "For questions about these Terms, email legal@pentacloud.ai.",
  },
];

export default function TermsPage() {
  return (
    <>
      <Navbar />
      <section className="pt-40 pb-24" style={{ background: "var(--color-aurora-bg)" }}>
        <div className="max-w-3xl mx-auto px-6">
          <div className="text-center mb-16">
            <div className="text-xs font-bold uppercase tracking-[0.2em] text-sky-400 mb-3">
              Legal
            </div>
            <h1
              className="text-4xl md:text-5xl font-black text-white tracking-tighter"
              style={{ fontFamily: "var(--font-display)" }}
            >
              Terms of Service
            </h1>
            <p className="mt-4 text-sm text-white/40">
              Effective: April 1, 2026.
            </p>
          </div>

          <div className="space-y-6">
            {SECTIONS.map((s) => (
              <div
                key={s.title}
                className="rounded-2xl p-6 md:p-8 bg-white/[0.02] border border-white/5"
              >
                <h2 className="text-lg font-bold text-white mb-3">{s.title}</h2>
                <p className="text-sm leading-relaxed text-white/60">{s.body}</p>
              </div>
            ))}
          </div>
        </div>
      </section>
      <Footer />
    </>
  );
}
