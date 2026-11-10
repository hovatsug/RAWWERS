"""The bi_* views: created with the tables, readable, and the same SQL as
the migration's frozen copy (a change to the views needs a migration)."""
import importlib.util
import pathlib

from sqlalchemy import text

from app.models import bi_views


def _migration():
    path = pathlib.Path(__file__).resolve().parents[1] / "alembic" / "versions" / "20261110_0093_bi_stamps.py"
    spec = importlib.util.spec_from_file_location("bi_migration", path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def test_the_views_match_the_migration():
    migration = _migration()
    assert migration.VIEWS_SQL == bi_views.create_sql()
    assert migration.VIEW_NAMES == [name for name, _ in bi_views.VIEWS]


def test_every_view_exists_and_reads(db_session):
    for name, _ in bi_views.VIEWS:
        assert name.startswith("bi_")
        db_session.execute(text(f"SELECT * FROM {name} LIMIT 1")).all()
