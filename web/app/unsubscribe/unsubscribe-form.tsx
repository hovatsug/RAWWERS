"use client";

import { useEffect, useState } from "react";
import { Button, Card } from "@/design-system/primitives";

const API_BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL || "http://localhost:8000";

type Link = { u: string; t: string; k: string; s: string };
type Checked = { topic: string; topic_label: string; all: { k: string; s: string } };
type State =
  | { step: "checking" }
  | { step: "invalid" }
  | { step: "ready"; link: Checked }
  | { step: "done"; link: Checked; all: boolean }
  | { step: "failed"; link: Checked };

function url(link: Link): string {
  const query = new URLSearchParams(link);
  return `${API_BASE_URL}/v1/email/unsubscribe?${query.toString()}`;
}

/**
 * Checks the link (GET, which changes nothing), then lets the person stop
 * that kind of email, or every email except account security, with a POST.
 * Account security email (sign-ins, password resets) cannot be stopped.
 */
export function UnsubscribeForm(link: Link) {
  const [state, setState] = useState<State>({ step: "checking" });

  useEffect(() => {
    let live = true;
    fetch(url(link))
      .then(async (res) => (res.ok ? ((await res.json()) as Checked) : null))
      .catch(() => null)
      .then((checked) => {
        if (live) setState(checked ? { step: "ready", link: checked } : { step: "invalid" });
      });
    return () => {
      live = false;
    };
    // The link is the page's; it does not change while the page is open.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const stop = async (checked: Checked, all: boolean) => {
    const target = all ? { u: link.u, t: "all", k: checked.all.k, s: checked.all.s } : link;
    const res = await fetch(url(target), { method: "POST" }).catch(() => null);
    setState(res?.ok ? { step: "done", link: checked, all } : { step: "failed", link: checked });
  };

  return (
    <Card className="mx-auto mt-16 max-w-md space-y-4 p-6">
      <h1 className="text-xl font-semibold">Email from RAWWERS</h1>
      {state.step === "checking" ? <p className="text-sm text-slate-400">Checking your link…</p> : null}
      {state.step === "invalid" ? (
        <p className="text-sm text-slate-300">This link is not valid. Open the latest email from RAWWERS and use its link, or change your email settings in the app.</p>
      ) : null}
      {state.step === "ready" || state.step === "failed" ? (
        <>
          <p className="text-sm text-slate-300">Stop emails about {state.link.topic_label}? You still see them in the app.</p>
          {state.step === "failed" ? <p className="text-sm text-red-400">That did not work. Try again.</p> : null}
          <div className="flex flex-wrap gap-3">
            <Button onClick={() => stop(state.link, false)}>Stop these emails</Button>
            <Button variant="glass" onClick={() => stop(state.link, true)}>
              Stop all emails
            </Button>
          </div>
          <p className="text-xs text-slate-500">Emails about your account&apos;s security, like a new sign-in or a password reset, always reach you.</p>
        </>
      ) : null}
      {state.step === "done" ? (
        <>
          <p className="text-sm text-slate-300">
            {state.all ? "Done. RAWWERS will only email you about your account's security." : `Done. No more emails about ${state.link.topic_label}.`}
          </p>
          <p className="text-xs text-slate-500">To switch them back on, contact RAWWERS support.</p>
        </>
      ) : null}
    </Card>
  );
}
