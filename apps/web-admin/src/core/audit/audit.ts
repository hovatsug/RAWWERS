import { trackEvent } from "@/api/routes/analytics";

export interface AdminAuditRecord {
  action: string;
  entityType: string;
  entityId?: string;
  payloadSummary?: string;
  timestamp?: string;
}

export async function recordAdminAction(_record: AdminAuditRecord) {
  return Promise.resolve();
}

export async function recordAndTrackAdminAction(record: AdminAuditRecord) {
  await recordAdminAction({ ...record, timestamp: record.timestamp || new Date().toISOString() });
  await trackEvent({
    name: "admin_action",
    props: {
      action: record.action,
      entity: record.entityType,
      entityId: record.entityId || null
    }
  });
}
