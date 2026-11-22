"""Health check for a Celery worker: does it answer a ping?

Used by the worker containers' healthcheck (deploy/compose.prod.yml). It
imports Celery only, not the app, so it costs little memory every minute.

    python scripts/celery_ping.py media     # pings media@<this container>
    python scripts/celery_ping.py photos

Exit 0: the worker answered. Exit 1: it did not answer within 10 seconds.
"""
from __future__ import annotations

import os
import socket
import sys

from celery import Celery


def main() -> int:
    if len(sys.argv) != 2 or sys.argv[1] in {"-h", "--help"}:
        print(__doc__)
        return 0 if len(sys.argv) == 2 else 2
    name = f"{sys.argv[1]}@{socket.gethostname()}"
    app = Celery(broker=os.environ["REDIS_URL"])
    replies = app.control.ping(destination=[name], timeout=10) or []
    ok = any(name in reply for reply in replies)
    print(("ok " if ok else "no answer from ") + name)
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
