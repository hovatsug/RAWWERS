"""Runtime deprecation signalling for routes that still work but should
not gain new callers.

A route marked deprecated only in the docs and the OpenAPI schema is
still a route somebody calls, and the caller finds out by reading
documentation they have no reason to re-read. These headers put the
notice in the response itself, where a client that never opens the docs
still receives it.

Deprecation and Link follow RFC 9745 / RFC 8288. Sunset (RFC 8594) is
deliberately not sent: it is a promise about a removal date, and
inventing one we have not committed to is its own kind of misinformation.
When a removal date is decided, add it here.
"""
from __future__ import annotations

from fastapi import Response


def mark_deprecated(response: Response, *, successor: str, reason: str) -> str:
    """Attach deprecation headers and return the human-readable notice, so
    the same sentence can go in the response body for clients that only
    ever look there."""
    notice = f"Deprecated: {reason} Use {successor} instead."
    response.headers["Deprecation"] = "true"
    response.headers["Link"] = f'<{successor}>; rel="successor-version"'
    # Warning is obsolete in HTTP terms but is still the field most client
    # libraries surface to a developer without extra configuration.
    response.headers["Warning"] = f'299 - "{notice}"'
    return notice
