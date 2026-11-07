"use client";

import { useEffect, useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { admin } from "@/lib/api/admin";
import { AdminButton, FieldLabel, Notice, PageHeader, Panel, TextField } from "@/app/admin/_components/ui";

/**
 * Gallery settings. How many days after finishing their selection a client may
 * still add photos: stamped on each booking when its selection closes, so a
 * change here applies to selections closed from now on, never to open ones.
 */
export default function AdminGalleriesPage() {
  const query = useQuery({ queryKey: ["admin", "gallery-policy"], queryFn: () => admin.galleryPolicy() });
  const [days, setDays] = useState("");
  const [message, setMessage] = useState<{ tone: "error" | "success"; text: string } | null>(null);
  useEffect(() => {
    if (query.data?.ok) setDays(String(query.data.data.selection_addon_days));
  }, [query.data]);

  return (
    <>
      <PageHeader title="Galleries" description="How long a client may add photos after finishing their selection." />
      <Panel className="max-w-xl space-y-3 p-4">
        {message ? <Notice tone={message.tone}>{message.text}</Notice> : null}
        <div>
          <FieldLabel htmlFor="addon-days">Days to add photos after choosing</FieldLabel>
          <TextField id="addon-days" inputMode="numeric" value={days} onChange={(e) => setDays(e.target.value.replace(/[^0-9]/g, ""))} />
          <p className="mt-1 text-xs text-slate-400">Applies to selections closed from now on. Open windows keep their end; extend one from its booking page.</p>
        </div>
        <AdminButton
          disabled={days === ""}
          onClick={async () => {
            const res = await admin.saveGalleryPolicy(Number(days));
            setMessage(res.ok ? { tone: "success", text: "Saved." } : { tone: "error", text: res.error.message });
          }}
        >
          Save
        </AdminButton>
      </Panel>
    </>
  );
}
