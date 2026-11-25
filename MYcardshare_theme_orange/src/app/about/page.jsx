import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import { JsonLd, breadcrumbSchema } from "@/lib/schema";

export const metadata = {
  title: "About Pentacloud — Digital Business Card Company",
  description:
    "Pentacloud is on a mission to replace paper business cards with intelligent digital identities. Founded in Dubai, empowering professionals with NFC, QR, and AI technology.",
  alternates: { canonical: "https://digitalbusinesscloudcard.com/about" },
  openGraph: {
    title: "About Pentacloud — Our Mission & Story",
    description:
      "Learn how Pentacloud is revolutionizing professional networking with modern digital business cards.",
    url: "https://digitalbusinesscloudcard.com/about",
  },
};

export default function AboutPage() {
  const breadcrumbs = breadcrumbSchema([
    { name: "Home", url: "/" },
    { name: "About" },
  ]);

  return (
    <>
      <JsonLd data={breadcrumbs} />
      <Navbar />
      <section className="pt-40 pb-24 bg-slate-50 relative overflow-hidden">
        {/* Subtle background decoration */}
        <div className="absolute inset-0 overflow-hidden pointer-events-none">
          <div className="absolute w-[800px] h-[800px] rounded-full -top-96 -right-96 bg-[radial-gradient(circle,rgba(56,189,248,0.1),transparent_70%)] filter blur-3xl" />
        </div>

        <div className="max-w-4xl mx-auto px-6 relative z-10">
          <div className="text-center mb-16">
            <h1
              className="text-5xl font-black text-slate-800 mb-6 tracking-tight"
            >
              About Pentacloud
            </h1>
            <p className="text-xl text-slate-500 font-medium">
              Building the modern standard for digital business card
              sharing.
            </p>
          </div>

          {/* Story */}
          <div className="space-y-12">
            <div className="rounded-[2rem] p-10 bg-white border border-slate-200 shadow-xl shadow-slate-200/50">
              <h2 className="text-3xl font-black text-slate-800 mb-6 tracking-tight">
                Our Mission
              </h2>
              <p className="text-lg leading-relaxed text-slate-600 font-medium">
                We believe professional identity should be as dynamic as the
                people behind it. Founded in Dubai, Pentacloud is on a mission
                to replace static business cards with intelligent, connected,
                and beautiful digital identities that adapt to every
                interaction.
              </p>
            </div>

            {/* Values */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              {[
                {
                  title: "Innovation First",
                  desc: "We push the boundaries of what's possible with NFC, AI, and cloud technology.",
                  color: "#6366f1",
                },
                {
                  title: "Privacy by Design",
                  desc: "Your data is yours. 256-bit encryption, SOC 2 compliant, zero third-party access.",
                  color: "#06b6d4",
                },
                {
                  title: "Global by Default",
                  desc: "Connect across borders. Built for global networking.",
                  color: "#10d9a8",
                },
              ].map(({ title, desc, color }) => (
                <div
                  key={title}
                  className="rounded-[2rem] p-8 bg-slate-50 border border-slate-200 hover:border-sky-300 hover:shadow-lg transition-all duration-300 group"
                >
                  <div
                    className="w-12 h-12 rounded-2xl flex items-center justify-center mb-6 shadow-sm transition-transform duration-300 group-hover:scale-110"
                    style={{ background: `${color}15` }}
                  >
                    <div
                      className="w-4 h-4 rounded-full"
                      style={{ background: color, boxShadow: `0 0 10px ${color}80` }}
                    />
                  </div>
                  <h3 className="text-xl font-bold text-slate-800 mb-3 tracking-tight">
                    {title}
                  </h3>
                  <p className="text-sm leading-relaxed text-slate-500 font-medium">
                    {desc}
                  </p>
                </div>
              ))}
            </div>

            {/* Stats */}
            <div className="rounded-[2.5rem] p-10 flex flex-wrap justify-around gap-8 bg-sky-50 border border-sky-100 shadow-xl shadow-sky-900/5 relative overflow-hidden">
              <div className="absolute inset-0 bg-gradient-to-r from-sky-400/5 to-indigo-500/5" />
              {[
                { val: "Instant", label: "QR & Link Sharing" },
                { val: "Paperless", label: "Eco-Friendly Networking" },
                { val: "256-bit", label: "AES Encryption" },
                { val: "Global", label: "Borderless Reach" },
              ].map(({ val, label }) => (
                <div key={label} className="text-center relative z-10">
                  <div className="text-4xl font-black bg-clip-text text-transparent bg-gradient-to-r from-sky-500 to-indigo-600 mb-2">
                    {val}
                  </div>
                  <div className="text-sm font-bold uppercase tracking-widest text-slate-500">
                    {label}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>
      <Footer />
    </>
  );
}
