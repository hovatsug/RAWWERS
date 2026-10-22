"""The client's raw IP on their own download log, for chargeback evidence.

media_access_log gains ip_address next to ip_hash. Written only for the
gig's own client, and cleared after MEDIA_ACCESS_RAW_IP_RETENTION_DAYS by the
daily purge_raw_access_ips job. Existing rows stay without one: their raw IP
was never kept.

Revision ID: 20261022_0068
Revises: 20261021_0067
"""
import sqlalchemy as sa
from alembic import op

revision = "20261022_0068"
down_revision = "20261021_0067"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("media_access_log", sa.Column("ip_address", sa.Text(), nullable=True))


def downgrade() -> None:
    op.drop_column("media_access_log", "ip_address")
