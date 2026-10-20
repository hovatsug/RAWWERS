#!/usr/bin/env python3
"""Register (or check) RAWWERS's Stripe webhook endpoints, pinned to our API version.

Two endpoints, as Stripe delivers Connect events separately:
  platform  every event the webhook handles, from our own account
  connect   account.updated, from photographers' connected accounts

Each is pinned to STRIPE_API_VERSION, so the events match what our calls
ask for, and subscribed to exactly app.api.v1.webhooks.HANDLED_STRIPE_EVENTS
(split between the two). Stripe sets an endpoint's API version only when it
is created: an endpoint with the wrong version is reported, never "updated"
- delete it in the dashboard and run this again.

    docker compose run --rm api python scripts/register_stripe_webhook.py \\
        --url https://api.rawwers.com/v1/webhooks/stripe --mode live [--apply]

Without --apply it only prints what it would do. A new endpoint's signing
secret is printed once: put it in STRIPE_WEBHOOK_SECRET (the Connect endpoint has
its own secret - see DEPLOY_CHECKLIST.md).
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))


def endpoint_params(url: str, *, connect: bool) -> dict:
    from app.api.v1.webhooks import CONNECT_STRIPE_EVENTS, HANDLED_STRIPE_EVENTS
    from app.core.config import get_settings

    events = CONNECT_STRIPE_EVENTS if connect else HANDLED_STRIPE_EVENTS - CONNECT_STRIPE_EVENTS
    return {
        "url": url,
        "api_version": get_settings().stripe_api_version,
        "enabled_events": sorted(events),
        "connect": connect,
        "description": f"RAWWERS {'connect' if connect else 'platform'} webhook (pinned)",
    }


def main() -> int:
    import stripe

    from app.services import stripe_service  # noqa: F401 - sets the key

    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("--url", required=True)
    parser.add_argument("--mode", choices=["test", "live"], required=True)
    parser.add_argument("--apply", action="store_true")
    args = parser.parse_args()
    if not stripe.api_key.startswith(f"sk_{args.mode}_"):
        print(f"STRIPE_SECRET_KEY is not a {args.mode}-mode key; refusing.")
        return 2

    existing = [e for e in stripe.WebhookEndpoint.list(limit=100).auto_paging_iter() if e.url == args.url]
    status = 0
    for connect in (False, True):
        wanted = endpoint_params(args.url, connect=connect)
        label = "connect" if connect else "platform"
        # Told apart by the description this script writes: Stripe does not
        # return whether an endpoint listens to connected accounts.
        match = next((e for e in existing if f"RAWWERS {label} webhook" in (e.get("description") or "")), None)
        if match is None:
            print(f"{label}: missing - would create {wanted['enabled_events']} at {wanted['api_version']}")
            if args.apply:
                created = stripe.WebhookEndpoint.create(**wanted)
                print(f"{label}: created {created.id}; signing secret (shown once): {created.secret}")
            continue
        if match.api_version != wanted["api_version"]:
            print(f"{label}: {match.id} is pinned to {match.api_version}, not {wanted['api_version']} - delete it and run again")
            status = 1
            continue
        if sorted(match.enabled_events) != wanted["enabled_events"]:
            print(f"{label}: {match.id} events differ: {sorted(match.enabled_events)} -> {wanted['enabled_events']}")
            if args.apply:
                stripe.WebhookEndpoint.modify(match.id, enabled_events=wanted["enabled_events"])
                print(f"{label}: events updated")
        else:
            print(f"{label}: {match.id} is as it should be")
    return status


if __name__ == "__main__":
    raise SystemExit(main())
