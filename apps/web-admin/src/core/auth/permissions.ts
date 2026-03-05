export type AdminAction =
  | "users.ban"
  | "users.roles"
  | "payouts.approve"
  | "payouts.reject"
  | "payouts.markPaid"
  | "disputes.resolve"
  | "disputes.setStatus"
  | "refunds.retry"
  | "flags.write"
  | "aiFlags.write"
  | "risk.write"
  | "abuse.resolve"
  | "onboarding.approve"
  | "onboarding.reject"
  | "search.rebuild"
  | "search.purge"
  | "impersonation.start"
  | "impersonation.end"
  | "store.write"
  | "prints.write"
  | "repairs.write"
  | "raww.write";

interface MeLike {
  roles?: string[];
  permissions?: string[];
}

export function can(me: MeLike | null | undefined, action: AdminAction) {
  if (!me) return false;
  if (Array.isArray(me.permissions) && me.permissions.length > 0) {
    return me.permissions.includes(action) || me.permissions.includes("*");
  }
  return (me.roles || []).includes("admin");
}
