#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
import sys
import time
from dataclasses import dataclass
from typing import Any
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import Request, urlopen


@dataclass
class GateThresholds:
    error_rate_max: float
    latency_p95_ms_max: float
    queue_backlog_max: float


def _http_get_json(url: str, headers: dict[str, str] | None = None, timeout: int = 10) -> Any:
    req = Request(url, headers=headers or {})
    with urlopen(req, timeout=timeout) as resp:
        body = resp.read().decode("utf-8")
        return json.loads(body)


def _check_health(health_url: str, ready_url: str | None) -> tuple[bool, str]:
    try:
        payload = _http_get_json(health_url)
        if payload.get("status") != "ok":
            return False, f"health check failed: {payload}"
    except Exception as exc:
        return False, f"health check error: {exc}"

    if ready_url:
        try:
            payload = _http_get_json(ready_url)
            if not payload.get("ready", False):
                return False, f"readiness failed: {payload}"
        except Exception as exc:
            return False, f"readiness check error: {exc}"

    return True, "health checks passed"


def _prom_query(prom_url: str, query: str, token: str | None = None) -> float:
    params = urlencode({"query": query})
    url = f"{prom_url.rstrip('/')}/api/v1/query?{params}"
    headers = {"Authorization": f"Bearer {token}"} if token else {}
    payload = _http_get_json(url, headers=headers)
    if payload.get("status") != "success":
        raise RuntimeError(f"prom query failed: {payload}")
    result = payload.get("data", {}).get("result", [])
    if not result:
        raise RuntimeError(f"prom query returned no data for: {query}")
    value = result[0]["value"][1]
    return float(value)


def _evaluate_metrics(prom_url: str, token: str | None, thresholds: GateThresholds) -> tuple[bool, list[str]]:
    checks: list[str] = []

    error_rate_query = "sum(rate(http_requests_total{status=~\"5..\"}[10m])) / clamp_min(sum(rate(http_requests_total[10m])), 1)"
    latency_query = "histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[10m])) by (le)) * 1000"
    queue_query = "sum(celery_queue_depth)"

    error_rate = _prom_query(prom_url, error_rate_query, token=token)
    latency_p95_ms = _prom_query(prom_url, latency_query, token=token)
    queue_backlog = _prom_query(prom_url, queue_query, token=token)

    checks.append(f"error_rate_10m={error_rate:.4f} threshold<{thresholds.error_rate_max:.4f}")
    checks.append(f"latency_p95_ms_10m={latency_p95_ms:.2f} threshold<{thresholds.latency_p95_ms_max:.2f}")
    checks.append(f"queue_backlog={queue_backlog:.2f} threshold<{thresholds.queue_backlog_max:.2f}")

    healthy = (
        error_rate < thresholds.error_rate_max
        and latency_p95_ms < thresholds.latency_p95_ms_max
        and queue_backlog < thresholds.queue_backlog_max
    )
    return healthy, checks


def _thresholds_for_env(env: str) -> GateThresholds:
    if env == "production":
        return GateThresholds(error_rate_max=0.01, latency_p95_ms_max=600.0, queue_backlog_max=500.0)
    if env == "staging":
        return GateThresholds(error_rate_max=0.03, latency_p95_ms_max=900.0, queue_backlog_max=1000.0)
    return GateThresholds(error_rate_max=0.05, latency_p95_ms_max=1200.0, queue_backlog_max=2000.0)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="RAWWERS release gate: health + observability checks")
    parser.add_argument("--env", default=os.getenv("GATE_ENV", "staging"), choices=["dev", "staging", "production"])
    parser.add_argument("--health-url", default=os.getenv("GATE_HEALTH_URL", "http://localhost:8000/healthz"))
    parser.add_argument("--ready-url", default=os.getenv("GATE_READY_URL", "http://localhost:8000/health/ready"))
    parser.add_argument("--prometheus-url", default=os.getenv("GATE_PROMETHEUS_URL"))
    parser.add_argument("--prometheus-token", default=os.getenv("GATE_PROMETHEUS_TOKEN"))
    parser.add_argument("--fail-open-if-no-metrics", action="store_true")
    parser.add_argument("--sleep-seconds", type=int, default=0)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    if args.sleep_seconds > 0:
        time.sleep(args.sleep_seconds)

    ok, reason = _check_health(args.health_url, args.ready_url)
    print(f"[release-gate] health: {reason}")
    if not ok:
        return 1

    thresholds = _thresholds_for_env(args.env)
    if not args.prometheus_url:
        if args.fail_open_if_no_metrics:
            print("[release-gate] no metrics backend configured; fail-open enabled")
            return 0
        print("[release-gate] no metrics backend configured; blocking release")
        return 1

    try:
        metrics_ok, checks = _evaluate_metrics(args.prometheus_url, args.prometheus_token, thresholds)
        for line in checks:
            print(f"[release-gate] {line}")
        if not metrics_ok:
            print("[release-gate] metrics check failed")
            return 1
    except (RuntimeError, HTTPError, URLError, ValueError) as exc:
        if args.fail_open_if_no_metrics:
            print(f"[release-gate] metrics unavailable ({exc}); fail-open enabled")
            return 0
        print(f"[release-gate] metrics check error: {exc}")
        return 1

    print("[release-gate] all checks passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
