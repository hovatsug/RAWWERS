import { z } from "zod";
import { getPaginated, postLoose, ListParams } from "@/api/routes/_common";

export const listAbuseSignals = (params: ListParams) => getPaginated("/v1/admin/abuse/signals", params, z.object({}).passthrough());
export const resolveAbuseSignal = (signalId: string, body?: unknown) => postLoose(`/v1/admin/abuse/signals/${signalId}/resolve`, body);
