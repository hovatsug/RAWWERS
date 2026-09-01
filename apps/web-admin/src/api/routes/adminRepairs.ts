import { z } from "zod";
import { getLoose, getPaginated, postLoose, putLoose, ListParams } from "@/api/routes/_common";

export const getRepairPartners = () => getLoose("/v1/admin/repairs/partners");
export const createRepairPartner = (body: unknown) => postLoose("/v1/admin/repairs/partners", body);
export const updateRepairPartner = (partnerId: string, body: unknown) => putLoose(`/v1/admin/repairs/partners/${partnerId}`, body);
export const setRepairPartnerActive = (partnerId: string, body: unknown) =>
  postLoose(`/v1/admin/repairs/partners/${partnerId}/set-active`, body);
export const recomputeRepairPartnerScore = (partnerId: string, body?: unknown) =>
  postLoose(`/v1/admin/repairs/partners/${partnerId}/recompute-score`, body);
export const getRepairPolicy = () => getLoose("/v1/admin/repairs/policy");
export const updateRepairPolicy = (body: unknown) => putLoose("/v1/admin/repairs/policy", body);
export const listRepairTickets = (params: ListParams) =>
  getPaginated("/v1/admin/repairs/tickets", params, z.object({}).passthrough());
export const assignRepairTicketPartner = (ticketId: string, body: unknown) =>
  postLoose(`/v1/admin/repairs/tickets/${ticketId}/assign-partner`, body);
export const setRepairTicketQuote = (ticketId: string, body: unknown) => postLoose(`/v1/admin/repairs/tickets/${ticketId}/set-quote`, body);
export const setRepairTicketStatus = (ticketId: string, body: unknown) =>
  postLoose(`/v1/admin/repairs/tickets/${ticketId}/set-status`, body);
export const listRepairLoaners = (params: ListParams) =>
  getPaginated("/v1/admin/repairs/loaners", params, z.object({}).passthrough());
export const setRepairLoanerStatus = (loanerRequestId: string, body: unknown) =>
  postLoose(`/v1/admin/repairs/loaners/${loanerRequestId}/set-status`, body);
export const setRepairOverride = (proUserId: string, body: unknown) => postLoose(`/v1/admin/repairs/overrides/${proUserId}`, body);
