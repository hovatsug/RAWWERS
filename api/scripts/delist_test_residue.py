#!/usr/bin/env python3
"""Take leftover test accounts out of client-facing discovery.

A dev database accumulates accounts from manual runs and abandoned test
flows. Most are harmless because they never clear the discovery gates. Some
do: one account on a `@rawwers.test` address, displayed as "Nadia Cole", held
approved KYC, an active package, a completeness score of 100 and an
`approved_public` onboarding row, so it appeared in the client home alongside
the real seeded photographers.

That is a data-hygiene problem with a face on it. A demo where a client
scrolls past a test artifact is the kind of thing that gets noticed by the
wrong person at the wrong time.

De-listing rather than deleting is deliberate. These 66 accounts are
referenced by roughly 68 tables, including gigs, stripe_payment, dispute,
payout_request and the earnings ledger. Cascading a delete through financial
tables to tidy up a browsing screen trades a cosmetic problem for a
much worse one. Clearing `is_accepting_bookings` and dropping the public
index row removes them from every client-facing surface, is exactly what an
admin would do to a real account, and is reversible.

The domain is the signal: real and demo accounts use `@rawwers.dev`,
throwaway ones use `@rawwers.test`. Nothing in the repository creates the
latter any more, so this is residue with no current producer - which is why
it is a script to run rather than a filter in the discovery query. Adding a
permanent email-domain exclusion to production code would be defending
against a thing that no longer happens, in the one place where a mistake
hides a real photographer.

    docker compose exec api python scripts/delist_test_residue.py
    docker compose exec api python scripts/delist_test_residue.py --apply
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
sys.path.insert(0, str(Path(__file__).resolve().parent))

from _seed_common import assert_environment_is_seedable  # noqa: E402
from sqlalchemy import select  # noqa: E402

from app.db.session import SessionLocal  # noqa: E402
from app.models.admin import ProProfile, UserAccount  # noqa: E402
from app.models.discovery import ProPublicIndex  # noqa: E402

# Addresses that only ever belong to throwaway accounts. `@rawwers.dev` is
# deliberately absent: the demo logins and the 40 seeded photographers use it
# and must stay discoverable.
TEST_EMAIL_SUFFIXES = ("@rawwers.test",)


def find_residue(db) -> list[tuple[UserAccount, ProProfile | None, ProPublicIndex | None]]:
    """Test-domain accounts that are currently visible to client traffic."""
    rows = []
    for account in db.execute(select(UserAccount)).scalars().all():
        email = (account.email or "").lower()
        if not email.endswith(TEST_EMAIL_SUFFIXES):
            continue
        profile = db.get(ProProfile, account.user_id)
        index = db.get(ProPublicIndex, account.user_id)
        # Visible means one of the two client-facing surfaces still carries
        # them: an index row, or a profile still accepting bookings.
        if index is None and (profile is None or not profile.is_accepting_bookings):
            continue
        rows.append((account, profile, index))
    return rows


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--apply", action="store_true", help="Write the change. Without it, nothing is modified.")
    args = parser.parse_args()

    assert_environment_is_seedable()

    db = SessionLocal()
    try:
        residue = find_residue(db)
        if not residue:
            print("No test-domain accounts are visible to client traffic.")
            return 0

        print(f"{'email':<34} {'display name':<16} {'accepting':<10} {'indexed':<8}")
        for account, profile, index in residue:
            print(
                f"{(account.email or '')[:33]:<34} "
                f"{((profile.display_name if profile else None) or '-')[:15]:<16} "
                f"{str(bool(profile and profile.is_accepting_bookings)):<10} "
                f"{str(index is not None):<8}"
            )

        if not args.apply:
            print(f"\nDry run: {len(residue)} account(s) would be de-listed. Nothing written.")
            print("Re-run with --apply to write the change.")
            return 0

        for _account, profile, index in residue:
            if profile is not None:
                profile.is_accepting_bookings = False
            if index is not None:
                db.delete(index)
        db.commit()

        remaining = find_residue(db)
        print(f"\nDe-listed {len(residue)} account(s). Still visible afterwards: {len(remaining)}")
        return 0 if not remaining else 1
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


if __name__ == "__main__":
    raise SystemExit(main())
