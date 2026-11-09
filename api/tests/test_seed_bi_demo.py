"""scripts/seed_bi_demo.py: dev only, its numbers hold together, and
--remove leaves nothing behind."""
import importlib.util
import pathlib

import pytest
from sqlalchemy import text

from app.core.config import get_settings
from app.services import bi


def _script():
    path = pathlib.Path(__file__).resolve().parents[1] / "scripts" / "seed_bi_demo.py"
    spec = importlib.util.spec_from_file_location("seed_bi_demo", path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def test_it_refuses_production(monkeypatch):
    seed = _script()
    monkeypatch.setattr(get_settings(), "app_env", "production")
    with pytest.raises(SystemExit, match="refuses"):
        seed.main([])


def test_seeded_numbers_hold_together_and_remove_leaves_nothing(db_session):
    seed = _script()
    today = bi.london_today()
    result = seed.Seeder(db_session, today).run()
    db_session.commit()
    assert result["bookings"] > 150 and result["shelf_orders"] > 0
    start = today - bi.timedelta(days=seed.DAYS - 1)
    summary = bi.summarize(db_session, start, today)
    assert bi.waterfall(summary)["adds_up"]
    assert summary.values["gmv"] > 0 and summary.values["stripe_fees"] > 0
    lines = {x["key"]: x for x in bi.reconciliation(summary)["lines"]}
    assert lines["charge"]["matches"] and lines["refund"]["matches"] and lines["transfer"]["matches"]
    assert {r["key"] for r in bi.breakdown(db_session, start, today, "country")} == {"GB", "PT", "ES"}

    seed.remove(db_session)
    db_session.commit()
    for table, where in (("gig", "metadata ->> 'bi_demo' = 'true'"), ("user_account", "email LIKE '%@bi-demo.rawwers.dev'"),
                         ("bi_stripe_txn", "demo"), ("bi_cost", "metadata ->> 'bi_demo' = 'true'"),
                         ("shelf_item", "title LIKE '[demo] %'"), ("pro_raww_ledger_entry", "true"), ("stripe_payment", "true")):
        assert db_session.execute(text(f"SELECT count(*) FROM {table} WHERE {where}")).scalar_one() == 0, table
