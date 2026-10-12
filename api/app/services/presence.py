"""Whether a photographer is online - the one place anything asks.

Presence does not exist yet: nothing records that a photographer's app is
open. Until it does, this says no for everyone. That is the honest answer -
the platform cannot tell, and pretending otherwise would make the assistant
wait for a person who is not there - and every caller already behaves
correctly on it: the assistant answers at once, as it did before.

The presence step replaces the body with the real check (a Redis key with a
short TTL, refreshed by the app's heartbeat), and nothing else changes.
"""
from __future__ import annotations

import uuid

from sqlalchemy.orm import Session


def photographer_is_online(db: Session, pro_user_id: uuid.UUID) -> bool:
    return False
