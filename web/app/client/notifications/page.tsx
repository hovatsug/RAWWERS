"use client";

import { useMutation, useQuery } from "@tanstack/react-query";
import { Button, Card, EmptyState } from "@/design-system/primitives";
import { auth } from "@/lib/api/auth";
import { useAuth } from "@/lib/auth/store";

export default function ClientNotificationsPage() {
  const { accessToken } = useAuth();
  const { data, isLoading, refetch } = useQuery({ queryKey: ["notifications"], queryFn: () => auth.getNotifications({}, accessToken) });
  const read = useMutation({
    mutationFn: (id: string) => auth.markNotificationRead(id, accessToken),
    onSuccess: () => refetch()
  });

  if (isLoading) return <p className="text-sm">Loading notifications…</p>;
  if (data && !data.ok) return <EmptyState title="Couldn't load notifications" body="Refresh to retry." />;
  if (!data?.data.items?.length) return <EmptyState title="No notifications" />;

  return (
    <div className="space-y-2">
      {data.data.items.map((item) => (
        <Card key={item.id} className="space-y-2">
          <p className="font-medium">{item.title}</p>
          <p className="text-sm text-neutral-600">{item.body}</p>
          <Button className="bg-neutral-700" onClick={() => read.mutate(item.id)}>Mark read</Button>
        </Card>
      ))}
    </div>
  );
}
