"use client";

import { useMutation, useQuery } from "@tanstack/react-query";
import { Button, Card, EmptyState } from "@/design-system/primitives";
import { endpoints } from "@/lib/api/endpoints";
import { useAuth } from "@/lib/auth/store";

export default function ClientNotificationsPage() {
  const { accessToken } = useAuth();
  const { data, refetch } = useQuery({ queryKey: ["notifications"], queryFn: () => endpoints.notifications(accessToken) });
  const read = useMutation({
    mutationFn: (id: string) => endpoints.markNotificationRead(id, accessToken),
    onSuccess: () => refetch()
  });

  if (!data?.items?.length) return <EmptyState title="No notifications" />;

  return (
    <div className="space-y-2">
      {data.items.map((item) => (
        <Card key={item.id} className="space-y-2">
          <p className="font-medium">{item.title}</p>
          <p className="text-sm text-neutral-600">{item.body}</p>
          <Button className="bg-neutral-700" onClick={() => read.mutate(item.id)}>Mark read</Button>
        </Card>
      ))}
    </div>
  );
}
