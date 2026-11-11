"""The client's IP address, the one way the API reads it.

`X-Forwarded-For` is whatever the caller says. It is read only when the
connection itself comes from a trusted proxy (`TRUSTED_PROXY_IPS`), and then
from the right: each trusted proxy appends the address it saw, so the entries
on the left are the caller's own and are never believed. Stepping back stops
at the first address that is not a trusted proxy, or after
`TRUSTED_PROXY_HOPS` proxies.

With no trusted proxies configured (dev, tests) the header is ignored and the
connection address is the answer. Uvicorn runs with --no-proxy-headers, so
that address is the socket's, not something Uvicorn rewrote.

Everything that keys on an address goes through `client_ip`: the admin IP
allowlist, rate limits, download evidence, risk and abuse signals.
"""
from __future__ import annotations

import ipaddress
from functools import lru_cache

from starlette.requests import Request

from app.core.config import get_settings

Network = ipaddress.IPv4Network | ipaddress.IPv6Network


@lru_cache(maxsize=8)
def _networks(raw: str) -> tuple[Network, ...]:
    out: list[Network] = []
    for item in raw.split(","):
        item = item.strip()
        if item:
            out.append(ipaddress.ip_network(item, strict=False))
    return tuple(out)


def parse_ip(value: str | None) -> str | None:
    """A bare address from a header entry or socket value, or None.

    Accepts "1.2.3.4", "1.2.3.4:5678", "2001:db8::1" and "[2001:db8::1]:443".
    """
    if not value:
        return None
    value = value.strip().strip('"')
    if value.startswith("["):
        value = value[1:].split("]", 1)[0]
    elif value.count(":") == 1:
        value = value.split(":", 1)[0]
    try:
        return str(ipaddress.ip_address(value))
    except ValueError:
        return None


def is_trusted_proxy(address: str | None) -> bool:
    ip = parse_ip(address)
    if ip is None:
        return False
    nets = _networks(get_settings().trusted_proxy_ips)
    addr = ipaddress.ip_address(ip)
    return any(addr in net for net in nets)


def client_ip(request: Request | None) -> str | None:
    """The address the request came from, believing only trusted proxies."""
    if request is None:
        return None
    peer_raw = request.client.host if request.client else None
    peer = parse_ip(peer_raw) or peer_raw
    if not is_trusted_proxy(peer):
        return peer
    header = request.headers.get("x-forwarded-for") or ""
    chain = [entry for entry in (e.strip() for e in header.split(",")) if entry]
    candidate = peer
    hops = get_settings().trusted_proxy_hops
    while hops > 0 and chain and is_trusted_proxy(candidate):
        stepped = parse_ip(chain.pop())
        if stepped is None:
            # A malformed entry: nothing to its left can be trusted either.
            break
        candidate = stepped
        hops -= 1
    return candidate
