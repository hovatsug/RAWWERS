import { z } from "zod";
import { getPaginated, getLoose, postLoose, ListParams } from "@/api/routes/_common";

const disputeSchema = z.object({ dispute_id: z.any().optional(), status: z.string().optional() }).passthrough();

export const listDisputes = (params: ListParams) => getPaginated("/v1/admin/disputes", params, disputeSchema);
export const getDispute = (id: string) => getLoose(`/v1/admin/disputes/${id}`);
export const resolveDispute = (id: string, body?: unknown) => postLoose(`/v1/admin/disputes/${id}/resolve`, body);
export const setDisputeStatus = (id: string, body?: unknown) => postLoose(`/v1/admin/disputes/${id}/set-status`, body);
export const createGigRefund = (gigId: string, body?: unknown) => postLoose(`/v1/admin/gigs/${gigId}/refunds`, body);
