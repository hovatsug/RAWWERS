"""TEST ONLY: set the settlement delay (how many days a photographer's
earning waits before it can be withdrawn) to 0 on the test server, so a
payout can be tried the same day; and put it back to the real value, 7 days.

It runs inside the API container that is already running, sent from the
Mac over SSH (the server's checkout is the deploy tag, which does not have
this file). From the repository on the Mac:

    ssh root@<SERVER_IP> 'cd /opt/rawwers/src && deploy/scripts/dc exec -T api python -' < tools/server/set-settlement-delay.py
        shows the policy now and what setting 0 would change; writes nothing
    ssh root@<SERVER_IP> 'cd /opt/rawwers/src && deploy/scripts/dc exec -T api python - --apply' < tools/server/set-settlement-delay.py
        sets the delay to 0
    ssh root@<SERVER_IP> 'cd /opt/rawwers/src && deploy/scripts/dc exec -T api python - --restore --apply' < tools/server/set-settlement-delay.py
        puts it back to 7 days and says what it was

It writes through the API's own admin handler for
PUT /v1/admin/finance/fee-policy (put_fee_policy_admin), the same path the
dev script docs/stage1-loop/fee_policy_delay.py uses, so the change gets the
same admin audit record (platform_fee_policy_updated). Every other field of
the policy is sent back as it is, and checked afterwards.

The delay applies when an earning is recorded (the client confirms the
selection): set it before that step. With 0 the payout path is exercised;
the 7-day wait itself is not proven. Run --restore when that test is done.

Safe to run twice: a delay already at the wanted value is left alone (no
write, no new audit record). It refuses to run unless DEPLOYMENT_MODE, read
from the container's environment, is "test".

Only what the API image of tag deploy-test-1 contains is imported.
"""
from __future__ import annotations

import argparse
import os
import sys

REAL_DELAY_DAYS = 7
TEST_DELAY_DAYS = 0
FIELDS = ("fee_percent_gigs", "fee_percent_extras", "fee_percent_studioverse", "settlement_delay_days", "dispute_hold_days")
BANNER = "TEST ONLY: this changes the settlement delay on a TEST server. Never on a live deployment."


def refuse(message: str) -> None:
    print(f"REFUSED: {message}", file=sys.stderr)
    raise SystemExit(2)


def check_deployment_mode() -> None:
    mode = os.environ.get("DEPLOYMENT_MODE")
    if mode is None or not mode.strip():
        refuse("cannot read DEPLOYMENT_MODE from the environment; this runs only on a test deployment.")
    if mode.strip().lower() == "live":
        refuse("DEPLOYMENT_MODE is live. The settlement delay is never changed by this script on a live deployment.")
    if mode.strip().lower() != "test":
        refuse("DEPLOYMENT_MODE is neither test nor live; stopping to be safe.")


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(prog="set-settlement-delay.py", description="TEST ONLY. " + __doc__.split("\n\n")[0])
    parser.add_argument("--restore", action="store_true", help=f"back to the real value, {REAL_DELAY_DAYS} days")
    parser.add_argument("--admin-email", help="the admin the audit record names (needed when there is more than one)")
    parser.add_argument("--apply", action="store_true", help="write (without it, only show)")
    return parser.parse_args(argv)


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    print(BANNER)
    check_deployment_mode()

    sys.path.insert(0, os.getcwd())
    from sqlalchemy import select

    import app.db.base  # noqa: F401  every model registered
    from app.api.v1.payouts import put_fee_policy_admin
    from app.db.session import SessionLocal
    from app.models.admin import UserAccount, UserRole, UserRoleType
    from app.models.payouts import PlatformFeePolicy
    from app.schemas.media import CurrentUser
    from app.schemas.payouts import PlatformFeePolicyUpdateRequest

    wanted_days = REAL_DELAY_DAYS if args.restore else TEST_DELAY_DAYS

    def current(db):
        # The row the API reads (ensure_default_platform_fee_policy): the newest.
        return db.execute(select(PlatformFeePolicy).order_by(PlatformFeePolicy.updated_at.desc())).scalars().first()

    def show(label: str, row) -> str:
        if row is None:
            return f"{label}: no fee policy row yet (the API uses its defaults: settlement_delay_days={REAL_DELAY_DAYS})"
        return f"{label}: " + ", ".join(f"{f}={getattr(row, f)}" for f in FIELDS)

    db = SessionLocal()
    try:
        admins = db.execute(
            select(UserAccount).join(UserRole, UserRole.user_id == UserAccount.user_id).where(UserRole.role == UserRoleType.admin)
        ).scalars().all()
        if args.admin_email:
            wanted = args.admin_email.strip().lower()
            admins = [a for a in admins if (a.email or "").strip().lower() == wanted]
            if not admins:
                refuse("no admin account has that email.")
        if not admins:
            refuse("there is no admin account yet (runbook step 20). Make it first.")
        if len(admins) > 1:
            refuse("there is more than one admin; say which one the audit names with --admin-email.")
        actor = CurrentUser(user_id=admins[0].user_id, roles=[UserRoleType.admin])

        before = current(db)
        print(show("before", before))
        was = before.settlement_delay_days if before is not None else REAL_DELAY_DAYS
        if was == wanted_days:
            print(f"The settlement delay is already {wanted_days} day(s): nothing to change.")
            return 0
        if not args.apply:
            print(f"would set settlement_delay_days {was} -> {wanted_days}; every other field unchanged")
            print("DRY RUN: nothing written. Add --apply to do it.")
            return 0

        kept = {f: getattr(before, f) for f in FIELDS} if before is not None else None
        if kept is None:
            # No row yet: the handler makes the default one (the API's own
            # defaults), and only the delay differs from it.
            from app.services.payouts import ensure_default_platform_fee_policy

            row = ensure_default_platform_fee_policy(db)
            kept = {f: getattr(row, f) for f in FIELDS}
        body = PlatformFeePolicyUpdateRequest(**{**kept, "settlement_delay_days": wanted_days})
        put_fee_policy_admin(body=body, actor=actor, db=db)

        db.expire_all()
        after = current(db)
        print(show("after ", after))
        moved = [f for f in FIELDS if f != "settlement_delay_days" and getattr(after, f) != kept[f]]
        if after.settlement_delay_days != wanted_days or moved:
            print(f"CHECK FAILED: the policy is not what was sent ({', '.join(moved) or 'settlement_delay_days'}). Look at it in the admin before going on.", file=sys.stderr)
            return 1
        if args.restore:
            print(f"Restored: settlement_delay_days was {was}, now {wanted_days} (the real value). Audit record: platform_fee_policy_updated.")
        else:
            print(f"Set: settlement_delay_days was {was}, now {wanted_days}. TEST ONLY: run --restore --apply when the payout test is done.")
        return 0
    finally:
        db.rollback()
        db.close()


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
