import type { Metadata } from "next";
import { WaitlistForm } from "@/components/marketing/waitlist-form";

export const metadata: Metadata = {
  title: "RAWWERS — book a photographer, or get booked",
  description:
    "A marketplace for photography where you can see the work before you book, and photographers keep control of their pricing."
};

/**
 * The public landing page.
 *
 * Deliberately contains no claims that are not yet true: no testimonials,
 * no photographer count, no "trusted by" line. The product has not
 * launched, and inventing social proof on the page that asks people to
 * trust you is the wrong trade.
 *
 * Nothing here touches /api/admin/*. The admin panel and this page share
 * a Next app and nothing else - no shared client, no shared session, and
 * the admin key exists only in the server-side proxy that these pages
 * never call.
 */
export default function HomePage() {
  return (
    <div className="mx-auto max-w-3xl space-y-16 py-10">
      <section className="space-y-5">
        <p className="text-sm uppercase tracking-widest text-neutral-500">RAWWERS</p>
        <h1 className="text-4xl font-semibold leading-tight sm:text-5xl">
          You should see the photographs before you book the photographer.
        </h1>
        <p className="max-w-xl text-lg text-neutral-400">
          Most directories show you a price range and a bio. You are hiring someone for how
          they see — so RAWWERS leads with the work, and tells you what a shoot actually
          costs before you enquire.
        </p>
      </section>

      <section className="grid gap-6 sm:grid-cols-2">
        <div className="space-y-2">
          <h2 className="text-lg font-medium">If you are booking</h2>
          <p className="text-sm text-neutral-400">
            Browse by what you need photographed. Every listing shows real work, the
            photographer&apos;s actual rate, and what a set of 25 or 50 photos comes to — not a
            &ldquo;from&rdquo; price that changes once you ask.
          </p>
        </div>
        <div className="space-y-2">
          <h2 className="text-lg font-medium">If you are shooting</h2>
          <p className="text-sm text-neutral-400">
            You set your rate. Pricing tapers as a client selects more photos, so a bigger
            job is worth taking without you having to invent a discount on the spot. You are
            paid after the client has their photos, not months later.
          </p>
        </div>
      </section>

      <section className="space-y-4">
        <div>
          <h2 className="text-2xl font-semibold">We are opening one city at a time</h2>
          <p className="mt-2 max-w-xl text-sm text-neutral-400">
            A marketplace is no use to anyone half-full, so we launch a city once there are
            enough photographers in it to be worth browsing. Tell us where you are and we
            will come to you sooner.
          </p>
        </div>
        <WaitlistForm />
      </section>
    </div>
  );
}
