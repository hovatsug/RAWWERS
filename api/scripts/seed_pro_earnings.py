#!/usr/bin/env python3
"""Write the earnings and payouts that completed gigs already imply.

A seeded photographer with twenty completed gigs at EUR 1,490 each had a
wallet reading EUR 0.00 in every field - pending, available, held, reserved
and withdrawable. The Wallet screen was honest; the data behind it was not.
That is the same shape as a check reporting zero because the request failed,
and it is a data-completeness bug rather than a design precondition: the
gigs were seeded, their downstream financial state never was.

Everything here goes through the real functions. `create_earnings_entry`
computes the platform fee from the live policy, decides whether a dispute
hold applies, refreshes the balance snapshot and is idempotent on
(pro, source_type, source_id). `settle_due_earnings_entries` performs the
pending -> available transition. `create_payout_request` enforces the
minimum, the weekly limit and the withdrawable balance.

No Stripe object is synthesised. Only `gallery_completion` derives the gross
from succeeded payments - which is exactly why these gigs have no earnings -
and `create_earnings_entry` itself takes the amount directly.

**The one value supplied rather than computed** is `available_at`.
`create_earnings_entry` sets it to now + the settlement delay, correct when
called at the moment a gig completes and wrong for a gig that completed
weeks ago. It is rewritten to what the function would have produced had it
run then, and the real settlement function makes the state transition
unmodified. Leaving it at now + 7 days would recreate the original problem
one layer down: nothing ever reaches available or withdrawable, which are
the two states that needed to exist.

**Payout history is deliberately shallow.** The real system allows two
requests per pro per seven days with a EUR 50 minimum, and this does not
work around either. A thin, real history beats a dense, fabricated one.

    docker compose exec api python scripts/seed_pro_earnings.py
    docker compose exec api python scripts/seed_pro_earnings.py --apply
"""
from __future__ import annotations

import argparse
import sys
import uuid
from datetime import timedelta
from decimal import Decimal
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
sys.path.insert(0, str(Path(__file__).resolve().parent))

from _seed_common import assert_environment_is_seedable  # noqa: E402
from sqlalchemy import select  # noqa: E402

from app.db.session import SessionLocal  # noqa: E402
from app.models.admin import UserAccount  # noqa: E402
from app.models.gig import Gig, GigStatus  # noqa: E402
from app.models.payouts import (  # noqa: E402
    EarningsLedgerEntry,
    EarningsSourceType,
    PayoutRequestStatus,
)
from app.services.photographer_money import booking_split  # noqa: E402
from app.services.payouts import (  # noqa: E402
    MIN_PAYOUT_EUR,
    PAYOUT_REQUEST_LIMIT_7D,
    approve_payout_request,
    create_earnings_entry,
    create_payout_request,
    ensure_default_platform_fee_policy,
    mark_payout_paid_manual,
    payout_balance_view,
    settle_due_earnings_entries,
)

# Only accounts this project seeds. The developer's own account and anything
# else in the database is left alone: writing invented financial history onto
# a real person's account is not a thing a seed script should be able to do.
SEED_EMAIL_SUFFIX = "@rawwers.dev"

ADMIN_USER_ID = uuid.UUID("00000000-0000-0000-0000-000000000001")


def _completed_at(gig: Gig):
    """When the gig actually finished.

    The seeded gigs carry no `scheduled_start` or `scheduled_end` at all, so
    this falls back to `created_at`. That is a real gap and it flattens the
    timeline - every seeded gig then looks like it completed the day the seed
    ran - but it is honest about what the row knows. Dating the gigs properly
    is a separate fix, and it would improve this automatically.
    """
    return gig.scheduled_end or gig.scheduled_start or gig.created_at


def _seed_domain_pro_ids(db) -> set[uuid.UUID]:
    return {
        account.user_id
        for account in db.execute(select(UserAccount)).scalars().all()
        if (account.email or "").lower().endswith(SEED_EMAIL_SUFFIX)
    }


