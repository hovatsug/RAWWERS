/** Check keys come back as machine names; the queue shows words. Lives
 *  outside page.tsx because Next only allows its own exports there. */
export function humanise(key: string): string {
  return (
    {
      profile_completed: "profile",
      portfolio_uploaded: "portfolio",
      packages_configured: "pricing",
      niches_selected: "niches",
      gear_verified: "gear"
    }[key] || key.replace(/_/g, " ")
  );
}

/** Whether a dispute still needs a decision. One definition, used by the
 *  disputes page and the sidebar count, so the two cannot disagree. */
export function isOpenDispute(dispute: { status: string }): boolean {
  return !dispute.status.startsWith("resolved") && dispute.status !== "closed" && dispute.status !== "cancelled";
}
