import type { Metadata } from "next";
import { WaitlistForm } from "@/components/marketing/waitlist-form";

export const metadata: Metadata = {
  title: "Join the RAWWERS waitlist",
  description: "Tell us where you are, and we will tell you when RAWWERS opens there."
};

/**
 * The waitlist, on its own page: the landing page's public form, nothing
 * else. It replaced a signed-in page that dumped the API's raw answer as
 * JSON and posted without the country the API requires.
 */
export default function WaitlistPage() {
  return (
    <div className="mx-auto max-w-xl space-y-5 py-10">
      <h1 className="text-3xl font-semibold leading-tight">Join the waitlist</h1>
      <p className="text-neutral-400">
        We open one city at a time. Tell us where you are and we will let you know when RAWWERS
        opens there.
      </p>
      <WaitlistForm />
    </div>
  );
}
