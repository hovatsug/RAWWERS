"use client";

import { useState } from "react";
import { useMutation, useQuery } from "@tanstack/react-query";
import { Button, Card, EmptyState, Textarea } from "@/design-system/primitives";
import { useAuth } from "@/lib/auth/store";
import { auth } from "@/lib/api/auth";

export default function SettingsPage() {
  const { accessToken } = useAuth();
  const [contactJson, setContactJson] = useState('{}');

  const prefQ = useQuery({ queryKey: ["client", "preferences"], queryFn: () => auth.getClientPreference(accessToken), enabled: !!accessToken });
  const notifPrefQ = useQuery({ queryKey: ["client", "notif-pref"], queryFn: () => auth.getNotificationPreferences(accessToken), enabled: !!accessToken });

  const saveContact = useMutation({ mutationFn: async () => auth.putContact(JSON.parse(contactJson), accessToken) });

  if (!accessToken) return <EmptyState title="Login required" />;

  return (
    <div className="space-y-3">
      <h1 className="text-xl font-semibold">Settings</h1>
      <Card className="space-y-2">
        <p className="text-sm font-medium">Contact</p>
        <Textarea rows={4} value={contactJson} onChange={(e) => setContactJson(e.target.value)} />
        <Button onClick={() => saveContact.mutate()} disabled={saveContact.isPending}>{saveContact.isPending ? 'Saving...' : 'Save contact'}</Button>
        {saveContact.data?.ok ? <p className="text-sm text-green-700">Saved</p> : null}
        {saveContact.data && !saveContact.data.ok ? <p className="text-sm text-red-700">{saveContact.data.error.message || "Couldn't save contact."}</p> : null}
      </Card>
      <Card><pre className="overflow-auto text-xs">{JSON.stringify(prefQ.data, null, 2)}</pre></Card>
      <Card><pre className="overflow-auto text-xs">{JSON.stringify(notifPrefQ.data, null, 2)}</pre></Card>
    </div>
  );
}
