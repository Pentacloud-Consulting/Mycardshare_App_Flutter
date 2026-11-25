import { notFound } from "next/navigation";
import cardService from "@/backend/services/card.service";
import PublicCardView from "@/components/card/PublicCardView";
import { JsonLd, personCardSchema, breadcrumbSchema } from "@/lib/schema";
export const dynamic = "force-dynamic";

/* ── Dynamic Metadata for each public card ────────────────── */
export async function generateMetadata({ params }) {
  const { slug } = await params;

  try {
    const card = await cardService.getCardBySlug(slug);

    if (!card || card.cardStatus !== "Published") {
      return { title: "Card Not Found | My Card Share" };
    }

    const fullName =
      card.fullName ||
      [card.firstName, card.lastName].filter(Boolean).join(" ") ||
      "Professional";
    const jobInfo = [card.jobTitle || card.title, card.companyName || card.company]
      .filter(Boolean)
      .join(" at ");

    return {
      title: `${fullName} — Digital Business Card`,
      description: jobInfo
        ? `${fullName} is ${jobInfo}. View their digital business card, connect via QR, and save their contact details instantly with My Card Share.`
        : `View ${fullName}'s digital business card on My Card Share. Connect via QR scan and save their contact details instantly.`,
      alternates: { canonical: `https://digitalbusinesscloudcard.com/card/${slug}` },
      openGraph: {
        title: `${fullName} — Digital Business Card | My Card Share`,
        description: jobInfo
          ? `${fullName} — ${jobInfo}. Digital business card powered by My Card Share.`
          : `${fullName}'s digital business card powered by My Card Share.`,
        url: `https://digitalbusinesscloudcard.com/card/${slug}`,
        type: "profile",
        images:
          card.avatarUrl || card.avatar
            ? [
                {
                  url: card.avatarUrl || card.avatar,
                  width: 400,
                  height: 400,
                  alt: `${fullName} profile photo`,
                },
              ]
            : [],
      },
      twitter: {
        card: "summary",
        title: `${fullName} — Digital Business Card`,
        description: jobInfo || `Digital business card on My Card Share`,
      },
      robots: { index: true, follow: true },
    };
  } catch {
    return { title: "Card Not Found | My Card Share" };
  }
}

/* ── Page Component ───────────────────────────────────────── */
export default async function CardPage({ params }) {
  const { slug } = await params;

  console.log(`🌐 [Card Page] Fetching slug: ${slug}`);

  let card;
  try {
    card = await cardService.getCardBySlug(slug);
  } catch (err) {
    console.error(`[Card Page] DB error for slug "${slug}":`, err);
    notFound();
  }

  if (!card) {
    console.warn(`❌ [Card Page] Card not live or missing. Slug: ${slug}`);
    notFound();
  }

  if (card.cardStatus !== "Published") {
    console.warn(`❌ [Card Page Debug] Card exists but not Published. Slug: ${slug}, Status: ${card.cardStatus}`);
    notFound();
  }

  // Increment views in background
  cardService.incrementViews(card._id).catch(err => 
    console.error(`[Card Page] Failed to increment views for ${slug}:`, err)
  );

  console.log(`✅ [Card Page] Rendering card for: ${card.fullName || card.firstName}`);

  // Safely serialize — MongoDB ObjectIds and Dates are not JSON-serializable.
  // Convert _id and any Date fields to strings before the server→client boundary.
  let cardPlain;
  try {
    cardPlain = JSON.parse(
      JSON.stringify(card, (key, value) => {
        // Convert ObjectId instances to string
        if (value && typeof value === "object" && value._bsontype) {
          return value.toString();
        }
        // Convert Date instances to ISO string
        if (value instanceof Date) {
          return value.toISOString();
        }
        return value;
      })
    );
  } catch (err) {
    console.error(`[Card Page] Serialization error for slug "${slug}":`, err);
    notFound();
  }

  const fullName =
    cardPlain.fullName ||
    [cardPlain.firstName, cardPlain.lastName].filter(Boolean).join(" ") ||
    "Professional";

  const personJsonLd = personCardSchema({
    name: fullName,
    title: cardPlain.jobTitle || cardPlain.title,
    company: cardPlain.companyName || cardPlain.company,
    email: cardPlain.workEmail || cardPlain.email,
    phone: cardPlain.workPhone || cardPlain.phone,
    website: cardPlain.website,
    avatar: cardPlain.avatarUrl || cardPlain.avatar,
    slug,
  });

  const breadcrumbs = breadcrumbSchema([
    { name: "Home", url: "/" },
    { name: `${fullName}'s Card` },
  ]);

  return (
    <main className="min-h-screen bg-[var(--color-aurora-bg)] flex items-center justify-center p-2 sm:p-4">
      <JsonLd data={personJsonLd} />
      <JsonLd data={breadcrumbs} />
      <div className="w-full max-w-[420px] flex justify-center">
        <PublicCardView data={cardPlain} />
      </div>
    </main>
  );
}
