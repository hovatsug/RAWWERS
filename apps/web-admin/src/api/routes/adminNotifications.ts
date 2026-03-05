import { z } from "zod";
import { getPaginated, postLoose, ListParams } from "@/api/routes/_common";

export const listNotificationLogs = (params: ListParams) =>
  getPaginated("/v1/admin/notifications/logs", params, z.object({}).passthrough());
export const resendNotification = (body: unknown) => postLoose("/v1/admin/notifications/resend", body);