def seed_earnings(db, *, gigs: list[Gig], settlement_days: int) -> tuple[int, int]:
    """One ledger entry per completed gig. Returns (created, already_there)."""
    created = existing = 0
    for gig in gigs:
        before = db.execute(
            select(EarningsLedgerEntry).where(
                EarningsLedgerEntry.pro_user_id == gig.pro_user_id,
                EarningsLedgerEntry.source_type == EarningsSourceType.gig_base,
                EarningsLedgerEntry.source_id == gig.id,
            )
        ).scalar_one_or_none()
        if before is not None:
            existing += 1
            continue

        entry = create_earnings_entry(
            db,
            pro_user_id=gig.pro_user_id,
            source_type=EarningsSourceType.gig_base,
            source_id=gig.id,
            # What the client paid, split the official way (15% and 5% each
            # rounded, the photographer's cash the remainder) - the same
            # split a real booking's earnings use. Without it this took a
            # single rounded 20%, a few cents off the invoice on some gigs.
            gross_eur=gig.amount_minimum,
            split=seed_split(db, gig),
            metadata={"gig_id": str(gig.id), "seeded": True},
        )
        if entry is None:
            continue
        entry.available_at = _completed_at(gig) + timedelta(days=settlement_days)
        created += 1
    return created, existing


def seed_split(db, gig: Gig):
    """The booking's own split of what was booked (seeded gigs carry no
    payments, so the booked price stands in for what was paid)."""
    return booking_split(db, gig, gig.amount_minimum)


def reseed_earnings(db, *, gigs: list[Gig]) -> list[tuple[Gig, Decimal, Decimal]]:
    """Bring existing seeded entries for `gigs` to the official split.
    Returns (gig, old net, new net) for each one changed."""
    changed = []
    for gig in gigs:
        entry = db.execute(
            select(EarningsLedgerEntry).where(
                EarningsLedgerEntry.pro_user_id == gig.pro_user_id,
                EarningsLedgerEntry.source_type == EarningsSourceType.gig_base,
                EarningsLedgerEntry.source_id == gig.id,
            )
        ).scalar_one_or_none()
        if entry is None:
            continue
        split = seed_split(db, gig)
        if entry.net_eur == split.pro_cash and entry.gross_eur == split.gross:
            continue
        changed.append((gig, entry.net_eur, split.pro_cash))
        entry.gross_eur, entry.platform_fee_eur, entry.net_eur = split.gross, split.gross - split.pro_cash, split.pro_cash
    db.flush()
    return changed


def check_reconciliation(db, *, gigs: list[Gig]) -> list[str]:
    """Every entry's net must equal what the booking earned by the official
    split. If the fee policy and the seeded amounts ever disagree, this is
    where it surfaces instead of in someone's balance.
    """
    problems = []
    by_gig = {gig.id: gig for gig in gigs}
    entries = db.execute(
        select(EarningsLedgerEntry).where(EarningsLedgerEntry.source_type == EarningsSourceType.gig_base)
    ).scalars().all()
    for entry in entries:
        gig = by_gig.get(entry.source_id)
        if gig is None:
            continue
        expected = seed_split(db, gig).pro_cash
        if entry.net_eur != expected:
            problems.append(f"gig {gig.id}: ledger net {entry.net_eur} != the booking's split {expected}")
    return problems


