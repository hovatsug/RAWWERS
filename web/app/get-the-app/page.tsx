import type { Metadata } from "next";
import Link from "next/link";

export const metadata: Metadata = {
  title: "RAWWERS is in the app",
  description: "Booking, your photos and your credit live in the RAWWERS app."
};

/**
 * Where client pages that moved to the app now send people.
 *
 * The web is the admin panel and the landing page only (owner's decision,
 * 2026-11-08). Bookings, galleries and credit are in the app, and no web
 * page shows a client's ledger or point numbers.
 */
export default function GetTheAppPage() {
  return (
    <div className="mx-auto max-w-xl space-y-5 py-16">
      <h1 className="text-3xl font-semibold leading-tight">This is in the RAWWERS app</h1>
      <p className="text-neutral-400">
        Your bookings, your photos and your credit are in the app. The app is in beta while we
        open city by city.
      </p>
      <Link href="/" className="inline-block text-sm underline">
        Join the waitlist on the home page
      </Link>
    </div>
  );
}
