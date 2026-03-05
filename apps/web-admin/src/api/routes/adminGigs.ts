import { getLoose, postLoose } from "@/api/routes/_common";

export const getGig = (gigId: string) => getLoose(`/v1/gigs/${gigId}`);
export const setGigStatus = (gigId: string, body: unknown) => postLoose(`/v1/admin/gigs/${gigId}/status`, body);
