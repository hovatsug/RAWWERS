"use client";

import Link from "next/link";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { listAdminUsers, banAdminUser, updateAdminUserRoles } from "@/api/routes/adminUsers";
import { PageHeader } from "@/components/layout/PageHeader";
import { ListPage } from "@/components/shared/ListPage";
import { StatusChip } from "@/components/data/StatusChip";
import { Chip } from "@/components/data/Chip";
import { formatDate } from "@/lib/format";
import { Button } from "@/components/forms/Button";
import { ConfirmDialog } from "@/components/overlays/ConfirmDialog";
import { useState } from "react";
import { Input } from "@/components/forms/Input";
import { Modal } from "@/components/overlays/Modal";
import { queryKeys } from "@/core/queryKeys";
import { recordAndTrackAdminAction } from "@/core/audit/audit";
import { can } from "@/core/auth/permissions";

export default function UsersPage() {
  const queryClient = useQueryClient();
  const me = useQuery({ queryKey: queryKeys.me, queryFn: () => Promise.resolve(queryClient.getQueryData(queryKeys.me) as any) });

  const [targetUser, setTargetUser] = useState<any>(null);
  const [rolesOpen, setRolesOpen] = useState(false);
  const [rolesText, setRolesText] = useState("");
  const [banOpen, setBanOpen] = useState(false);

  const banMutation = useMutation({
    mutationFn: ({ userId }: { userId: string }) => banAdminUser(userId),
    onSuccess: async (_, vars) => {
      await recordAndTrackAdminAction({ action: "users.ban", entityType: "user", entityId: vars.userId });
      queryClient.invalidateQueries({ queryKey: ["admin", "users"] });
    }
  });

  const rolesMutation = useMutation({
    mutationFn: ({ userId, roles }: { userId: string; roles: string[] }) => updateAdminUserRoles(userId, roles),
    onSuccess: async (_, vars) => {
      await recordAndTrackAdminAction({ action: "users.roles", entityType: "user", entityId: vars.userId });
      queryClient.invalidateQueries({ queryKey: ["admin", "users"] });
    }
  });

  return (
    <div className="space-y-4">
      <PageHeader title="Users" subtitle="Search and moderate users" />
      <ListPage
        queryKey={["admin", "users"]}
        queryFn={listAdminUsers}
        columns={[
          {
            key: "id",
            title: "User",
            render: (row: any) => {
              const id = String(row.user_id || row.id || "-");
              return <Link href={`/admin/users/${id}`} className="text-accent">{id}</Link>;
            }
          },
          { key: "email", title: "Email", render: (row: any) => row.email || "-" },
          {
            key: "roles",
            title: "Roles",
            render: (row: any) => (
              <div className="flex flex-wrap gap-1">{(row.roles || []).map((role: string) => <Chip key={role}>{role}</Chip>)}</div>
            )
          },
          { key: "status", title: "Status", render: (row: any) => <StatusChip value={row.banned ? "banned" : "active"} /> },
          { key: "created", title: "Created", render: (row: any) => formatDate(row.created_at) },
          {
            key: "actions",
            title: "Actions",
            render: (row: any) => {
              const id = String(row.user_id || row.id || "");
              return (
                <div className="flex gap-2" onClick={(e) => e.stopPropagation()}>
                  <Button
                    variant="danger"
                    disabled={!can(me.data as any, "users.ban")}
                    onClick={() => {
                      setTargetUser(row);
                      setBanOpen(true);
                    }}
                  >
                    Ban/Unban
                  </Button>
                  <Button
                    variant="secondary"
                    disabled={!can(me.data as any, "users.roles")}
                    onClick={() => {
                      setTargetUser(row);
                      setRolesText((row.roles || []).join(","));
                      setRolesOpen(true);
                    }}
                  >
                    Edit Roles
                  </Button>
                </div>
              );
            }
          }
        ]}
        searchPlaceholder="Search users by email or id"
      />

      <ConfirmDialog
        open={banOpen}
        title="Confirm user moderation"
        description={`Apply ban/unban for user ${targetUser?.user_id || targetUser?.id || ""}?`}
        onCancel={() => setBanOpen(false)}
        onConfirm={() => {
          banMutation.mutate({ userId: String(targetUser?.user_id || targetUser?.id) });
          setBanOpen(false);
        }}
        confirmLabel="Confirm"
        danger
      />

      <Modal open={rolesOpen} onClose={() => setRolesOpen(false)} title="Update roles">
        <div className="space-y-3">
          <Input value={rolesText} onChange={(e) => setRolesText(e.target.value)} placeholder="admin,ops" />
          <div className="flex justify-end gap-2">
            <Button variant="secondary" onClick={() => setRolesOpen(false)}>
              Cancel
            </Button>
            <Button
              onClick={() => {
                rolesMutation.mutate({
                  userId: String(targetUser?.user_id || targetUser?.id),
                  roles: rolesText
                    .split(",")
                    .map((r) => r.trim())
                    .filter(Boolean)
                });
                setRolesOpen(false);
              }}
              loading={rolesMutation.isPending}
            >
              Save
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  );
}
