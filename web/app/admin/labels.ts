/** Check keys come back as machine names; the queue shows words. Lives
 *  outside page.tsx because Next only allows its own exports there. */
export function humanise(key: string): string {
  return (
    {
      profile_completed: "profile",
      portfolio_uploaded: "portfolio",
      packages_configured: "pricing",
      niches_selected: "niches"
    }[key] || key.replace(/_/g, " ")
  );
}
