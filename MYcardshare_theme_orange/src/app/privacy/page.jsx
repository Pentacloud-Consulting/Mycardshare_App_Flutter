import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";

export const metadata = {
  title: "Privacy Policy — My Card Share",
  description:
    "How My Card Share collects, uses, and protects your personal and professional data across our digital business card platform.",
  alternates: { canonical: "https://digitalbusinesscloudcard.com/privacy" },
};

const SECTIONS = [
  {
    title: "1. Data we collect",
    body:
      "We collect only what is necessary to deliver the service: your name, email, optional phone number, profile photo, job title, organization, and public card content you choose to share. Authentication identifiers are provided by Firebase Authentication.",
  },
  {
    title: "2. How we use your data",
    body:
      "Your data is used to create and render your digital business card, power QR exchanges, sync contacts to your vault, and provide analytics to you and your organization admin (if linked).",
  },
  {
    title: "3. Storage and security",
    body:
      "Account data is stored in Google Firebase (Firestore + Auth). Card content and contact records are stored in MongoDB Atlas. Connections are encrypted in transit using TLS 1.2+.",
  },
  {
    title: "4. Sharing with third parties",
    body:
      "We never sell your data. We share only with the processors required to run the platform (Google, MongoDB, Vercel). If you add your card to Apple/Google/Samsung Wallet, the wallet provider receives the data necessary to render your pass.",
  },
  {
    title: "5. Your rights",
    body:
      "You can edit, export, or permanently delete your profile at any time from the Settings page. For organization-linked accounts, admins can remove your employee linkage, which clears your company association.",
  },
  {
    title: "6. Contact",
    body:
      "For privacy questions or deletion requests, email privacy@pentacloud.ai. We respond within 30 days.",
  },
];

export default function PrivacyPage() {
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
              Privacy Policy
            </h1>
            <p className="mt-4 text-sm text-white/40">
              Effective: April 1, 2026 · Updated quarterly.
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
