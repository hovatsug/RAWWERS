"""The reference-data bootstrap (scripts/bootstrap_reference_data.py): it
adds what an empty database lacks, a second run changes nothing, and a row an
admin edited is left alone."""
from __future__ import annotations

import sys
from decimal import Decimal
from pathlib import Path

from sqlalchemy import func, select

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))

import bootstrap_reference_data as boot  # noqa: E402

from app.models.gear_verification import CameraModelReference  # noqa: E402
from app.models.package_pricing import NichePackagePriceCap  # noqa: E402


def _caps(db) -> int:
    return db.execute(select(func.count()).select_from(NichePackagePriceCap)).scalar_one()


def test_a_second_run_adds_nothing_and_changes_nothing(db_session, capsys):
    boot.bootstrap(db_session)
    db_session.commit()
    cameras = db_session.execute(select(func.count()).select_from(CameraModelReference)).scalar_one()
    caps = _caps(db_session)
    assert cameras > 50 and caps > 0

    # An admin edits one cap; the bootstrap must not put it back.
    row = db_session.execute(select(NichePackagePriceCap).limit(1)).scalar_one()
    row.entry_price_max = Decimal("1.23")
    db_session.commit()

    capsys.readouterr()
    second = boot.bootstrap(db_session)
    db_session.commit()
    assert sum(second.values()) == 0, second
    assert db_session.execute(select(func.count()).select_from(CameraModelReference)).scalar_one() == cameras
    assert _caps(db_session) == caps
    db_session.refresh(row)
    assert row.entry_price_max == Decimal("1.23")
    out = capsys.readouterr().out
    assert "created    0" in out and "1 differ from the file, left as they are" in out


def test_without_price_caps_none_are_written(db_session):
    before = _caps(db_session)
    created = boot.bootstrap(db_session, with_price_caps=False)
    assert not any(k.startswith("price_caps") for k in created)
    assert _caps(db_session) == before
