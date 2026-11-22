#!/usr/bin/env python3
"""What this deployment is running with: switches, flags, migrations, rates.

Prints no secret: only on/off, names and dates. deploy/scripts/version.sh
runs it inside the API container after each deploy.

    python scripts/print_deploy_state.py              # everything (needs the database)
    python scripts/print_deploy_state.py --no-db      # only what the settings say
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))


def _settings_part() -> None:
    from app.core.config import get_settings
    from app.services.feature_flags import DEFAULT_FLAG_KEYS, default_flag_state

    s = get_settings()
    on = lambda v: "on" if v else "off"  # noqa: E731
    print("== settings")
    print(f"APP_ENV                     {s.app_env}")
    print(f"DEPLOYMENT_MODE             {s.deployment_mode}")
    print(f"release (SENTRY_RELEASE)    {s.sentry_release or '-'}")
    print(f"API docs                    {on(s.api_docs_on)}")
    print(f"email sending               {on(s.email_sending_on)} (Brevo key {'set' if s.brevo_api_key else 'missing'})")
    print(f"email allowlist only        {on((not s.is_production) or s.is_test_deployment)}")
    key = s.stripe_secret_key or ""
    kind = "live" if key.startswith(("sk_live_", "rk_live_")) else "test" if key.startswith(("sk_test_", "rk_test_")) else "missing"
    print(f"Stripe key                  {kind}")
    print(f"Mux configured              {'yes' if s.mux_token_id and s.mux_token_secret else 'no'}"
          f" (signing key {'yes' if s.mux_signing_key_id else 'no'}, webhook secret {'yes' if s.mux_webhook_secret else 'no'})")
    print(f"PRESENTATION_VIDEO_ENABLED  {on(s.presentation_video_enabled)}")
    print(f"MUX_FAKE                    {on(s.mux_fake)}")
    print(f"MUX_PLAYBACK_MAX_RESOLUTION {s.mux_playback_max_resolution}")
    print(f"LLM_PROVIDER                {s.llm_provider} (OpenAI key {'set' if s.openai_api_key else 'empty'})")
    print(f"Sentry                      {'on' if s.sentry_dsn else 'off'}")
    print(f"TRUST_CLOUDFLARE            {on(s.trust_cloudflare)}; TRUSTED_PROXY_IPS {s.trusted_proxy_ips or '-'}")
    print("\n== feature flags when no row exists (the defaults for this APP_ENV)")
    for flag in sorted(DEFAULT_FLAG_KEYS):
        print(f"{flag:<44} {on(default_flag_state(flag))}")


def _database_part() -> None:
    from sqlalchemy import select, text

    import app.db.base  # noqa: F401
    from app.db.session import SessionLocal
    from app.models.ops import FeatureFlag
    from app.services import fx
    from app.services.shelf_settings import shelf_settings

    db = SessionLocal()
    try:
        print("\n== database")
        version = db.execute(text("SELECT version_num FROM alembic_version")).scalar_one_or_none()
        print(f"migration                   {version}")
        rows = db.execute(select(FeatureFlag).order_by(FeatureFlag.key)).scalars().all()
        print(f"flag rows                   {len(rows)}" + ("" if rows else " (the defaults above apply)"))
        for row in rows:
            print(f"  {row.key:<42} {'on' if row.is_enabled else 'off'} ({row.scope.value})")
        try:
            shelf = shelf_settings(db)  # read; a row it creates is rolled back below
            print(f"The Shelf                   {'on' if shelf.shelf_enabled else 'off'}")
        except Exception as exc:  # noqa: BLE001
            print(f"The Shelf                   ? ({type(exc).__name__})")
        view = fx.rates_view(db)
        print(f"exchange rates              {view['rates'] or 'none fresh'} as of {view['as_of'] or '-'}")
        db.rollback()
    finally:
        db.close()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--no-db", action="store_true", help="only the settings, no database")
    args = parser.parse_args()
    _settings_part()
    if not args.no_db:
        _database_part()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
