"""Switch a city on for the test server: photographers can sign up there and
clients can browse it. TEST SERVER helper; the admin web has no page for
this yet (BETA_SCOPE #31).

It runs inside the API container that is already running, so nothing is
built or installed. The server's checkout is the deploy tag, which does not
have this file, so it is sent from the Mac over SSH. From the repository on
the Mac (<SERVER_IP> as in the runbook):

    ssh root@<SERVER_IP> 'cd /opt/rawwers/src && deploy/scripts/dc exec -T api python -' < tools/server/enable-city.py
        shows what it would do for London GB and Lisbon PT; writes nothing
    ssh root@<SERVER_IP> 'cd /opt/rawwers/src && deploy/scripts/dc exec -T api python - --apply' < tools/server/enable-city.py
        does it
    ssh root@<SERVER_IP> 'cd /opt/rawwers/src && deploy/scripts/dc exec -T api python - --city Manchester --country GB --apply' < tools/server/enable-city.py
        one other city

It writes through the API's own admin handler for PUT /v1/admin/rollout/cities
(upsert_rollout_cities), so each city gets the same admin audit record as a
change made through the API. The audit names an admin account: the only one
there is, or the one given with --admin-email.

Safe to run twice: a city already switched on is left alone (no write, no new
audit record). It prints each city before and after.

It refuses to run unless DEPLOYMENT_MODE, read from the container's
environment, is "test": it stops when DEPLOYMENT_MODE is "live", missing or
anything else.

Only what the API image of tag deploy-test-1 contains is imported.
"""
from __future__ import annotations

import argparse
import os
import sys

DEFAULT_CITIES = [("London", "GB"), ("Lisbon", "PT")]


def refuse(message: str) -> None:
    print(f"REFUSED: {message}", file=sys.stderr)
    raise SystemExit(2)


def check_deployment_mode() -> None:
    mode = os.environ.get("DEPLOYMENT_MODE")
    if mode is None or not mode.strip():
        refuse("cannot read DEPLOYMENT_MODE from the environment; this runs only on a test deployment.")
    if mode.strip().lower() == "live":
        refuse("DEPLOYMENT_MODE is live. This is a test-server helper and never runs on a live deployment.")
    if mode.strip().lower() != "test":
        refuse("DEPLOYMENT_MODE is neither test nor live; stopping to be safe.")


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        prog="enable-city.py",
        description="Switch a city on (photographer sign-up and client browsing). Test server only.",
    )
    parser.add_argument("--city", help="city name, as photographers type it (for example London)")
    parser.add_argument("--country", help="two-letter country code (for example GB)")
    parser.add_argument("--admin-email", help="the admin the audit record names (needed when there is more than one)")
    parser.add_argument("--apply", action="store_true", help="write (without it, only show)")
    args = parser.parse_args(argv)
    if bool(args.city) != bool(args.country):
        parser.error("give --city and --country together, or neither (London GB and Lisbon PT)")
    if args.country and (len(args.country.strip()) != 2 or not args.country.strip().isalpha()):
        parser.error("--country is a two-letter code, for example GB")
    return args


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    check_deployment_mode()

    # The API's own code, from the image (the working directory is /app).
    sys.path.insert(0, os.getcwd())
    from sqlalchemy import func, select

    import app.db.base  # noqa: F401  every model registered
    from app.api.v1.admin import upsert_rollout_cities
    from app.db.session import SessionLocal
    from app.models.admin import UserAccount, UserRole, UserRoleType
    from app.models.launch_ops import RolloutCity
    from app.schemas.launch_ops import RolloutCityUpsertItem
    from app.schemas.media import CurrentUser

    cities = [(args.city.strip(), args.country.strip().upper())] if args.city else DEFAULT_CITIES

    def find(db, city: str, country: str):
        return db.execute(
            select(RolloutCity).where(
                func.upper(RolloutCity.country) == country.upper(),
                func.lower(RolloutCity.city) == city.lower(),
            )
        ).scalar_one_or_none()

    def describe(row) -> str:
        if row is None:
            return "not listed (off)"
        return (
            f"photographer sign-up {'on' if row.is_pro_onboarding_enabled else 'off'}, "
            f"client browsing {'on' if row.is_client_browsing_enabled else 'off'}"
        )

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

        todo = []
        for city, country in cities:
            row = find(db, city, country)
            print(f"before  {city}, {country}: {describe(row)}")
            if row is not None and row.is_pro_onboarding_enabled and row.is_client_browsing_enabled:
                print(f"        {city}, {country} is already on: nothing to change.")
                continue
            todo.append(
                RolloutCityUpsertItem(
                    country=country,
                    city=row.city if row is not None else city,
                    is_pro_onboarding_enabled=True,
                    is_client_browsing_enabled=True,
                    metadata=dict(row.meta or {}) if row is not None else {},
                )
            )

        if not todo:
            print("Nothing to do.")
            return 0
        if not args.apply:
            for item in todo:
                print(f"would switch on  {item.city}, {item.country} (photographer sign-up and client browsing)")
            print("DRY RUN: nothing written. Add --apply to do it.")
            return 0

        upsert_rollout_cities(body=todo, actor=actor, db=db)
        db.expire_all()
        for item in todo:
            print(f"after   {item.city}, {item.country}: {describe(find(db, item.city, item.country))}")
        print(f"Done: {len(todo)} city(ies) switched on, each with an admin audit record (rollout_city_upsert).")
        return 0
    finally:
        db.rollback()
        db.close()


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
