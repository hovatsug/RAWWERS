import { z } from "zod";
import { getPaginated, postLoose, getLoose, putLoose, ListParams } from "@/api/routes/_common";

const payoutSchema = z
  .object({
    payout_request_id: z.union([z.string(), z.number()]).optional(),
    pro_user_id: z.union([z.string(), z.number()]).optional(),
    amount: z.number().optional(),
    status: z.string().optional(),
    requested_at: z.string().optional()
  })
  .passthrough();

export function listPayouts(params: ListParams) {
  return getPaginated("/v1/admin/payouts", params, payoutSchema);
}

export const approvePayout = (id: string, body?: unknown) => postLoose(`/v1/admin/payouts/${id}/approve`, body);
export const rejectPayout = (id: string, body?: unknown) => postLoose(`/v1/admin/payouts/${id}/reject`, body);
export const markPayoutPaid = (id: string, body?: unknown) => postLoose(`/v1/admin/payouts/${id}/mark-paid`, body);

export const getFeePolicy = () => getLoose("/v1/admin/finance/fee-policy");
export const updateFeePolicy = (body: unknown) => putLoose("/v1/admin/finance/fee-policy", body);
export const listFinancePros = (params: ListParams) => getPaginated("/v1/admin/finance/pros", params, z.object({}).passthrough());
export const getFinancePro = (proUserId: string) => getLoose(`/v1/admin/finance/pros/${proUserId}`);