def seed_payouts(db, *, pro_ids: set[uuid.UUID]) -> dict[str, int]:
    """A shallow but real payout history.

    Deliberately not dense. The real system allows PAYOUT_REQUEST_LIMIT_7D
    requests per seven days and refuses anything under MIN_PAYOUT_EUR, and
    seeding past either would be fabricating history the running system would
    never have produced. Statuses are spread so the screen has a paid one, an
    approved one and a pending one to render rather than three of a kind.
    """
    counts = {"requested": 0, "approved": 0, "paid": 0, "skipped_low_balance": 0}
    for index, pro_user_id in enumerate(sorted(pro_ids)):
        balance = payout_balance_view(db, pro_user_id=pro_user_id)
        withdrawable = Decimal(str(balance["withdrawable_eur"]))
        if withdrawable < MIN_PAYOUT_EUR:
            counts["skipped_low_balance"] += 1
            continue

        # Well inside the weekly limit, and a fraction of the balance so the
        # wallet still shows something left rather than a drained account.
        wanted = min(PAYOUT_REQUEST_LIMIT_7D, 1 + (index % PAYOUT_REQUEST_LIMIT_7D))
        for n in range(wanted):
            amount = (withdrawable / Decimal(4)).quantize(Decimal("0.01"))
            if amount < MIN_PAYOUT_EUR:
                break
            try:
                request = create_payout_request(db, pro_user_id=pro_user_id, amount_eur=amount)
            except Exception as exc:  # noqa: BLE001
                print(f"  ! payout request refused for {pro_user_id}: {exc}")
                break

            # Spread the lifecycle rather than leaving everything requested.
            stage = (index + n) % 3
            if stage == 0:
                counts["requested"] += 1
            elif stage == 1:
                approve_payout_request(db, payout_request_id=request.id, admin_user_id=ADMIN_USER_ID)
                counts["approved"] += 1
            else:
                approve_payout_request(db, payout_request_id=request.id, admin_user_id=ADMIN_USER_ID)
                mark_payout_paid_manual(
                    db,
                    payout_request_id=request.id,
                    admin_user_id=ADMIN_USER_ID,
                    reference={"mode": "seed", "note": "Seeded payout history"},
                )
                counts["paid"] += 1
            db.flush()
            balance = payout_balance_view(db, pro_user_id=pro_user_id)
            withdrawable = Decimal(str(balance["withdrawable_eur"]))
    return counts


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--apply", action="store_true", help="Write. Without it nothing is committed.")
    parser.add_argument(
        "--reseed", action="append", metavar="EMAIL", default=[],
        help="Rewrite this seeded account's existing earnings to the official split, then stop. Repeatable.",
    )
    args = parser.parse_args()

    assert_environment_is_seedable()

    db = SessionLocal()
    try:
        policy = ensure_default_platform_fee_policy(db)
        pro_ids = _seed_domain_pro_ids(db)

        if args.reseed:
            ids = {a.user_id for a in db.execute(select(UserAccount).where(UserAccount.email.in_(args.reseed))).scalars()}
            ids &= pro_ids
            gigs = db.execute(select(Gig).where(Gig.status == GigStatus.completed, Gig.pro_user_id.in_(ids))).scalars().all()
            changed = reseed_earnings(db, gigs=gigs)
            for gig, old, new in changed[:10]:
                print(f"  gig {gig.id}: {old} -> {new}")
            print(f"reseeded {len(changed)} entr{'y' if len(changed) == 1 else 'ies'} for {len(ids)} account(s)")
            if args.apply:
                db.commit()
                print("Written.")
            else:
                db.rollback()
                print("Dry run. Nothing written. Re-run with --apply.")
            return 0

        all_completed = db.execute(select(Gig).where(Gig.status == GigStatus.completed)).scalars().all()
        gigs = [g for g in all_completed if g.pro_user_id in pro_ids]
        skipped = len(all_completed) - len(gigs)

        print(f"seed-domain pros            : {len(pro_ids)}")
        print(f"completed gigs in scope     : {len(gigs)}")
        print(f"completed gigs left alone   : {skipped}  (not on {SEED_EMAIL_SUFFIX})")
        print(f"platform fee / settlement   : {policy.fee_percent_gigs}% / {policy.settlement_delay_days} days")
        if not gigs:
            print("\nNothing to do.")
            return 0

        created, existing = seed_earnings(db, gigs=gigs, settlement_days=int(policy.settlement_delay_days))
        print(f"\nledger entries created      : {created}")
        print(f"ledger entries already there: {existing}")

        problems = check_reconciliation(db, gigs=gigs)
        if problems:
            print(f"\nREFUSING: {len(problems)} entries do not reconcile with the gig they came from")
            for line in problems[:5]:
                print(f"  {line}")
            db.rollback()
            return 1
        print("reconciliation              : every net matches its booking's split")

        settled = settle_due_earnings_entries(db, limit=10_000)
        print(f"entries settled to available: {settled}")

        payouts = seed_payouts(db, pro_ids=pro_ids)
        print(
            "payout requests             : "
            + ", ".join(f"{k}={v}" for k, v in payouts.items())
        )

        if not args.apply:
            db.rollback()
            print("\nDry run. Nothing written. Re-run with --apply.")
            return 0

        db.commit()
        print("\nWritten.")

        funded = 0
        for pro_user_id in sorted(pro_ids):
            balance = payout_balance_view(db, pro_user_id=pro_user_id)
            if Decimal(str(balance["available_eur"])) > 0 or Decimal(str(balance["pending_eur"])) > 0:
                funded += 1
        paid_total = db.execute(
            select(EarningsLedgerEntry).where(EarningsLedgerEntry.source_type == EarningsSourceType.gig_base)
        ).scalars().all()
        print(f"pros with a non-zero balance: {funded} / {len(pro_ids)}")
        print(f"ledger entries in total     : {len(paid_total)}")
        return 0
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


if __name__ == "__main__":
    raise SystemExit(main())
