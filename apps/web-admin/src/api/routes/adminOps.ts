import { getLoose } from "@/api/routes/_common";

export const getMetricsSummary = () => getLoose("/v1/admin/ops/metrics-summary");
