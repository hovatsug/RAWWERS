import { z } from "zod";
import { getPaginated, postLoose, ListParams } from "@/api/routes/_common";

const refundSchema = z.object({ refund_case_id: z.any().optional(), status: z.string().optional() }).passthrough();

export const listRefunds = (params: ListParams) => getPaginated("/v1/admin/refunds", params, refundSchema);
export const retryRefund = (id: string, body?: unknown) => postLoose(`/v1/admin/refunds/${id}/retry`, body);
