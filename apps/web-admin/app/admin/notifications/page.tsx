"use client";

import { useState } from "react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { listNotificationLogs, resendNotification } from "@/api/routes/adminNotifications";
import { PageHeader } from "@/components/layout/PageHeader";
import { ListPage } from "@/components/shared/ListPage";
import { Button } from "@/components/forms/Button";
import { Modal } from "@/components/overlays/Modal";
import { Input } from "@/components/forms/Input";

export default function NotificationsPage() {
  const queryClient = useQueryClient();
  const [open, setOpen] = useState(false);
  const [notificationId, setNotificationId] = useState("");
  const resend = useMutation({
    mutationFn: () => resendNotification({ notification_id: notificationId }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["admin", "notification-logs"] });
      setOpen(false);
    }
  });

  return (
    <div className="space-y-4">
      <PageHeader title="Notifications" subtitle="Delivery logs and resend tools" actions={<Button onClick={() => setOpen(true)}>Resend</Button>} />
      <ListPage
        queryKey={["admin", "notification-logs"]}
        queryFn={listNotificationLogs}
        columns={[
          { key: "id", title: "ID", render: (r: any) => String(r.notification_id || r.id || "-") },
          { key: "type", title: "Type", render: (r: any) => r.type || "-" },
          { key: "status", title: "Status", render: (r: any) => r.status || "-" },
          { key: "created", title: "Created", render: (r: any) => r.created_at || "-" }
        ]}
      />
      <Modal open={open} onClose={() => setOpen(false)} title="Resend Notification">
        <div className="space-y-3">
          <Input value={notificationId} onChange={(e) => setNotificationId(e.target.value)} placeholder="Notification ID" />
          <Button onClick={() => resend.mutate()} loading={resend.isPending}>Resend</Button>
        </div>
      </Modal>
    </div>
  );
}
