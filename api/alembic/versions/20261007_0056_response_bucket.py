"""Replace the average response time with an honest bucket.

`avg_response_minutes` was the mean time to accept or decline, and it left
out requests that expired unanswered: ignoring most requests and answering a
few quickly read as fast. It is replaced by the median over the last 10
resolved requests, with an expired request counted as the standard day and
a minute whatever its own window, and an even sample taking the higher middle
value, and the bucket clients are shown (see app/services/response_time.py).

Existing rows are backfilled here with the same rule, in SQL, so a label is
right from the first request after deploy rather than after each
photographer's next recompute.

Revision ID: 20261007_0056
Revises: 20261002_0055
"""
from alembic import op
import sqlalchemy as sa

revision = "20261007_0056"
down_revision = "20261002_0055"
branch_labels = None
depends_on = None

# The same rule as app/services/response_time.py, in SQL. A module constant so
# tests/test_response_time.py can run this exact text against edge cases and
# compare it with the Python function.
BACKFILL_SQL = """
WITH resolved AS (
    SELECT r.pro_user_id,
           CASE WHEN t.to_status = 'expired'
                -- Never answered: the standard day and a minute, whatever
                -- window the request had (response_time.EXPIRED_COUNTS_AS_MINUTES).
                THEN 1441
                ELSE GREATEST(0, EXTRACT(EPOCH FROM (t.created_at - r.created_at)) / 60)
           END AS minutes,
           ROW_NUMBER() OVER (PARTITION BY r.pro_user_id ORDER BY t.created_at DESC) AS recency
    FROM booking_request_transition t
    JOIN booking_request r ON r.id = t.booking_request_id
    WHERE t.from_status = 'pending' AND t.to_status IN ('accepted', 'declined', 'expired')
),
ranked AS (
    SELECT pro_user_id, minutes,
           ROW_NUMBER() OVER (PARTITION BY pro_user_id ORDER BY minutes) AS position,
           COUNT(*) OVER (PARTITION BY pro_user_id) AS sample
    FROM resolved
    WHERE recency <= 10
),
medians AS (
    -- The middle value; of an even sample, the higher of the two middle ones.
    SELECT pro_user_id, FLOOR(minutes)::int AS median
    FROM ranked
    WHERE sample >= 3 AND position = sample / 2 + 1
)
UPDATE pro_public_index i
SET response_median_minutes = m.median,
    response_bucket = CASE
        WHEN m.median <= 60 THEN 'within_hour'
        WHEN m.median <= 360 THEN 'few_hours'
        WHEN m.median <= 1440 THEN 'within_day'
        ELSE 'over_day'
    END
FROM medians m
WHERE m.pro_user_id = i.pro_user_id
"""


def upgrade() -> None:
    op.add_column("pro_public_index", sa.Column("response_median_minutes", sa.Integer(), nullable=True))
    op.add_column(
        "pro_public_index",
        sa.Column("response_bucket", sa.String(length=16), nullable=False, server_default="no_history"),
    )
    op.execute(BACKFILL_SQL)
    op.drop_column("pro_public_index", "avg_response_minutes")


def downgrade() -> None:
    op.add_column("pro_public_index", sa.Column("avg_response_minutes", sa.Integer(), nullable=True))
    op.drop_column("pro_public_index", "response_bucket")
    op.drop_column("pro_public_index", "response_median_minutes")
