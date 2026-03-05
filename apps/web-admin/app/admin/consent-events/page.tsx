"use client";

import { listConsentEvents } from "@/api/routes/adminConsent";
import { PageHeader } from "@/components/layout/PageHeader";
import { ListPage } from "@/components/shared/ListPage";

export default function ConsentEventsPage() {
  return (
    <div className="space-y-4">
      <PageHeader title="Consent Events" subtitle="Track consent state changes and logs." />
      <ListPage
        queryKey={["admin", "consent-events"]}
        queryFn={listConsentEvents}
        columns={[
          { key: "id", title: "Event", render: (r: any) => String(r.event_id || r.id || "-") },
          { key: "user", title: "User", render: (r: any) => String(r.user_id || "-") },
          { key: "type", title: "Type", render: (r: any) => r.type || "-" },
          { key: "at", title: "At", render: (r: any) => r.created_at || "-" }
        ]}
      />
    </div>
  );
}
